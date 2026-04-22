# modules/dlt_pipeline/variables.tf

variable "spark_version" {
  description = "Databricks Runtime version for the DLT cluster."
  type        = string
}

variable "default_node_type" {
  description = "EC2 instance type for DLT cluster nodes."
  type        = string
}

variable "notebook_ingest_path" {
  description = "Workspace path of the Bronze ingestion notebook (DLT source)."
  type        = string
}

variable "notebook_transform_path" {
  description = "Workspace path of the Silver transformation notebook (DLT source)."
  type        = string
}

variable "target_catalog" {
  description = "Unity Catalog name to use as the DLT pipeline target."
  type        = string
  default     = "dev"
}
