-- =====================================================
-- СИСТЕМА ОПРЕДЕЛЕНИЯ ТИПОВ ФАЙЛОВ ПО СТОЛБЦАМ
-- =====================================================

-- Таблица эталонных шаблонов столбцов для каждого типа файла
CREATE TABLE IF NOT EXISTS file_type_templates (
    id SERIAL PRIMARY KEY,
    file_type VARCHAR(50) NOT NULL,
    language VARCHAR(10) NOT NULL,
    column_name VARCHAR(255) NOT NULL,
    column_order INTEGER,
    is_required BOOLEAN DEFAULT TRUE,
    data_type VARCHAR(50),
    sample_value TEXT
);

-- Вставляем эталонные шаблоны для Hardware Orders (English)
INSERT INTO file_type_templates (file_type, language, column_name, column_order, data_type, sample_value) VALUES
('hardware', 'eng', 'Order number', 1, 'varchar', 'ff00000304202508040701283266181f0000'),
('hardware', 'eng', 'Operator Code', 2, 'varchar', 'G9982401B-1'),
('hardware', 'eng', 'Goods name', 3, 'varchar', 'MacCoffee 3in1'),
('hardware', 'eng', 'Flavour name', 4, 'varchar', 'MacCoffee с сахаром'),
('hardware', 'eng', 'Order resource', 5, 'varchar', 'Cash payment'),
('hardware', 'eng', 'Order type', 6, 'varchar', 'Normal order'),
('hardware', 'eng', 'Order status', 7, 'varchar', 'Paid'),
('hardware', 'eng', 'Cup type', 8, 'integer', '1'),
('hardware', 'eng', 'Machine Code', 9, 'varchar', '3266181f0000'),
('hardware', 'eng', 'Address', 10, 'text', 'остановка 198 школа'),
('hardware', 'eng', 'Order price', 11, 'decimal', '10000'),
('hardware', 'eng', 'Brew status', 12, 'varchar', 'Delivered'),
('hardware', 'eng', 'Creation time', 13, 'timestamp', '2025-08-04 04:01:30'),
('hardware', 'eng', 'Paying time', 14, 'timestamp', '2025-08-04 04:01:30'),
('hardware', 'eng', 'Brewing time', 15, 'timestamp', '2025-08-04 04:01:30'),
('hardware', 'eng', 'Delivery time', 16, 'timestamp', '2025-08-04 04:02:19'),
('hardware', 'eng', 'Refund time', 17, 'timestamp', NULL),
('hardware', 'eng', 'Pay Card', 18, 'varchar', NULL),
('hardware', 'eng', 'Reason', 19, 'text', NULL),
('hardware', 'eng', 'Remark', 20, 'text', NULL)
ON CONFLICT (file_type, language, column_name) DO NOTHING;

-- Hardware Orders (Russian)
INSERT INTO file_type_templates (file_type, language, column_name, column_order, data_type, sample_value) VALUES
('hardware', 'rus', 'Номер заказа', 1, 'varchar', 'ff00000304202508040701283266181f0000'),
('hardware', 'rus', 'Номер оператора', 2, 'varchar', 'G9982401B-1'),
('hardware', 'rus', 'Наименование товара', 3, 'varchar', 'MacCoffee 3in1'),
('hardware', 'rus', 'Название вкуса', 4, 'varchar', 'MacCoffee с сахаром'),
('hardware', 'rus', 'Ресурс заказа', 5, 'varchar', 'Оплата наличными'),
('hardware', 'rus', 'Тип заказа', 6, 'varchar', 'Обычный порядок'),
('hardware', 'rus', 'Статус платежа', 7, 'varchar', 'Оплачено'),
('hardware', 'rus', 'Тип чашки', 8, 'integer', '1'),
('hardware', 'rus', 'Машинный код', 9, 'varchar', '3266181f0000'),
('hardware', 'rus', 'Адрес', 10, 'text', 'остановка 198 школа'),
('hardware', 'rus', 'Цена заказа', 11, 'decimal', '10000'),
('hardware', 'rus', 'Статус варки', 12, 'varchar', 'Доставлен'),
('hardware', 'rus', 'Время создания', 13, 'timestamp', '2025-08-04 04:01:30'),
('hardware', 'rus', 'Время оплаты', 14, 'timestamp', '2025-08-04 04:01:30'),
('hardware', 'rus', 'Время заваривания', 15, 'timestamp', '2025-08-04 04:01:30'),
('hardware', 'rus', 'Срок поставки', 16, 'timestamp', '2025-08-04 04:02:19'),
('hardware', 'rus', 'Время возврата денег', 17, 'timestamp', NULL),
('hardware', 'rus', 'Платежная карта', 18, 'varchar', NULL),
('hardware', 'rus', 'Причина', 19, 'text', NULL),
('hardware', 'rus', 'Замечание', 20, 'text', NULL)
ON CONFLICT (file_type, language, column_name) DO NOTHING;

