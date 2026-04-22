# modules/instance_pools/main.tf
# Provisions a shared instance pool so clusters start faster by reusing
# pre-warmed EC2 instances rather than requesting new ones from AWS.

resource "databricks_instance_pool" "shared_pool" {
  instance_pool_name = "shared-instance-pool"

  # Keep zero idle nodes when nothing is running (cost-efficient)
  min_idle_instances = 0
  # Hard cap on how many instances can be in the pool at once
  max_capacity = 10

  # Terminate idle instances after 10 minutes to avoid unused charges
  idle_instance_autotermination_minutes = 10

  node_type_id = var.default_node_type

  # Pre-load the Databricks Runtime so first cluster start is fast
  preloaded_spark_versions = [var.spark_version]

  # Use Spot instances in the pool (SPOT or ON_DEMAND; no SPOT_WITH_FALLBACK for pools)
  aws_attributes {
    availability           = "SPOT"
    spot_bid_price_percent = 100
    zone_id                = "auto"
  }

  # Ignore library-install changes so Terraform doesn't force-recreate the pool
  lifecycle {
    ignore_changes = [preloaded_spark_versions]
  }
}
