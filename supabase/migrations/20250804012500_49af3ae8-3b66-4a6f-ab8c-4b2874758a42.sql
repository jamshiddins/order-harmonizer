-- =====================================================
-- ПОЛНАЯ СИСТЕМА ЧАСТИЧНОГО ФОРМИРОВАНИЯ ОБЩЕЙ БАЗЫ ДАННЫХ
-- =====================================================

-- =====================================================
-- 1. ДОБАВЛЯЕМ НОВЫЕ СТОЛБЦЫ В UNIFIED_ORDERS
-- =====================================================

-- Расширяем unified_orders для поддержки всех источников данных
ALTER TABLE public.unified_orders 
ADD COLUMN IF NOT EXISTS vhr_id INTEGER,
ADD COLUMN IF NOT EXISTS vhr_time TIMESTAMP,
ADD COLUMN IF NOT EXISTS vhr_ikpu_code VARCHAR(50),
ADD COLUMN IF NOT EXISTS vhr_barcode VARCHAR(100),
ADD COLUMN IF NOT EXISTS vhr_marking VARCHAR(100),
ADD COLUMN IF NOT EXISTS vhr_payment_type VARCHAR(50),
ADD COLUMN IF NOT EXISTS vhr_username VARCHAR(100),
ADD COLUMN IF NOT EXISTS vhr_accrued_bonus DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS vhr_machine_category VARCHAR(100),

-- Поля для фискальных чеков
ADD COLUMN IF NOT EXISTS fiscal_receipt_number VARCHAR(50),
ADD COLUMN IF NOT EXISTS fiscal_module VARCHAR(100),
ADD COLUMN IF NOT EXISTS fiscal_recipe_number VARCHAR(50),
ADD COLUMN IF NOT EXISTS fiscal_operation_type VARCHAR(50),
ADD COLUMN IF NOT EXISTS fiscal_cashier VARCHAR(100),
ADD COLUMN IF NOT EXISTS fiscal_trade_point VARCHAR(100),
ADD COLUMN IF NOT EXISTS fiscal_operation_amount DECIMAL(12,2),
ADD COLUMN IF NOT EXISTS fiscal_cash_amount DECIMAL(12,2),
ADD COLUMN IF NOT EXISTS fiscal_card_amount DECIMAL(12,2),
ADD COLUMN IF NOT EXISTS fiscal_customer_info VARCHAR(255),
ADD COLUMN IF NOT EXISTS fiscal_operation_datetime TIMESTAMP,

-- Поля для платежей Payme
ADD COLUMN IF NOT EXISTS payme_provider_name VARCHAR(100),
ADD COLUMN IF NOT EXISTS payme_cashbox_name VARCHAR(100),
ADD COLUMN IF NOT EXISTS payme_payment_state VARCHAR(50),
ADD COLUMN IF NOT EXISTS payme_payment_time TIMESTAMP,
ADD COLUMN IF NOT EXISTS payme_processing_name VARCHAR(100),
ADD COLUMN IF NOT EXISTS payme_card_number VARCHAR(50),
ADD COLUMN IF NOT EXISTS payme_amount_without_commission DECIMAL(12,2),
ADD COLUMN IF NOT EXISTS payme_client_commission DECIMAL(12,2),
ADD COLUMN IF NOT EXISTS payme_payment_system_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS payme_provider_payment_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS payme_rrn VARCHAR(50),
ADD COLUMN IF NOT EXISTS payme_fiscal_receipt_id VARCHAR(100),
ADD COLUMN IF NOT EXISTS payme_order_number VARCHAR(255),

-- Поля для платежей Click
ADD COLUMN IF NOT EXISTS click_id VARCHAR(50),
ADD COLUMN IF NOT EXISTS click_billing_id VARCHAR(50),
ADD COLUMN IF NOT EXISTS click_identifier VARCHAR(100),
ADD COLUMN IF NOT EXISTS click_service_name VARCHAR(100),
ADD COLUMN IF NOT EXISTS click_client_info VARCHAR(100),
ADD COLUMN IF NOT EXISTS click_payment_method VARCHAR(100),
ADD COLUMN IF NOT EXISTS click_amount DECIMAL(12,2),
ADD COLUMN IF NOT EXISTS click_payment_status VARCHAR(50),
ADD COLUMN IF NOT EXISTS click_cashbox VARCHAR(100),
ADD COLUMN IF NOT EXISTS click_payment_date TIMESTAMP,