-- Sales Reports (Russian)
INSERT INTO file_type_templates (file_type, language, column_name, column_order, data_type, sample_value) VALUES
('sales', 'rus', 'ID', 1, 'integer', '8774'),
('sales', 'rus', 'Номер заказа', 2, 'varchar', 'ff0000025520250701025853a7ca181f0000'),
('sales', 'rus', 'ID товара', 3, 'integer', '380'),
('sales', 'rus', 'Время', 4, 'decimal', '45838.99988425926'),
('sales', 'rus', 'Наименование товара', 5, 'varchar', 'Hot Chocolate'),
('sales', 'rus', 'Цена заказа', 6, 'decimal', '15000.00'),
('sales', 'rus', 'Код ИКПУ', 7, 'varchar', '2202004001000000'),
('sales', 'rus', 'Штрих код', 8, 'varchar', 'Нет данных'),
('sales', 'rus', 'Маркировка', 9, 'varchar', 'Нет данных'),
('sales', 'rus', 'Ресурс заказа', 10, 'varchar', 'cash'),
('sales', 'rus', 'Тип платежа', 11, 'varchar', 'Наличные'),
('sales', 'rus', 'Категория машины', 12, 'varchar', 'перевушка'),
('sales', 'rus', 'Машинный код', 13, 'varchar', 'a7ca181f0000'),
('sales', 'rus', 'Начисленный бонус', 14, 'decimal', '0.00'),
('sales', 'rus', 'Имя пользователя', 15, 'varchar', 'Не определен')
ON CONFLICT (file_type, language, column_name) DO NOTHING;

-- Fiscal Receipts (Russian)
INSERT INTO file_type_templates (file_type, language, column_name, column_order, data_type, sample_value) VALUES
('fiscal', 'rus', '№', 1, 'integer', '1'),
('fiscal', 'rus', 'Дата и время', 2, 'timestamp', '2025-05-27 11:03:27'),
('fiscal', 'rus', 'Операция', 3, 'varchar', 'Продажа'),
('fiscal', 'rus', 'Номер чека', 4, 'integer', '2'),
('fiscal', 'rus', 'Кассир', 5, 'varchar', 'VendiHub Online'),
('fiscal', 'rus', 'Торговый пункт', 6, 'varchar', 'Сервер'),
('fiscal', 'rus', 'Фискальный модуль', 7, 'varchar', 'LG420230630322'),
('fiscal', 'rus', 'Наличные', 8, 'decimal', '12000'),
('fiscal', 'rus', 'Карта', 9, 'decimal', '0'),
('fiscal', 'rus', 'Сумма операции', 10, 'decimal', '12000'),
('fiscal', 'rus', 'Номер рецепта', 11, 'varchar', NULL),
('fiscal', 'rus', 'Покупатель', 12, 'varchar', NULL)
ON CONFLICT (file_type, language, column_name) DO NOTHING;

