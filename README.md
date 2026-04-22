# DBRX-Migration

A production-ready **Terraform** project that provisions every major asset in an AWS-hosted Databricks workspace.

> **Target workspace:** `https://dbc-bd6bd71d-fa92.cloud.databricks.com` (workspace ID `3905551482944124`)

📖 **Full usage guide (VS Code + CLI + CI/CD):** [docs/USAGE_GUIDE.md](docs/USAGE_GUIDE.md)

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Prerequisites](#prerequisites)
3. [Authentication](#authentication)
4. [Getting Started](#getting-started)
5. [Module Reference](#module-reference)
6. [Variable Reference](#variable-reference)
7. [Outputs Reference](#outputs-reference)
8. [Security Notes](#security-notes)
9. [Folder Structure](#folder-structure)

---

## Architecture Overview

```
AWS Databricks Workspace
│
├── Instance Pool          ← shared warm EC2 nodes (i3.xlarge, SPOT_WITH_FALLBACK)
│
├── Cluster Policies       ← governance: Job Compute + Interactive policies
│
├── Interactive Cluster    ← all-purpose cluster (autoscale 1-4, 30 min autotermination)
│
├── Notebooks              ← Python notebooks uploaded to /terraform-managed/
│   ├── 01_init            ← library installs & Spark config
│   ├── 02_ingest_bronze   ← Bronze: raw event ingestion → Delta
│   ├── 03_transform_silver← Silver: clean/upsert with Delta MERGE
│   └── 04_report_gold     ← Gold: aggregated KPI table
│
├── Databricks Job         ← 4-task pipeline (init→ingest→transform→report)
│   └── schedule: daily 06:00 UTC
│
├── Unity Catalog
│   ├── Metastore          ← single metastore for all environments
│   ├── Catalogs           ← dev / staging / prod
│   └── Schemas            ← bronze / silver / gold in each catalog
│
├── SQL Warehouses
│   ├── Serverless (Small) ← ad-hoc queries, auto-stop 10 min
│   └── Classic (Medium)   ← multi-cluster BI, auto-stop 30 min
│
├── Secret Scope           ← app-secrets scope with storage/api/db secrets
│
├── DLT Pipeline           ← Delta Live Tables (triggered, dev mode)
│
├── Lakeview Dashboard     ← Pipeline Overview dashboard
│
└── Permissions / ACLs     ← group-based access for admins/engineers/analysts
```

---

## Prerequisites

| Tool | Minimum version |
|------|----------------|
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | 1.3.0 |
| [Databricks provider](https://registry.terraform.io/providers/databricks/databricks) | 1.38.0 |
| Databricks workspace | Premium or above (Unity Catalog requires Premium) |
| AWS IAM role | With access to the S3 bucket used as `storage_root` |

---

## Authentication

Two authentication modes are supported — set **exactly one**:

### Mode A — Personal Access Token (interactive/developer use)

1. Navigate to **Settings → Developer → Access Tokens** in the workspace.
2. Click **Generate New Token**, copy the value.
3. In `terraform.tfvars` set `auth_type = "pat"` and `databricks_token = "dapi..."`.

### Mode B — Service Principal OAuth M2M (CI/CD / automation)

1. Go to **Settings → Identity & Access → Service Principals** → select your SP.
2. Click **Generate Secret**, copy the secret.
3. In `terraform.tfvars` set `auth_type = "service_principal"`, `client_id`, and `client_secret`.

> 📖 Full step-by-step instructions: [docs/USAGE_GUIDE.md → Authentication Methods](docs/USAGE_GUIDE.md#authentication-methods)

---

## Getting Started

```bash
# 1. Clone the repository
git clone https://github.com/aviral-bhardwaj/DBRX-Migration.git
cd DBRX-Migration/terraform

# 2. Copy the example variable file
cp terraform.tfvars.example terraform.tfvars

# 3. Edit terraform.tfvars with real values
#    - set databricks_host
#    - set databricks_token  (use env variable TF_VAR_databricks_token for CI)
#    - set storage_root to your S3 bucket path
vim terraform.tfvars

# 4. Initialise Terraform (downloads the Databricks provider)
terraform init

# 5. Review what will be created (dry run)
terraform plan

# 6. Apply — creates all resources in the workspace
terraform apply

# 7. View outputs
terraform output
```

### Using Environment Variables (recommended for CI/CD)

```bash
export TF_VAR_databricks_host="https://dbc-bd6bd71d-fa92.cloud.databricks.com"
export TF_VAR_databricks_token="dapi..."
terraform apply -auto-approve
```

---

## Module Reference

| Module | Description |
|--------|-------------|
| `modules/policies` | Cluster policies — Job Compute (cost-controlled) and Interactive (autotermination enforced) |
| `modules/instance_pools` | Shared instance pool of i3.xlarge SPOT nodes with 10-min idle termination |
| `modules/clusters` | All-purpose interactive cluster with autoscaling 1-4 and Delta optimisations |
| `modules/notebooks` | Four Python notebooks implementing Bronze/Silver/Gold medallion architecture |
| `modules/jobs` | Multi-task Databricks Job with daily schedule and email failure alerts |
| `modules/unity_catalog` | Metastore, dev/staging/prod catalogs, bronze/silver/gold schemas, and grants |
| `modules/sql_warehouse` | Serverless (Small) and Classic (Medium) SQL Warehouses |
| `modules/secret_scope` | `app-secrets` Databricks-backed secret scope with placeholder secrets |
| `modules/dlt_pipeline` | Delta Live Tables pipeline (triggered, development mode) |
| `modules/dashboards` | Lakeview dashboard wired to the serverless warehouse |
| `modules/permissions` | Group-based ACLs for clusters, jobs, notebooks, and warehouses |
| `modules/service_principal` | Registers a service principal for OAuth M2M auth, adds it to a group |

---

## Variable Reference

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `databricks_host` | `string` | — | Workspace URL |
| `auth_type` | `string` | `pat` | `pat` or `service_principal` |
| `databricks_token` | `string` | `""` | PAT (Mode A) — leave empty for Mode B |
| `client_id` | `string` | `""` | Service-principal Application ID (Mode B) |
| `client_secret` | `string` | `""` | Service-principal secret (Mode B, sensitive) |
| `service_principal_application_id` | `string` | `""` | App ID to register in workspace |
| `service_principal_display_name` | `string` | `terraform-sp` | SP display name |
| `service_principal_create_token` | `bool` | `false` | Generate OBO token for SP |
| `environment` | `string` | `dev` | Deployment environment label |
| `unity_catalog_metastore_id` | `string` | `""` | Existing metastore ID; empty = create new |
| `cloud_type` | `string` | `aws` | Cloud provider (`aws` \| `azure` \| `gcp`) |
| `default_node_type` | `string` | `i3.xlarge` | EC2 instance type for clusters |
| `spark_version` | `string` | `14.3.x-scala2.12` | Databricks Runtime version |
| `storage_root` | `string` | `s3://...` | S3/ADLS path for Unity Catalog metastore |
| `admin_group_name` | `string` | `admins` | Group receiving ALL PRIVILEGES |
| `notification_email` | `string` | `ops@example.com` | Job failure notification address |

---

## Outputs Reference

| Output | Description |
|--------|-------------|
| `cluster_id` | All-purpose cluster ID |
| `job_id` | Multi-task pipeline job ID |
| `job_url` | URL to open the job in the UI |
| `serverless_warehouse_id` | Serverless SQL Warehouse ID |
| `classic_warehouse_id` | Classic SQL Warehouse ID |
| `catalog_names` | Map of environment → catalog name |
| `pipeline_id` | Delta Live Tables pipeline ID |
| `instance_pool_id` | Shared instance pool ID |
| `secret_scope_name` | Name of the `app-secrets` scope |
| `dashboard_id` | Lakeview dashboard ID |

---

## Security Notes

- **Never commit `terraform.tfvars`** — it contains your PAT. It is listed in `.gitignore`.
- Replace placeholder secret values in `modules/secret_scope/main.tf` using `TF_VAR_*` environment variables or a secrets manager (e.g., AWS Secrets Manager with Vault integration).
- Replace the placeholder IAM role ARN in `modules/unity_catalog/main.tf` with a real IAM role that has S3 access before applying.
- Use **service-principal OAuth tokens** instead of PATs for production deployments.

---

## Folder Structure

```
terraform/
├── main.tf                    # Root orchestration — wires all modules
├── variables.tf               # All input variable declarations
├── outputs.tf                 # Key resource IDs surfaced after apply
├── providers.tf               # Databricks provider configuration
├── terraform.tfvars.example   # Example variable values (safe to commit)
└── modules/
    ├── clusters/              # Interactive all-purpose cluster
    ├── dashboards/            # Lakeview dashboard
    ├── dlt_pipeline/          # Delta Live Tables pipeline
    ├── instance_pools/        # Shared EC2 instance pool
    ├── jobs/                  # Multi-task Databricks Job
    ├── notebooks/             # Python notebooks (Bronze/Silver/Gold)
    ├── permissions/           # Group-based ACLs
    ├── policies/              # Cluster policies
    ├── secret_scope/          # Secret scope & secrets
    ├── sql_warehouse/         # Serverless + classic SQL Warehouses
    └── unity_catalog/         # Metastore, catalogs, schemas, grants
```