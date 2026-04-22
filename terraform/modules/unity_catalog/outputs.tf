# modules/unity_catalog/outputs.tf

output "metastore_id" {
  description = "ID of the active Unity Catalog metastore."
  value       = local.active_metastore_id
}

output "catalog_names" {
  description = "Map of environment label to catalog name."
  value       = { for k, v in databricks_catalog.env_catalog : k => v.name }
}

output "schema_ids" {
  description = "Map of 'catalog/schema' to schema full_name."
  value       = { for k, v in databricks_schema.env_schema : k => v.id }
}
