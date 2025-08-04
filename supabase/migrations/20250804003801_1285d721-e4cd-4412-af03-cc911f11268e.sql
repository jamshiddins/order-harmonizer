-- =====================================================
-- СИСТЕМА КОНСОЛИДАЦИИ ЧАСТИЧНЫХ ЗАПИСЕЙ
-- =====================================================

-- Функция для поиска и объединения записей которые могли быть созданы из разных источников
CREATE OR REPLACE FUNCTION consolidate_partial_records()
RETURNS TABLE(
    consolidated_count INTEGER,
    operation_details TEXT
) AS $$
DECLARE
    partial_record RECORD;
    target_record RECORD;
    consolidation_count INTEGER := 0;
BEGIN
    -- Ищем временные записи которые могут быть объединены с основными
    FOR partial_record IN
        SELECT * FROM unified_orders 
        WHERE is_temporary = TRUE 
        ORDER BY creation_time DESC
    LOOP
        -- Ищем подходящую основную запись для объединения
        SELECT * INTO target_record
        FROM unified_orders main
        WHERE main.id != partial_record.id
          AND main.is_temporary = FALSE
          AND main.order_price = partial_record.order_price
          AND (
              -- Совпадение по времени ±10 секунд
              ABS(EXTRACT(EPOCH FROM (main.creation_time - COALESCE(partial_record.vhr_time, partial_record.fiscal_operation_datetime, partial_record.payme_payment_time, partial_record.click_payment_date, partial_record.uzum_parsed_datetime)))) <= 10
              OR 
              -- Или совпадение номера заказа
              (partial_record.order_number IS NOT NULL AND main.order_number = partial_record.order_number)
          )
        LIMIT 1;
        
        IF target_record.id IS NOT NULL THEN
            -- Объединяем данные из частичной записи в основную
            UPDATE unified_orders SET
                -- Добавляем данные из sales_reports если есть
                vhr_id = COALESCE(target_record.vhr_id, partial_record.vhr_id),
                vhr_time = COALESCE(target_record.vhr_time, partial_record.vhr_time),
                vhr_ikpu_code = COALESCE(target_record.vhr_ikpu_code, partial_record.vhr_ikpu_code),
                vhr_barcode = COALESCE(target_record.vhr_barcode, partial_record.vhr_barcode),
                vhr_marking = COALESCE(target_record.vhr_marking, partial_record.vhr_marking),
                vhr_payment_type = COALESCE(target_record.vhr_payment_type, partial_record.vhr_payment_type),
                vhr_username = COALESCE(target_record.vhr_username, partial_record.vhr_username),
                vhr_accrued_bonus = COALESCE(target_record.vhr_accrued_bonus, partial_record.vhr_accrued_bonus),
                vhr_machine_category = COALESCE(target_record.vhr_machine_category, partial_record.vhr_machine_category),
                
                -- Добавляем данные из fiscal_receipts если есть
                fiscal_receipt_number = COALESCE(target_record.fiscal_receipt_number, partial_record.fiscal_receipt_number),
                fiscal_module = COALESCE(target_record.fiscal_module, partial_record.fiscal_module),
                fiscal_recipe_number = COALESCE(target_record.fiscal_recipe_number, partial_record.fiscal_recipe_number),
                fiscal_operation_type = COALESCE(target_record.fiscal_operation_type, partial_record.fiscal_operation_type),
                fiscal_cashier = COALESCE(target_record.fiscal_cashier, partial_record.fiscal_cashier),
                fiscal_trade_point = COALESCE(target_record.fiscal_trade_point, partial_record.fiscal_trade_point),
                fiscal_operation_amount = COALESCE(target_record.fiscal_operation_amount, partial_record.fiscal_operation_amount),
                fiscal_cash_amount = COALESCE(target_record.fiscal_cash_amount, partial_record.fiscal_cash_amount),
                fiscal_card_amount = COALESCE(target_record.fiscal_card_amount, partial_record.fiscal_card_amount),
                fiscal_customer_info = COALESCE(target_record.fiscal_customer_info, partial_record.fiscal_customer_info),
                fiscal_operation_datetime = COALESCE(target_record.fiscal_operation_datetime, partial_record.fiscal_operation_datetime),
                
                -- Добавляем данные из payme_payments если есть
                payme_provider_name = COALESCE(target_record.payme_provider_name, partial_record.payme_provider_name),
                payme_cashbox_name = COALESCE(target_record.payme_cashbox_name, partial_record.payme_cashbox_name),
                payme_payment_state = COALESCE(target_record.payme_payment_state, partial_record.payme_payment_state),
                payme_payment_time = COALESCE(target_record.payme_payment_time, partial_record.payme_payment_time),
                payme_processing_name = COALESCE(target_record.payme_processing_name, partial_record.payme_processing_name),
                payme_card_number = COALESCE(target_record.payme_card_number, partial_record.payme_card_number),
                payme_amount_without_commission = COALESCE(target_record.payme_amount_without_commission, partial_record.payme_amount_without_commission),
                payme_client_commission = COALESCE(target_record.payme_client_commission, partial_record.payme_client_commission),
                payme_payment_system_id = COALESCE(target_record.payme_payment_system_id, partial_record.payme_payment_system_id),
                payme_provider_payment_id = COALESCE(target_record.payme_provider_payment_id, partial_record.payme_provider_payment_id),
                payme_rrn = COALESCE(target_record.payme_rrn, partial_record.payme_rrn),
                payme_fiscal_receipt_id = COALESCE(target_record.payme_fiscal_receipt_id, partial_record.payme_fiscal_receipt_id),
                payme_order_number = COALESCE(target_record.payme_order_number, partial_record.payme_order_number),
                
                -- Добавляем данные из click_payments если есть
                click_id = COALESCE(target_record.click_id, partial_record.click_id),
                click_billing_id = COALESCE(target_record.click_billing_id, partial_record.click_billing_id),
                click_identifier = COALESCE(target_record.click_identifier, partial_record.click_identifier),
                click_service_name = COALESCE(target_record.click_service_name, partial_record.click_service_name),
                click_client_info = COALESCE(target_record.click_client_info, partial_record.click_client_info),
                click_payment_method = COALESCE(target_record.click_payment_method, partial_record.click_payment_method),
                click_amount = COALESCE(target_record.click_amount, partial_record.click_amount),
                click_payment_status = COALESCE(target_record.click_payment_status, partial_record.click_payment_status),
                click_cashbox = COALESCE(target_record.click_cashbox, partial_record.click_cashbox),
                click_payment_date = COALESCE(target_record.click_payment_date, partial_record.click_payment_date),
                
                -- Добавляем данные из uzum_payments если есть
                uzum_service_name = COALESCE(target_record.uzum_service_name, partial_record.uzum_service_name),
                uzum_amount = COALESCE(target_record.uzum_amount, partial_record.uzum_amount),
                uzum_commission = COALESCE(target_record.uzum_commission, partial_record.uzum_commission),
                uzum_card_type = COALESCE(target_record.uzum_card_type, partial_record.uzum_card_type),
                uzum_card_number = COALESCE(target_record.uzum_card_number, partial_record.uzum_card_number),
                uzum_status = COALESCE(target_record.uzum_status, partial_record.uzum_status),
                uzum_merchant_id = COALESCE(target_record.uzum_merchant_id, partial_record.uzum_merchant_id),
                uzum_receipt_id = COALESCE(target_record.uzum_receipt_id, partial_record.uzum_receipt_id),
                uzum_parsed_datetime = COALESCE(target_record.uzum_parsed_datetime, partial_record.uzum_parsed_datetime),
                
                -- Обновляем метаданные
                match_score = target_record.match_score + partial_record.match_score,
                last_matched_at = NOW(),
                source_files = array_cat(target_record.source_files, partial_record.source_files)
            WHERE id = target_record.id;
            
            -- Удаляем объединенную частичную запись
            DELETE FROM unified_orders WHERE id = partial_record.id;
            
            consolidation_count := consolidation_count + 1;
            
            -- Логируем объединение
            INSERT INTO order_changes (
                table_name, record_id, order_number, field_name,
                new_value, change_type, change_reason
            ) VALUES (
                'unified_orders', target_record.id, target_record.order_number,
                'consolidation', 'Объединена частичная запись ID:' || partial_record.id,
                'auto-match', 'Консолидация частичных записей'
            );
        END IF;
    END LOOP;
    
    consolidated_count := consolidation_count;
    operation_details := 'Объединено ' || consolidation_count || ' частичных записей с основными';
    
    RETURN NEXT;
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- ПРЕДСТАВЛЕНИЯ ДЛЯ АНАЛИЗА ЧАСТИЧНЫХ ДАННЫХ
-- =====================================================

