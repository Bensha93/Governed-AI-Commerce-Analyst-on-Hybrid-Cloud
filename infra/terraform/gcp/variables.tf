variable "gcp_project_id" {
  type        = string
  description = "GCP project ID."
}

variable "bq_location" {
  type        = string
  description = "BigQuery location. Use EU if you are building from Poland/EU."
  default     = "EU"
}

variable "environment" {
  type        = string
  description = "Environment name."
  default     = "dev"
}
