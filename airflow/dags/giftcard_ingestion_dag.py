from airflow import DAG
from airflow.decorators import dag, task
from airflow.providers.google.cloud.operators.pubsub import PubSubPullOperator
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from airflow.datasets import Dataset
from airflow.models import Variable


from datetime import datetime, timedelta
import json
import base64

from airflow.hooks.base import BaseHook

PROJECT_ID = Variable.get("project-id")

# Datasets pour déclencher le DAG de consolidation
eu_dataset = Dataset(f"bq://{PROJECT_ID}.giftcard_transactions.transactions_eu")
us_dataset = Dataset(f"bq://{PROJECT_ID}.giftcard_transactions.transactions_us")

@dag(
    dag_id="giftcard_ingestion_dag",
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    tags=["giftcard", "pubsub", "ingestion"]
)
def giftcard_ingestion():

    pull_messages = PubSubPullOperator(
        task_id='pull_giftcard_messages',
        project_id=PROJECT_ID,
        subscription='giftcard-transactions-sub',
        max_messages=5,
        ack_messages=False,
        gcp_conn_id='gcp_id'
    )
    

    @task
    def transform_messages(**context):
            pulled_messages = context['ti'].xcom_pull(task_ids='pull_giftcard_messages')
            transformed = []
            if not pulled_messages:
                return transformed
            for msg in pulled_messages:
                try:
                    raw_data = msg['message']['data']
                    decoded_data = base64.b64decode(raw_data).decode('utf-8')
                    data = json.loads(decoded_data)
                    purchase_date = datetime.strptime(data['purchase_date'], "%Y-%m-%dT%H:%M:%SZ")
                    expiry_date = purchase_date + timedelta(days=365)
                    transformed.append({
                        "card_id": data["transaction_id"],
                        "region": data["region"],
                        "amount": int(data["amount"]),
                        "currency": data["currency"],
                        "purchase_date": data["purchase_date"],
                        "expiry_date": expiry_date.isoformat()
                    })
                except Exception as e:
                    print(f"Erreur de parsing message: {msg} - {e}")
            return transformed

    @task
    def build_sql(records):
        if not records:
            return ""
        print('------------------',PROJECT_ID)
        queries = []
        for row in records:
            table = "transactions_eu" if row["region"] == "EU" else "transactions_us"
            query = f"""
            INSERT INTO `{PROJECT_ID}.giftcard_transactions.{table}`
            (card_id, region, amount, currency, purchase_date, expiry_date)
            VALUES (
                '{row["card_id"]}', '{row["region"]}', {row["amount"]}, '{row["currency"]}',
                TIMESTAMP('{row["purchase_date"]}'), TIMESTAMP('{row["expiry_date"]}')
            )
            """
            queries.append(query.strip())
        return ";\n".join(queries)

    insert_query = BigQueryInsertJobOperator(
        task_id='insert_into_bigquery',
        gcp_conn_id='gcp_id',
        project_id=PROJECT_ID,
        configuration={
            "query": {
                "query": "{{ ti.xcom_pull(task_ids='build_sql') }}",
                "useLegacySql": False,
            }
        },
        outlets=[eu_dataset, us_dataset]  # permet de déclencher les DAGs dépendants
    )

    # Déroulé des tâches
    pulled = pull_messages
    transformed = transform_messages()
    query = build_sql(transformed)
    pulled >> transformed >> query >> insert_query


giftcard_ingestion()