-- Payme Payments (Russian)
INSERT INTO file_type_templates (file_type, language, column_name, column_order, data_type, sample_value) VALUES
('payme', 'rus', '№', 1, 'integer', '1'),
('payme', 'rus', 'НАЗВАНИЕ ПОСТАВЩИКA', 2, 'varchar', 'HUB'),
('payme', 'rus', 'НАЗВАНИЕ КАССЫ', 3, 'varchar', 'VendHub LLC'),
('payme', 'rus', 'СОСТОЯНИЕ ОПЛАТЫ', 4, 'varchar', 'ОПЛАЧЕНО'),
('payme', 'rus', 'ВРЕМЯ ОПЛАТЫ', 5, 'varchar', '23-05-2025 14:35:49'),
('payme', 'rus', 'ВРЕМЯ ОТМЕНЫ', 6, 'varchar', 'N/A'),
('payme', 'rus', 'ПРОЦЕССИНГОВОЕ ВРЕМЯ ОПЕРАЦИИ', 7, 'varchar', '23-05-2025 14:35:51'),
('payme', 'rus', 'ОПЕРАЦИОННОЕ ВРЕМЯ БАНКА', 8, 'varchar', 'N/A'),
('payme', 'rus', 'СОСТОЯНИЕ', 9, 'varchar', 'N/A'),
('payme', 'rus', 'НАЗВАНИЕ ПРОЦЕССИНГА', 10, 'varchar', 'HUMO'),
('payme', 'rus', 'ePos Merchant ID', 11, 'varchar', '011800492427503'),
('payme', 'rus', 'ePos Terminal ID', 12, 'varchar', '35620620'),
('payme', 'rus', 'НОМЕР КАРТЫ', 13, 'varchar', '986035******3061'),
('payme', 'rus', 'СУММА БЕЗ КОМИССИИ', 14, 'decimal', '10000'),
('payme', 'rus', 'КОМИССИЯ С КЛИЕНТА', 15, 'varchar', 'N/A'),
('payme', 'rus', 'ИДЕНТИФИКАТОР ПЛАТЕЖА (ПЛАТЕЖНАЯ СИСТЕМА)', 16, 'varchar', '683041472f4617567e1d800e'),
('payme', 'rus', 'ИДЕНТИФИКАТОР ПЛАТЕЖА (ПОСТАВЩИК)', 17, 'varchar', '683041472f4617567e1d800e'),
('payme', 'rus', 'RRN', 18, 'varchar', '514309086214'),
('payme', 'rus', 'ИДЕНТИФИКАТОР КЕШБОКСА', 19, 'varchar', '682c4dbf7e520fa86770fe0f'),
('payme', 'rus', 'ИДЕНТИФИКАТОР КАССЫ', 20, 'varchar', '682af8225a11e938e9a1f877'),
('payme', 'rus', 'ДАТА БАНКОВСКОГО ПОСТУПЛЕНИЯ', 21, 'date', '23-05-2025'),
('payme', 'rus', 'ФИСКАЛЬНЫЙ ПРИЗНАК', 22, 'varchar', '205537029102'),
('payme', 'rus', 'ИДЕНТИФИКАТОР ФИСКАЛЬНОГО ЧЕКА', 23, 'varchar', '9866760'),
('payme', 'rus', 'EXTERNAL ID', 24, 'varchar', 'N/A'),
('payme', 'rus', 'ОПИСАНИЕ ПЛАТЕЖА', 25, 'varchar', 'N/A'),
('payme', 'rus', 'НОМЕР ЗАКАЗА', 26, 'varchar', '17524')
ON CONFLICT (file_type, language, column_name) DO NOTHING;

-- Click Payments (Russian)
INSERT INTO file_type_templates (file_type, language, column_name, column_order, data_type, sample_value) VALUES
('click', 'rus', 'Дата', 1, 'timestamp', '2025-08-02 20:48:30'),
('click', 'rus', 'Сервис', 2, 'varchar', 'Vendhub'),
('click', 'rus', 'Клиент', 3, 'varchar', '99899***7278'),
('click', 'rus', 'Способ оплаты', 4, 'varchar', '986035******2665'),
('click', 'rus', 'Сумма', 5, 'decimal', '20000'),
('click', 'rus', 'Идент-р', 6, 'varchar', '33040'),
('click', 'rus', 'Касса', 7, 'varchar', NULL),
('click', 'rus', 'Click ID', 8, 'varchar', '4284973632'),
('click', 'rus', 'Billing ID', 9, 'varchar', '3209532077'),
('click', 'rus', 'Статус платежа', 10, 'varchar', 'Успешно подтвержден')
ON CONFLICT (file_type, language, column_name) DO NOTHING;

-- Uzum Payments (Russian)
INSERT INTO file_type_templates (file_type, language, column_name, column_order, data_type, sample_value) VALUES
('uzum', 'rus', 'Название сервиса', 1, 'varchar', 'Кофейный вендинговый аппарат'),
('uzum', 'rus', 'Сумма', 2, 'decimal', '20000'),
('uzum', 'rus', 'Комиссия', 3, 'decimal', '400'),
('uzum', 'rus', 'Тип карты', 4, 'varchar', 'UZCARD'),
('uzum', 'rus', 'Номер карты', 5, 'varchar', '561468******1701'),
('uzum', 'rus', 'Статус', 6, 'varchar', 'SUCCESS'),
('uzum', 'rus', 'merchantId', 7, 'varchar', '90640007693'),
('uzum', 'rus', 'receiptId', 8, 'varchar', 'a3f666d9-4abf-4b15-ae55-b5b59881b823'),
('uzum', 'rus', 'Дата и время', 9, 'varchar', '27.04.2025, 19:10:40')
ON CONFLICT (file_type, language, column_name) DO NOTHING;

-- =====================================================
-- ФУНКЦИИ ОПРЕДЕЛЕНИЯ ТИПА ФАЙЛА ПО СТОЛБЦАМ
-- =====================================================

-- Функция вычисления процента совпадения столбцов
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Функция определения типа файла
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- ФУНКЦИИ ПРОВЕРКИ СУЩЕСТВОВАНИЯ ЗАПИСЕЙ
-- =====================================================

-- Функция проверки существования записи в hardware_orders
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Функция проверки существования записи в sales_reports
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Функция проверки существования фискального чека
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- ФУНКЦИЯ ОБРАБОТКИ НОВОГО ФАЙЛА
-- =====================================================

-- Функция обработки нового файла
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
$$ LANGUAGE plpgsql SECURITY DEFINER;