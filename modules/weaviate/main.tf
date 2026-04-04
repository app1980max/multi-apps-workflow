
###########################################################
# 1️⃣ Namespace
###########################################################
resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

###########################################################
# 2️⃣ API Key Secret
###########################################################
resource "kubernetes_secret" "weaviate_apikey" {
  metadata {
    name      = "weaviate-apikey"
    namespace = var.namespace
  }

  data = {
    allowed_keys = base64encode(join(",", var.api_keys))
    users        = base64encode(join(",", var.api_users))
  }
}

###########################################################
# 3️⃣ Helm Release
###########################################################
resource "helm_release" "weaviate" {
  name       = var.release_name
  repository = "https://weaviate.github.io/weaviate-helm"
  chart      = "weaviate"
  version    = var.chart_version
  namespace  = var.namespace
  create_namespace = true

  values = [templatefile("${path.module}/values.yaml.tpl", {
    vectorizer_module = var.vectorizer_module
    enable_modules    = join(",", distinct([for c in var.classes : c.vectorizer if c.vectorizer != "none"]))
    storage_size      = var.storage_size
  })]

  depends_on = [kubernetes_secret.weaviate_apikey]
}

###########################################################
# 4️⃣ Create Classes + Properties
###########################################################
resource "null_resource" "weaviate_classes" {
  for_each = { for cls in var.classes : cls.name => cls }
  depends_on = [helm_release.weaviate]

  provisioner "local-exec" {
    command = <<EOT
class='${jsonencode(each.value)}'
class_name=$(echo "$class" | jq -r '.name')
api_key='${var.api_keys[0]}'
namespace='${var.namespace}'

# Create class if missing
if ! curl -s -H "X-API-KEY: $api_key" http://weaviate.$namespace.svc.cluster.local:8080/v1/schema | jq -e ".classes[] | select(.class==\"$class_name\")" > /dev/null; then
  echo "Creating class $class_name..."
  curl -s -X POST http://weaviate.$namespace.svc.cluster.local:8080/v1/schema \
    -H "Content-Type: application/json" \
    -H "X-API-KEY: $api_key" \
    -d "$class"
fi

# Ensure properties exist
for prop in $(echo "$class" | jq -c '.properties[]'); do
  prop_name=$(echo "$prop" | jq -r '.name')
  if ! curl -s -H "X-API-KEY: $api_key" http://weaviate.$namespace.svc.cluster.local:8080/v1/schema | jq -e ".classes[] | select(.class==\"$class_name\") | .properties[] | select(.name==\"$prop_name\")" > /dev/null; then
    echo "Adding missing property $prop_name to $class_name..."
    curl -s -X POST http://weaviate.$namespace.svc.cluster.local:8080/v1/schema/properties \
      -H "Content-Type: application/json" \
      -H "X-API-KEY: $api_key" \
      -d "$(echo "$prop" | jq -c '{class: "'"$class_name"'", name: .name, dataType: .dataType, description: .description}')"
  fi
done
EOT
  }
}

###########################################################
# 5️⃣ Insert Initial Sample Data
###########################################################
resource "null_resource" "weaviate_initial_data" {
  for_each = var.initial_data
  depends_on = [null_resource.weaviate_classes]

  provisioner "local-exec" {
    command = <<EOT
api_key='${var.api_keys[0]}'
namespace='${var.namespace}'
class_name='${each.key}'

for obj in $(echo '${jsonencode(each.value)}' | jq -c '.[]'); do
  curl -s -X POST http://weaviate.$namespace.svc.cluster.local:8080/v1/objects \
    -H "Content-Type: application/json" \
    -H "X-API-KEY: $api_key" \
    -d "$(echo "$obj" | jq -c '{class: "'"$class_name"'", properties: .properties}')"
done
EOT
  }
}
