# modules/dashboards/main.tf
# Creates a Lakeview dashboard that visualises the Gold-layer event summary.
# The serialized_dashboard field contains the Lakeview JSON spec.

locals {
  # Minimal Lakeview dashboard JSON spec
  dashboard_spec = jsonencode({
    pages = [
      {
        displayName = "Pipeline Overview"
        layout      = []
        widgets     = []
      }
    ]
  })
}

resource "databricks_dashboard" "pipeline_overview" {
  display_name         = "Pipeline Overview Dashboard"
  warehouse_id         = var.warehouse_id
  serialized_dashboard = local.dashboard_spec
  parent_path          = "/terraform-managed/dashboards"
  embed_credentials    = false

  lifecycle {
    # Avoid replacing the dashboard if users make UI edits
    ignore_changes = [serialized_dashboard]
  }
}
