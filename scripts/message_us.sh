gcloud pubsub topics publish giftcard-transactions \
  --message='{
    "transaction_id": "US002",
    "amount": 120,
    "currency": "USD",
    "region": "US",
    "purchase_date": "2025-03-29T12:05:00Z"
  }'
