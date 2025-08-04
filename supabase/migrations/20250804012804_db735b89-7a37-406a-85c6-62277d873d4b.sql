-- =====================================================
-- ФУНКЦИИ СОПОСТАВЛЕНИЯ И ОБРАБОТКИ ДАННЫХ
-- =====================================================

-- Функция улучшенного поиска совпадений с учетом частичной загрузки данных
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
$$ LANGUAGE plpgsql;