# modules/notebooks/outputs.tf

output "notebook_init_path" {
  description = "Workspace path of the init/setup notebook."
  value       = databricks_notebook.init.path
}

output "notebook_ingest_path" {
  description = "Workspace path of the Bronze ingestion notebook."
  value       = databricks_notebook.ingest.path
}

output "notebook_transform_path" {
  description = "Workspace path of the Silver transformation notebook."
  value       = databricks_notebook.transform.path
}

output "notebook_report_path" {
  description = "Workspace path of the Gold reporting notebook."
  value       = databricks_notebook.report.path
}
