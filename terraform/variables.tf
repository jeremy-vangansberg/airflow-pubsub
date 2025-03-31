variable "project_id" {
  description = "ID du projet GCP"
  type        = string
  default     = "illicado-demo"
}

variable "region" {
  description = "Région GCP pour le déploiement"
  type        = string
  default     = "europe-west1"
}

variable "service_account_name" {
  default = "airflow-service-account"
}

variable "key_path" {
  default = "../airflow/config/gcp.json"
}