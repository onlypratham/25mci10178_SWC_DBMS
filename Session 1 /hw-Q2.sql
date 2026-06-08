WITH purchases AS (
    SELECT 
        transaction_id,
        transaction_date,
        amount
    FROM product_sales
    WHERE product_id = 'PROD-2891'
      AND country = 'US'
      AND type = 'purchase'
      AND status = 'completed'
      AND transaction_date BETWEEN '2025-04-15' AND '2025-04-28'
),

transactions AS (
    
    -- purchases
    SELECT 
        transaction_date,
        amount
    FROM purchases

    UNION ALL

    -- refunds
    SELECT
        r.transaction_date,
        -r.amount
    FROM product_sales r
    JOIN purchases p
      ON r.original_transaction_id = p.transaction_id
    WHERE r.type = 'refund'
      AND r.status = 'completed'
)

SELECT
    d::date AS transaction_date,
    COALESCE(ROUND(SUM(t.amount)::numeric,2),0) AS daily_net_revenue
FROM generate_series(
        '2025-04-15'::date,
        '2025-04-28'::date,
        '1 day'
     ) d
LEFT JOIN transactions t
ON d = t.transaction_date
GROUP BY d
ORDER BY d;
