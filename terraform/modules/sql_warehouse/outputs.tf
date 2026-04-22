# modules/sql_warehouse/outputs.tf

output "serverless_warehouse_id" {
  description = "ID of the serverless SQL Warehouse."
  value       = databricks_sql_endpoint.serverless.id
}

output "classic_warehouse_id" {
  description = "ID of the classic SQL Warehouse."
  value       = databricks_sql_endpoint.classic.id
}
