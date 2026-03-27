
resource "helm_release" "crossplane" {
  name             = "crossplane"
  repository       = "https://charts.crossplane.io/stable"
  chart            = "crossplane"
  namespace        = "crossplane-system"
  create_namespace = true
  timeout          = 300

  set {
    name  = "replicas"
    value = "2"
  }
  set {
    name  = "deploymentStrategy"
    value = "RollingUpdate"
  }

  set {
    name  = "image.pullPolicy"
    value = "Always"
  }
}

resource "null_resource" "wait_for_crossplane" {
  triggers = {
    key = uuid()
  }

  provisioner "local-exec" {

    command = <<EOF
      printf "\nWaiting for the crossplane pods to start...\n"
      sleep 5
      until kubectl wait -n ${helm_release.crossplane.namespace} --for=condition=Ready pods --all; do
        sleep 2
      done  2>/dev/null
    EOF
  }

  depends_on = [helm_release.crossplane]
}
