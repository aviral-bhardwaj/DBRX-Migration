# modules/secret_scope/variables.tf

variable "admin_group_name" {
  description = "Databricks group that receives READ access to the secret scope."
  type        = string
}
