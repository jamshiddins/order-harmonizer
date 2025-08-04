-- =====================================================
-- Удаляем старые таблицы и создаем новую структуру
-- =====================================================

-- Удаляем старые таблицы если они существуют
DROP TABLE IF EXISTS order_errors CASCADE;
DROP TABLE IF EXISTS order_changes CASCADE;
DROP TABLE IF EXISTS unified_orders CASCADE;
DROP TABLE IF EXISTS uzum_payments CASCADE;
DROP TABLE IF EXISTS click_payments CASCADE;
DROP TABLE IF EXISTS payme_payments CASCADE;
DROP TABLE IF EXISTS fiscal_receipts CASCADE;
DROP TABLE IF EXISTS sales_reports CASCADE;
DROP TABLE IF EXISTS hardware_orders CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS machines CASCADE;

-- Пересоздаем files с обновленной структурой
DROP TABLE IF EXISTS files CASCADE;

-- =====================================================
-- 8. FILES - Управление файлами-источниками
-- =====================================================
CREATE TABLE files (
    -- Системные поля
    id                      SERIAL PRIMARY KEY,
    
    -- Информация о файле
    filename                VARCHAR(255) NOT NULL,              -- Системное имя файла
    original_name           VARCHAR(255) NOT NULL,              -- Оригинальное имя файла
    file_type               VARCHAR(50) NOT NULL,               -- 'hardware', 'sales', 'fiscal', 'payme', 'click', 'uzum'
    content_hash            VARCHAR(64) NOT NULL,               -- SHA256 хеш содержимого
    file_size               BIGINT,                             -- Размер файла в байтах
    file_url                TEXT,                               -- URL файла в облаке
    
    -- Статистика обработки
    records_count           INTEGER DEFAULT 0,                  -- Количество записей в файле
    processed_records       INTEGER DEFAULT 0,                  -- Количество обработанных записей
    matched_records         INTEGER DEFAULT 0,                  -- Количество сопоставленных записей
    error_records           INTEGER DEFAULT 0,                  -- Количество записей с ошибками
    
    -- Информация о дубликатах
    similarity_percent      DECIMAL(5,2),                       -- Процент схожести с другими файлами
    duplicate_of_id         INTEGER REFERENCES files(id),       -- Ссылка на оригинальный файл если дубликат
    
    -- Метаданные загрузки
    uploaded_by             UUID REFERENCES profiles(user_id),  -- ID пользователя
    uploaded_at             TIMESTAMP DEFAULT NOW(),            -- Время загрузки
    processing_started_at   TIMESTAMP,                          -- Время начала обработки
    processing_finished_at  TIMESTAMP,                          -- Время окончания обработки
    processing_status       VARCHAR(50) DEFAULT 'pending',     -- 'pending', 'processing', 'completed', 'failed'
    error_message           TEXT,                               -- Сообщение об ошибке если обработка неудачная
    
    -- Дополнительная информация
    detected_encoding       VARCHAR(50),                        -- Определенная кодировка файла
    detected_delimiter      VARCHAR(10),                        -- Определенный разделитель (для CSV)
    sheet_names             TEXT[],                             -- Имена листов (для Excel)
    processed_sheet         VARCHAR(255)                        -- Обработанный лист
);

-- =====================================================
-- 1. HARDWARE_ORDERS - Основной источник заказов (HW.xlsx)
-- =====================================================
CREATE TABLE hardware_orders (
    -- Системные поля
    id                      BIGSERIAL PRIMARY KEY,
    
    -- Основные поля заказа
    order_number            VARCHAR(255) UNIQUE NOT NULL,          -- ff0000025520250701025853a7ca181f0000
    address                 TEXT,                                  -- кудрат первушка
    machine_code            VARCHAR(50),                           -- a7ca181f0000
    
    -- Информация о товаре
    goods_name              VARCHAR(255),                          -- Hot Chocolate
    taste_name              VARCHAR(255),                          -- Горячий шоколад
    order_type              VARCHAR(100) DEFAULT 'Normal order',  -- Normal order / Shopping cart order
    
    -- Платеж и статусы
    order_resource          VARCHAR(100),                          -- Cash payment / Custom payment / testShipment
    payment_status          VARCHAR(50) DEFAULT 'Paid',           -- Paid / Refunded
    brew_status             VARCHAR(50),                           -- Delivered / Not delivered / Delivery failure
    order_price             DECIMAL(12,2),                         -- 15000 (в суммах)
    
    -- Временные метки
    creation_time           TIMESTAMP,                             -- 2025-06-30 23:59:06
    paying_time             TIMESTAMP,                             -- 2025-06-30 23:59:06
    brewing_time            TIMESTAMP,                             -- 2025-06-30 23:59:06
    delivery_time           TIMESTAMP,                             -- 2025-06-30 23:59:50
    refund_time             TIMESTAMP,                             -- NULL (только при возврате)
    
    -- Дополнительные поля
    reason                  TEXT,                                  -- Причина проблемы (если есть)
    
    -- Метаданные
    source_file_id          INTEGER REFERENCES files(id),
    created_at              TIMESTAMP DEFAULT NOW(),
    updated_at              TIMESTAMP DEFAULT NOW(),
    version                 INTEGER DEFAULT 1
);

