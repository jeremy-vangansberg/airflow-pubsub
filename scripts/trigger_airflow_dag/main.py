import base64
import requests
import json
import os

AIRFLOW_URL = os.getenv("AIRFLOW_URL")

AIRFLOW_AUTH = (os.getenv("AIRFLOW_USER"), os.getenv("AIRFLOW_PASS"))  # identifiants Airflow

def trigger_dag(event, context):
    try:
        payload = base64.b64decode(event["data"]).decode("utf-8")
        print(f"Payload reçu: {payload}")

        # On ignore volontairement le message si un champ est manquant
        try:
            conf = json.loads(payload)
        except Exception as parse_err:
            print(f"⚠️ Message invalide ignoré: {parse_err}")
            return  # ✅ terminé = ack automatique

        response = requests.post(
            AIRFLOW_URL,
            auth=AIRFLOW_AUTH,
            headers={"Content-Type": "application/json"},
            json={"conf": conf}
        )

        print(f"Status: {response.status_code}, body: {response.text}")

    except Exception as e:
        print(f"❌ Erreur générale: {e}")
        raise  # ❌ provoque un échec → pas ack → retry du message
