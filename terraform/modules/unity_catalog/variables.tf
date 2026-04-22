# modules/unity_catalog/variables.tf

variable "databricks_host" {
  description = "Workspace URL used to derive the workspace ID for metastore assignment."
  type        = string
}

variable "workspace_id" {
  description = "Numeric Databricks workspace ID (the 'o=' value from the workspace URL)."
  type        = number
}

variable "storage_root" {
  description = "Root storage location for the Unity Catalog metastore (s3:// or abfss://)."
  type        = string
}

variable "unity_catalog_metastore_id" {
  description = "ID of an existing metastore. If empty a new metastore is created."
  type        = string
  default     = ""
}

variable "admin_group_name" {
  description = "Name of the Databricks group that receives ALL PRIVILEGES."
  type        = string
}

variable "environment" {
  description = "Active deployment environment (dev | staging | prod)."
  type        = string
}

variable "storage_credential_iam_role_arn" {
  description = "ARN of the AWS IAM role that Databricks uses to access the S3 storage root."
  type        = string
  default     = ""
}
