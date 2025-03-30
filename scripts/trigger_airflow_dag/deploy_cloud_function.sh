#!/bin/bash

# Charger un fichier .env si tu veux
if [ -f .env ]; then
  echo "📦 Chargement des variables depuis .env"
  set -a
  source .env
  set +a
fi

echo "AIRFLOW_USER : ${AIRFLOW_USER}"
echo "AIRFLOW_PASS : ${AIRFLOW_PASS}"

# Récupérer dynamiquement l'URL publique d'ngrok
NGROK_URL=$(curl --silent http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[0].public_url')

if [[ "$NGROK_URL" == "null" || -z "$NGROK_URL" ]]; then
  echo "Erreur: Impossible de récupérer l'URL ngrok. Assure-toi qu'ngrok tourne bien."
  exit 1
fi

# Construire l'URL de l'API Airflow avec endpoint dagRun
AIRFLOW_ENDPOINT="${NGROK_URL}/api/v1/dags/giftcard_ingestion_dag/dagRuns"

# Affichage pour vérification
echo "URL ngrok détectée : $NGROK_URL"
echo "Déploiement Cloud Function avec endpoint : $AIRFLOW_ENDPOINT"

# Lancer le déploiement de la Cloud Function avec l'URL dynamique
gcloud functions deploy trigger_airflow_dag \
  --runtime python311 \
  --entry-point trigger_dag \
  --trigger-topic giftcard-transactions \
  --set-env-vars AIRFLOW_URL=${AIRFLOW_ENDPOINT},AIRFLOW_USER=${AIRFLOW_USER},AIRFLOW_PASS=${AIRFLOW_PASS} \
  --gen2 --region=us-central1

# Fin
echo "Déploiement lancé avec succès."