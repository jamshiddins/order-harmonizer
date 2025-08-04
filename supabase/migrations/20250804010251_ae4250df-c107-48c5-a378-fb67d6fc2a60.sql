-- =====================================================
-- ФУНКЦИИ ДЛЯ АВТОМАТИЧЕСКОГО СОПОСТАВЛЕНИЯ ДАННЫХ
-- =====================================================

-- Основная функция для добавления hardware_orders в unified_orders
CREATE OR REPLACE FUNCTION add_hardware_to_unified()
RETURNS TRIGGER AS $$
BEGIN
    -- Проверяем, есть ли уже запись (временная или постоянная)
    UPDATE unified_orders SET
        -- Основные поля из hardware_orders
        address = NEW.address,
        machine_code = NEW.machine_code,
        goods_name = NEW.goods_name,
        taste_name = NEW.taste_name,
        order_type = NEW.order_type,
        order_resource = NEW.order_resource,
        payment_status = NEW.payment_status,
        brew_status = NEW.brew_status,
        order_price = NEW.order_price,
        creation_time = NEW.creation_time,
        paying_time = NEW.paying_time,
        brewing_time = NEW.brewing_time,
        delivery_time = NEW.delivery_time,
        refund_time = NEW.refund_time,
        reason = NEW.reason,
        -- Убираем временный статус
        is_temporary = FALSE,
        match_score = match_score + 1,
        last_matched_at = NOW(),
        updated_at = NOW()
    WHERE order_number = NEW.order_number;
    
    -- Если записи нет, создаем новую
    IF NOT FOUND THEN
        INSERT INTO unified_orders (
            order_number, address, machine_code, goods_name, taste_name,
            order_type, order_resource, payment_status, brew_status, order_price,
            creation_time, paying_time, brewing_time, delivery_time, refund_time,
            reason, is_temporary, match_score, source_files
        ) VALUES (
            NEW.order_number, NEW.address, NEW.machine_code, NEW.goods_name, NEW.taste_name,
            NEW.order_type, NEW.order_resource, NEW.payment_status, NEW.brew_status, NEW.order_price,
            NEW.creation_time, NEW.paying_time, NEW.brewing_time, NEW.delivery_time, NEW.refund_time,
            NEW.reason, FALSE, 1, ARRAY[NEW.source_file_id::TEXT]
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для сопоставления sales_reports с hardware_orders
CREATE OR REPLACE FUNCTION match_sales_to_hardware()
RETURNS TRIGGER AS $$
BEGIN
    -- Ищем соответствующий заказ в unified_orders
    UPDATE unified_orders SET
        vhr_id = NEW.report_id,
        vhr_time = NEW.formatted_time,
        vhr_ikpu_code = NEW.ikpu_code,
        vhr_barcode = NEW.barcode,
        vhr_marking = NEW.marking,
        vhr_payment_type = NEW.payment_type,
        vhr_username = NEW.username,
        vhr_accrued_bonus = NEW.accrued_bonus,
        vhr_machine_category = NEW.machine_category,
        match_score = match_score + 1,
        last_matched_at = NOW(),
        updated_at = NOW()
    WHERE order_number = NEW.order_number
      AND machine_code = NEW.machine_code
      AND order_price = NEW.order_price
      AND order_resource = NEW.order_resource
      AND ABS(EXTRACT(EPOCH FROM (creation_time - NEW.formatted_time))) <= 5;
    
    -- Если совпадение не найдено, создаем временную запись
    IF NOT FOUND THEN
        INSERT INTO unified_orders (
            order_number, machine_code, order_price, order_resource,
            vhr_id, vhr_time, vhr_ikpu_code, vhr_barcode, vhr_marking,
            vhr_payment_type, vhr_username, vhr_accrued_bonus, vhr_machine_category,
            is_temporary, match_score, source_files
        ) VALUES (
            NEW.order_number, NEW.machine_code, NEW.order_price, NEW.order_resource,
            NEW.report_id, NEW.formatted_time, NEW.ikpu_code, NEW.barcode, NEW.marking,
            NEW.payment_type, NEW.username, NEW.accrued_bonus, NEW.machine_category,
            TRUE, 1, ARRAY[NEW.source_file_id::TEXT]
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для сопоставления fiscal_receipts
CREATE OR REPLACE FUNCTION match_fiscal_to_unified()
RETURNS TRIGGER AS $$
BEGIN
    -- Ищем заказ по времени и сумме
    UPDATE unified_orders SET
        fiscal_receipt_number = NEW.receipt_number,
        fiscal_module = NEW.fiscal_module,
        fiscal_recipe_number = NEW.recipe_number,
        fiscal_operation_type = NEW.operation_type,
        fiscal_cashier = NEW.cashier,
        fiscal_trade_point = NEW.trade_point,
        fiscal_operation_amount = NEW.operation_amount,
        fiscal_cash_amount = NEW.cash_amount,
        fiscal_card_amount = NEW.card_amount,
        fiscal_customer_info = NEW.customer_info,
        fiscal_operation_datetime = NEW.operation_datetime,
        match_score = match_score + 1,
        last_matched_at = NOW(),
        updated_at = NOW()
    WHERE NEW.cash_amount = order_price
      AND (
          ABS(EXTRACT(EPOCH FROM (creation_time - NEW.operation_datetime))) <= 5
          OR ABS(EXTRACT(EPOCH FROM (delivery_time - NEW.operation_datetime))) <= 5
          OR ABS(EXTRACT(EPOCH FROM (vhr_time - NEW.operation_datetime))) <= 5
      );
    
    -- Если не найдено, создаем временную запись
    IF NOT FOUND THEN
        INSERT INTO unified_orders (
            order_price, fiscal_receipt_number, fiscal_module, fiscal_operation_datetime,
            fiscal_cash_amount, fiscal_trade_point, is_temporary, match_score, source_files
        ) VALUES (
            NEW.cash_amount, NEW.receipt_number, NEW.fiscal_module, NEW.operation_datetime,
            NEW.cash_amount, NEW.trade_point, TRUE, 1, ARRAY[NEW.source_file_id::TEXT]
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- ТРИГГЕРЫ ДЛЯ АВТОМАТИЧЕСКОГО СОПОСТАВЛЕНИЯ
-- =====================================================

-- Триггер для hardware_orders
CREATE TRIGGER trigger_match_hardware
    AFTER INSERT ON hardware_orders
    FOR EACH ROW
    EXECUTE FUNCTION add_hardware_to_unified();

-- Триггер для sales_reports
CREATE TRIGGER trigger_match_sales
    AFTER INSERT ON sales_reports
    FOR EACH ROW
    EXECUTE FUNCTION match_sales_to_hardware();

-- Триггер для fiscal_receipts
CREATE TRIGGER trigger_match_fiscal
    AFTER INSERT ON fiscal_receipts
    FOR EACH ROW
    EXECUTE FUNCTION match_fiscal_to_unified();

-- =====================================================
-- ПРЕДСТАВЛЕНИЯ (VIEWS) ДЛЯ УДОБСТВА РАБОТЫ
-- =====================================================

-- Представление полных заказов (с данными из всех источников)
CREATE VIEW v_complete_orders AS
SELECT 
    u.*,
    f.original_name as source_filename,
    f.uploaded_at as file_uploaded_at,
    CASE 
        WHEN u.match_score = 6 THEN 'Полное совпадение'
        WHEN u.match_score >= 4 THEN 'Хорошее совпадение'
        WHEN u.match_score >= 2 THEN 'Частичное совпадение'
        ELSE 'Минимальное совпадение'
    END as match_quality
FROM unified_orders u
LEFT JOIN files f ON f.id = ANY(string_to_array(array_to_string(u.source_files, ','), ',')::int[]);

-- Представление проблемных заказов
CREATE VIEW v_problematic_orders AS
SELECT 
    u.order_number,
    u.order_price,
    u.machine_code,
    u.creation_time,
    u.is_temporary,
    u.match_score,
    COUNT(e.id) as error_count,
    STRING_AGG(e.error_type, ', ') as error_types
FROM unified_orders u
LEFT JOIN order_errors e ON e.order_number = u.order_number
WHERE u.is_temporary = TRUE 
   OR u.match_score < 2 
   OR EXISTS (SELECT 1 FROM order_errors WHERE order_number = u.order_number AND resolution_status = 'open')
GROUP BY u.order_number, u.order_price, u.machine_code, u.creation_time, u.is_temporary, u.match_score;

-- Представление статистики по файлам
CREATE VIEW v_file_processing_stats AS
SELECT 
    f.file_type,
    f.original_name,
    f.records_count,
    f.processed_records,
    f.matched_records,
    f.error_records,
    ROUND((f.processed_records::decimal / NULLIF(f.records_count, 0)) * 100, 2) as processing_percentage,
    ROUND((f.matched_records::decimal / NULLIF(f.processed_records, 0)) * 100, 2) as matching_percentage,
    f.processing_status,
    f.uploaded_at,
    f.processing_finished_at
FROM files f
ORDER BY f.uploaded_at DESC;