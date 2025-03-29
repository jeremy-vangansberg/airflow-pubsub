terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.8.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Pub/Sub Topics
resource "google_pubsub_topic" "giftcard_transactions" {
  name    = "giftcard-transactions"
  project = var.project_id
}

resource "google_pubsub_topic" "marketing_notifications" {
  name    = "marketing-notifications"
  project = var.project_id
}

# Pub/Sub Subscriptions
resource "google_pubsub_subscription" "giftcard_transactions_sub" {
  name    = "giftcard-transactions-sub"
  topic   = google_pubsub_topic.giftcard_transactions.name
  project = var.project_id
}

# BigQuery Dataset
resource "google_bigquery_dataset" "giftcard_transactions" {
  dataset_id                  = "giftcard_transactions"
  project                     = var.project_id
  location                    = var.region
  delete_contents_on_destroy  = true
}

# BigQuery Tables
resource "google_bigquery_table" "transactions_eu" {
  dataset_id = google_bigquery_dataset.giftcard_transactions.dataset_id
  table_id   = "transactions_eu"
  project    = var.project_id

  schema = <<EOF
[
  {
    "name": "card_id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "region",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "amount",
    "type": "INTEGER",
    "mode": "REQUIRED"
  },
  {
    "name": "currency",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "purchase_date",
    "type": "TIMESTAMP",
    "mode": "REQUIRED"
  },
  {
    "name": "expiry_date",
    "type": "TIMESTAMP",
    "mode": "REQUIRED"
  }
]
EOF
}

resource "google_bigquery_table" "transactions_us" {
  dataset_id = google_bigquery_dataset.giftcard_transactions.dataset_id
  table_id   = "transactions_us"
  project    = var.project_id

  schema = <<EOF
[
  {
    "name": "card_id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "region",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "amount",
    "type": "INTEGER",
    "mode": "REQUIRED"
  },
  {
    "name": "currency",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "purchase_date",
    "type": "TIMESTAMP",
    "mode": "REQUIRED"
  },
  {
    "name": "expiry_date",
    "type": "TIMESTAMP",
    "mode": "REQUIRED"
  }
]
EOF
}

resource "google_bigquery_table" "transactions_global" {
  dataset_id = google_bigquery_dataset.giftcard_transactions.dataset_id
  table_id   = "transactions_global"
  project    = var.project_id

  schema = <<EOF
[
  {
    "name": "card_id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "region",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "amount",
    "type": "INTEGER",
    "mode": "REQUIRED"
  },
  {
    "name": "currency",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "purchase_date",
    "type": "TIMESTAMP",
    "mode": "REQUIRED"
  },
  {
    "name": "expiry_date",
    "type": "TIMESTAMP",
    "mode": "REQUIRED"
  },
  {
    "name": "consolidation_date",
    "type": "TIMESTAMP",
    "mode": "REQUIRED"
  }
]
EOF
}
