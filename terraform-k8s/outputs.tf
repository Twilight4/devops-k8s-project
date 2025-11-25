output "postgres_password" {
  value     = random_password.pg_password.result
  sensitive = true
}
