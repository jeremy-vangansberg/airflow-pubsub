#!/bin/bash

set -e

PROJECT_ID="illicado-demo"
SERVICE_ACCOUNT_NAME="airflow-service-account"
SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"
KEY_PATH="./airflow/config/gcp.json"

echo "🔧 Configuration du projet : $PROJECT_ID"
gcloud config set project "$PROJECT_ID" > /dev/null

# 🔁 Supprimer clé existante
if [ -f "$KEY_PATH" ]; then
  echo "🧹 Suppression de la clé existante à $KEY_PATH"
  rm -f "$KEY_PATH"
fi

# 🗑️ Supprimer compte si existe déjà
if gcloud iam service-accounts describe "$SERVICE_ACCOUNT_EMAIL" > /dev/null 2>&1; then
  echo "🗑️ Suppression du compte de service existant : $SERVICE_ACCOUNT_EMAIL"
  gcloud iam service-accounts delete "$SERVICE_ACCOUNT_EMAIL" --quiet
fi

# 👤 Création du compte
echo "👤 Création du compte de service '$SERVICE_ACCOUNT_NAME'"
gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" \
  --description="Compte pour Airflow" \
  --display-name="Airflow Service Account"

# 🕒 Attendre que le compte soit disponible
echo "⏳ Attente de la propagation du compte..."
RETRY=0
MAX_RETRY=10
until gcloud iam service-accounts describe "$SERVICE_ACCOUNT_EMAIL" > /dev/null 2>&1; do
  sleep 2
  RETRY=$((RETRY + 1))
  if [ "$RETRY" -ge "$MAX_RETRY" ]; then
    echo "❌ Le compte de service n’est toujours pas disponible après $MAX_RETRY tentatives."
    exit 1
  fi
done

# 🔐 Attribution des rôles
echo "🔐 Attribution des rôles..."
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role="roles/pubsub.subscriber" --quiet

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role="roles/bigquery.dataEditor" --quiet

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role="roles/bigquery.jobUser" --quiet

# 💾 Génération de la clé
echo "💾 Génération de la clé à $KEY_PATH"
mkdir -p "$(dirname "$KEY_PATH")"

gcloud iam service-accounts keys create "$KEY_PATH" \
  --iam-account="$SERVICE_ACCOUNT_EMAIL"

echo "✅ Clé générée avec succès : $KEY_PATH"
