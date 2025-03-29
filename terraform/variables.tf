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
