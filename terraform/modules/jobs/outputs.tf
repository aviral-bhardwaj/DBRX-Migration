# modules/jobs/outputs.tf

output "job_id" {
  description = "ID of the Databricks multi-task job."
  value       = databricks_job.pipeline_job.id
}

output "job_url" {
  description = "Direct link to the job in the Databricks UI."
  value       = databricks_job.pipeline_job.url
}
