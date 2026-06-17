variable "gcp_project_id" {
  type        = string
  description = "governed-ai-commerce-analyst."
}

variable "bq_location" {
  type        = string
  description = "BigQuery location. Europe"
  default     = "EU"
}

variable "environment" {
  type        = string
  description = "Environment name."
  default     = "dev"
}
