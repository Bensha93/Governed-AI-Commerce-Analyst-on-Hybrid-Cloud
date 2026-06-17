variable "project_name" {
  description = "Governed AI Commerce Analyst"
  type        = string
  default     = "governed-ai-commerce-analyst."
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