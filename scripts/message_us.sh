gcloud pubsub topics publish giftcard-transactions \
  --message='{
    "transaction_id": "US005",
    "amount": 121,
    "currency": "USD",
    "region": "US",
    "purchase_date": "2025-04-01T12:15:00Z"
  }'
