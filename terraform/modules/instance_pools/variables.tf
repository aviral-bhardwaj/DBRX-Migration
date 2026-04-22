# modules/instance_pools/variables.tf

variable "spark_version" {
  description = "Databricks Runtime version to pre-load on idle instances."
  type        = string
}

variable "default_node_type" {
  description = "EC2 instance type for pool nodes."
  type        = string
}
