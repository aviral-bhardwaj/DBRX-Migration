# modules/unity_catalog/main.tf
# Provisions Unity Catalog assets: metastore, catalogs (dev/staging/prod),
# schemas (bronze/silver/gold), and grants for admin and reader groups.

locals {
  # Decide whether we create a new metastore or reuse an existing one
  create_metastore    = var.unity_catalog_metastore_id == ""
  active_metastore_id = local.create_metastore ? databricks_metastore.this[0].id : var.unity_catalog_metastore_id

  # The three environment catalogs we always want
  catalogs = toset(["dev", "staging", "prod"])

  # The three schemas we want inside every catalog
  schemas = ["bronze", "silver", "gold"]

  # Cartesian product of catalogs × schemas for for_each
  catalog_schema_pairs = {
    for pair in flatten([
      for cat in local.catalogs : [
        for sch in local.schemas : {
          key     = "${cat}/${sch}"
          catalog = cat
          schema  = sch
        }
      ]
    ]) : pair.key => pair
  }
}

# ---------------------------------------------------------------------------
# Metastore (created only when no existing ID is supplied)
# ---------------------------------------------------------------------------
resource "databricks_metastore" "this" {
  count = local.create_metastore ? 1 : 0

  name          = "primary-metastore"
  storage_root  = var.storage_root
  force_destroy = true
}

# ---------------------------------------------------------------------------
# Assign the metastore to this workspace
# ---------------------------------------------------------------------------
resource "databricks_metastore_assignment" "this" {
  metastore_id = local.active_metastore_id
  # workspace_id is passed in as a variable (the numeric o= value from the workspace URL)
  workspace_id = var.workspace_id

  depends_on = [databricks_metastore.this]
}

# ---------------------------------------------------------------------------
# Storage credential (parameterised — provide the IAM role ARN via variable)
# ---------------------------------------------------------------------------
resource "databricks_storage_credential" "external" {
  name = "terraform-storage-credential"

  aws_iam_role {
    # Provide the real IAM role ARN via the storage_credential_iam_role_arn variable
    role_arn = var.storage_credential_iam_role_arn != "" ? var.storage_credential_iam_role_arn : "arn:aws:iam::ACCOUNT_ID:role/DatabricksStorageRole"
  }

  comment = "Managed by Terraform — set storage_credential_iam_role_arn to the real IAM role ARN."

  depends_on = [databricks_metastore_assignment.this]
}

# ---------------------------------------------------------------------------
# External location (optional — points to the storage root)
# ---------------------------------------------------------------------------
resource "databricks_external_location" "root" {
  name            = "terraform-external-location"
  url             = var.storage_root
  credential_name = databricks_storage_credential.external.id
  comment         = "Root external location managed by Terraform."

  depends_on = [databricks_storage_credential.external]
}

# ---------------------------------------------------------------------------
# Catalogs — dev, staging, prod
# ---------------------------------------------------------------------------
resource "databricks_catalog" "env_catalog" {
  for_each = local.catalogs

  metastore_id = local.active_metastore_id
  name         = each.key
  comment      = "Catalog for ${each.key} environment. Managed by Terraform."

  depends_on = [databricks_metastore_assignment.this]
}

# ---------------------------------------------------------------------------
# Schemas — bronze, silver, gold in each catalog
# ---------------------------------------------------------------------------
resource "databricks_schema" "env_schema" {
  for_each = local.catalog_schema_pairs

  catalog_name = databricks_catalog.env_catalog[each.value.catalog].name
  name         = each.value.schema
  comment      = "${each.value.schema} layer schema in ${each.value.catalog} catalog."

  depends_on = [databricks_catalog.env_catalog]
}

# ---------------------------------------------------------------------------
# Grants on each catalog — ALL PRIVILEGES for admins, USE CATALOG for readers
# ---------------------------------------------------------------------------
resource "databricks_grants" "catalog_grants" {
  for_each = local.catalogs

  catalog = databricks_catalog.env_catalog[each.key].name

  grant {
    principal  = var.admin_group_name
    privileges = ["ALL_PRIVILEGES"]
  }

  grant {
    principal  = "data_readers"
    privileges = ["USE_CATALOG"]
  }

  depends_on = [databricks_catalog.env_catalog]
}

# ---------------------------------------------------------------------------
# Grants on each schema — SELECT + USE for readers, ALL for admins
# ---------------------------------------------------------------------------
resource "databricks_grants" "schema_grants" {
  for_each = local.catalog_schema_pairs

  schema = "${databricks_catalog.env_catalog[each.value.catalog].name}.${each.value.schema}"

  grant {
    principal  = var.admin_group_name
    privileges = ["ALL_PRIVILEGES"]
  }

  grant {
    principal  = "data_readers"
    privileges = ["USE_SCHEMA", "SELECT"]
  }

  depends_on = [databricks_schema.env_schema]
}
