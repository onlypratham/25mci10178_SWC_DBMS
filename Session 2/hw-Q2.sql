WITH max_date AS (    
    SELECT MAX(event_timestamp) AS max_ts FROM search_events
),
session_clicks AS (
    SELECT 
        s.user_id,
        s.event_timestamp AS search_ts,
        MIN(c.event_timestamp) AS first_click_ts
    FROM search_events s
    LEFT JOIN search_events c 
      ON s.session_id = c.session_id 
     AND s.user_id = c.user_id
     AND c.event_type = 'click' 
     AND c.event_timestamp > s.event_timestamp
    WHERE s.event_type = 'search'
    GROUP BY s.user_id, s.event_id, s.event_timestamp
)
SELECT 
    CASE 
        WHEN a.registration_date >= (SELECT max_ts::date - 30 FROM max_date) THEN 'new'
        ELSE 'existing'
    END AS user_segment,
    COUNT(*) AS total_searches,
    COUNT(CASE WHEN sc.first_click_ts <= sc.search_ts + INTERVAL '30 seconds' THEN 1 END) AS successful_searches,
    ROUND(COUNT(CASE WHEN sc.first_click_ts <= sc.search_ts + INTERVAL '30 seconds' THEN 1 END)::numeric / COUNT(*), 4) AS success_rate
FROM session_clicks sc
JOIN accounts a ON sc.user_id = a.user_id
GROUP BY 1;
