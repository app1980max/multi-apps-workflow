
resource "null_resource" "weaviate_products_schema" {
  depends_on = [] # ensure module runs after helm in root

  provisioner "local-exec" {
    command = <<EOT
      echo "📄 Creating Products schema and inserting sample data..."

      kubectl run schema-products \
        --rm -i \
        --restart=Never \
        --image=yauritux/busybox-curl:latest \
        --env="WEAVIATE_API_KEY=${var.api_keys[0]}" \
        --env="WEAVIATE_NAMESPACE=${var.namespace}" \
        --command -- sh -c '
          set -e

          echo "🔍 Using namespace: $WEAVIATE_NAMESPACE"

          WEAVIATE_URL="http://weaviate.$WEAVIATE_NAMESPACE.svc.cluster.local:80"

          echo "🌐 Weaviate URL: $WEAVIATE_URL"

          # Wait for Weaviate readiness
          echo "⏳ Waiting for Weaviate..."
          for i in $(seq 1 30); do
            if curl -s $WEAVIATE_URL/v1/.well-known/ready > /dev/null; then
              echo "✅ Weaviate is ready!"
              break
            fi
            sleep 5
          done

          # Create schema (ignore if exists)
          echo "📦 Creating Products schema..."
          curl -s -o /dev/null -w "%%%{http_code}" -X POST $WEAVIATE_URL/v1/schema \
            -H "Content-Type: application/json" \
            -H "X-API-KEY: $WEAVIATE_API_KEY" \
            -d '\''{
              "class": "Products",
              "description": "Stores product information",
              "vectorizer": "none",
              "properties": [
                {"name": "name", "dataType": ["string"]},
                {"name": "price", "dataType": ["number"]}
              ]
            }'\'' || true

          echo "📥 Inserting sample data..."

          for product in \
            '\''{"name":"Laptop","price":1200.50}'\'' \
            '\''{"name":"Smartphone","price":799.99}'\'' \
            '\''{"name":"Headphones","price":199.99}'\''; do

              curl -s -X POST $WEAVIATE_URL/v1/objects \
                -H "Content-Type: application/json" \
                -H "X-API-KEY: $WEAVIATE_API_KEY" \
                -d "{\"class\": \"Products\", \"properties\": $product}"
          done

          echo "✅ Done!"
        '
    EOT
  }
}
