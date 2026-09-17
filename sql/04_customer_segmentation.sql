-- ============================================
-- RFM-анализ клиентов (Recency, Frequency, Monetary)
-- ============================================
WITH reference_date AS (
    SELECT MAX(invoice_date) + INTERVAL '1 day' AS ref_date
    FROM marketplace_orders
),
customer_metrics AS (
    SELECT 
        o.customer_id,
        EXTRACT(DAY FROM r.ref_date - MAX(o.invoice_date)) AS recency_days,
        COUNT(DISTINCT o.invoice_no) AS frequency,
        SUM(o.quantity * o.unit_price) AS monetary
    FROM marketplace_orders o
    CROSS JOIN reference_date r
    WHERE o.customer_id IS NOT NULL
      AND o.quantity > 0
    GROUP BY o.customer_id, r.ref_date
),
segmented AS (
    SELECT 
        customer_id,
        recency_days,
        frequency,
        ROUND(monetary::numeric, 2) AS monetary,
        NTILE(4) OVER (ORDER BY recency_days)  AS r_score,
        NTILE(4) OVER (ORDER BY frequency)     AS f_score,
        NTILE(4) OVER (ORDER BY monetary)      AS m_score
    FROM customer_metrics
)
SELECT 
    customer_id,
    recency_days,
    frequency,
    monetary,
    CASE 
        WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN '⭐ Champions'
        WHEN r_score <= 2 AND f_score >= 2                  THEN '💎 Loyal'
        WHEN r_score <= 2 AND f_score = 1                   THEN '🆕 New'
        WHEN r_score >= 3 AND f_score >= 2                  THEN '⚠️ Need Attention'
        WHEN r_score >= 3 AND f_score = 1                   THEN '💤 Lost'
        ELSE '🔘 Others'
    END AS segment
FROM segmented
ORDER BY monetary DESC;
