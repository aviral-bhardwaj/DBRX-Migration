# modules/dashboards/variables.tf

variable "warehouse_id" {
  description = "SQL Warehouse ID that the dashboard executes queries against."
  type        = string
}
