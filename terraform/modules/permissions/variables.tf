# modules/permissions/variables.tf

variable "cluster_id" {
  description = "ID of the all-purpose cluster to set permissions on."
  type        = string
}

variable "job_id" {
  description = "ID of the Databricks job to set permissions on."
  type        = string
}

variable "warehouse_id" {
  description = "ID of the SQL Warehouse to set permissions on."
  type        = string
}

variable "notebook_init_path" {
  description = "Workspace path of the init notebook."
  type        = string
}

variable "notebook_ingest_path" {
  description = "Workspace path of the ingest notebook."
  type        = string
}

variable "notebook_transform_path" {
  description = "Workspace path of the transform notebook."
  type        = string
}

variable "notebook_report_path" {
  description = "Workspace path of the report notebook."
  type        = string
}

variable "admin_group_name" {
  description = "Group that receives elevated permissions."
  type        = string
}
