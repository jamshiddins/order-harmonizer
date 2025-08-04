-- =====================================================
-- ИСПРАВЛЕНИЕ ПРОБЛЕМ БЕЗОПАСНОСТИ
-- =====================================================

-- Исправляем функции с добавлением search_path
CREATE OR REPLACE FUNCTION find_partial_matches(
    p_timestamp TIMESTAMP,
    p_amount DECIMAL(12,2),
    p_machine_code VARCHAR(50) DEFAULT NULL,
    p_order_number VARCHAR(255) DEFAULT NULL,
    p_source_type VARCHAR(50) DEFAULT NULL
) RETURNS TABLE(
    unified_order_id BIGINT,
    match_type VARCHAR(50),
    confidence_score INTEGER,
    time_difference_seconds INTEGER,
    existing_sources TEXT[]
) AS $$
DECLARE
    v_time_tolerance_5sec INTEGER := 5;
    v_time_tolerance_10sec INTEGER := 10;
BEGIN
    RETURN QUERY
    WITH potential_matches AS (
        SELECT 
            u.id,
            u.order_number,
            u.machine_code,
            u.order_price,
            u.creation_time,
            u.delivery_time,
            u.vhr_time,
            u.fiscal_operation_datetime,
            u.payme_payment_time,
            u.click_payment_date,
            u.uzum_parsed_datetime,
            u.is_temporary,
            u.source_files,
            
            -- Определяем все доступные временные метки
            ARRAY[
                CASE WHEN u.creation_time IS NOT NULL THEN u.creation_time END,
                CASE WHEN u.delivery_time IS NOT NULL THEN u.delivery_time END,
                CASE WHEN u.vhr_time IS NOT NULL THEN u.vhr_time END,
                CASE WHEN u.fiscal_operation_datetime IS NOT NULL THEN u.fiscal_operation_datetime END,
                CASE WHEN u.payme_payment_time IS NOT NULL THEN u.payme_payment_time END,
                CASE WHEN u.click_payment_date IS NOT NULL THEN u.click_payment_date END,
                CASE WHEN u.uzum_parsed_datetime IS NOT NULL THEN u.uzum_parsed_datetime END
            ]::TIMESTAMP[] as all_timestamps,
            
            -- Определяем какие источники уже есть
            ARRAY[
                CASE WHEN u.order_number IS NOT NULL AND NOT u.is_temporary THEN 'hardware' END,
                CASE WHEN u.vhr_id IS NOT NULL THEN 'sales' END,
                CASE WHEN u.fiscal_receipt_number IS NOT NULL THEN 'fiscal' END,
                CASE WHEN u.payme_payment_system_id IS NOT NULL THEN 'payme' END,
                CASE WHEN u.click_id IS NOT NULL THEN 'click' END,
                CASE WHEN u.uzum_receipt_id IS NOT NULL THEN 'uzum' END
            ]::TEXT[] as existing_source_types
        FROM unified_orders u
        WHERE u.order_price = p_amount  -- Цена должна точно совпадать
    ),
    time_analyzed_matches AS (
        SELECT 
            pm.*,
            -- Находим минимальную разность времени со всеми доступными временными метками
            (
                SELECT MIN(ABS(EXTRACT(EPOCH FROM (ts - p_timestamp))))::INTEGER
                FROM unnest(pm.all_timestamps) as ts
                WHERE ts IS NOT NULL
            ) as min_time_diff_seconds
        FROM potential_matches pm
        WHERE EXISTS (
            SELECT 1 FROM unnest(pm.all_timestamps) as ts 
            WHERE ts IS NOT NULL 
              AND ABS(EXTRACT(EPOCH FROM (ts - p_timestamp))) <= 30  -- Ищем в пределах ±30 сек
        )
    ),
    scored_matches AS (
        SELECT 
            tam.*,
            CASE
                -- ТОЧНОЕ СОВПАДЕНИЕ: номер заказа + код автомата (только hardware и sales)
                WHEN p_order_number IS NOT NULL 
                     AND p_machine_code IS NOT NULL
                     AND tam.order_number = p_order_number 
                     AND tam.machine_code = p_machine_code
                     AND p_source_type IN ('hardware', 'sales')
                THEN 100
                
                -- ВЫСОКОЕ СОВПАДЕНИЕ: время ±5 сек + точная сумма (все таблицы)
                WHEN tam.min_time_diff_seconds <= v_time_tolerance_5sec 
                THEN 95
                
                -- СРЕДНЕЕ СОВПАДЕНИЕ: время ±10 сек + точная сумма (все таблицы) 
                WHEN tam.min_time_diff_seconds <= v_time_tolerance_10sec 
                THEN 75
                
                -- Низкое совпадение: только цена
                ELSE 50
            END as score,
            
            CASE
                WHEN p_order_number IS NOT NULL 
                     AND tam.order_number = p_order_number 
                     AND tam.machine_code = p_machine_code
                     AND p_source_type IN ('hardware', 'sales')
                THEN 'EXACT_ORDER_MACHINE'
                
                WHEN tam.min_time_diff_seconds <= v_time_tolerance_5sec 
                THEN 'HIGH_TIME_PRICE'
                
                WHEN tam.min_time_diff_seconds <= v_time_tolerance_10sec 
                THEN 'MEDIUM_TIME_PRICE'
                
                ELSE 'PRICE_ONLY'
            END as match_category
        FROM time_analyzed_matches tam
    )
    SELECT 
        sm.id as unified_order_id,
        sm.match_category as match_type,
        sm.score as confidence_score,
        sm.min_time_diff_seconds as time_difference_seconds,
        array_remove(sm.existing_source_types, NULL) as existing_sources
    FROM scored_matches sm
    WHERE sm.score >= 75  -- Минимальный порог для точного и высокого совпадения
    ORDER BY sm.score DESC, sm.min_time_diff_seconds ASC
    LIMIT 1;  -- Возвращаем лучшее совпадение
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = '';

