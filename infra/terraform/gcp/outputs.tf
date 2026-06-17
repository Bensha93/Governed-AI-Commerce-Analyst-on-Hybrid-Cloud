output "raw_dataset" {
  value = google_bigquery_dataset.raw.dataset_id
}

output "enriched_dataset" {
  value = google_bigquery_dataset.enriched.dataset_id
}

output "marts_dataset" {
  value = google_bigquery_dataset.marts.dataset_id
}

output "governed_dataset" {
  value = google_bigquery_dataset.governed.dataset_id
}

output "audit_dataset" {
  value = google_bigquery_dataset.audit.dataset_id
}
