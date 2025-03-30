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

        response = requests.post(
            AIRFLOW_URL,
            auth=AIRFLOW_AUTH,
            headers={"Content-Type": "application/json"},
            json={"conf": json.loads(payload)}
        )

        print(f"Status: {response.status_code}, body: {response.text}")
    except Exception as e:
        print(f"Erreur: {e}")
        raise
