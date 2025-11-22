terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

# create namespace
resource "kubernetes_namespace" "demo" {
  metadata {
    name = var.namespace
  }
}

# ----------------- USERS -----------------
resource "kubernetes_deployment" "users" {
  metadata {
    name      = "users"
    namespace = kubernetes_namespace.demo.metadata[0].name
    labels    = { app = "users" }
  }

  spec {
    replicas = var.users.replicas

    selector {
      match_labels = { app = "users" }
    }

    template {
      metadata {
        labels = { app = "users" }
      }

      spec {
        container {
          name  = "users"
          image = "${var.users.image}:${var.users.tag}"
          port {
            container_port = 3001
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 3001
            }
            initial_delay_seconds = var.users.readiness.initialDelaySeconds
            period_seconds        = var.users.readiness.periodSeconds
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 3001
            }
            initial_delay_seconds = var.users.liveness.initialDelaySeconds
            period_seconds        = var.users.liveness.periodSeconds
          }

          resources {
            limits   = var.users.resources.limits
            requests = var.users.resources.requests
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "users" {
  metadata {
    name      = "users"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }
  spec {
    selector = { app = "users" }
    port {
      port        = 80
      target_port = 3001
      protocol    = "TCP"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "users_hpa" {
  metadata {
    name      = "users-hpa"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.users.metadata[0].name
    }
    min_replicas = var.users.hpa.minReplicas
    max_replicas = var.users.hpa.maxReplicas

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = var.users.hpa.targetCPUUtilization
        }
      }
    }
  }
}

# ----------------- ORDERS -----------------
resource "kubernetes_deployment" "orders" {
  metadata {
    name      = "orders"
    namespace = kubernetes_namespace.demo.metadata[0].name
    labels    = { app = "orders" }
  }

  spec {
    replicas = var.orders.replicas

    selector {
      match_labels = { app = "orders" }
    }

    template {
      metadata {
        labels = { app = "orders" }
      }

      spec {
        container {
          name  = "orders"
          image = "${var.orders.image}:${var.orders.tag}"
          port {
            container_port = 3002
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 3002
            }
            initial_delay_seconds = var.orders.readiness.initialDelaySeconds
            period_seconds        = var.orders.readiness.periodSeconds
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 3002
            }
            initial_delay_seconds = var.orders.liveness.initialDelaySeconds
            period_seconds        = var.orders.liveness.periodSeconds
          }

          resources {
            limits   = var.orders.resources.limits
            requests = var.orders.resources.requests
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "orders" {
  metadata {
    name      = "orders"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }
  spec {
    selector = { app = "orders" }
    port {
      port        = 80
      target_port = 3002
      protocol    = "TCP"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "orders_hpa" {
  metadata {
    name      = "orders-hpa"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.orders.metadata[0].name
    }
    min_replicas = var.orders.hpa.minReplicas
    max_replicas = var.orders.hpa.maxReplicas

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = var.orders.hpa.targetCPUUtilization
        }
      }
    }
  }
}

# ----------------- API GATEWAY -----------------
resource "kubernetes_deployment" "api" {
  metadata {
    name      = "api-gateway"
    namespace = kubernetes_namespace.demo.metadata[0].name
    labels    = { app = "api-gateway" }
  }

  spec {
    replicas = var.apiGateway.replicas

    selector {
      match_labels = { app = "api-gateway" }
    }

    template {
      metadata {
        labels = { app = "api-gateway" }
      }

      spec {
        container {
          name  = "api-gateway"
          image = "${var.apiGateway.image}:${var.apiGateway.tag}"
          port {
            container_port = 3000
          }

          env {
            name  = "USERS_URL"
            value = var.apiGateway.env.usersUrl
          }
          env {
            name  = "ORDERS_URL"
            value = var.apiGateway.env.ordersUrl
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 3000
            }
            initial_delay_seconds = var.apiGateway.readiness.initialDelaySeconds
            period_seconds        = var.apiGateway.readiness.periodSeconds
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 3000
            }
            initial_delay_seconds = var.apiGateway.liveness.initialDelaySeconds
            period_seconds        = var.apiGateway.liveness.periodSeconds
          }

          resources {
            limits   = var.apiGateway.resources.limits
            requests = var.apiGateway.resources.requests
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "api" {
  metadata {
    name      = var.apiGateway.serviceName
    namespace = kubernetes_namespace.demo.metadata[0].name
  }
  spec {
    selector = { app = "api-gateway" }
    port {
      port        = var.apiGateway.servicePort
      target_port = 3000
      protocol    = "TCP"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "api_hpa" {
  metadata {
    name      = "api-gateway-hpa"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.api.metadata[0].name
    }
    min_replicas = var.apiGateway.hpa.minReplicas
    max_replicas = var.apiGateway.hpa.maxReplicas

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = var.apiGateway.hpa.targetCPUUtilization
        }
      }
    }
  }
}

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
