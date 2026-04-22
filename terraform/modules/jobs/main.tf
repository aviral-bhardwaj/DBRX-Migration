# modules/jobs/main.tf
# Creates a Databricks multi-task job with four sequential tasks that
# implement the Bronze → Silver → Gold pipeline.
# Each task runs on its own ephemeral job cluster to maximise isolation.

locals {
  # Shared job cluster definition reused by all four tasks
  shared_job_cluster_key = "pipeline_cluster"
}

resource "databricks_job" "pipeline_job" {
  name = "databricks-pipeline-job"

  # -----------------------------------------------------------------------
  # Shared job cluster (all tasks reference this key)
  # -----------------------------------------------------------------------
  job_cluster {
    job_cluster_key = local.shared_job_cluster_key

    new_cluster {
      spark_version    = var.spark_version
      node_type_id     = var.default_node_type
      instance_pool_id = var.instance_pool_id
      policy_id        = var.job_policy_id

      # 1 driver + 2 workers is sufficient for the sample pipeline
      num_workers = 2

      spark_conf = {
        "spark.databricks.delta.optimizeWrite.enabled" = "true"
        "spark.databricks.delta.autoCompact.enabled"   = "true"
        "spark.sql.adaptive.enabled"                   = "true"
        "pipeline.target_catalog"                      = "dev"
      }

      aws_attributes {
        availability           = "SPOT_WITH_FALLBACK"
        spot_bid_price_percent = 100
        zone_id                = "auto"
      }
    }
  }

  # -----------------------------------------------------------------------
  # Task 1 — Init (no upstream dependencies)
  # -----------------------------------------------------------------------
  task {
    task_key        = "init"
    job_cluster_key = local.shared_job_cluster_key

    notebook_task {
      notebook_path = var.notebook_init_path
      base_parameters = {
        env = "dev"
      }
    }

    # Retry once on transient failures
    max_retries               = 2
    min_retry_interval_millis = 30000
    timeout_seconds           = 3600
  }

  # -----------------------------------------------------------------------
  # Task 2 — Ingest (depends on init)
  # -----------------------------------------------------------------------
  task {
    task_key        = "ingest_bronze"
    job_cluster_key = local.shared_job_cluster_key

    depends_on {
      task_key = "init"
    }

    notebook_task {
      notebook_path = var.notebook_ingest_path
    }

    max_retries               = 2
    min_retry_interval_millis = 30000
    timeout_seconds           = 3600
  }

  # -----------------------------------------------------------------------
  # Task 3 — Transform (depends on ingest)
  # -----------------------------------------------------------------------
  task {
    task_key        = "transform_silver"
    job_cluster_key = local.shared_job_cluster_key

    depends_on {
      task_key = "ingest_bronze"
    }

    notebook_task {
      notebook_path = var.notebook_transform_path
    }

    max_retries               = 2
    min_retry_interval_millis = 30000
    timeout_seconds           = 3600
  }

  # -----------------------------------------------------------------------
  # Task 4 — Report (depends on transform)
  # -----------------------------------------------------------------------
  task {
    task_key        = "report_gold"
    job_cluster_key = local.shared_job_cluster_key

    depends_on {
      task_key = "transform_silver"
    }

    notebook_task {
      notebook_path = var.notebook_report_path
    }

    max_retries               = 2
    min_retry_interval_millis = 30000
    timeout_seconds           = 3600
  }

  # -----------------------------------------------------------------------
  # Schedule: run daily at 06:00 UTC
  # -----------------------------------------------------------------------
  schedule {
    quartz_cron_expression = "0 0 6 * * ?"
    timezone_id            = "UTC"
    pause_status           = "UNPAUSED"
  }

  # -----------------------------------------------------------------------
  # Email notifications on any failure
  # -----------------------------------------------------------------------
  email_notifications {
    on_failure = [var.notification_email]
  }

  # Overall job timeout
  timeout_seconds = 14400

  # Tag the job for cost attribution
  tags = {
    managed_by = "terraform"
    pipeline   = "bronze-silver-gold"
  }
}
