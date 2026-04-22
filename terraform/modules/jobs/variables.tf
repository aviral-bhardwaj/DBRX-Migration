# modules/jobs/variables.tf

variable "spark_version" {
  description = "Databricks Runtime version for job clusters."
  type        = string
}

variable "default_node_type" {
  description = "EC2 instance type for job cluster nodes."
  type        = string
}

variable "instance_pool_id" {
  description = "ID of the instance pool job clusters draw from."
  type        = string
}

variable "job_policy_id" {
  description = "ID of the Job Compute cluster policy."
  type        = string
}

variable "notification_email" {
  description = "Email address to notify on job failure."
  type        = string
}

variable "notebook_init_path" {
  description = "Workspace path of the init notebook."
  type        = string
}

variable "notebook_ingest_path" {
  description = "Workspace path of the Bronze ingestion notebook."
  type        = string
}

variable "notebook_transform_path" {
  description = "Workspace path of the Silver transformation notebook."
  type        = string
}

variable "notebook_report_path" {
  description = "Workspace path of the Gold reporting notebook."
  type        = string
}
