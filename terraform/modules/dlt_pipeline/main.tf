# modules/dlt_pipeline/main.tf
# Creates a Delta Live Tables (DLT) pipeline that runs the ingestion and
# transformation notebooks in a managed, declarative fashion.
# Set continuous = true for streaming; false (triggered) is fine for batch.

resource "databricks_pipeline" "dlt" {
  name = "dlt-bronze-silver-pipeline"
  # Triggered mode: run on demand or via a schedule (not streaming)
  continuous = false
  # Development mode shows more verbose errors and disables retries
  development = true
  # Target Unity Catalog schema for DLT-managed tables
  target  = "${var.target_catalog}.silver"
  catalog = var.target_catalog

  # ---------------------------------------------------------------------------
  # Notebook sources — DLT discovers @dlt.table-decorated functions here
  # ---------------------------------------------------------------------------
  library {
    notebook {
      path = var.notebook_ingest_path
    }
  }

  library {
    notebook {
      path = var.notebook_transform_path
    }
  }

  # ---------------------------------------------------------------------------
  # Cluster configuration: autoscaling 1-3 workers
  # ---------------------------------------------------------------------------
  cluster {
    label = "default"

    autoscale {
      min_workers = 1
      max_workers = 3
      mode        = "ENHANCED"
    }

    node_type_id = var.default_node_type

    aws_attributes {
      availability = "SPOT_WITH_FALLBACK"
      zone_id      = "auto"
    }
  }

  # DLT manages its own storage under the catalog; no separate DBFS path needed
  configuration = {
    "pipeline.target_catalog" = var.target_catalog
  }
}