-- =====================================================
-- 2. SALES_REPORTS - Дополняет заказы из HWH (report.xlsx)
-- =====================================================
CREATE TABLE sales_reports (
    -- Системные поля
    id                      BIGSERIAL PRIMARY KEY,
    
    -- Основные идентификаторы
    report_id               INTEGER,                               -- 8774 (ID)
    order_number            VARCHAR(255),                         -- ff0000025520250701025853a7ca181f0000
    goods_id                INTEGER,                              -- 380 (Goods ID)
    
    -- Информация о времени
    time_value              DECIMAL(20,10),                       -- 45838.99988425926 (Excel время)
    formatted_time          TIMESTAMP,                            -- Преобразованное время для сравнения
    
    -- Товар и цена
    goods_name              VARCHAR(255),                         -- Hot Chocolate
    order_price             DECIMAL(12,2),                        -- 15000.00
    
    -- Коды и идентификаторы
    ikpu_code               VARCHAR(50),                          -- 2202004001000000 (ИКПУ)
    barcode                 VARCHAR(100) DEFAULT 'Нет данных',   -- Штрих код
    marking                 VARCHAR(100) DEFAULT 'Нет данных',   -- Маркировка
    
    -- Платеж и ресурсы
    order_resource          VARCHAR(100),                         -- cash
    payment_type            VARCHAR(100),                         -- Наличные
    
    -- Машина и категория
    machine_category        VARCHAR(255),                         -- перевушка
    machine_code            VARCHAR(50),                          -- a7ca181f0000
    
    -- Бонусы и пользователь
    accrued_bonus           DECIMAL(10,2) DEFAULT 0,             -- 0.00
    username                VARCHAR(255) DEFAULT 'Не определен', -- Не определен
    
    -- Метаданные
    source_file_id          INTEGER REFERENCES files(id),
    created_at              TIMESTAMP DEFAULT NOW(),
    updated_at              TIMESTAMP DEFAULT NOW(),
    version                 INTEGER DEFAULT 1
);

-- =====================================================
-- 3. FISCAL_RECEIPTS - Фискальные чеки (fiscal_bills.xlsx)
-- =====================================================
CREATE TABLE fiscal_receipts (
    -- Системные поля
    id                      BIGSERIAL PRIMARY KEY,
    
    -- Основные идентификаторы чека
    receipt_number          VARCHAR(50) NOT NULL,                 -- 885
    fiscal_module           VARCHAR(100),                         -- LG420230630322
    recipe_number           VARCHAR(50),                          -- Номер рецепта
    
    -- Информация об операции
    operation_type          VARCHAR(50) DEFAULT 'Продажа',       -- Продажа
    cashier                 VARCHAR(255),                         -- VendiHub Online
    trade_point             VARCHAR(255),                         -- Сервер
    
    -- Суммы операции
    operation_amount        DECIMAL(12,2) NOT NULL,              -- 15000
    cash_amount             DECIMAL(12,2) DEFAULT 0,             -- 15000 (наличные)
    card_amount             DECIMAL(12,2) DEFAULT 0,             -- 0 (по карте)
    
    -- Покупатель
    customer_info           TEXT,                                 -- Информация о покупателе
    
    -- Временная метка
    operation_datetime      TIMESTAMP NOT NULL,                  -- 2025-06-16 07:06:42
    
    -- Метаданные
    source_file_id          INTEGER REFERENCES files(id),
    created_at              TIMESTAMP DEFAULT NOW(),
    updated_at              TIMESTAMP DEFAULT NOW(),
    version                 INTEGER DEFAULT 1
);

