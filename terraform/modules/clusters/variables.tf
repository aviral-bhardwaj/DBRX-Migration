# modules/clusters/variables.tf

variable "spark_version" {
  description = "Databricks Runtime version string."
  type        = string
}

variable "default_node_type" {
  description = "EC2 instance type for cluster nodes."
  type        = string
}

variable "instance_pool_id" {
  description = "ID of the shared instance pool to draw nodes from."
  type        = string
}

variable "job_policy_id" {
  description = "ID of the Job Compute cluster policy."
  type        = string
}

variable "interactive_policy_id" {
  description = "ID of the Interactive cluster policy."
  type        = string
}
