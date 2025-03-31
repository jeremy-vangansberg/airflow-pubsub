from airflow.decorators import dag
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from airflow.datasets import Dataset
from airflow.hooks.base import BaseHook
from datetime import datetime
from airflow.models import Variable


PROJECT_ID = Variable.get("project-id")

eu_dataset = Dataset(f"bq://{PROJECT_ID}.giftcard_transactions.transactions_eu")
us_dataset = Dataset(f"bq://{PROJECT_ID}.giftcard_transactions.transactions_us")

@dag(
    dag_id="giftcard_consolidation_dag",
    start_date=datetime(2024, 1, 1),
    schedule=[eu_dataset, us_dataset],
    catchup=False,
    tags=["giftcard", "bigquery", "consolidation"]
)
def giftcard_consolidation():
    
    sql_consolidation = f"""
    INSERT INTO `illicado-demo.giftcard_transactions.transactions_global`
    WITH deduplicated AS (
        SELECT *
        FROM (
            SELECT *,
                ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY purchase_date DESC) AS row_num
            FROM (
                SELECT * FROM `illicado-demo.giftcard_transactions.transactions_eu`
                UNION ALL
                SELECT * FROM `illicado-demo.giftcard_transactions.transactions_us`
            )
        )
        WHERE row_num = 1
    )
    SELECT card_id, region, amount, currency, purchase_date, expiry_date
    FROM deduplicated
    """

    consolidate_transactions = BigQueryInsertJobOperator(
        task_id="consolidate_transactions",
        project_id=PROJECT_ID,
        gcp_conn_id='gcp-id',
        configuration={
            "query": {
                "query": sql_consolidation,
                "useLegacySql": False,
            }
        }
    )

giftcard_consolidation()
