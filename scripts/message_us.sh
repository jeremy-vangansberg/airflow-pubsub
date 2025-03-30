gcloud pubsub topics publish giftcard-transactions \
  --message='{
    "transaction_id": "US001",
    "amount": 124,
    "currency": "USD",
    "region": "US",
    "purchase_date": "2025-04-01T12:15:00Z"
  }'
