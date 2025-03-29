gcloud pubsub topics publish giftcard-transactions \
  --message='{
    "transaction_id": "EU001",
    "amount": 100,
    "currency": "EUR",
    "region": "EU",
    "purchase_date": "2025-03-29T12:00:00Z"
  }'
