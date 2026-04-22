# modules/dashboards/outputs.tf

output "dashboard_id" {
  description = "ID of the Lakeview dashboard."
  value       = databricks_dashboard.pipeline_overview.id
}
