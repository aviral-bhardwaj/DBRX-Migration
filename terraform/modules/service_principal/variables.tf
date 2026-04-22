# modules/service_principal/variables.tf

variable "display_name" {
  description = "Human-readable name for the service principal shown in the Databricks UI."
  type        = string
  default     = "terraform-sp"
}

variable "application_id" {
  description = "Azure AD / Databricks Application (Client) ID of the service principal."
  type        = string
}

variable "allow_cluster_create" {
  description = "Whether the service principal may create clusters."
  type        = bool
  default     = true
}

variable "allow_instance_pool_create" {
  description = "Whether the service principal may create instance pools."
  type        = bool
  default     = true
}

variable "workspace_access" {
  description = "Grant the service principal access to the workspace."
  type        = bool
  default     = true
}

variable "databricks_sql_access" {
  description = "Grant the service principal access to Databricks SQL."
  type        = bool
  default     = true
}

variable "admin_group_name" {
  description = "Databricks group the service principal will be added to as a member."
  type        = string
  default     = "admins"
}

variable "create_token" {
  description = "Whether to generate a PAT-style OAuth token for the service principal."
  type        = bool
  default     = false
}

variable "token_lifetime_seconds" {
  description = "Lifetime of the generated service-principal token (seconds). 0 = no expiry."
  type        = number
  default     = 0
}
