-- ============================================
-- 1. Сравнение выручки месяц к месяцу (MoM) через LAG/LEAD
-- ============================================
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', invoice_date) AS month,
        SUM(quantity * unit_price) AS revenue
    FROM marketplace_orders
    WHERE customer_id IS NOT NULL AND quantity > 0
    GROUP BY DATE_TRUNC('month', invoice_date)
)
SELECT 
    month,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND(LAG(revenue) OVER (ORDER BY month)::numeric, 2) AS prev_month_revenue,
    ROUND(LEAD(revenue) OVER (ORDER BY month)::numeric, 2) AS next_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0 
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 2
    ) AS mom_growth_pct
FROM monthly_revenue
ORDER BY month;

-- ============================================
-- 2. Топ-5 товаров по выручке в каждой стране (ROW_NUMBER)
-- ============================================
WITH country_product AS (
    SELECT 
        country,
        stock_code,
        description,
        SUM(quantity * unit_price) AS revenue
    FROM marketplace_orders
    WHERE customer_id IS NOT NULL AND quantity > 0
    GROUP BY country, stock_code, description
),
ranked AS (
    SELECT 
        country,
        stock_code,
        description,
        ROUND(revenue::numeric, 2) AS revenue,
        ROW_NUMBER() OVER (PARTITION BY country ORDER BY revenue DESC) AS rank
    FROM country_product
)
SELECT * FROM ranked
WHERE rank <= 5
ORDER BY country, rank;
