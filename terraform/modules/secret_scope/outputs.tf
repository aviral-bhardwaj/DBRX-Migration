# modules/secret_scope/outputs.tf

output "secret_scope_name" {
  description = "Name of the Databricks-backed secret scope."
  value       = databricks_secret_scope.app_secrets.name
}