-- Поля для платежей Uzum
ADD COLUMN IF NOT EXISTS uzum_service_name VARCHAR(100),
ADD COLUMN IF NOT EXISTS uzum_amount DECIMAL(12,2),
ADD COLUMN IF NOT EXISTS uzum_commission DECIMAL(12,2),
ADD COLUMN IF NOT EXISTS uzum_card_type VARCHAR(50),
ADD COLUMN IF NOT EXISTS uzum_card_number VARCHAR(50),
ADD COLUMN IF NOT EXISTS uzum_status VARCHAR(50),
ADD COLUMN IF NOT EXISTS uzum_merchant_id VARCHAR(100),
ADD COLUMN IF NOT EXISTS uzum_receipt_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS uzum_parsed_datetime TIMESTAMP;

-- =====================================================
-- 2. СОЗДАЕМ ДОПОЛНИТЕЛЬНЫЕ ТАБЛИЦЫ
-- =====================================================

-- Таблица для отчетов продаж (VendHub)
CREATE TABLE IF NOT EXISTS public.sales_reports (
    id SERIAL PRIMARY KEY,
    report_id INTEGER NOT NULL,
    order_number VARCHAR(255),
    goods_id INTEGER,
    formatted_time TIMESTAMP,
    goods_name VARCHAR(255),
    order_price DECIMAL(12,2),
    ikpu_code VARCHAR(50),
    barcode VARCHAR(100),
    marking VARCHAR(100),
    order_resource VARCHAR(50),
    payment_type VARCHAR(50),
    machine_category VARCHAR(100),
    machine_code VARCHAR(50),
    accrued_bonus DECIMAL(10,2),
    username VARCHAR(100),
    source_file_id INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Таблица для фискальных чеков
CREATE TABLE IF NOT EXISTS public.fiscal_receipts (
    id SERIAL PRIMARY KEY,
    receipt_number VARCHAR(50) NOT NULL,
    fiscal_module VARCHAR(100),
    recipe_number VARCHAR(50),
    operation_type VARCHAR(50),
    cashier VARCHAR(100),
    trade_point VARCHAR(100),
    operation_amount DECIMAL(12,2),
    cash_amount DECIMAL(12,2),
    card_amount DECIMAL(12,2),
    customer_info VARCHAR(255),
    operation_datetime TIMESTAMP,
    source_file_id INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Таблица для платежей Payme
CREATE TABLE IF NOT EXISTS public.payme_payments (
    id SERIAL PRIMARY KEY,
    provider_name VARCHAR(100),
    cashbox_name VARCHAR(100),
    payment_state VARCHAR(50),
    payment_time TIMESTAMP,
    processing_name VARCHAR(100),
    card_number VARCHAR(50),
    amount_without_commission DECIMAL(12,2),
    client_commission DECIMAL(12,2),
    payment_system_id VARCHAR(255) NOT NULL,
    provider_payment_id VARCHAR(255),
    rrn VARCHAR(50),
    fiscal_receipt_id VARCHAR(100),
    order_number VARCHAR(255),
    source_file_id INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Таблица для платежей Click
CREATE TABLE IF NOT EXISTS public.click_payments (
    id SERIAL PRIMARY KEY,
    click_id VARCHAR(50) NOT NULL,
    billing_id VARCHAR(50),
    identifier VARCHAR(100),
    service_name VARCHAR(100),
    client_info VARCHAR(100),
    payment_method VARCHAR(100),
    amount DECIMAL(12,2),
    payment_status VARCHAR(50),
    cashbox VARCHAR(100),
    payment_date TIMESTAMP,
    source_file_id INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Таблица для платежей Uzum
CREATE TABLE IF NOT EXISTS public.uzum_payments (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(100),
    amount DECIMAL(12,2),
    commission DECIMAL(12,2),
    card_type VARCHAR(50),
    card_number VARCHAR(50),
    status VARCHAR(50),
    merchant_id VARCHAR(100),
    receipt_id VARCHAR(255) NOT NULL,
    parsed_datetime TIMESTAMP,
    source_file_id INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Таблица для логирования изменений
CREATE TABLE IF NOT EXISTS public.order_changes (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
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
-- 3. СОЗДАЕМ ИНДЕКСЫ ДЛЯ ПРОИЗВОДИТЕЛЬНОСТИ
-- =====================================================

-- Индексы для unified_orders
CREATE INDEX IF NOT EXISTS idx_unified_orders_order_number ON public.unified_orders(order_number);
CREATE INDEX IF NOT EXISTS idx_unified_orders_machine_code ON public.unified_orders(machine_code);
CREATE INDEX IF NOT EXISTS idx_unified_orders_order_price ON public.unified_orders(order_price);
CREATE INDEX IF NOT EXISTS idx_unified_orders_creation_time ON public.unified_orders(creation_time);
CREATE INDEX IF NOT EXISTS idx_unified_orders_is_temporary ON public.unified_orders(is_temporary);
CREATE INDEX IF NOT EXISTS idx_unified_orders_match_score ON public.unified_orders(match_score);

-- Индексы для source таблиц
CREATE INDEX IF NOT EXISTS idx_sales_reports_order_number ON public.sales_reports(order_number);
CREATE INDEX IF NOT EXISTS idx_sales_reports_formatted_time ON public.sales_reports(formatted_time);
CREATE INDEX IF NOT EXISTS idx_sales_reports_order_price ON public.sales_reports(order_price);

CREATE INDEX IF NOT EXISTS idx_fiscal_receipts_operation_datetime ON public.fiscal_receipts(operation_datetime);
CREATE INDEX IF NOT EXISTS idx_fiscal_receipts_operation_amount ON public.fiscal_receipts(operation_amount);

CREATE INDEX IF NOT EXISTS idx_payme_payments_payment_time ON public.payme_payments(payment_time);
CREATE INDEX IF NOT EXISTS idx_payme_payments_amount ON public.payme_payments(amount_without_commission);

CREATE INDEX IF NOT EXISTS idx_click_payments_payment_date ON public.click_payments(payment_date);
CREATE INDEX IF NOT EXISTS idx_click_payments_amount ON public.click_payments(amount);

CREATE INDEX IF NOT EXISTS idx_uzum_payments_parsed_datetime ON public.uzum_payments(parsed_datetime);
CREATE INDEX IF NOT EXISTS idx_uzum_payments_amount ON public.uzum_payments(amount);

-- =====================================================
-- 4. НАСТРАИВАЕМ RLS ПОЛИТИКИ
-- =====================================================

-- Включаем RLS для всех новых таблиц
ALTER TABLE public.sales_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fiscal_receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payme_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.click_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.uzum_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_changes ENABLE ROW LEVEL SECURITY;

-- Политики для sales_reports
CREATE POLICY "Authenticated users can view sales reports" ON public.sales_reports
FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Operators can manage sales reports" ON public.sales_reports
FOR ALL USING (has_role(auth.uid(), 'operator'));

-- Политики для fiscal_receipts  
CREATE POLICY "Authenticated users can view fiscal receipts" ON public.fiscal_receipts
FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Operators can manage fiscal receipts" ON public.fiscal_receipts
FOR ALL USING (has_role(auth.uid(), 'operator'));

-- Политики для payme_payments
CREATE POLICY "Authenticated users can view payme payments" ON public.payme_payments
FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Operators can manage payme payments" ON public.payme_payments
FOR ALL USING (has_role(auth.uid(), 'operator'));

-- Политики для click_payments
CREATE POLICY "Authenticated users can view click payments" ON public.click_payments
FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Operators can manage click payments" ON public.click_payments
FOR ALL USING (has_role(auth.uid(), 'operator'));

-- Политики для uzum_payments
CREATE POLICY "Authenticated users can view uzum payments" ON public.uzum_payments
FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Operators can manage uzum payments" ON public.uzum_payments
FOR ALL USING (has_role(auth.uid(), 'operator'));

-- Политики для order_changes
CREATE POLICY "Authenticated users can view order changes" ON public.order_changes
FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Operators can manage order changes" ON public.order_changes
FOR ALL USING (has_role(auth.uid(), 'operator'));

-- =====================================================
-- 5. СОЗДАЕМ ТРИГГЕРЫ ДЛЯ АВТОМАТИЧЕСКОГО ОБНОВЛЕНИЯ
-- =====================================================

-- Триггер для updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Применяем триггеры ко всем таблицам
CREATE TRIGGER update_sales_reports_updated_at
    BEFORE UPDATE ON public.sales_reports
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_fiscal_receipts_updated_at
    BEFORE UPDATE ON public.fiscal_receipts
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_payme_payments_updated_at
    BEFORE UPDATE ON public.payme_payments
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_click_payments_updated_at
    BEFORE UPDATE ON public.click_payments
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_uzum_payments_updated_at
    BEFORE UPDATE ON public.uzum_payments
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();