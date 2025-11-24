provider "kubernetes" {
  config_path = var.kubeconfig_path
}

resource "kubernetes_namespace" "demo" {
  metadata {
    name = var.namespace
  }
}

