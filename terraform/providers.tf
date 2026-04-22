# providers.tf
# Configures the Databricks Terraform provider.
# Docs: https://registry.terraform.io/providers/databricks/databricks/latest/docs

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.38.0"
    }
  }
}

# The provider reads host + token from input variables so that no credentials
# are ever hard-coded in source control.
provider "databricks" {
  host  = var.databricks_host
  token = var.databricks_token
}
