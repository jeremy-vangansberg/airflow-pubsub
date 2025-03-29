output "pubsub_topic" {
  description = "Nom du topic Pub/Sub pour les transactions"
  value       = google_pubsub_topic.giftcard_transactions.name
}

output "pubsub_subscription" {
  description = "Nom de la subscription Pub/Sub"
  value       = google_pubsub_subscription.giftcard_transactions_sub.name
}

output "bigquery_dataset" {
  description = "ID du dataset BigQuery"
  value       = google_bigquery_dataset.giftcard_transactions.dataset_id
}

output "bigquery_tables" {
  description = "Noms des tables BigQuery"
  value = {
    eu     = google_bigquery_table.transactions_eu.table_id
    us     = google_bigquery_table.transactions_us.table_id
    global = google_bigquery_table.transactions_global.table_id
  }
} 