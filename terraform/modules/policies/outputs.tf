# modules/policies/outputs.tf

output "job_policy_id" {
  description = "ID of the Job Compute cluster policy."
  value       = databricks_cluster_policy.job_policy.id
}

output "interactive_policy_id" {
  description = "ID of the Interactive cluster policy."
  value       = databricks_cluster_policy.interactive_policy.id
}
