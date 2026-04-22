# modules/permissions/main.tf
# Configures Databricks ACLs for clusters, jobs, notebooks, and warehouses.
# All permissions use the group-based model — individual users should be
# managed via group membership, not direct ACL entries.

# ---------------------------------------------------------------------------
# Cluster permissions
# CAN_RESTART: the group can attach notebooks and restart the cluster
# ---------------------------------------------------------------------------
resource "databricks_permissions" "cluster" {
  cluster_id = var.cluster_id

  access_control {
    group_name       = var.admin_group_name
    permission_level = "CAN_MANAGE"
  }

  access_control {
    group_name       = "data_engineers"
    permission_level = "CAN_RESTART"
  }

  access_control {
    group_name       = "data_analysts"
    permission_level = "CAN_ATTACH_TO"
  }
}

# ---------------------------------------------------------------------------
# Job permissions
# CAN_MANAGE_RUN: the group can trigger and monitor job runs
# ---------------------------------------------------------------------------
resource "databricks_permissions" "job" {
  job_id = var.job_id

  access_control {
    group_name       = var.admin_group_name
    permission_level = "CAN_MANAGE"
  }

  access_control {
    group_name       = "data_engineers"
    permission_level = "CAN_MANAGE_RUN"
  }

  access_control {
    group_name       = "data_analysts"
    permission_level = "CAN_VIEW"
  }
}

# ---------------------------------------------------------------------------
# SQL Warehouse permissions
# CAN_USE: the group can run queries against the warehouse
# ---------------------------------------------------------------------------
resource "databricks_permissions" "warehouse" {
  sql_endpoint_id = var.warehouse_id

  access_control {
    group_name       = var.admin_group_name
    permission_level = "CAN_MANAGE"
  }

  access_control {
    group_name       = "data_analysts"
    permission_level = "CAN_USE"
  }
}

# ---------------------------------------------------------------------------
# Notebook permissions (applied to each notebook path)
# CAN_RUN: the group can execute the notebook
# ---------------------------------------------------------------------------
locals {
  notebook_paths = {
    init      = var.notebook_init_path
    ingest    = var.notebook_ingest_path
    transform = var.notebook_transform_path
    report    = var.notebook_report_path
  }
}

resource "databricks_permissions" "notebook" {
  for_each = local.notebook_paths

  notebook_path = each.value

  access_control {
    group_name       = var.admin_group_name
    permission_level = "CAN_MANAGE"
  }

  access_control {
    group_name       = "data_engineers"
    permission_level = "CAN_RUN"
  }

  access_control {
    group_name       = "data_analysts"
    permission_level = "CAN_READ"
  }
}
