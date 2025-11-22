variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
  description = "Path to kubeconfig that Terraform should use"
}

variable "ingress_host" {
  type    = string
  default = "micro.local"
}

# Users service
variable "users_image" { type = string; default = "twilight4/users" }
variable "users_tag"   { type = string; default = "0.1.0" }
variable "users_replicas" { type = number; default = 2 }

# Orders service
variable "orders_image" { type = string; default = "twilight4/orders" }
variable "orders_tag"   { type = string; default = "0.1.0" }
variable "orders_replicas" { type = number; default = 2 }

# API Gateway
variable "api_image" { type = string; default = "twilight4/api" }
variable "api_tag"   { type = string; default = "0.1.0" }
variable "api_replicas" { type = number; default = 1 }

# Postgres
variable "postgres_image" { type = string; default = "postgres" }
variable "postgres_tag"   { type = string; default = "15" }
variable "postgres_replicas" { type = number; default = 1 }
variable "postgres_storage" { type = string; default = "1Gi" }
variable "postgres_password" { type = string; default = "supersecret" }

# Resource stubs (optional)
variable "default_limits" {
  type = map(string)
  default = { cpu = "200m", memory = "256Mi" }
}
variable "default_requests" {
  type = map(string)
  default = { cpu = "100m", memory = "128Mi" }
}
