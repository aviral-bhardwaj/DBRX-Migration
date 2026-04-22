# modules/service_principal/outputs.tf

output "service_principal_id" {
  description = "Internal Databricks ID of the service principal."
  value       = databricks_service_principal.sp.id
}

output "application_id" {
  description = "Application (Client) ID of the service principal — use as client_id in the provider."
  value       = databricks_service_principal.sp.application_id
}

output "display_name" {
  description = "Display name of the service principal."
  value       = databricks_service_principal.sp.display_name
}

output "sp_token_value" {
  description = "Generated OAuth token value (only populated when create_token = true). Store securely."
  value       = var.create_token ? databricks_obo_token.sp_token[0].token_value : null
  sensitive   = true
}
