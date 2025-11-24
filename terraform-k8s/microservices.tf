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