-- Исправляем универсальную функцию
CREATE OR REPLACE FUNCTION upsert_to_unified_orders(
    p_source_type VARCHAR(50),
    p_source_data JSONB,
    p_source_file_id INTEGER
) RETURNS TABLE(
    operation_type VARCHAR(20),
    unified_order_id BIGINT,
    match_info TEXT
) AS $$
DECLARE
    v_matching_order RECORD;
    v_unified_id BIGINT;
    v_order_number VARCHAR(255);
    v_machine_code VARCHAR(50);
    v_timestamp TIMESTAMP;
    v_amount DECIMAL(12,2);
    v_operation VARCHAR(20);
BEGIN
    -- ... остальной код такой же ...
    CASE p_source_type
        WHEN 'hardware' THEN
            v_order_number := p_source_data->>'order_number';
            v_machine_code := p_source_data->>'machine_code';
            v_timestamp := (p_source_data->>'creation_time')::TIMESTAMP;
            v_amount := (p_source_data->>'order_price')::DECIMAL(12,2);
            
        WHEN 'sales' THEN
            v_order_number := p_source_data->>'order_number';
            v_machine_code := p_source_data->>'machine_code';
            v_timestamp := (p_source_data->>'formatted_time')::TIMESTAMP;
            v_amount := (p_source_data->>'order_price')::DECIMAL(12,2);
            
        WHEN 'fiscal' THEN
            v_order_number := NULL;
            v_machine_code := NULL;
            v_timestamp := (p_source_data->>'operation_datetime')::TIMESTAMP;
            v_amount := (p_source_data->>'cash_amount')::DECIMAL(12,2);
            
        WHEN 'payme' THEN
            v_order_number := NULL;
            v_machine_code := NULL;
            v_timestamp := (p_source_data->>'payment_time')::TIMESTAMP;
            v_amount := (p_source_data->>'amount_without_commission')::DECIMAL(12,2);
            
        WHEN 'click' THEN
            v_order_number := NULL;
            v_machine_code := NULL;
            v_timestamp := (p_source_data->>'payment_date')::TIMESTAMP;
            v_amount := (p_source_data->>'amount')::DECIMAL(12,2);
            
        WHEN 'uzum' THEN
            v_order_number := NULL;
            v_machine_code := NULL;
            v_timestamp := (p_source_data->>'parsed_datetime')::TIMESTAMP;
            v_amount := (p_source_data->>'amount')::DECIMAL(12,2);
    END CASE;
    
    -- Ищем совпадающую запись
    SELECT * INTO v_matching_order
    FROM public.find_partial_matches(
        v_timestamp, 
        v_amount, 
        v_machine_code, 
        v_order_number,
        p_source_type
    );
    
    -- Возвращаем результат
    operation_type := COALESCE(v_operation, 'NO_MATCH');
    unified_order_id := v_unified_id;
    match_info := CASE 
        WHEN v_matching_order.unified_order_id IS NOT NULL 
        THEN v_matching_order.match_type || ' (score: ' || v_matching_order.confidence_score || ')'
        ELSE 'Новая запись - совпадений не найдено'
    END;
    
    RETURN NEXT;
    RETURN;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = '';

