variable "kubeconfig_path" {
  description = "Path to kubeconfig that Terraform should use"
  type        = string
  default     = "~/.kube/config"
}

variable "namespace" {
  description = "Kubernetes namespace to create resources in"
  type        = string
  default     = "demo"
}

variable "global" {
  description = "Global values"
  type = object({
    ingressHost = string
    className   = string
  })
  default = {
    ingressHost = "micro.local"
    className   = "nginx"
  }
}

variable "users" {
  description = "Users service configuration"
  type = object({
    image    = string
    tag      = string
    replicas = number

    readiness = object({
      initialDelaySeconds = number
      periodSeconds       = number
    })

    liveness = object({
      initialDelaySeconds = number
      periodSeconds       = number
    })

    resources = object({
      limits = object({
        cpu    = string
        memory = string
      })
      requests = object({
        cpu    = string
        memory = string
      })
    })

    hpa = object({
      minReplicas          = number
      maxReplicas          = number
      targetCPUUtilization = number
    })
  })
  default = {
    image    = "twilight4/users-service"
    tag      = "0.1.0"
    replicas = 2
    readiness = {
      initialDelaySeconds = 5
      periodSeconds       = 10
    }
    liveness = {
      initialDelaySeconds = 10
      periodSeconds       = 20
    }
    resources = {
      limits   = { cpu = "200m", memory = "256Mi" }
      requests = { cpu = "100m", memory = "128Mi" }
    }
    hpa = {
      minReplicas          = 1
      maxReplicas          = 5
      targetCPUUtilization = 50
    }
  }
}

variable "orders" {
  description = "Orders service configuration"
  type = object({
    image    = string
    tag      = string
    replicas = number

    readiness = object({
      initialDelaySeconds = number
      periodSeconds       = number
    })

    liveness = object({
      initialDelaySeconds = number
      periodSeconds       = number
    })

    resources = object({
      limits = object({
        cpu    = string
        memory = string
      })
      requests = object({
        cpu    = string
        memory = string
      })
    })

    hpa = object({
      minReplicas          = number
      maxReplicas          = number
      targetCPUUtilization = number
    })
  })
  default = {
    image    = "twilight4/orders-service"
    tag      = "0.1.0"
    replicas = 2
    readiness = {
      initialDelaySeconds = 5
      periodSeconds       = 10
    }
    liveness = {
      initialDelaySeconds = 10
      periodSeconds       = 20
    }
    resources = {
      limits   = { cpu = "200m", memory = "256Mi" }
      requests = { cpu = "100m", memory = "128Mi" }
    }
    hpa = {
      minReplicas          = 1
      maxReplicas          = 5
      targetCPUUtilization = 50
    }
  }
}

variable "apiGateway" {
  description = "API gateway configuration"
  type = object({
    serviceName = string
    servicePort = number

    env = object({
      usersUrl  = string
      ordersUrl = string
    })

    readiness = object({
      initialDelaySeconds = number
      periodSeconds       = number
    })

    liveness = object({
      initialDelaySeconds = number
      periodSeconds       = number
    })

    image    = string
    tag      = string
    replicas = number

    resources = object({
      limits = object({
        cpu    = string
        memory = string
      })
      requests = object({
        cpu    = string
        memory = string
      })
    })

    hpa = object({
      minReplicas          = number
      maxReplicas          = number
      targetCPUUtilization = number
    })
  })
  default = {
    serviceName = "api-gateway-service"
    servicePort = 3000
    env = {
      usersUrl  = "http://users:80"
      ordersUrl = "http://orders:80"
    }
    readiness = {
      initialDelaySeconds = 5
      periodSeconds       = 10
    }
    liveness = {
      initialDelaySeconds = 10
      periodSeconds       = 20
    }
    image    = "twilight4/api-service"
    tag      = "0.1.0"
    replicas = 1
    resources = {
      limits   = { cpu = "200m", memory = "256Mi" }
      requests = { cpu = "100m", memory = "128Mi" }
    }
    hpa = {
      minReplicas          = 1
      maxReplicas          = 5
      targetCPUUtilization = 50
    }
  }
}

variable "postgres" {
  description = "Postgres configuration"
  type = object({
    image    = string
    tag      = string
    replicas = number
    storage  = string
    resources = object({
      limits = object({
        cpu    = string
        memory = string
      })
      requests = object({
        cpu    = string
        memory = string
      })
    })
  })
  default = {
    image    = "postgres"
    tag      = "15"
    replicas = 1
    storage  = "1Gi"
    resources = {
      limits   = { cpu = "300m", memory = "512Mi" }
      requests = { cpu = "150m", memory = "256Mi" }
    }
  }
}

variable "postgres_password" {
  description = "Postgres password"
  type        = string
  default     = "changeme"
}
