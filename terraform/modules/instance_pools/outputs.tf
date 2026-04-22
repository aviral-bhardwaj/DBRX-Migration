# modules/instance_pools/outputs.tf

output "instance_pool_id" {
  description = "ID of the shared instance pool."
  value       = databricks_instance_pool.shared_pool.id
}
