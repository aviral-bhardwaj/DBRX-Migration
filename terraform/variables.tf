# variables.tf (root)
# All top-level input variables for the Databricks workspace deployment.

variable "databricks_host" {
  description = "The URL of the Databricks workspace (e.g. https://dbc-xxxx.cloud.databricks.com)."
  type        = string
}

variable "databricks_token" {
  description = "A personal access token (PAT) or service-principal OAuth token for the workspace."
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Deployment environment label: dev | staging | prod."
  type        = string
  default     = "dev"
}

variable "unity_catalog_metastore_id" {
  description = "ID of an existing Unity Catalog metastore. Leave empty to create a new one."
  type        = string
  default     = ""
}

variable "cloud_type" {
  description = "Cloud provider hosting the workspace: aws | azure | gcp."
  type        = string
  default     = "aws"
}

variable "default_node_type" {
  description = "EC2 / VM instance type used for interactive and job clusters."
  type        = string
  default     = "i3.xlarge"
}

variable "spark_version" {
  description = "Databricks Runtime version string (LTS recommended)."
  type        = string
  default     = "14.3.x-scala2.12"
}

variable "storage_root" {
  description = "Root storage path for Unity Catalog (s3://bucket/path or abfss://…)."
  type        = string
  default     = "s3://my-databricks-bucket/unity-catalog"
}

variable "admin_group_name" {
  description = "Name of the Databricks group that receives admin/owner privileges."
  type        = string
  default     = "admins"
}

variable "notification_email" {
  description = "E-mail address that receives job failure notifications."
  type        = string
  default     = "ops@example.com"
}

variable "workspace_id" {
  description = "Numeric Databricks workspace ID (the 'o=' parameter in the workspace URL)."
  type        = number
  default     = 3905551482944124
}

variable "storage_credential_iam_role_arn" {
  description = "ARN of the AWS IAM role used as the Unity Catalog storage credential."
  type        = string
  default     = ""
}
