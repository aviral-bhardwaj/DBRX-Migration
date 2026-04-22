# modules/dlt_pipeline/outputs.tf

output "pipeline_id" {
  description = "ID of the Delta Live Tables pipeline."
  value       = databricks_pipeline.dlt.id
}
