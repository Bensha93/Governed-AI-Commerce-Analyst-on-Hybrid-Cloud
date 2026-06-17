variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
  default     = "hybrid-ai-commerce"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for the project."
  type        = string
  default     = "eu-central-1"
}