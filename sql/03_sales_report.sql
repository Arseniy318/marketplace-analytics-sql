-- ============================================
-- 1. Еженедельный отчёт по продажам и возвратам
-- ============================================
SELECT 
    DATE_TRUNC('week', invoice_date) AS week,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(CASE WHEN quantity > 0 THEN quantity * unit_price ELSE 0 END) AS revenue,
    SUM(CASE WHEN quantity < 0 THEN ABS(quantity * unit_price) ELSE 0 END) AS refunds,
    SUM(quantity * unit_price) AS net_revenue
FROM marketplace_orders
WHERE customer_id IS NOT NULL
GROUP BY DATE_TRUNC('week', invoice_date)
ORDER BY week;

-- ============================================
-- 2. Materialized View для ускорения отчёта
-- ============================================
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_weekly_sales AS
SELECT 
    DATE_TRUNC('week', invoice_date) AS week,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(quantity * unit_price) AS net_revenue,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM marketplace_orders
WHERE customer_id IS NOT NULL
GROUP BY DATE_TRUNC('week', invoice_date);

-- Индекс на Materialized View
CREATE INDEX IF NOT EXISTS idx_mv_week ON mv_weekly_sales(week);

-- Обновление данных (запускать раз в неделю)
REFRESH MATERIALIZED VIEW mv_weekly_sales;

-- Быстрый запрос из готовой витрины
SELECT * FROM mv_weekly_sales ORDER BY week DESC LIMIT 10;
