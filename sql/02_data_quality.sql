-- ============================================
-- 1. Проверка качества данных
-- ============================================

-- Общая статистика по таблице
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT invoice_no) AS unique_invoices,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(CASE WHEN customer_id IS NULL THEN 1 END) AS rows_without_customer
FROM marketplace_orders;

-- ============================================
-- 2. Поиск дублей заказов (как в резюме)
-- ============================================
WITH duplicates AS (
    SELECT 
        invoice_no,
        stock_code,
        quantity,
        invoice_date,
        ROW_NUMBER() OVER (
            PARTITION BY invoice_no, stock_code, quantity, invoice_date 
            ORDER BY invoice_date
        ) AS rn
    FROM marketplace_orders
)
SELECT COUNT(*) AS duplicate_rows
FROM duplicates
WHERE rn > 1;

-- ============================================
-- 3. Удаление дублей (Data Quality fix)
-- ============================================
DELETE FROM marketplace_orders
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT ctid,
               ROW_NUMBER() OVER (
                   PARTITION BY invoice_no, stock_code, quantity, invoice_date 
                   ORDER BY ctid
               ) AS rn
        FROM marketplace_orders
    ) t
    WHERE t.rn > 1
);
