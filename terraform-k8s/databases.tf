# ----------------- POSTGRES (secret + pvc + deployment + svc) -----------------
resource "kubernetes_secret" "pg" {
  metadata {
    name      = "pg-secret"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }
  data = {
    password = base64encode(var.postgres_password)
  }
  type = "Opaque"
}

resource "kubernetes_persistent_volume_claim" "pgdata" {
  metadata {
    name      = "pgdata"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = { storage = var.postgres.storage }
    }
  }
}

resource "kubernetes_deployment" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.demo.metadata[0].name
    labels    = { app = "postgres" }
  }

  spec {
    replicas = var.postgres.replicas

    selector { match_labels = { app = "postgres" } }

    template {
      metadata { labels = { app = "postgres" } }

      spec {
        container {
          name  = "postgres"
          image = "${var.postgres.image}:${var.postgres.tag}"
          port { container_port = 5432 }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.pg.metadata[0].name
                key  = "password"
              }
            }
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/postgresql/data"
          }

          resources {
            limits   = var.postgres.resources.limits
            requests = var.postgres.resources.requests
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.pgdata.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }
  spec {
    selector = { app = "postgres" }
    port {
      port        = 5432
      target_port = 5432
      protocol    = "TCP"
    }
    type = "ClusterIP"
  }
}
