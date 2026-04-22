# modules/sql_warehouse/main.tf
# Creates two SQL Warehouses:
#   - serverless: low-latency ad-hoc queries, auto-stops after 10 min idle
#   - classic:    multi-cluster for heavier BI workloads

# ---------------------------------------------------------------------------
# Serverless SQL Warehouse
# Best for interactive dashboards and quick ad-hoc SQL queries.
# ---------------------------------------------------------------------------
resource "databricks_sql_endpoint" "serverless" {
  name             = "serverless-warehouse"
  cluster_size     = "Small"
  max_num_clusters = 1
  auto_stop_mins   = 10
  enable_photon    = true

  # Serverless type requires warehouse_type = "PRO" (maps to serverless billing)
  warehouse_type = "PRO"

  tags {
    custom_tags {
      key   = "managed_by"
      value = "terraform"
    }
  }
}

# ---------------------------------------------------------------------------
# Classic SQL Warehouse
# Multi-cluster warehouse for heavier workloads and concurrent BI users.
# ---------------------------------------------------------------------------
resource "databricks_sql_endpoint" "classic" {
  name             = "classic-warehouse"
  cluster_size     = "Medium"
  max_num_clusters = 3
  auto_stop_mins   = 30
  enable_photon    = true

  # Classic type for cost-controlled on-demand scaling
  warehouse_type = "CLASSIC"

  tags {
    custom_tags {
      key   = "managed_by"
      value = "terraform"
    }
  }
}
