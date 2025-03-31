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

# Pub/Sub Subscriptions
resource "google_pubsub_subscription" "giftcard_transactions_sub" {
  name    = "giftcard-transactions-sub"
  topic   = google_pubsub_topic.giftcard_transactions.name
  project = var.project_id
}

resource "google_pubsub_subscription" "marketing_notifications_sub" {
  name    = "marketing-notifications-sub"
  topic   = google_pubsub_topic.giftcard_transactions.name
  project = var.project_id
}

# BigQuery Dataset
resource "google_bigquery_dataset" "giftcard_transactions" {
  dataset_id                  = "giftcard_transactions"
  project                     = var.project_id
  location                    = var.region
  delete_contents_on_destroy  = false
}

# BigQuery Tables
resource "google_bigquery_table" "transactions_eu" {
  dataset_id = google_bigquery_dataset.giftcard_transactions.dataset_id
  table_id   = "transactions_eu"
  project    = var.project_id
  deletion_protection=false

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
  deletion_protection=false

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
  deletion_protection=false

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

# 👤 Service Account
resource "google_service_account" "airflow" {
  account_id   = var.service_account_name
  display_name = "Airflow Service Account"
  description  = "Compte pour Airflow"
  project      = var.project_id
}

# 🔐 Attribution des rôles IAM
resource "google_project_iam_member" "airflow_pubsub" {
  project = var.project_id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.airflow.email}"
}

resource "google_project_iam_member" "airflow_bq_data_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.airflow.email}"
}

resource "google_project_iam_member" "airflow_bq_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.airflow.email}"
}

# 🔑 Clé privée générée
resource "google_service_account_key" "airflow_key" {
  service_account_id = google_service_account.airflow.name
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

# 💾 Sauvegarde dans un fichier local (optionnel)
resource "local_file" "airflow_key_file" {
  content  = base64decode(google_service_account_key.airflow_key.private_key)
  filename = var.key_path
}