-- =====================================================
-- 4. PAYME_PAYMENTS - Платежи через Payme (Payme.xlsx)
-- =====================================================
CREATE TABLE payme_payments (
    -- Системные поля
    id                      BIGSERIAL PRIMARY KEY,
    
    -- Номер в отчете
    report_number           INTEGER,                              -- № (порядковый номер)
    
    -- Основная информация
    provider_name           VARCHAR(100),                         -- HUB (НАЗВАНИЕ ПОСТАВЩИКA)
    cashbox_name            VARCHAR(255),                         -- VendHub LLC (НАЗВАНИЕ КАССЫ)
    payment_state           VARCHAR(50),                          -- ОПЛАЧЕНО (СОСТОЯНИЕ ОПЛАТЫ)
    
    -- Временные метки
    payment_time            TIMESTAMP,                            -- 16-06-2025 12:07:29 (ВРЕМЯ ОПЛАТЫ)
    cancel_time             TIMESTAMP,                            -- N/A (ВРЕМЯ ОТМЕНЫ)
    processing_time         TIMESTAMP,                            -- 16-06-2025 12:07:28 (ПРОЦЕССИНГОВОЕ ВРЕМЯ)
    bank_time               TIMESTAMP,                            -- N/A (ОПЕРАЦИОННОЕ ВРЕМЯ БАНКА)
    
    -- Процессинг и состояние
    state                   VARCHAR(50),                          -- N/A (СОСТОЯНИЕ)
    processing_name         VARCHAR(100),                         -- UZCARD (НАЗВАНИЕ ПРОЦЕССИНГА)
    
    -- ePos данные
    epos_merchant_id        VARCHAR(50),                          -- 906292
    epos_terminal_id        VARCHAR(50),                          -- 96300282
    
    -- Платежная информация
    card_number             VARCHAR(50),                          -- 860033******4372 (НОМЕР КАРТЫ)
    amount_without_commission DECIMAL(12,2),                     -- 20000 (СУММА БЕЗ КОМИССИИ)
    client_commission       DECIMAL(12,2),                       -- N/A (КОМИССИЯ С КЛИЕНТА)
    
    -- Идентификаторы платежа
    payment_system_id       VARCHAR(255),                        -- 684fc2aeedb85b85cd0f099e (ИДЕНТИФИКАТОР ПЛАТЕЖНОЙ СИСТЕМЫ)
    provider_payment_id     VARCHAR(255),                        -- 684fc2aeedb85b85cd0f099e (ИДЕНТИФИКАТОР ПОСТАВЩИКА)
    rrn                     VARCHAR(50),                         -- 025149539584
    
    -- Дополнительные идентификаторы
    cashbox_identifier      VARCHAR(255),                        -- 682c4dc07e520fa86771229a (ИДЕНТИФИКАТОР КЕШБОКСА)
    cash_register_id        VARCHAR(255),                        -- 682af8225a11e938e9a1f877 (ИДЕНТИФИКАТОР КАССЫ)
    
    -- Банковские данные
    bank_receipt_date       DATE,                                -- 16-06-2025 (ДАТА БАНКОВСКОГО ПОСТУПЛЕНИЯ)
    fiscal_sign             VARCHAR(50),                         -- 901000240615 (ФИСКАЛЬНЫЙ ПРИЗНАК)
    fiscal_receipt_id       VARCHAR(50),                         -- 33087269 (ИДЕНТИФИКАТОР ФИСКАЛЬНОГО ЧЕКА)
    
    -- Дополнительная информация
    external_id             VARCHAR(255),                        -- N/A (EXTERNAL ID)
    payment_description     TEXT,                                -- N/A (ОПИСАНИЕ ПЛАТЕЖА)
    order_number            VARCHAR(50),                         -- 22622 (НОМЕР ЗАКАЗА)
    
    -- Метаданные
    source_file_id          INTEGER REFERENCES files(id),
    created_at              TIMESTAMP DEFAULT NOW(),
    updated_at              TIMESTAMP DEFAULT NOW(),
    version                 INTEGER DEFAULT 1
);

