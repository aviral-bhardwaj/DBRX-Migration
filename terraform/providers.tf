# providers.tf
# Configures the Databricks Terraform provider.
# Docs: https://registry.terraform.io/providers/databricks/databricks/latest/docs
#
# TWO authentication modes are supported — set ONE of them in terraform.tfvars:
#
#   Mode A — Personal Access Token (PAT):
#     databricks_token = "dapi..."
#     (leave client_id and client_secret empty)
#
#   Mode B — Service Principal OAuth M2M:
#     client_id     = "<Application/Client ID of the service principal>"
#     client_secret = "<Client secret generated in Databricks / Azure AD>"
#     (leave databricks_token empty)
#
# The provider uses whichever credentials are non-empty.
# For CI/CD pipelines, Mode B (service principal) is strongly recommended.

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.38.0"
    }
  }
}

provider "databricks" {
  host = var.databricks_host

  # PAT token — used when client_id / client_secret are not provided
  token = var.databricks_token != "" ? var.databricks_token : null

  # Service-principal OAuth M2M — takes precedence over token when both are set
  client_id     = var.client_id != "" ? var.client_id : null
  client_secret = var.client_secret != "" ? var.client_secret : null
}
