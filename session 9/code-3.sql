-- Y-on-Y Growth Rate
WITH yearly_spend AS (
  SELECT 
    EXTRACT(YEAR FROM transaction_date)::INTEGER AS year,
    product_id,
    SUM(spend) AS curr_year_spend
  FROM user_transactions
  GROUP BY EXTRACT(YEAR FROM transaction_date), product_id
),
lagged_spend AS (
  SELECT 
    year,
    product_id,
    curr_year_spend,
    LAG(curr_year_spend) OVER (
      PARTITION BY product_id 
      ORDER BY year
    ) AS prev_year_spend
  FROM yearly_spend
)
SELECT 
  year,
  product_id,
  curr_year_spend,
  prev_year_spend,
  ROUND(
    ((curr_year_spend - prev_year_spend) / prev_year_spend) * 100.0, 
    2
  ) AS yoy_rate
FROM lagged_spend
ORDER BY product_id, year;