-- =====================================================
-- 5. CLICK_PAYMENTS - Платежи через Click (Click.xlsx)
-- =====================================================
CREATE TABLE click_payments (
    -- Системные поля
    id                      BIGSERIAL PRIMARY KEY,
    
    -- Основные идентификаторы
    click_id                VARCHAR(50) UNIQUE NOT NULL,         -- 4207054231
    billing_id              VARCHAR(50),                         -- 3161773774
    identifier              VARCHAR(50),                         -- 24966 (Идент-р)
    
    -- Информация о платеже
    service_name            VARCHAR(100),                        -- Vendhub
    client_info             VARCHAR(100),                        -- 99893***5666 (замаскированный номер)
    payment_method          VARCHAR(100),                        -- 561468******7178 (номер карты)
    amount                  DECIMAL(12,2) NOT NULL,             -- 20000
    
    -- Статус и касса
    payment_status          VARCHAR(50),                         -- Успешно подтвержден
    cashbox                 VARCHAR(100),                        -- Касса (может быть пустым)
    
    -- Временная метка
    payment_date            TIMESTAMP NOT NULL,                  -- 2025-06-29 21:03:32
    
    -- Метаданные
    source_file_id          INTEGER REFERENCES files(id),
    created_at              TIMESTAMP DEFAULT NOW(),
    updated_at              TIMESTAMP DEFAULT NOW(),
    version                 INTEGER DEFAULT 1
);

-- =====================================================
-- 6. UZUM_PAYMENTS - Платежи через Uzum (uzum.xlsx)
-- =====================================================
CREATE TABLE uzum_payments (
    -- Системные поля
    id                      BIGSERIAL PRIMARY KEY,
    
    -- Основная информация о сервисе
    service_name            VARCHAR(255) NOT NULL,              -- Кофейный вендинговый аппарат
    
    -- Финансовая информация
    amount                  DECIMAL(12,2) NOT NULL,             -- 20000
    commission              DECIMAL(12,2),                      -- 400
    
    -- Карта и тип
    card_type               VARCHAR(50),                        -- UZCARD
    card_number             VARCHAR(50),                        -- 561468******1701
    
    -- Статус платежа
    status                  VARCHAR(50),                        -- SUCCESS
    
    -- Идентификаторы
    merchant_id             VARCHAR(50),                        -- 90640007693
    receipt_id              VARCHAR(255) UNIQUE NOT NULL,      -- a3f666d9-4abf-4b15-ae55-b5b59881b823
    
    -- Временная метка
    payment_datetime        VARCHAR(100),                       -- 27.04.2025, 19:10:40 (оригинальный формат)
    parsed_datetime         TIMESTAMP,                          -- Преобразованная дата
    
    -- Метаданные
    source_file_id          INTEGER REFERENCES files(id),
    created_at              TIMESTAMP DEFAULT NOW(),
    updated_at              TIMESTAMP DEFAULT NOW(),
    version                 INTEGER DEFAULT 1
);

