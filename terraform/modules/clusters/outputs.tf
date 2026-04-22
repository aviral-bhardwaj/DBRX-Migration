# modules/clusters/outputs.tf

output "cluster_id" {
  description = "ID of the all-purpose interactive cluster."
  value       = databricks_cluster.interactive.id
}

output "cluster_name" {
  description = "Display name of the all-purpose cluster."
  value       = databricks_cluster.interactive.cluster_name
}
