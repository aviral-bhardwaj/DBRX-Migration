# modules/clusters/main.tf
# Creates an all-purpose interactive cluster that data engineers / analysts
# can attach notebooks to for exploratory work.

resource "databricks_cluster" "interactive" {
  cluster_name     = "interactive-cluster"
  spark_version    = var.spark_version
  node_type_id     = var.default_node_type
  instance_pool_id = var.instance_pool_id
  policy_id        = var.interactive_policy_id

  # Autoscale between 1 and 4 workers depending on workload
  autoscale {
    min_workers = 1
    max_workers = 4
  }

  # Terminate idle cluster after 30 minutes to save cost
  autotermination_minutes = 30

  # Custom Spark settings for better performance and Delta optimizations
  spark_conf = {
    "spark.databricks.delta.preview.enabled"        = "true"
    "spark.databricks.delta.optimizeWrite.enabled"  = "true"
    "spark.databricks.delta.autoCompact.enabled"    = "true"
    "spark.databricks.io.cache.enabled"             = "true"
    "spark.sql.adaptive.enabled"                    = "true"
    "spark.sql.adaptive.coalescePartitions.enabled" = "true"
  }

  # Use Spot instances with on-demand fallback
  aws_attributes {
    availability           = "SPOT_WITH_FALLBACK"
    spot_bid_price_percent = 100
    zone_id                = "auto"
    first_on_demand        = 1
  }

  # Standard cluster log delivery to DBFS
  cluster_log_conf {
    dbfs {
      destination = "dbfs:/cluster-logs/interactive"
    }
  }

  # Libraries pre-installed on every start
  library {
    pypi {
      package = "great-expectations==0.18.12"
    }
  }

  # Ignore library drift so Terraform doesn't recreate the cluster every plan
  lifecycle {
    ignore_changes = [
      library,
      num_workers,
    ]
  }
}