-- =====================================================
-- 7. UNIFIED_ORDERS - Общая база заказов
-- =====================================================
CREATE TABLE unified_orders (
    -- Системные поля
    id                      BIGSERIAL PRIMARY KEY,
    
    -- Основные поля из hardware_orders
    order_number            VARCHAR(255) UNIQUE NOT NULL,       -- Основной идентификатор
    address                 TEXT,
    machine_code            VARCHAR(50),
    goods_name              VARCHAR(255),
    taste_name              VARCHAR(255),
    order_type              VARCHAR(100),
    order_resource          VARCHAR(100),
    payment_status          VARCHAR(50),
    brew_status             VARCHAR(50),
    order_price             DECIMAL(12,2),
    creation_time           TIMESTAMP,
    paying_time             TIMESTAMP,
    brewing_time            TIMESTAMP,
    delivery_time           TIMESTAMP,
    refund_time             TIMESTAMP,
    reason                  TEXT,
    
    -- Поля из sales_reports (префикс vhr_)
    vhr_id                  INTEGER,
    vhr_time                TIMESTAMP,
    vhr_ikpu_code           VARCHAR(50),
    vhr_barcode             VARCHAR(100),
    vhr_marking             VARCHAR(100),
    vhr_payment_type        VARCHAR(100),
    vhr_username            VARCHAR(255),
    vhr_accrued_bonus       DECIMAL(10,2),
    vhr_machine_category    VARCHAR(255),
    
    -- Поля из fiscal_receipts (префикс fiscal_)
    fiscal_receipt_number   VARCHAR(50),
    fiscal_module           VARCHAR(100),
    fiscal_recipe_number    VARCHAR(50),
    fiscal_operation_type   VARCHAR(50),
    fiscal_cashier          VARCHAR(255),
    fiscal_trade_point      VARCHAR(255),
    fiscal_operation_amount DECIMAL(12,2),
    fiscal_cash_amount      DECIMAL(12,2),
    fiscal_card_amount      DECIMAL(12,2),
    fiscal_customer_info    TEXT,
    fiscal_operation_datetime TIMESTAMP,
    
    -- Поля из payme_payments (префикс payme_)
    payme_provider_name     VARCHAR(100),
    payme_cashbox_name      VARCHAR(255),
    payme_payment_state     VARCHAR(50),
    payme_payment_time      TIMESTAMP,
    payme_processing_name   VARCHAR(100),
    payme_card_number       VARCHAR(50),
    payme_amount_without_commission DECIMAL(12,2),
    payme_client_commission DECIMAL(12,2),
    payme_payment_system_id VARCHAR(255),
    payme_provider_payment_id VARCHAR(255),
    payme_rrn               VARCHAR(50),
    payme_fiscal_receipt_id VARCHAR(50),
    payme_order_number      VARCHAR(50),
    
    -- Поля из click_payments (префикс click_)
    click_id                VARCHAR(50),
    click_billing_id        VARCHAR(50),
    click_identifier        VARCHAR(50),
    click_service_name      VARCHAR(100),
    click_client_info       VARCHAR(100),
    click_payment_method    VARCHAR(100),
    click_amount            DECIMAL(12,2),
    click_payment_status    VARCHAR(50),
    click_cashbox           VARCHAR(100),
    click_payment_date      TIMESTAMP,
    
    -- Поля из uzum_payments (префикс uzum_)
    uzum_service_name       VARCHAR(255),
    uzum_amount             DECIMAL(12,2),
    uzum_commission         DECIMAL(12,2),
    uzum_card_type          VARCHAR(50),
    uzum_card_number        VARCHAR(50),
    uzum_status             VARCHAR(50),
    uzum_merchant_id        VARCHAR(50),
    uzum_receipt_id         VARCHAR(255),
    uzum_parsed_datetime    TIMESTAMP,
    
    -- Метаданные
    is_temporary            BOOLEAN DEFAULT FALSE,
    source_files            TEXT[],
    created_at              TIMESTAMP DEFAULT NOW(),
    updated_at              TIMESTAMP DEFAULT NOW(),
    last_matched_at         TIMESTAMP,
    match_score             INTEGER DEFAULT 0
);

-- =====================================================
-- 9. ORDER_CHANGES - История изменений
-- =====================================================
CREATE TABLE order_changes (
    -- Системные поля
    id                      BIGSERIAL PRIMARY KEY,
    
    -- Идентификация записи
    table_name              VARCHAR(50) NOT NULL,
    record_id               BIGINT NOT NULL,
    order_number            VARCHAR(255),
    
    -- Информация об изменении
    field_name              VARCHAR(100) NOT NULL,
    old_value               TEXT,
    new_value               TEXT,
    change_type             VARCHAR(20) NOT NULL,
    
    -- Контекст изменения
    change_reason           TEXT,
    confidence_score        DECIMAL(3,2),
    
    -- Метаданные
    changed_at              TIMESTAMP DEFAULT NOW(),
    source_file_id          INTEGER REFERENCES files(id),
    changed_by              UUID REFERENCES profiles(user_id),
    
    -- Дополнительная информация
    processing_batch_id     UUID,
    validation_status       VARCHAR(50) DEFAULT 'pending'
);

-- =====================================================
-- 10. ORDER_ERRORS - Ошибки сопоставления
-- =====================================================
CREATE TABLE order_errors (
    -- Системные поля
    id                      BIGSERIAL PRIMARY KEY,
    
    -- Информация об ошибке
    order_number            VARCHAR(255),
    error_type              VARCHAR(100) NOT NULL,
    error_code              VARCHAR(50),
    description             TEXT NOT NULL,
    severity                VARCHAR(20) DEFAULT 'medium',
    
    -- Контекст ошибки
    source_table            VARCHAR(50),
    source_record_id        BIGINT,
    target_table            VARCHAR(50),
    target_record_id        BIGINT,
    
    -- Данные для анализа
    conflicting_values      JSONB,
    suggested_resolution    TEXT,
    
    -- Метаданные
    error_timestamp         TIMESTAMP DEFAULT NOW(),
    source_file_id          INTEGER REFERENCES files(id),
    processing_batch_id     UUID,
    
    -- Статус обработки ошибки
    resolution_status       VARCHAR(50) DEFAULT 'open',
    resolved_at             TIMESTAMP,
    resolved_by             UUID REFERENCES profiles(user_id),
    resolution_note         TEXT
);

