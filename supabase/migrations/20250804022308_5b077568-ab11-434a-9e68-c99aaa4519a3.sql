-- =====================================================
-- ФУНКЦИИ АНАЛИЗА И КОНСОЛИДАЦИИ ДАННЫХ
-- =====================================================

-- Функция анализа состояния данных по источникам
CREATE OR REPLACE FUNCTION analyze_data_completeness()
RETURNS TABLE(
    source_combination TEXT,
    record_count INTEGER,
    percentage DECIMAL(5,2),
    avg_match_score DECIMAL(3,1),
    quality_level VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    WITH source_analysis AS (
        SELECT 
            ARRAY[
                CASE WHEN u.order_number IS NOT NULL AND NOT u.is_temporary THEN 'H' END,
                CASE WHEN u.vhr_id IS NOT NULL THEN 'S' END,
                CASE WHEN u.fiscal_receipt_number IS NOT NULL THEN 'F' END,
                CASE WHEN u.payme_payment_system_id IS NOT NULL THEN 'P' END,
                CASE WHEN u.click_id IS NOT NULL THEN 'C' END,
                CASE WHEN u.uzum_receipt_id IS NOT NULL THEN 'U' END
            ] as sources,
            u.match_score,
            u.id
        FROM unified_orders u
    ),
    combinations AS (
        SELECT 
            array_to_string(array_remove(sources, NULL), '') as combination,
            COUNT(*) as cnt,
            AVG(match_score) as avg_score
        FROM source_analysis
        GROUP BY array_to_string(array_remove(sources, NULL), '')
    ),
    totals AS (
        SELECT SUM(cnt) as total_records FROM combinations
    )
    SELECT 
        CASE c.combination
            WHEN 'H' THEN 'Только Hardware'
            WHEN 'S' THEN 'Только Sales'
            WHEN 'F' THEN 'Только Fiscal'
            WHEN 'P' THEN 'Только Payme'
            WHEN 'C' THEN 'Только Click'
            WHEN 'U' THEN 'Только Uzum'
            WHEN 'HS' THEN 'Hardware + Sales'
            WHEN 'HF' THEN 'Hardware + Fiscal'
            WHEN 'HP' THEN 'Hardware + Payme'
            WHEN 'HSF' THEN 'Hardware + Sales + Fiscal'
            WHEN 'HSFP' THEN 'Hardware + Sales + Fiscal + Payme'
            WHEN 'HSFPC' THEN 'Hardware + Sales + Fiscal + Payme + Click'
            WHEN 'HSFPCU' THEN 'Все источники (Hardware + Sales + Fiscal + Payme + Click + Uzum)'
            ELSE 'Комбинация: ' || c.combination
        END as source_combination,
        c.cnt as record_count,
        ROUND((c.cnt::DECIMAL / t.total_records) * 100, 2) as percentage,
        ROUND(c.avg_score, 1) as avg_match_score,
        CASE 
            WHEN c.avg_score >= 5 THEN 'ОТЛИЧНО'
            WHEN c.avg_score >= 4 THEN 'ХОРОШО'
            WHEN c.avg_score >= 2 THEN 'СРЕДНЕ'
            ELSE 'ПЛОХО'
        END as quality_level
    FROM combinations c
    CROSS JOIN totals t
    ORDER BY c.cnt DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Функция полного анализа системы
CREATE OR REPLACE FUNCTION generate_system_health_report()
RETURNS TABLE(
    report_section VARCHAR(50),
    metric_name VARCHAR(100),
    current_value TEXT,
    status VARCHAR(15),
    recommendation TEXT
) AS $$
DECLARE
    total_unified_orders INTEGER;
    temporary_orders INTEGER;
    high_quality_orders INTEGER;
    total_files INTEGER;
    failed_files INTEGER;
    orphaned_payments INTEGER;
    missing_fiscal INTEGER;
BEGIN
    -- Получаем базовую статистику
    SELECT COUNT(*) INTO total_unified_orders FROM unified_orders;
    SELECT COUNT(*) INTO temporary_orders FROM unified_orders WHERE is_temporary = TRUE;
    SELECT COUNT(*) INTO high_quality_orders FROM unified_orders WHERE match_score >= 4;
    SELECT COUNT(*) INTO total_files FROM files;
    SELECT COUNT(*) INTO failed_files FROM files WHERE processing_status = 'failed';
    
    SELECT COUNT(*) INTO orphaned_payments 
    FROM unified_orders 
    WHERE (payme_payment_system_id IS NOT NULL OR click_id IS NOT NULL OR uzum_receipt_id IS NOT NULL)
      AND order_number IS NULL;
      
    SELECT COUNT(*) INTO missing_fiscal
    FROM unified_orders 
    WHERE order_number IS NOT NULL 
      AND NOT is_temporary 
      AND fiscal_receipt_number IS NULL;
    
    -- === РАЗДЕЛ: ОБЩАЯ СТАТИСТИКА ===
    report_section := 'ОБЩАЯ СТАТИСТИКА';
    
    metric_name := 'Всего заказов в системе';
    current_value := total_unified_orders::TEXT;
    status := 'INFO';
    recommendation := 'Общее количество записей в unified_orders';
    RETURN NEXT;
    
    metric_name := 'Временные записи';
    current_value := temporary_orders::TEXT || ' (' || ROUND((temporary_orders::DECIMAL/NULLIF(total_unified_orders,0))*100,1) || '%)';
    status := CASE WHEN temporary_orders::DECIMAL/NULLIF(total_unified_orders,0) > 0.3 THEN 'WARNING' ELSE 'OK' END;
    recommendation := CASE WHEN temporary_orders::DECIMAL/NULLIF(total_unified_orders,0) > 0.3 
        THEN 'Много временных записей - нужна консолидация' 
        ELSE 'Нормальный уровень временных записей' END;
    RETURN NEXT;
    
    metric_name := 'Высококачественные заказы';
    current_value := high_quality_orders::TEXT || ' (' || ROUND((high_quality_orders::DECIMAL/NULLIF(total_unified_orders,0))*100,1) || '%)';
    status := CASE WHEN high_quality_orders::DECIMAL/NULLIF(total_unified_orders,0) >= 0.7 THEN 'GOOD' ELSE 'WARNING' END;
    recommendation := 'Заказы с match_score >= 4 (данные из 4+ источников)';
    RETURN NEXT;
    
    -- === РАЗДЕЛ: ФАЙЛЫ И ОБРАБОТКА ===
    report_section := 'ФАЙЛЫ И ОБРАБОТКА';
    
    metric_name := 'Всего файлов';
    current_value := total_files::TEXT;
    status := 'INFO';
    recommendation := 'Количество загруженных файлов';
    RETURN NEXT;
    
    metric_name := 'Файлы с ошибками';
    current_value := failed_files::TEXT;
    status := CASE WHEN failed_files = 0 THEN 'GOOD' WHEN failed_files < 3 THEN 'WARNING' ELSE 'ERROR' END;
    recommendation := CASE WHEN failed_files > 0 THEN 'Проверьте файлы с ошибками обработки' ELSE 'Все файлы обработаны успешно' END;
    RETURN NEXT;
    
    -- === РАЗДЕЛ: КАЧЕСТВО ДАННЫХ ===
    report_section := 'КАЧЕСТВО ДАННЫХ';
    
    metric_name := 'Платежи без заказов';
    current_value := orphaned_payments::TEXT;
    status := CASE WHEN orphaned_payments = 0 THEN 'GOOD' WHEN orphaned_payments < 10 THEN 'WARNING' ELSE 'ERROR' END;
    recommendation := CASE WHEN orphaned_payments > 0 
        THEN 'Есть платежи без соответствующих заказов - проверьте временные интервалы'
        ELSE 'Все платежи сопоставлены с заказами' END;
    RETURN NEXT;
    
    metric_name := 'Заказы без фискальных чеков';
    current_value := missing_fiscal::TEXT;
    status := CASE WHEN missing_fiscal = 0 THEN 'GOOD' WHEN missing_fiscal < total_unified_orders*0.1 THEN 'WARNING' ELSE 'ERROR' END;
    recommendation := CASE WHEN missing_fiscal > 0 
        THEN 'Не все заказы имеют фискальные чеки - проверьте загрузку fiscal_bills'
        ELSE 'Все заказы имеют фискальные чеки' END;
    RETURN NEXT;
    
    RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Функция проверки качества объединенных данных
CREATE OR REPLACE FUNCTION validate_unified_order_quality(
    p_order_id BIGINT
) RETURNS TABLE(
    validation_type VARCHAR(50),
    is_valid BOOLEAN,
    error_message TEXT,
    severity VARCHAR(20)
) AS $$
DECLARE
    order_rec RECORD;
BEGIN
    -- Получаем запись заказа
    SELECT * INTO order_rec FROM unified_orders WHERE id = p_order_id;
    
    IF order_rec IS NULL THEN
        validation_type := 'EXISTENCE_CHECK';
        is_valid := FALSE;
        error_message := 'Заказ не найден';
        severity := 'CRITICAL';
        RETURN NEXT;
        RETURN;
    END IF;
    
    -- 1. Проверка основных полей
    validation_type := 'REQUIRED_FIELDS';
    is_valid := (order_rec.order_number IS NOT NULL AND order_rec.machine_code IS NOT NULL);
    error_message := CASE 
        WHEN order_rec.order_number IS NULL THEN 'Отсутствует номер заказа'
        WHEN order_rec.machine_code IS NULL THEN 'Отсутствует код автомата'
        ELSE NULL
    END;
    severity := CASE WHEN is_valid THEN 'INFO' ELSE 'HIGH' END;
    RETURN NEXT;
    
    -- 2. Проверка оценки совпадения
    validation_type := 'MATCH_SCORE';
    is_valid := (order_rec.match_score >= 2);
    error_message := CASE 
        WHEN order_rec.match_score < 2 THEN 'Низкая оценка совпадения данных (< 2)'
        ELSE 'Хорошая оценка совпадения: ' || order_rec.match_score::TEXT
    END;
    severity := CASE 
        WHEN order_rec.match_score >= 4 THEN 'INFO'
        WHEN order_rec.match_score >= 2 THEN 'LOW'
        ELSE 'HIGH'
    END;
    RETURN NEXT;
    
    RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- =====================================================
-- ПРЕДСТАВЛЕНИЯ ДЛЯ МОНИТОРИНГА ЧАСТИЧНОЙ ЗАГРУЗКИ
-- =====================================================

-- Представление для мониторинга процесса загрузки по файлам
CREATE OR REPLACE VIEW v_file_processing_progress AS
SELECT 
    f.id,
    f.original_name,
    f.file_type,
    f.processing_status,
    f.records_count,
    f.processed_records,
    f.matched_records,
    f.error_records,
    
    -- Прогресс обработки
    CASE 
        WHEN f.records_count > 0 
        THEN ROUND((f.processed_records::DECIMAL / f.records_count) * 100, 1)
        ELSE 0 
    END as processing_percentage,
    
    -- Прогресс сопоставления
    CASE 
        WHEN f.processed_records > 0 
        THEN ROUND((f.matched_records::DECIMAL / f.processed_records) * 100, 1)
        ELSE 0 
    END as matching_percentage,
    
    -- Влияние на общую базу данных
    (
        SELECT COUNT(*) 
        FROM unified_orders u 
        WHERE f.id::TEXT = ANY(u.source_files)
    ) as unified_records_affected,
    
    f.uploaded_at,
    f.processing_started_at,
    f.processing_finished_at,
    
    -- Время обработки
    CASE 
        WHEN f.processing_finished_at IS NOT NULL AND f.processing_started_at IS NOT NULL
        THEN EXTRACT(EPOCH FROM (f.processing_finished_at - f.processing_started_at))::INTEGER
        ELSE NULL 
    END as processing_duration_seconds
    
FROM files f
ORDER BY f.uploaded_at DESC;

-- Включаем RLS на новую таблицу file_type_templates
ALTER TABLE file_type_templates ENABLE ROW LEVEL SECURITY;

-- Политики для file_type_templates
CREATE POLICY "Authenticated users can view file type templates" 
ON file_type_templates 
FOR SELECT 
TO authenticated 
USING (true);

CREATE POLICY "Operators can manage file type templates" 
ON file_type_templates 
FOR ALL 
TO authenticated 
USING (has_role(auth.uid(), 'operator'::character varying));

-- Исправляем функции добавив SET search_path
CREATE OR REPLACE FUNCTION calculate_column_match_percentage(
    file_headers TEXT[],
    template_type VARCHAR(50),
    template_language VARCHAR(10)
) RETURNS DECIMAL(5,2) AS $$
DECLARE
    template_headers TEXT[];
    normalized_file_headers TEXT[];
    normalized_template_headers TEXT[];
    matches INTEGER := 0;
    total_template_columns INTEGER;
BEGIN
    -- Получаем эталонные заголовки для типа и языка
    SELECT array_agg(column_name ORDER BY column_order)
    INTO template_headers
    FROM file_type_templates
    WHERE file_type = template_type AND language = template_language;
    
    IF template_headers IS NULL OR array_length(template_headers, 1) = 0 THEN
        RETURN 0;
    END IF;
    
    total_template_columns := array_length(template_headers, 1);
    
    -- Нормализуем заголовки файла
    SELECT array_agg(lower(trim(header)))
    INTO normalized_file_headers
    FROM unnest(file_headers) AS header;
    
    -- Нормализуем эталонные заголовки
    SELECT array_agg(lower(trim(header)))
    INTO normalized_template_headers
    FROM unnest(template_headers) AS header;
    
    -- Считаем совпадения
    FOR i IN 1..array_length(normalized_template_headers, 1) LOOP
        IF normalized_template_headers[i] = ANY(normalized_file_headers) THEN
            matches := matches + 1;
        END IF;
    END LOOP;
    
    -- Возвращаем процент совпадения
    RETURN ROUND((matches::DECIMAL / total_template_columns) * 100, 2);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION detect_file_type_by_columns(
    file_headers TEXT[]
) RETURNS TABLE(
    file_type VARCHAR(50),
    language VARCHAR(10),
    match_percentage DECIMAL(5,2),
    confidence_level VARCHAR(20)
) AS $$
DECLARE
    type_record RECORD;
    match_percent DECIMAL(5,2);
BEGIN
    -- Проверяем все возможные типы и языки
    FOR type_record IN 
        SELECT DISTINCT ft.file_type, ft.language
        FROM file_type_templates ft
    LOOP
        -- Вычисляем процент совпадения
        SELECT calculate_column_match_percentage(
            file_headers, 
            type_record.file_type, 
            type_record.language
        ) INTO match_percent;
        
        -- Определяем уровень уверенности
        file_type := type_record.file_type;
        language := type_record.language;
        match_percentage := match_percent;
        
        confidence_level := CASE
            WHEN match_percent >= 95 THEN 'ОЧЕНЬ ВЫСОКИЙ'
            WHEN match_percent >= 85 THEN 'ВЫСОКИЙ'
            WHEN match_percent >= 70 THEN 'СРЕДНИЙ'
            WHEN match_percent >= 50 THEN 'НИЗКИЙ'
            ELSE 'ОЧЕНЬ НИЗКИЙ'
        END;
        
        -- Возвращаем только результаты с совпадением > 0
        IF match_percent > 0 THEN
            RETURN NEXT;
        END IF;
    END LOOP;
    
    RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION hardware_record_exists(
    p_order_number VARCHAR(255),
    p_machine_code VARCHAR(50),
    p_creation_time TIMESTAMP,
    p_order_price DECIMAL(12,2)
) RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM hardware_orders 
        WHERE order_number = p_order_number
          AND machine_code = p_machine_code
          AND creation_time = p_creation_time
          AND order_price = p_order_price
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION sales_record_exists(
    p_order_number VARCHAR(255),
    p_machine_code VARCHAR(50),
    p_formatted_time TIMESTAMP,
    p_order_price DECIMAL(12,2)
) RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM sales_reports 
        WHERE order_number = p_order_number
          AND machine_code = p_machine_code
          AND formatted_time = p_formatted_time
          AND order_price = p_order_price
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION fiscal_record_exists(
    p_receipt_number VARCHAR(50),
    p_fiscal_module VARCHAR(100),
    p_operation_datetime TIMESTAMP,
    p_operation_amount DECIMAL(12,2)
) RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM fiscal_receipts 
        WHERE receipt_number = p_receipt_number
          AND fiscal_module = p_fiscal_module
          AND operation_datetime = p_operation_datetime
          AND operation_amount = p_operation_amount
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION process_new_file(
    p_filename VARCHAR(255),
    p_original_name VARCHAR(255),
    p_content_hash VARCHAR(64),
    p_file_headers TEXT[]
) RETURNS TABLE(
    file_id INTEGER,
    detected_type VARCHAR(50),
    detected_language VARCHAR(10),
    match_percentage DECIMAL(5,2),
    is_duplicate BOOLEAN,
    duplicate_of_id INTEGER,
    processing_status VARCHAR(50),
    error_message TEXT
) AS $$
DECLARE
    v_file_id INTEGER;
    v_duplicate_file_id INTEGER;
    v_best_match RECORD;
BEGIN
    -- 1. Проверяем на дубликаты по хешу содержимого
    SELECT id INTO v_duplicate_file_id 
    FROM files 
    WHERE content_hash = p_content_hash 
    LIMIT 1;
    
    -- 2. Определяем тип файла по столбцам
    SELECT dt.file_type, dt.language, dt.match_percentage
    INTO v_best_match
    FROM detect_file_type_by_columns(p_file_headers) dt
    WHERE dt.match_percentage >= 85
    ORDER BY dt.match_percentage DESC
    LIMIT 1;
    
    -- 3. Создаем запись в таблице files
    INSERT INTO files (
        filename, original_name, content_hash,
        file_type, similarity_percent, duplicate_of_id,
        processing_status, detected_encoding
    ) VALUES (
        p_filename, p_original_name, p_content_hash,
        COALESCE(v_best_match.file_type, 'unknown'),
        COALESCE(v_best_match.match_percentage, 0),
        v_duplicate_file_id,
        CASE 
            WHEN v_duplicate_file_id IS NOT NULL THEN 'duplicate'
            WHEN v_best_match.file_type IS NULL THEN 'type_unknown'
            ELSE 'pending'
        END,
        'utf-8'
    ) RETURNING id INTO v_file_id;
    
    -- 4. Возвращаем результат
    file_id := v_file_id;
    detected_type := COALESCE(v_best_match.file_type, 'unknown');
    detected_language := COALESCE(v_best_match.language, 'unknown');
    match_percentage := COALESCE(v_best_match.match_percentage, 0);
    is_duplicate := (v_duplicate_file_id IS NOT NULL);
    duplicate_of_id := v_duplicate_file_id;
    processing_status := CASE 
        WHEN v_duplicate_file_id IS NOT NULL THEN 'duplicate'
        WHEN v_best_match.file_type IS NULL THEN 'type_unknown'
        ELSE 'ready_for_processing'
    END;
    error_message := CASE
        WHEN v_duplicate_file_id IS NOT NULL THEN 'Файл является дубликатом существующего'
        WHEN v_best_match.file_type IS NULL THEN 'Не удалось определить тип файла'
        ELSE NULL
    END;
    
    RETURN NEXT;
    RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;