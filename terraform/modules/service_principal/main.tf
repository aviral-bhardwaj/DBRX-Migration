# modules/service_principal/main.tf
# Creates and manages a Databricks service principal for OAuth M2M (machine-to-machine)
# authentication. Use this principal's client_id + client_secret instead of a PAT
# token when running Terraform from CI/CD pipelines or shared automation scripts.
#
# Relationship to provider authentication:
#   Root providers.tf accepts EITHER:
#     a) databricks_token  — personal access token (interactive use)
#     b) client_id + client_secret — OAuth M2M via this service principal (CI/CD)
#
# How the service principal is created on first run:
#   The first `terraform apply` must be done with a PAT token (admin user).
#   After the SP is created you can rotate to SP-based auth for all subsequent runs.

# ---------------------------------------------------------------------------
# Service principal registration in the workspace
# ---------------------------------------------------------------------------
resource "databricks_service_principal" "sp" {
  # application_id is the Client ID from the Databricks / Azure AD app registration
  application_id = var.application_id
  display_name   = var.display_name

  # Entitlements — what the SP is allowed to do at the workspace level
  allow_cluster_create       = var.allow_cluster_create
  allow_instance_pool_create = var.allow_instance_pool_create
  workspace_access           = var.workspace_access
  databricks_sql_access      = var.databricks_sql_access
}

# ---------------------------------------------------------------------------
# Add the service principal to the specified group (default: admins)
# so it inherits all group-level Unity Catalog grants and ACLs.
# ---------------------------------------------------------------------------
data "databricks_group" "target_group" {
  display_name = var.admin_group_name
}

resource "databricks_group_member" "sp_in_group" {
  group_id  = data.databricks_group.target_group.id
  member_id = databricks_service_principal.sp.id
}

# ---------------------------------------------------------------------------
# Optional: generate a PAT-style OAuth token for the service principal.
# Set create_token = true only if you need a long-lived token for legacy tools
# that don't support full OAuth M2M flows. Prefer M2M OAuth for CI/CD.
# ---------------------------------------------------------------------------
resource "databricks_obo_token" "sp_token" {
  count = var.create_token ? 1 : 0

  application_id   = databricks_service_principal.sp.application_id
  comment          = "Token for ${var.display_name} — managed by Terraform"
  lifetime_seconds = var.token_lifetime_seconds > 0 ? var.token_lifetime_seconds : null

  depends_on = [databricks_service_principal.sp]
}
