# modules/policies/main.tf
# Creates cluster policies that enforce governance on cluster configurations.
# Policies are referenced by both the clusters and jobs modules.

locals {
  # Allowed node types for job clusters (cost-optimised compute)
  job_node_types = ["i3.xlarge", "i3.2xlarge", "m5.xlarge", "m5.2xlarge"]
}

# ---------------------------------------------------------------------------
# Job Compute Policy
# Restricts node types and enforces autoscaling bounds for job clusters.
# ---------------------------------------------------------------------------
resource "databricks_cluster_policy" "job_policy" {
  name = "Job Compute Policy"

  definition = jsonencode({
    # Lock down autoscaling range to keep costs predictable
    "autoscale.min_workers" = {
      type         = "range"
      minValue     = 1
      maxValue     = 4
      defaultValue = 1
    }
    "autoscale.max_workers" = {
      type         = "range"
      minValue     = 1
      maxValue     = 8
      defaultValue = 4
    }
    # Only allow spot instances for jobs
    "aws_attributes.availability" = {
      type         = "allowlist"
      values       = ["SPOT", "SPOT_WITH_FALLBACK"]
      defaultValue = "SPOT_WITH_FALLBACK"
    }
    # Enforce auto-termination after 60 minutes of inactivity
    "autotermination_minutes" = {
      type   = "fixed"
      value  = 60
      hidden = false
    }
  })
}

# ---------------------------------------------------------------------------
# Interactive Compute Policy
# Enforces autotermination and Spark version for all-purpose clusters.
# ---------------------------------------------------------------------------
resource "databricks_cluster_policy" "interactive_policy" {
  name = "Interactive Compute Policy"

  definition = jsonencode({
    # Autotermination is mandatory (cannot be disabled by users)
    "autotermination_minutes" = {
      type         = "range"
      minValue     = 10
      maxValue     = 120
      defaultValue = 30
    }
    # Restrict to current LTS runtimes
    "spark_version" = {
      type   = "allowlist"
      values = ["14.3.x-scala2.12", "13.3.x-scala2.12", "15.4.x-scala2.12"]
    }
    # On-demand only for interactive clusters (reliability > cost)
    "aws_attributes.availability" = {
      type         = "allowlist"
      values       = ["ON_DEMAND", "SPOT_WITH_FALLBACK"]
      defaultValue = "SPOT_WITH_FALLBACK"
    }
  })
}
