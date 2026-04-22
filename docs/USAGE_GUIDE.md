# DBRX-Migration — Complete Usage Guide

This guide explains how to use the Terraform project end-to-end:
from installing prerequisites to running your first `terraform apply`
in both **VS Code** and the **Databricks / terminal CLI**.

---

## Table of Contents

1. [What This Project Provisions](#what-this-project-provisions)
2. [Prerequisites](#prerequisites)
3. [Authentication Methods](#authentication-methods)
   - [Mode A — Personal Access Token (PAT)](#mode-a--personal-access-token-pat)
   - [Mode B — Service Principal OAuth M2M](#mode-b--service-principal-oauth-m2m)
4. [One-Time Setup](#one-time-setup)
5. [Running with VS Code](#running-with-vs-code)
6. [Running from the Terminal / CLI](#running-from-the-terminal--cli)
7. [Using a Service Principal After First Apply](#using-a-service-principal-after-first-apply)
8. [CI/CD (GitHub Actions)](#cicd-github-actions)
9. [Variable Reference](#variable-reference)
10. [Common Commands](#common-commands)
11. [Troubleshooting](#troubleshooting)

---

## What This Project Provisions

Running `terraform apply` creates the following assets inside your
Databricks workspace (`https://dbc-bd6bd71d-fa92.cloud.databricks.com`):

| Asset | Module |
|-------|--------|
| Service principal (OAuth M2M) | `modules/service_principal` |
| Cluster policies (Job + Interactive) | `modules/policies` |
| Shared instance pool | `modules/instance_pools` |
| All-purpose interactive cluster | `modules/clusters` |
| 4 Python notebooks (Bronze → Silver → Gold) | `modules/notebooks` |
| Multi-task Databricks Job (daily schedule) | `modules/jobs` |
| Unity Catalog (metastore + catalogs + schemas + grants) | `modules/unity_catalog` |
| Serverless + Classic SQL Warehouses | `modules/sql_warehouse` |
| Secret scope (`app-secrets`) | `modules/secret_scope` |
| Delta Live Tables pipeline | `modules/dlt_pipeline` |
| Lakeview dashboard | `modules/dashboards` |
| Group-based ACLs | `modules/permissions` |

---

## Prerequisites

### 1. Install Terraform (≥ 1.3.0)

**macOS (Homebrew):**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform -version
```

**Windows (winget):**
```powershell
winget install Hashicorp.Terraform
terraform -version
```

**Linux:**
```bash
curl -fsSL https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip \
  -o /tmp/tf.zip
unzip /tmp/tf.zip -d /usr/local/bin/
chmod +x /usr/local/bin/terraform
terraform -version
```

### 2. Install Databricks CLI (optional but useful for debugging)

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh

# Windows
winget install Databricks.DatabricksCLI

# Verify
databricks version
```

### 3. Install Git

```bash
git --version   # should already be installed on most systems
```

---

## Authentication Methods

> **Rule:** Set exactly ONE of the two modes. The other fields must be empty strings.

### Mode A — Personal Access Token (PAT)

Use this for **interactive / developer runs** from your laptop.

**Step 1 — Generate a PAT:**
1. Log in to `https://dbc-bd6bd71d-fa92.cloud.databricks.com`
2. Click your profile icon (top-right) → **Settings**
3. Go to **Developer** → **Access Tokens**
4. Click **Generate New Token**
5. Give it a comment (e.g., `terraform-local`) and an expiry
6. Copy the token — you won't see it again

**Step 2 — Set in terraform.tfvars:**
```hcl
auth_type        = "pat"
databricks_token = "dapi1234567890abcdef..."   # your PAT
client_id        = ""
client_secret    = ""
```

---

### Mode B — Service Principal OAuth M2M

Use this for **CI/CD pipelines, shared scripts, and automation**.
A service principal is a non-human identity — it never expires like a PAT.

**Your service principal details:**
| Field | Value |
|-------|-------|
| Display name | `testing` |
| Application (Client) ID | `e4f520d6-f2e0-42a2-b743-0...` |
| Client Secret | generated in Databricks (see below) |

**Step 1 — Generate a client secret (if not done yet):**
1. Log in to the workspace as an admin
2. Go to **Settings** → **Identity & Access** → **Service Principals**
3. Click on **testing** (or your SP name)
4. Click **Generate Secret**
5. Copy the secret — you won't see it again

**Step 2 — Set in terraform.tfvars:**
```hcl
auth_type        = "service_principal"
databricks_token = ""                                 # leave empty
client_id        = "e4f520d6-f2e0-42a2-b743-0..."    # Application ID
client_secret    = "dosef61fda3e3ae6c36c5af..."       # your client secret
```

> ⚠️ **Never commit real secrets to Git.** Use environment variables for CI/CD — see [CI/CD section](#cicd-github-actions).

---

## One-Time Setup

```bash
# 1. Clone the repository
git clone https://github.com/aviral-bhardwaj/DBRX-Migration.git
cd DBRX-Migration

# 2. Copy the example variable file
cp terraform/terraform.tfvars.example terraform/terraform.tfvars

# 3. Edit terraform.tfvars (see Authentication section above)
#    Fill in at minimum:
#      - databricks_host
#      - databricks_token  OR  client_id + client_secret
#      - storage_root  (your S3 bucket)
#      - storage_credential_iam_role_arn  (your IAM role ARN)

# 4. Move into the terraform directory
cd terraform

# 5. Download the Databricks provider
terraform init
```

---

## Running with VS Code

### Recommended Extensions

Install these from the VS Code Extensions panel (`Ctrl+Shift+X` / `Cmd+Shift+X`):

| Extension | Publisher | Purpose |
|-----------|-----------|---------|
| **HashiCorp Terraform** | HashiCorp | Syntax highlighting, auto-complete, `terraform` commands in terminal |
| **Databricks** | Databricks | Connect to workspace, browse catalogs, run notebooks |
| **GitLens** | GitKraken | Git history and blame |
| **DotENV** | mikestead | Highlight `.env` / `.tfvars` files |

### Step-by-Step in VS Code

**1. Open the project:**
```
File → Open Folder → select the DBRX-Migration folder
```

**2. Open an integrated terminal:**
```
Terminal → New Terminal   (or  Ctrl+` )
```

**3. Navigate to the Terraform directory:**
```bash
cd terraform
```

**4. Initialise Terraform** (downloads provider, registers modules):
```bash
terraform init
```
Expected output: `Terraform has been successfully initialized!`

**5. Preview changes (dry run):**
```bash
terraform plan
```
Review the output — it lists every resource that will be created.
No resources are created or modified at this step.

**6. Apply (create resources):**
```bash
terraform apply
```
Type `yes` when prompted. Terraform will create all resources in ~2-5 minutes.

**7. View outputs** (cluster IDs, job IDs, etc.):
```bash
terraform output
```

**Tip — VS Code HashiCorp extension features:**
- Press `Ctrl+Space` inside any `.tf` file for auto-complete
- Hover over any resource type to see inline docs
- Use the command palette (`Ctrl+Shift+P`) and type `Terraform:` for commands

---

## Running from the Terminal / CLI

```bash
# Navigate into the terraform directory
cd DBRX-Migration/terraform

# Initialise (only needed once, or when modules/providers change)
terraform init

# Validate syntax
terraform validate

# Preview — shows what will be created/changed/destroyed
terraform plan

# Apply — creates all resources (prompts for confirmation)
terraform apply

# Apply without prompt (CI/CD or scripting)
terraform apply -auto-approve

# View all output values
terraform output

# View a specific output
terraform output job_url

# Destroy all resources created by this project
terraform destroy
```

### Passing Variables on the Command Line

```bash
# Override a single variable
terraform apply -var="environment=staging"

# Override multiple variables
terraform apply \
  -var="databricks_token=dapi..." \
  -var="default_node_type=m5.xlarge"

# Point to a different tfvars file
terraform apply -var-file="staging.tfvars"
```

### Using Environment Variables

Any `TF_VAR_<name>` environment variable overrides the matching Terraform variable.
This is the **recommended approach for secrets in CI/CD**:

```bash
# Mode A — PAT
export TF_VAR_databricks_host="https://dbc-bd6bd71d-fa92.cloud.databricks.com"
export TF_VAR_databricks_token="dapi..."
terraform apply -auto-approve

# Mode B — Service principal
export TF_VAR_databricks_host="https://dbc-bd6bd71d-fa92.cloud.databricks.com"
export TF_VAR_auth_type="service_principal"
export TF_VAR_client_id="e4f520d6-f2e0-42a2-b743-0..."
export TF_VAR_client_secret="dosef61fda..."
terraform apply -auto-approve
```

---

## Using a Service Principal After First Apply

The very first `terraform apply` must use a **PAT from an admin user**
because the service principal doesn't exist in the workspace yet.

After the first apply:

1. The `service_principal` module has registered your SP in the workspace.
2. Update `terraform.tfvars` to switch to Mode B:

```hcl
# Switch auth mode
auth_type        = "service_principal"
databricks_token = ""
client_id        = "e4f520d6-f2e0-42a2-b743-0..."
client_secret    = "<YOUR_CLIENT_SECRET>"

# Keep the SP application_id so Terraform doesn't try to re-create it
service_principal_application_id = "e4f520d6-f2e0-42a2-b743-0..."
```

3. Run `terraform plan` — it should show **no changes** (only the auth method changed).
4. All future runs (including CI/CD) now use the service principal.

---

## CI/CD (GitHub Actions)

Create `.github/workflows/terraform.yml`:

```yaml
name: Terraform Databricks

on:
  push:
    branches: [main]
    paths: ["terraform/**"]
  pull_request:
    branches: [main]
    paths: ["terraform/**"]

jobs:
  terraform:
    name: Terraform Plan & Apply
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: terraform

    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.7.5"

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        run: terraform plan -no-color
        env:
          TF_VAR_databricks_host:  ${{ secrets.DATABRICKS_HOST }}
          TF_VAR_auth_type:         "service_principal"
          TF_VAR_client_id:         ${{ secrets.DATABRICKS_CLIENT_ID }}
          TF_VAR_client_secret:     ${{ secrets.DATABRICKS_CLIENT_SECRET }}
          TF_VAR_storage_root:      ${{ secrets.STORAGE_ROOT }}
          TF_VAR_storage_credential_iam_role_arn: ${{ secrets.IAM_ROLE_ARN }}

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve -no-color
        env:
          TF_VAR_databricks_host:  ${{ secrets.DATABRICKS_HOST }}
          TF_VAR_auth_type:         "service_principal"
          TF_VAR_client_id:         ${{ secrets.DATABRICKS_CLIENT_ID }}
          TF_VAR_client_secret:     ${{ secrets.DATABRICKS_CLIENT_SECRET }}
          TF_VAR_storage_root:      ${{ secrets.STORAGE_ROOT }}
          TF_VAR_storage_credential_iam_role_arn: ${{ secrets.IAM_ROLE_ARN }}
```

**Required GitHub repository secrets:**

| Secret name | Value |
|-------------|-------|
| `DATABRICKS_HOST` | `https://dbc-bd6bd71d-fa92.cloud.databricks.com` |
| `DATABRICKS_CLIENT_ID` | `e4f520d6-f2e0-42a2-b743-0...` |
| `DATABRICKS_CLIENT_SECRET` | your client secret |
| `STORAGE_ROOT` | `s3://your-bucket/metastore` |
| `IAM_ROLE_ARN` | `arn:aws:iam::ACCOUNT:role/Role` |

---

## Variable Reference

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `databricks_host` | ✅ | — | Workspace URL |
| `databricks_token` | Mode A | `""` | Personal Access Token |
| `client_id` | Mode B | `""` | Service-principal Application ID |
| `client_secret` | Mode B | `""` | Service-principal client secret |
| `auth_type` | — | `pat` | `pat` or `service_principal` (informational) |
| `service_principal_application_id` | — | `""` | App ID of SP to register in workspace |
| `service_principal_display_name` | — | `terraform-sp` | Display name for the SP |
| `service_principal_create_token` | — | `false` | Generate an OBO token for the SP |
| `environment` | — | `dev` | Active environment (`dev`/`staging`/`prod`) |
| `default_node_type` | — | `i3.xlarge` | EC2 instance type |
| `spark_version` | — | `14.3.x-scala2.12` | Databricks Runtime version |
| `storage_root` | — | `s3://...` | S3/ADLS path for Unity Catalog metastore |
| `admin_group_name` | — | `admins` | Group receiving ALL PRIVILEGES |
| `notification_email` | — | `ops@example.com` | Job failure alert email |
| `workspace_id` | — | `3905551482944124` | Numeric workspace ID (`o=` in URL) |
| `storage_credential_iam_role_arn` | — | `""` | IAM role ARN for Unity Catalog |
| `unity_catalog_metastore_id` | — | `""` | Existing metastore (empty = create new) |

---

## Common Commands

```bash
# Format all .tf files (run before committing)
terraform fmt -recursive

# Validate syntax without connecting to Databricks
terraform validate

# Show current Terraform state
terraform state list

# Show details of a specific resource
terraform state show module.clusters.databricks_cluster.interactive

# Import an existing Databricks resource into state
terraform import module.clusters.databricks_cluster.interactive <cluster_id>

# Remove a resource from state without destroying it
terraform state rm module.secret_scope.databricks_secret.db_password

# Target a single module (skip all others)
terraform apply -target=module.notebooks

# Destroy a single resource
terraform destroy -target=module.clusters.databricks_cluster.interactive

# See sensitive output values
terraform output -json | jq .
```

---

## Troubleshooting

### "Error: cannot create token: 403 Forbidden"
- Your token or service principal does not have admin rights.
- Log in as a workspace admin and add your user / SP to the `admins` group.

### "Error: could not find group 'admins'"
- The group doesn't exist yet. Create it manually in **Settings → Identity & Access → Groups**,
  or comment out the `service_principal` module on the first apply.

### "Error: workspace_id … is already assigned to a metastore"
- A metastore is already assigned. Set `unity_catalog_metastore_id` to the existing
  metastore ID (find it in the Unity Catalog admin console) and re-run.

### "Error: provider produced inconsistent result after apply"
- Usually a provider version issue. Run `terraform init -upgrade` and retry.

### Provider authentication fails with service principal
Check these in order:
1. `client_id` matches the **Application (Client) ID** exactly.
2. `client_secret` is the generated secret, not the secret ID.
3. The service principal has been added to the workspace (run once with PAT first).
4. The SP has **workspace access** entitlement enabled.

### Terraform state is out of sync (resource deleted manually)
```bash
terraform refresh          # sync state with actual workspace
terraform plan             # verify what will be re-created
terraform apply            # recreate drifted resources
```

### Check provider and module versions
```bash
terraform version
cat terraform/.terraform.lock.hcl
```

---

## Security Best Practices

1. **Never commit `terraform.tfvars`** — it contains secrets. It is in `.gitignore`.
2. Use **environment variables** (`TF_VAR_*`) in CI/CD — never inline secrets in YAML.
3. Rotate the service-principal client secret every 90 days.
4. Use **Terraform remote state** (S3 + DynamoDB locking) for team environments:
   ```hcl
   terraform {
     backend "s3" {
       bucket         = "my-tfstate-bucket"
       key            = "dbrx-migration/terraform.tfstate"
       region         = "us-east-1"
       dynamodb_table = "terraform-locks"
       encrypt        = true
     }
   }
   ```
5. Store `client_secret` in AWS Secrets Manager / HashiCorp Vault and pull it
   at deploy time rather than storing it in any file.
