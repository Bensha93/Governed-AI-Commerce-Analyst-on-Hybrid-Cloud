terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
}

locals {
  labels = {
    environment = var.environment
    project     = "hybrid-commerce-ai"
  }
}

resource "google_bigquery_dataset" "raw" {
  dataset_id                 = "commerce_raw"
  friendly_name              = "Commerce Raw"
  description                = "Raw imported commerce source data."
  location                   = var.bq_location
  delete_contents_on_destroy = false
  labels                     = local.labels
}

resource "google_bigquery_dataset" "enriched" {
  dataset_id                 = "commerce_enriched"
  friendly_name              = "Commerce Enriched"
  description                = "Cleaned and standardized commerce data."
  location                   = var.bq_location
  delete_contents_on_destroy = false
  labels                     = local.labels
}

resource "google_bigquery_dataset" "marts" {
  dataset_id                 = "commerce_dbt_marts"
  friendly_name              = "Commerce dbt Marts"
  description                = "dbt facts, dimensions, and marts."
  location                   = var.bq_location
  delete_contents_on_destroy = false
  labels                     = local.labels
}

resource "google_bigquery_dataset" "governed" {
  dataset_id                 = "commerce_governed"
  friendly_name              = "Commerce Governed"
  description                = "Certified views exposed to the AI analyst agent."
  location                   = var.bq_location
  delete_contents_on_destroy = false
  labels                     = local.labels
}

resource "google_bigquery_dataset" "audit" {
  dataset_id                 = "commerce_audit"
  friendly_name              = "Commerce Audit"
  description                = "AI agent audit and policy logs."
  location                   = var.bq_location
  delete_contents_on_destroy = false
  labels                     = local.labels
}

resource "google_bigquery_table" "ai_agent_query_log" {
  dataset_id = google_bigquery_dataset.audit.dataset_id
  table_id   = "ai_agent_query_log"

  schema = jsonencode([
    { name = "audit_id", type = "STRING", mode = "REQUIRED" },
    { name = "event_timestamp", type = "TIMESTAMP", mode = "REQUIRED" },
    { name = "user_id", type = "STRING", mode = "NULLABLE" },
    { name = "user_role", type = "STRING", mode = "NULLABLE" },
    { name = "business_purpose", type = "STRING", mode = "NULLABLE" },
    { name = "question", type = "STRING", mode = "NULLABLE" },
    { name = "generated_sql", type = "STRING", mode = "NULLABLE" },
    { name = "approved_sql", type = "STRING", mode = "NULLABLE" },
    { name = "tables_used", type = "STRING", mode = "REPEATED" },
    { name = "policy_decision", type = "STRING", mode = "NULLABLE" },
    { name = "row_count_returned", type = "INTEGER", mode = "NULLABLE" },
    { name = "answer_summary", type = "STRING", mode = "NULLABLE" },
    { name = "model_used", type = "STRING", mode = "NULLABLE" },
    { name = "execution_status", type = "STRING", mode = "NULLABLE" }
  ])
}
