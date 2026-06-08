WITH partitioned_transactions AS (
  SELECT 
    transaction_timestamp,
    LAG(transaction_timestamp) OVER(
      PARTITION BY merchant_id, credit_card_id, amount 
      ORDER BY transaction_timestamp
    ) AS prev_transaction_timestamp
  FROM transactions
)

SELECT COUNT(*) AS payment_count
FROM partitioned_transactions
WHERE transaction_timestamp - prev_transaction_timestamp <= INTERVAL '10 minutes';
