
resource "null_resource" "weaviate_ready" {
  #depends_on = [helm_release.weaviate]

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for Weaviate to be ready..."

      for i in $(seq 1 30); do
        # Use the correct in-cluster service DNS
        if kubectl run curl-test --rm -i --restart=Never \
          --image=yauritux/busybox-curl:latest \
          -- sh -c "curl -s http://weaviate.weaviate.svc.cluster.local:80/v1/meta"; then
          echo "✅ Weaviate is ready!"
          exit 0
        fi
        echo "⏳ Still waiting..."
        sleep 5
      done

      echo "❌ Timeout waiting for Weaviate"
      exit 1
    EOT
  }
}

resource "null_resource" "weaviate_schema_data" {
  depends_on = [null_resource.weaviate_ready]

  provisioner "local-exec" {
    command = <<EOT
      echo "📄 Creating schema and inserting data inside Kubernetes..."

      kubectl run schema-setup --rm -i --restart=Never \
        --image=yauritux/busybox-curl:latest \
        -- sh -c '
          set -e

          # Create schema
          curl -s -X POST http://weaviate.weaviate.svc.cluster.local:80/v1/schema \
            -H "Content-Type: application/json" \
            -d '\''{
              "classes": [
                {
                  "class": "Book",
                  "description": "A class representing books",
                  "vectorizer": "none",
                  "properties": [
                    {"name": "title", "dataType": ["string"]},
                    {"name": "author", "dataType": ["string"]},
                    {"name": "year", "dataType": ["int"]}
                  ]
                }
              ]
            }'\''

          # Insert data
          for book in \
            '\''{"title":"The Hobbit","author":"J.R.R. Tolkien","year":1937}'\'' \
            '\''{"title":"1984","author":"George Orwell","year":1949}'\'' \
            '\''{"title":"Dune","author":"Frank Herbert","year":1965}'\''; do
              curl -s -X POST http://weaviate.weaviate.svc.cluster.local:80/v1/objects \
                   -H "Content-Type: application/json" \
                   -d "{\"class\": \"Book\", \"properties\": $book}"
          done

          echo "✅ Schema and data setup complete!"
        '
    EOT
  }
}
