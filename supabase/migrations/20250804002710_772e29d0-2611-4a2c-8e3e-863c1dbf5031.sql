-- =====================================================
-- УНИВЕРСАЛЬНАЯ ФУНКЦИЯ ДОБАВЛЕНИЯ ДАННЫХ В ОБЩУЮ БАЗУ
-- =====================================================

-- Функция для добавления/обновления данных в unified_orders из любого источника
CREATE OR REPLACE FUNCTION upsert_to_unified_orders(
    p_source_type VARCHAR(50),  -- 'hardware', 'sales', 'fiscal', 'payme', 'click', 'uzum'
    p_source_data JSONB,        -- Данные из исходной таблицы в JSON формате
    p_source_file_id INTEGER    -- ID файла-источника
) RETURNS TABLE(
    operation_type VARCHAR(20), -- 'INSERT', 'UPDATE', 'NO_MATCH'
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
    -- Извлекаем ключевые поля в зависимости от типа источника
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
    FROM find_partial_matches(
        v_timestamp, 
        v_amount, 
        v_machine_code, 
        v_order_number,
        p_source_type
    );
    
    IF v_matching_order.unified_order_id IS NOT NULL THEN
        -- ОБНОВЛЯЕМ существующую запись
        v_unified_id := v_matching_order.unified_order_id;
        v_operation := 'UPDATE';
        
        -- Обновляем поля в зависимости от типа источника
        CASE p_source_type
            WHEN 'hardware' THEN
                UPDATE unified_orders SET
                    order_number = v_order_number,
                    machine_code = v_machine_code,
                    address = p_source_data->>'address',
                    goods_name = p_source_data->>'goods_name',
                    taste_name = p_source_data->>'taste_name',
                    order_type = p_source_data->>'order_type',
                    order_resource = p_source_data->>'order_resource',
                    payment_status = p_source_data->>'payment_status',
                    brew_status = p_source_data->>'brew_status',
                    order_price = v_amount,
                    creation_time = v_timestamp,
                    paying_time = (p_source_data->>'paying_time')::TIMESTAMP,
                    brewing_time = (p_source_data->>'brewing_time')::TIMESTAMP,
                    delivery_time = (p_source_data->>'delivery_time')::TIMESTAMP,
                    refund_time = (p_source_data->>'refund_time')::TIMESTAMP,
                    reason = p_source_data->>'reason',
                    is_temporary = FALSE,  -- Убираем временный статус для hardware
                    match_score = match_score + 1,
                    last_matched_at = NOW(),
                    source_files = array_append(source_files, p_source_file_id::TEXT)
                WHERE id = v_unified_id;
                
            WHEN 'sales' THEN
                UPDATE unified_orders SET
                    vhr_id = (p_source_data->>'report_id')::INTEGER,
                    vhr_time = v_timestamp,
                    vhr_ikpu_code = p_source_data->>'ikpu_code',
                    vhr_barcode = p_source_data->>'barcode',
                    vhr_marking = p_source_data->>'marking',
                    vhr_payment_type = p_source_data->>'payment_type',
                    vhr_username = p_source_data->>'username',
                    vhr_accrued_bonus = (p_source_data->>'accrued_bonus')::DECIMAL(10,2),
                    vhr_machine_category = p_source_data->>'machine_category',
                    match_score = match_score + 1,
                    last_matched_at = NOW(),
                    source_files = array_append(source_files, p_source_file_id::TEXT)
                WHERE id = v_unified_id;
                
            WHEN 'fiscal' THEN
                UPDATE unified_orders SET
                    fiscal_receipt_number = p_source_data->>'receipt_number',
                    fiscal_module = p_source_data->>'fiscal_module',
                    fiscal_recipe_number = p_source_data->>'recipe_number',
                    fiscal_operation_type = p_source_data->>'operation_type',
                    fiscal_cashier = p_source_data->>'cashier',
                    fiscal_trade_point = p_source_data->>'trade_point',
                    fiscal_operation_amount = (p_source_data->>'operation_amount')::DECIMAL(12,2),
                    fiscal_cash_amount = v_amount,
                    fiscal_card_amount = (p_source_data->>'card_amount')::DECIMAL(12,2),
                    fiscal_customer_info = p_source_data->>'customer_info',
                    fiscal_operation_datetime = v_timestamp,
                    match_score = match_score + 1,
                    last_matched_at = NOW(),
                    source_files = array_append(source_files, p_source_file_id::TEXT)
                WHERE id = v_unified_id;
                
            WHEN 'payme' THEN
                UPDATE unified_orders SET
                    payme_provider_name = p_source_data->>'provider_name',
                    payme_cashbox_name = p_source_data->>'cashbox_name',
                    payme_payment_state = p_source_data->>'payment_state',
                    payme_payment_time = v_timestamp,
                    payme_processing_name = p_source_data->>'processing_name',
                    payme_card_number = p_source_data->>'card_number',
                    payme_amount_without_commission = v_amount,
                    payme_client_commission = (p_source_data->>'client_commission')::DECIMAL(12,2),
                    payme_payment_system_id = p_source_data->>'payment_system_id',
                    payme_provider_payment_id = p_source_data->>'provider_payment_id',
                    payme_rrn = p_source_data->>'rrn',
                    payme_fiscal_receipt_id = p_source_data->>'fiscal_receipt_id',
                    payme_order_number = p_source_data->>'order_number',
                    match_score = match_score + 1,
                    last_matched_at = NOW(),
                    source_files = array_append(source_files, p_source_file_id::TEXT)
                WHERE id = v_unified_id;
                
            WHEN 'click' THEN
                UPDATE unified_orders SET
                    click_id = p_source_data->>'click_id',
                    click_billing_id = p_source_data->>'billing_id',
                    click_identifier = p_source_data->>'identifier',
                    click_service_name = p_source_data->>'service_name',
                    click_client_info = p_source_data->>'client_info',
                    click_payment_method = p_source_data->>'payment_method',
                    click_amount = v_amount,
                    click_payment_status = p_source_data->>'payment_status',
                    click_cashbox = p_source_data->>'cashbox',
                    click_payment_date = v_timestamp,
                    match_score = match_score + 1,
                    last_matched_at = NOW(),
                    source_files = array_append(source_files, p_source_file_id::TEXT)
                WHERE id = v_unified_id;
                
            WHEN 'uzum' THEN
                UPDATE unified_orders SET
                    uzum_service_name = p_source_data->>'service_name',
                    uzum_amount = v_amount,
                    uzum_commission = (p_source_data->>'commission')::DECIMAL(12,2),
                    uzum_card_type = p_source_data->>'card_type',
                    uzum_card_number = p_source_data->>'card_number',
                    uzum_status = p_source_data->>'status',
                    uzum_merchant_id = p_source_data->>'merchant_id',
                    uzum_receipt_id = p_source_data->>'receipt_id',
                    uzum_parsed_datetime = v_timestamp,
                    match_score = match_score + 1,
                    last_matched_at = NOW(),
                    source_files = array_append(source_files, p_source_file_id::TEXT)
                WHERE id = v_unified_id;
        END CASE;
        
    ELSE
        -- СОЗДАЕМ новую запись (частичную)
        v_operation := 'INSERT';
        
        CASE p_source_type
            WHEN 'hardware' THEN
                INSERT INTO unified_orders (
                    order_number, machine_code, address, goods_name, taste_name,
                    order_type, order_resource, payment_status, brew_status, order_price,
                    creation_time, paying_time, brewing_time, delivery_time, refund_time,
                    reason, is_temporary, match_score, source_files
                ) VALUES (
                    v_order_number, v_machine_code, p_source_data->>'address',
                    p_source_data->>'goods_name', p_source_data->>'taste_name',
                    p_source_data->>'order_type', p_source_data->>'order_resource',
                    p_source_data->>'payment_status', p_source_data->>'brew_status', v_amount,
                    v_timestamp, (p_source_data->>'paying_time')::TIMESTAMP,
                    (p_source_data->>'brewing_time')::TIMESTAMP, (p_source_data->>'delivery_time')::TIMESTAMP,
                    (p_source_data->>'refund_time')::TIMESTAMP, p_source_data->>'reason',
                    FALSE, 1, ARRAY[p_source_file_id::TEXT]
                ) RETURNING id INTO v_unified_id;
                
            WHEN 'sales' THEN
                INSERT INTO unified_orders (
                    order_number, machine_code, order_price, order_resource,
                    vhr_id, vhr_time, vhr_ikpu_code, vhr_barcode, vhr_marking,
                    vhr_payment_type, vhr_username, vhr_accrued_bonus, vhr_machine_category,
                    is_temporary, match_score, source_files
                ) VALUES (
                    v_order_number, v_machine_code, v_amount, p_source_data->>'order_resource',
                    (p_source_data->>'report_id')::INTEGER, v_timestamp, p_source_data->>'ikpu_code',
                    p_source_data->>'barcode', p_source_data->>'marking', p_source_data->>'payment_type',
                    p_source_data->>'username', (p_source_data->>'accrued_bonus')::DECIMAL(10,2),
                    p_source_data->>'machine_category', TRUE, 1, ARRAY[p_source_file_id::TEXT]
                ) RETURNING id INTO v_unified_id;
                
            ELSE  -- fiscal, payme, click, uzum
                INSERT INTO unified_orders (
                    order_price, is_temporary, match_score, source_files,
                    -- Добавляем соответствующие поля для каждого типа
                    fiscal_receipt_number, fiscal_operation_datetime, fiscal_cash_amount,
                    payme_payment_time, payme_amount_without_commission,
                    click_payment_date, click_amount, click_id,
                    uzum_parsed_datetime, uzum_amount, uzum_receipt_id,
                    order_number
                ) VALUES (
                    v_amount, TRUE, 1, ARRAY[p_source_file_id::TEXT],
                    CASE WHEN p_source_type = 'fiscal' THEN p_source_data->>'receipt_number' END,
                    CASE WHEN p_source_type = 'fiscal' THEN v_timestamp END,
                    CASE WHEN p_source_type = 'fiscal' THEN v_amount END,
                    CASE WHEN p_source_type = 'payme' THEN v_timestamp END,
                    CASE WHEN p_source_type = 'payme' THEN v_amount END,
                    CASE WHEN p_source_type = 'click' THEN v_timestamp END,
                    CASE WHEN p_source_type = 'click' THEN v_amount END,
                    CASE WHEN p_source_type = 'click' THEN p_source_data->>'click_id' END,
                    CASE WHEN p_source_type = 'uzum' THEN v_timestamp END,
                    CASE WHEN p_source_type = 'uzum' THEN v_amount END,
                    CASE WHEN p_source_type = 'uzum' THEN p_source_data->>'receipt_id' END,
                    COALESCE(v_order_number, 'TEMP_' || p_source_type || '_' || extract(epoch from v_timestamp)::text)
                ) RETURNING id INTO v_unified_id;
        END CASE;
    END IF;
    
    -- Возвращаем результат
    operation_type := v_operation;
    unified_order_id := v_unified_id;
    match_info := CASE 
        WHEN v_matching_order.unified_order_id IS NOT NULL 
        THEN v_matching_order.match_type || ' (score: ' || v_matching_order.confidence_score || ')'
        ELSE 'Новая запись - совпадений не найдено'
    END;
    
    RETURN NEXT;
    RETURN;
END;
$$ LANGUAGE plpgsql;