-- Представление показывает какие источники данных есть для каждого заказа
CREATE VIEW v_partial_data_analysis AS
SELECT 
    id,
    order_number,
    machine_code,
    order_price,
    is_temporary,
    match_score,
    
    -- Показываем какие источники данных присутствуют
    CASE WHEN order_number IS NOT NULL AND NOT is_temporary THEN '✓' ELSE '✗' END as has_hardware,
    CASE WHEN vhr_id IS NOT NULL THEN '✓' ELSE '✗' END as has_sales,
    CASE WHEN fiscal_receipt_number IS NOT NULL THEN '✓' ELSE '✗' END as has_fiscal,
    CASE WHEN payme_payment_system_id IS NOT NULL THEN '✓' ELSE '✗' END as has_payme,
    CASE WHEN click_id IS NOT NULL THEN '✓' ELSE '✗' END as has_click,
    CASE WHEN uzum_receipt_id IS NOT NULL THEN '✓' ELSE '✗' END as has_uzum,
    
    -- Формируем список доступных источников
    array_to_string(
        array_remove(ARRAY[
            CASE WHEN order_number IS NOT NULL AND NOT is_temporary THEN 'Hardware' END,
            CASE WHEN vhr_id IS NOT NULL THEN 'Sales' END,
            CASE WHEN fiscal_receipt_number IS NOT NULL THEN 'Fiscal' END,
            CASE WHEN payme_payment_system_id IS NOT NULL THEN 'Payme' END,
            CASE WHEN click_id IS NOT NULL THEN 'Click' END,
            CASE WHEN uzum_receipt_id IS NOT NULL THEN 'Uzum' END
        ], NULL), 
        ', '
    ) as available_sources,
    
    -- Показываем основные временные метки
    creation_time,
    vhr_time,
    fiscal_operation_datetime,
    payme_payment_time,
    click_payment_date,
    uzum_parsed_datetime,
    
    last_matched_at
FROM unified_orders
ORDER BY match_score DESC, last_matched_at DESC;