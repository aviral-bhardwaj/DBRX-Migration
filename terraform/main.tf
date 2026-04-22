# main.tf (root)
# Orchestrates all sub-modules and wires their outputs together.
# Apply order (implicit through depends_on + output references):
#   service_principal → policies → instance_pools → clusters → notebooks → jobs
#                                ↘ unity_catalog → dlt_pipeline
#                                ↘ sql_warehouse → dashboards
#                                ↘ secret_scope
#                                ↘ permissions

# ---------------------------------------------------------------------------
# 0. Service Principal
# Registers the SP in the workspace and (optionally) adds it to the admin group.
# Skip this block on first-ever apply when the admins group doesn't yet exist
# by setting service_principal_application_id = "" in terraform.tfvars.
# ---------------------------------------------------------------------------
module "service_principal" {
  source = "./modules/service_principal"

  # Only create the SP resource when an application_id is provided
  count = var.service_principal_application_id != "" ? 1 : 0

  application_id   = var.service_principal_application_id
  display_name     = var.service_principal_display_name
  admin_group_name = var.admin_group_name
  create_token     = var.service_principal_create_token
}

# ---------------------------------------------------------------------------
# 1. Cluster policies
# ---------------------------------------------------------------------------
module "policies" {
  source = "./modules/policies"
}

# ---------------------------------------------------------------------------
# 2. Instance pool (shared warm nodes for faster cluster start)
# ---------------------------------------------------------------------------
module "instance_pools" {
  source = "./modules/instance_pools"

  spark_version     = var.spark_version
  default_node_type = var.default_node_type
}

# ---------------------------------------------------------------------------
# 3. All-purpose interactive cluster
# ---------------------------------------------------------------------------
module "clusters" {
  source = "./modules/clusters"

  spark_version         = var.spark_version
  default_node_type     = var.default_node_type
  instance_pool_id      = module.instance_pools.instance_pool_id
  job_policy_id         = module.policies.job_policy_id
  interactive_policy_id = module.policies.interactive_policy_id
}

# ---------------------------------------------------------------------------
# 4. Notebooks (Python source uploaded to the workspace)
# ---------------------------------------------------------------------------
module "notebooks" {
  source = "./modules/notebooks"
}

# ---------------------------------------------------------------------------
# 5. Multi-task Databricks Job
# ---------------------------------------------------------------------------
module "jobs" {
  source = "./modules/jobs"

  spark_version      = var.spark_version
  default_node_type  = var.default_node_type
  instance_pool_id   = module.instance_pools.instance_pool_id
  job_policy_id      = module.policies.job_policy_id
  notification_email = var.notification_email

  notebook_init_path      = module.notebooks.notebook_init_path
  notebook_ingest_path    = module.notebooks.notebook_ingest_path
  notebook_transform_path = module.notebooks.notebook_transform_path
  notebook_report_path    = module.notebooks.notebook_report_path
}

# ---------------------------------------------------------------------------
# 6. Unity Catalog (metastore, catalogs, schemas, grants)
# ---------------------------------------------------------------------------
module "unity_catalog" {
  source = "./modules/unity_catalog"

  databricks_host                 = var.databricks_host
  workspace_id                    = var.workspace_id
  storage_root                    = var.storage_root
  unity_catalog_metastore_id      = var.unity_catalog_metastore_id
  admin_group_name                = var.admin_group_name
  environment                     = var.environment
  storage_credential_iam_role_arn = var.storage_credential_iam_role_arn
}

# ---------------------------------------------------------------------------
# 7. SQL Warehouses
# ---------------------------------------------------------------------------
module "sql_warehouse" {
  source = "./modules/sql_warehouse"
}

# ---------------------------------------------------------------------------
# 8. Secret scope & secrets
# ---------------------------------------------------------------------------
module "secret_scope" {
  source = "./modules/secret_scope"

  admin_group_name = var.admin_group_name
}

# ---------------------------------------------------------------------------
# 9. Delta Live Tables pipeline
# ---------------------------------------------------------------------------
module "dlt_pipeline" {
  source = "./modules/dlt_pipeline"

  spark_version           = var.spark_version
  default_node_type       = var.default_node_type
  notebook_ingest_path    = module.notebooks.notebook_ingest_path
  notebook_transform_path = module.notebooks.notebook_transform_path
  target_catalog          = module.unity_catalog.catalog_names[var.environment]
}

# ---------------------------------------------------------------------------
# 10. Lakeview Dashboard
# ---------------------------------------------------------------------------
module "dashboards" {
  source = "./modules/dashboards"

  warehouse_id = module.sql_warehouse.serverless_warehouse_id
}

# ---------------------------------------------------------------------------
# 11. Permissions & ACLs
# ---------------------------------------------------------------------------
module "permissions" {
  source = "./modules/permissions"

  cluster_id   = module.clusters.cluster_id
  job_id       = module.jobs.job_id
  warehouse_id = module.sql_warehouse.serverless_warehouse_id

  notebook_init_path      = module.notebooks.notebook_init_path
  notebook_ingest_path    = module.notebooks.notebook_ingest_path
  notebook_transform_path = module.notebooks.notebook_transform_path
  notebook_report_path    = module.notebooks.notebook_report_path

  admin_group_name = var.admin_group_name
}