-- Создаем все индексы
CREATE INDEX idx_hardware_order_number ON hardware_orders(order_number);
CREATE INDEX idx_hardware_machine_code ON hardware_orders(machine_code);
CREATE INDEX idx_hardware_creation_time ON hardware_orders(creation_time);

CREATE INDEX idx_sales_order_number ON sales_reports(order_number);
CREATE INDEX idx_sales_machine_code ON sales_reports(machine_code);
CREATE INDEX idx_sales_formatted_time ON sales_reports(formatted_time);

CREATE INDEX idx_fiscal_receipt_number ON fiscal_receipts(receipt_number);
CREATE INDEX idx_fiscal_datetime ON fiscal_receipts(operation_datetime);

CREATE INDEX idx_payme_payment_system_id ON payme_payments(payment_system_id);
CREATE INDEX idx_payme_payment_time ON payme_payments(payment_time);

CREATE INDEX idx_click_id ON click_payments(click_id);
CREATE INDEX idx_click_payment_date ON click_payments(payment_date);

CREATE INDEX idx_uzum_receipt_id ON uzum_payments(receipt_id);
CREATE INDEX idx_uzum_parsed_datetime ON uzum_payments(parsed_datetime);

CREATE INDEX idx_unified_order_number ON unified_orders(order_number);
CREATE INDEX idx_unified_machine_code ON unified_orders(machine_code);
CREATE INDEX idx_unified_creation_time ON unified_orders(creation_time);

CREATE INDEX idx_files_content_hash ON files(content_hash);
CREATE INDEX idx_files_type ON files(file_type);
CREATE INDEX idx_files_uploaded_at ON files(uploaded_at);

-- Включаем RLS для всех таблиц
ALTER TABLE files ENABLE ROW LEVEL SECURITY;
ALTER TABLE hardware_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE fiscal_receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE payme_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE click_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE uzum_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE unified_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_changes ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_errors ENABLE ROW LEVEL SECURITY;

-- Создаем политики RLS
-- Files
CREATE POLICY "Users can view files they uploaded" ON files FOR SELECT USING (uploaded_by = auth.uid() OR public.has_role(auth.uid(), 'admin'));
CREATE POLICY "Operators can upload files" ON files FOR INSERT WITH CHECK (public.has_role(auth.uid(), 'operator'));
CREATE POLICY "Admins can manage all files" ON files FOR ALL USING (public.has_role(auth.uid(), 'admin'));

-- Hardware orders
CREATE POLICY "Authenticated users can view hardware orders" ON hardware_orders FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Operators can manage hardware orders" ON hardware_orders FOR ALL USING (public.has_role(auth.uid(), 'operator'));

-- Sales reports
CREATE POLICY "Authenticated users can view sales reports" ON sales_reports FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Operators can manage sales reports" ON sales_reports FOR ALL USING (public.has_role(auth.uid(), 'operator'));

-- Fiscal receipts
CREATE POLICY "Authenticated users can view fiscal receipts" ON fiscal_receipts FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Operators can manage fiscal receipts" ON fiscal_receipts FOR ALL USING (public.has_role(auth.uid(), 'operator'));

-- Payment tables
CREATE POLICY "Authenticated users can view payme payments" ON payme_payments FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Operators can manage payme payments" ON payme_payments FOR ALL USING (public.has_role(auth.uid(), 'operator'));

CREATE POLICY "Authenticated users can view click payments" ON click_payments FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Operators can manage click payments" ON click_payments FOR ALL USING (public.has_role(auth.uid(), 'operator'));

CREATE POLICY "Authenticated users can view uzum payments" ON uzum_payments FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Operators can manage uzum payments" ON uzum_payments FOR ALL USING (public.has_role(auth.uid(), 'operator'));

-- Unified orders
CREATE POLICY "Authenticated users can view unified orders" ON unified_orders FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Operators can manage unified orders" ON unified_orders FOR ALL USING (public.has_role(auth.uid(), 'operator'));

-- Order changes and errors
CREATE POLICY "Authenticated users can view order changes" ON order_changes FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Operators can manage order changes" ON order_changes FOR ALL USING (public.has_role(auth.uid(), 'operator'));

CREATE POLICY "Authenticated users can view order errors" ON order_errors FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Operators can manage order errors" ON order_errors FOR ALL USING (public.has_role(auth.uid(), 'operator'));