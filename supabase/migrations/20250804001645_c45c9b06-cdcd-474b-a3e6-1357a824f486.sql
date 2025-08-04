-- =====================================================
-- СИСТЕМА ЧАСТИЧНОГО ФОРМИРОВАНИЯ ОБЩЕЙ БАЗЫ ДАННЫХ
-- Создание всех необходимых таблиц и функций
-- =====================================================

-- =====================================================
-- 1. ДОПОЛНИТЕЛЬНЫЕ ТАБЛИЦЫ ДЛЯ ИСТОЧНИКОВ ДАННЫХ
-- =====================================================

-- Таблица для sales reports (VendHub)
CREATE TABLE IF NOT EXISTS sales_reports (
    id SERIAL PRIMARY KEY,
    report_id INTEGER,
    order_number VARCHAR(255),
    goods_id INTEGER,
    time_value DECIMAL(15,11),
    goods_name VARCHAR(255),
    order_price DECIMAL(12,2),
    ikpu_code VARCHAR(50),
    barcode VARCHAR(255),
    marking VARCHAR(255),
    order_resource VARCHAR(100),
    payment_type VARCHAR(100),
    machine_category VARCHAR(100),
    machine_code VARCHAR(50),
    accrued_bonus DECIMAL(10,2),
    username VARCHAR(255),
    formatted_time TIMESTAMP,
    source_file_id INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Таблица для фискальных чеков
CREATE TABLE IF NOT EXISTS fiscal_receipts (
    id SERIAL PRIMARY KEY,
    receipt_number VARCHAR(50),
    fiscal_module VARCHAR(100),
    recipe_number VARCHAR(50),
    operation_type VARCHAR(100),
    cashier VARCHAR(255),
    trade_point VARCHAR(255),
    operation_amount DECIMAL(12,2),
    cash_amount DECIMAL(12,2),
    card_amount DECIMAL(12,2),
    customer_info TEXT,
    operation_datetime TIMESTAMP,
    source_file_id INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Таблица для платежей Payme
CREATE TABLE IF NOT EXISTS payme_payments (
    id SERIAL PRIMARY KEY,
    provider_name VARCHAR(255),
    cashbox_name VARCHAR(255),
    payment_state VARCHAR(100),
    payment_time TIMESTAMP,
    cancel_time TIMESTAMP,
    processing_operation_time TIMESTAMP,
    bank_operation_time TIMESTAMP,
    state VARCHAR(100),
    processing_name VARCHAR(255),
    epos_merchant_id VARCHAR(100),
    epos_terminal_id VARCHAR(100),
    card_number VARCHAR(50),
    amount_without_commission DECIMAL(12,2),
    client_commission VARCHAR(50),
    payment_system_id VARCHAR(255),
    provider_payment_id VARCHAR(255),
    rrn VARCHAR(50),
    cashbox_id VARCHAR(255),
    cashbox_identifier VARCHAR(255),
    bank_receipt_date DATE,
    fiscal_receipt_id VARCHAR(255),
    external_id VARCHAR(255),
    payment_description TEXT,
    order_number VARCHAR(255),
    source_file_id INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Таблица для платежей Click
CREATE TABLE IF NOT EXISTS click_payments (
    id SERIAL PRIMARY KEY,
    payment_date TIMESTAMP,
    service_name VARCHAR(255),
    client_info VARCHAR(255),
    payment_method VARCHAR(255),
    amount DECIMAL(12,2),
    identifier VARCHAR(255),
    cashbox VARCHAR(255),
    click_id VARCHAR(50),
    billing_id VARCHAR(50),
    payment_status VARCHAR(100),
    source_file_id INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Таблица для платежей Uzum
CREATE TABLE IF NOT EXISTS uzum_payments (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(255),
    amount DECIMAL(12,2),
    commission DECIMAL(12,2),
    card_type VARCHAR(50),
    card_number VARCHAR(50),
    status VARCHAR(100),
    merchant_id VARCHAR(100),
    receipt_id VARCHAR(255),
    parsed_datetime TIMESTAMP,
    source_file_id INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Таблица для логирования изменений
CREATE TABLE IF NOT EXISTS order_changes (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(100),
    record_id BIGINT,
    order_number VARCHAR(255),
    field_name VARCHAR(100),
    old_value TEXT,
    new_value TEXT,
    change_type VARCHAR(50),
    change_reason TEXT,
    source_file_id INTEGER,
    changed_at TIMESTAMP DEFAULT NOW(),
    changed_by UUID REFERENCES auth.users(id)
);

-- =====================================================
-- 2. РАСШИРЕНИЕ ТАБЛИЦЫ UNIFIED_ORDERS
-- =====================================================

-- Добавляем новые поля для всех источников данных
ALTER TABLE unified_orders 
ADD COLUMN IF NOT EXISTS vhr_id INTEGER,
ADD COLUMN IF NOT EXISTS vhr_time TIMESTAMP,
ADD COLUMN IF NOT EXISTS vhr_ikpu_code VARCHAR(50),
ADD COLUMN IF NOT EXISTS vhr_barcode VARCHAR(255),
ADD COLUMN IF NOT EXISTS vhr_marking VARCHAR(255),
ADD COLUMN IF NOT EXISTS vhr_payment_type VARCHAR(100),
ADD COLUMN IF NOT EXISTS vhr_username VARCHAR(255),
ADD COLUMN IF NOT EXISTS vhr_accrued_bonus DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS vhr_machine_category VARCHAR(100);

-- Поля для фискальных чеков
ALTER TABLE unified_orders 
ADD COLUMN IF NOT EXISTS fiscal_receipt_number VARCHAR(50),
ADD COLUMN IF NOT EXISTS fiscal_module VARCHAR(100),
ADD COLUMN IF NOT EXISTS fiscal_recipe_number VARCHAR(50),
ADD COLUMN IF NOT EXISTS fiscal_operation_type VARCHAR(100),
ADD COLUMN IF NOT EXISTS fiscal_cashier VARCHAR(255),
ADD COLUMN IF NOT EXISTS fiscal_trade_point VARCHAR(255),
ADD COLUMN IF NOT EXISTS fiscal_operation_amount DECIMAL(12,2),
ADD COLUMN IF NOT EXISTS fiscal_cash_amount DECIMAL(12,2),
ADD COLUMN IF NOT EXISTS fiscal_card_amount DECIMAL(12,2),
ADD COLUMN IF NOT EXISTS fiscal_customer_info TEXT,
ADD COLUMN IF NOT EXISTS fiscal_operation_datetime TIMESTAMP;

-- Поля для Payme
ALTER TABLE unified_orders 
ADD COLUMN IF NOT EXISTS payme_provider_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS payme_cashbox_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS payme_payment_state VARCHAR(100),
ADD COLUMN IF NOT EXISTS payme_payment_time TIMESTAMP,
ADD COLUMN IF NOT EXISTS payme_processing_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS payme_card_number VARCHAR(50),
ADD COLUMN IF NOT EXISTS payme_amount_without_commission DECIMAL(12,2),
ADD COLUMN IF NOT EXISTS payme_client_commission DECIMAL(12,2),
ADD COLUMN IF NOT EXISTS payme_payment_system_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS payme_provider_payment_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS payme_rrn VARCHAR(50),
ADD COLUMN IF NOT EXISTS payme_fiscal_receipt_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS payme_order_number VARCHAR(255);

-- Поля для Click
ALTER TABLE unified_orders 
ADD COLUMN IF NOT EXISTS click_id VARCHAR(50),
ADD COLUMN IF NOT EXISTS click_billing_id VARCHAR(50),
ADD COLUMN IF NOT EXISTS click_identifier VARCHAR(255),
ADD COLUMN IF NOT EXISTS click_service_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS click_client_info VARCHAR(255),
ADD COLUMN IF NOT EXISTS click_payment_method VARCHAR(255),
ADD COLUMN IF NOT EXISTS click_amount DECIMAL(12,2),
ADD COLUMN IF NOT EXISTS click_payment_status VARCHAR(100),
ADD COLUMN IF NOT EXISTS click_cashbox VARCHAR(255),
ADD COLUMN IF NOT EXISTS click_payment_date TIMESTAMP;

-- Поля для Uzum
ALTER TABLE unified_orders 
ADD COLUMN IF NOT EXISTS uzum_service_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS uzum_amount DECIMAL(12,2),
ADD COLUMN IF NOT EXISTS uzum_commission DECIMAL(12,2),
ADD COLUMN IF NOT EXISTS uzum_card_type VARCHAR(50),
ADD COLUMN IF NOT EXISTS uzum_card_number VARCHAR(50),
ADD COLUMN IF NOT EXISTS uzum_status VARCHAR(100),
ADD COLUMN IF NOT EXISTS uzum_merchant_id VARCHAR(100),
ADD COLUMN IF NOT EXISTS uzum_receipt_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS uzum_parsed_datetime TIMESTAMP;