variable "tags" {
  description = "Tags to apply to all resources in this module."
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "Name prefix for resources created by this module."
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain logs. Typically lower in test, higher in prod."
  type        = number
  default     = 7
}
