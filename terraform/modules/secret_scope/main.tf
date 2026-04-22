# modules/secret_scope/main.tf
# Creates a Databricks-backed secret scope and populates it with
# placeholder secrets. Replace placeholder values with real secrets via
# the CLI or CI/CD pipeline — never commit real values to source control.

# ---------------------------------------------------------------------------
# Secret scope — Databricks-backed (no Azure Key Vault required)
# ---------------------------------------------------------------------------
resource "databricks_secret_scope" "app_secrets" {
  name = "app-secrets"
  # DATABRICKS backend means secrets are stored in Databricks' internal vault
  initial_manage_principal = "users"
}

# ---------------------------------------------------------------------------
# Secrets — IMPORTANT: replace placeholder strings with real secret values
# via `terraform apply -var='...'` or a secrets manager integration.
# ---------------------------------------------------------------------------
resource "databricks_secret" "storage_account_key" {
  key          = "storage_account_key"
  string_value = "REPLACE_WITH_REAL_STORAGE_KEY"
  scope        = databricks_secret_scope.app_secrets.name
}

resource "databricks_secret" "api_key" {
  key          = "api_key"
  string_value = "REPLACE_WITH_REAL_API_KEY"
  scope        = databricks_secret_scope.app_secrets.name
}

resource "databricks_secret" "db_password" {
  key          = "db_password"
  string_value = "REPLACE_WITH_REAL_DB_PASSWORD"
  scope        = databricks_secret_scope.app_secrets.name
}

# ---------------------------------------------------------------------------
# ACL — grant READ to the admin group so pipelines can access secrets
# ---------------------------------------------------------------------------
resource "databricks_secret_acl" "admin_read" {
  principal  = var.admin_group_name
  permission = "READ"
  scope      = databricks_secret_scope.app_secrets.name

  depends_on = [databricks_secret_scope.app_secrets]
}
