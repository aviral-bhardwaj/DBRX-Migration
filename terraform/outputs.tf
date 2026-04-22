# outputs.tf (root)
# Surfaces the most important resource IDs / URLs after a successful apply.

output "service_principal_id" {
  description = "Internal Databricks ID of the service principal (empty if SP not configured)."
  value       = length(module.service_principal) > 0 ? module.service_principal[0].service_principal_id : null
}

output "service_principal_application_id" {
  description = "Application (Client) ID of the service principal — use as client_id in terraform.tfvars."
  value       = length(module.service_principal) > 0 ? module.service_principal[0].application_id : null
}

output "cluster_id" {
  description = "ID of the all-purpose interactive cluster."
  value       = module.clusters.cluster_id
}

output "job_id" {
  description = "ID of the multi-task Databricks Job."
  value       = module.jobs.job_id
}

output "job_url" {
  description = "Web URL to open the job in the Databricks UI."
  value       = module.jobs.job_url
}

output "serverless_warehouse_id" {
  description = "ID of the serverless SQL Warehouse."
  value       = module.sql_warehouse.serverless_warehouse_id
}

output "classic_warehouse_id" {
  description = "ID of the classic SQL Warehouse."
  value       = module.sql_warehouse.classic_warehouse_id
}

output "catalog_names" {
  description = "Map of environment → catalog name created in Unity Catalog."
  value       = module.unity_catalog.catalog_names
}

output "pipeline_id" {
  description = "ID of the Delta Live Tables pipeline."
  value       = module.dlt_pipeline.pipeline_id
}

output "instance_pool_id" {
  description = "ID of the shared instance pool."
  value       = module.instance_pools.instance_pool_id
}

output "secret_scope_name" {
  description = "Name of the Databricks-backed secret scope."
  value       = module.secret_scope.secret_scope_name
}

output "dashboard_id" {
  description = "ID of the Lakeview dashboard."
  value       = module.dashboards.dashboard_id
}
