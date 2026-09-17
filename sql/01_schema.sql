-- Создание таблицы продаж маркетплейса
CREATE TABLE IF NOT EXISTS marketplace_orders (
    invoice_no    VARCHAR(20),
    stock_code    VARCHAR(20),
    description   TEXT,
    quantity      INTEGER,
    invoice_date  TIMESTAMP,
    unit_price    DECIMAL(10, 2),
    customer_id   VARCHAR(20),
    country       VARCHAR(50)
);

-- Индексы для ускорения типовых запросов
CREATE INDEX IF NOT EXISTS idx_invoice_date ON marketplace_orders(invoice_date);
CREATE INDEX IF NOT EXISTS idx_customer_id  ON marketplace_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_country      ON marketplace_orders(country);
