# variables.tf (root)
# All top-level input variables for the Databricks workspace deployment.

# ---------------------------------------------------------------------------
# Workspace connection
# ---------------------------------------------------------------------------
variable "databricks_host" {
  description = "The URL of the Databricks workspace (e.g. https://dbc-xxxx.cloud.databricks.com)."
  type        = string
}

# ---------------------------------------------------------------------------
# Authentication — choose ONE mode:
#   Mode A: set databricks_token, leave client_id/client_secret empty
#   Mode B: set client_id + client_secret, leave databricks_token empty
# ---------------------------------------------------------------------------
variable "databricks_token" {
  description = "Personal access token (PAT) for Mode A authentication. Leave empty when using service-principal OAuth."
  type        = string
  sensitive   = true
  default     = ""
}

variable "client_id" {
  description = "Service-principal Application (Client) ID for Mode B OAuth M2M authentication."
  type        = string
  default     = ""
}

variable "client_secret" {
  description = "Service-principal client secret for Mode B OAuth M2M authentication."
  type        = string
  sensitive   = true
  default     = ""
}

variable "auth_type" {
  description = "Informational label for which auth mode is active: pat | service_principal."
  type        = string
  default     = "pat"
  validation {
    condition     = contains(["pat", "service_principal"], var.auth_type)
    error_message = "auth_type must be 'pat' or 'service_principal'."
  }
}

# ---------------------------------------------------------------------------
# Service principal provisioning
# ---------------------------------------------------------------------------
variable "service_principal_application_id" {
  description = "Application (Client) ID of the service principal to register in the workspace. Same value as client_id."
  type        = string
  default     = ""
}

variable "service_principal_display_name" {
  description = "Display name for the service principal in the Databricks workspace."
  type        = string
  default     = "terraform-sp"
}

variable "service_principal_create_token" {
  description = "Set to true to generate an OBO (on-behalf-of) token for the service principal."
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------
# Environment & compute
# ---------------------------------------------------------------------------
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
