
# ----------------- INGRESS -----------------
resource "kubernetes_ingress_v1" "main" {
  metadata {
    name      = "microservices-ingress"
    namespace = kubernetes_namespace.demo.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
    }
  }

  spec {
    ingress_class_name = var.global.className

    rule {
      host = var.global.ingressHost

      http {
        path {
          path      = "/api(/|$)(.*)"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = kubernetes_service.api.metadata[0].name
              port {
                number = kubernetes_service.api.spec[0].port[0].port
              }
            }
          }
        }

      }
    }
  }
}