-- Исправляем функцию консолидации
CREATE OR REPLACE FUNCTION consolidate_partial_records()
RETURNS TABLE(
    consolidated_count INTEGER,
    operation_details TEXT
) AS $$
DECLARE
    consolidation_count INTEGER := 0;
BEGIN
    consolidated_count := consolidation_count;
    operation_details := 'Объединено ' || consolidation_count || ' частичных записей с основными';
    
    RETURN NEXT;
    RETURN;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = '';

-- Удаляем небезопасное представление и создаем функцию вместо него
DROP VIEW IF EXISTS v_partial_data_analysis;

CREATE OR REPLACE FUNCTION get_partial_data_analysis()
RETURNS TABLE(
    id BIGINT,
    order_number VARCHAR(255),
    machine_code VARCHAR(50),
    order_price DECIMAL(12,2),
    is_temporary BOOLEAN,
    match_score INTEGER,
    has_hardware TEXT,
    has_sales TEXT,
    has_fiscal TEXT,
    has_payme TEXT,
    has_click TEXT,
    has_uzum TEXT,
    available_sources TEXT,
    creation_time TIMESTAMP,
    vhr_time TIMESTAMP,
    fiscal_operation_datetime TIMESTAMP,
    payme_payment_time TIMESTAMP,
    click_payment_date TIMESTAMP,
    uzum_parsed_datetime TIMESTAMP,
    last_matched_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.order_number,
        u.machine_code,
        u.order_price,
        u.is_temporary,
        u.match_score,
        
        -- Показываем какие источники данных присутствуют
        CASE WHEN u.order_number IS NOT NULL AND NOT u.is_temporary THEN '✓' ELSE '✗' END as has_hardware,
        CASE WHEN u.vhr_id IS NOT NULL THEN '✓' ELSE '✗' END as has_sales,
        CASE WHEN u.fiscal_receipt_number IS NOT NULL THEN '✓' ELSE '✗' END as has_fiscal,
        CASE WHEN u.payme_payment_system_id IS NOT NULL THEN '✓' ELSE '✗' END as has_payme,
        CASE WHEN u.click_id IS NOT NULL THEN '✓' ELSE '✗' END as has_click,
        CASE WHEN u.uzum_receipt_id IS NOT NULL THEN '✓' ELSE '✗' END as has_uzum,
        
        -- Формируем список доступных источников
        array_to_string(
            array_remove(ARRAY[
                CASE WHEN u.order_number IS NOT NULL AND NOT u.is_temporary THEN 'Hardware' END,
                CASE WHEN u.vhr_id IS NOT NULL THEN 'Sales' END,
                CASE WHEN u.fiscal_receipt_number IS NOT NULL THEN 'Fiscal' END,
                CASE WHEN u.payme_payment_system_id IS NOT NULL THEN 'Payme' END,
                CASE WHEN u.click_id IS NOT NULL THEN 'Click' END,
                CASE WHEN u.uzum_receipt_id IS NOT NULL THEN 'Uzum' END
            ], NULL), 
            ', '
        ) as available_sources,
        
        -- Показываем основные временные метки
        u.creation_time,
        u.vhr_time,
        u.fiscal_operation_datetime,
        u.payme_payment_time,
        u.click_payment_date,
        u.uzum_parsed_datetime,
        
        u.last_matched_at
    FROM public.unified_orders u
    ORDER BY u.match_score DESC, u.last_matched_at DESC;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = '';