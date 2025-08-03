-- Создаем основные таблицы согласно схеме

-- =====================================================
-- FILES - Управление файлами-источниками
-- =====================================================
CREATE TABLE files (
    id                      SERIAL PRIMARY KEY,
    filename                VARCHAR(255) NOT NULL,
    original_name           VARCHAR(255) NOT NULL,
    file_type               VARCHAR(50) NOT NULL,
    content_hash            VARCHAR(64) NOT NULL,
    file_size               BIGINT,
    file_url                TEXT,
    records_count           INTEGER DEFAULT 0,
    processed_records       INTEGER DEFAULT 0,
    matched_records         INTEGER DEFAULT 0,
    error_records           INTEGER DEFAULT 0,
    similarity_percent      DECIMAL(5,2),
    duplicate_of_id         INTEGER REFERENCES files(id),
    uploaded_by             UUID REFERENCES profiles(user_id),
    uploaded_at             TIMESTAMP DEFAULT NOW(),
    processing_started_at   TIMESTAMP,
    processing_finished_at  TIMESTAMP,
    processing_status       VARCHAR(50) DEFAULT 'pending',
    error_message           TEXT,
    detected_encoding       VARCHAR(50),
    detected_delimiter      VARCHAR(10),
    sheet_names             TEXT[],
    processed_sheet         VARCHAR(255)
);

-- =====================================================
-- HARDWARE_ORDERS - Основной источник заказов
-- =====================================================
CREATE TABLE hardware_orders (
    id                      BIGSERIAL PRIMARY KEY,
    order_number            VARCHAR(255) UNIQUE NOT NULL,
    address                 TEXT,
    machine_code            VARCHAR(50),
    goods_name              VARCHAR(255),
    taste_name              VARCHAR(255),
    order_type              VARCHAR(100) DEFAULT 'Normal order',
    order_resource          VARCHAR(100),
    payment_status          VARCHAR(50) DEFAULT 'Paid',
    brew_status             VARCHAR(50),
    order_price             DECIMAL(12,2),
    creation_time           TIMESTAMP,
    paying_time             TIMESTAMP,
    brewing_time            TIMESTAMP,
    delivery_time           TIMESTAMP,
    refund_time             TIMESTAMP,
    reason                  TEXT,
    source_file_id          INTEGER REFERENCES files(id),
    created_at              TIMESTAMP DEFAULT NOW(),
    updated_at              TIMESTAMP DEFAULT NOW(),
    version                 INTEGER DEFAULT 1
);

-- =====================================================
-- UNIFIED_ORDERS - Общая база заказов
-- =====================================================
CREATE TABLE unified_orders (
    id                      BIGSERIAL PRIMARY KEY,
    order_number            VARCHAR(255) UNIQUE NOT NULL,
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
    is_temporary            BOOLEAN DEFAULT FALSE,
    source_files            TEXT[],
    created_at              TIMESTAMP DEFAULT NOW(),
    updated_at              TIMESTAMP DEFAULT NOW(),
    last_matched_at         TIMESTAMP,
    match_score             INTEGER DEFAULT 0
);

-- Создаем индексы
CREATE INDEX idx_hardware_order_number ON hardware_orders(order_number);
CREATE INDEX idx_hardware_machine_code ON hardware_orders(machine_code);
CREATE INDEX idx_hardware_creation_time ON hardware_orders(creation_time);

CREATE INDEX idx_unified_order_number ON unified_orders(order_number);
CREATE INDEX idx_unified_machine_code ON unified_orders(machine_code);
CREATE INDEX idx_unified_creation_time ON unified_orders(creation_time);

CREATE INDEX idx_files_content_hash ON files(content_hash);
CREATE INDEX idx_files_type ON files(file_type);
CREATE INDEX idx_files_uploaded_at ON files(uploaded_at);

-- Включаем RLS для всех таблиц
ALTER TABLE files ENABLE ROW LEVEL SECURITY;
ALTER TABLE hardware_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE unified_orders ENABLE ROW LEVEL SECURITY;

-- Создаем политики RLS
-- Files
CREATE POLICY "Users can view files they uploaded" ON files 
  FOR SELECT USING (uploaded_by = auth.uid() OR public.has_role(auth.uid(), 'admin'));
CREATE POLICY "Operators can upload files" ON files 
  FOR INSERT WITH CHECK (public.has_role(auth.uid(), 'operator'));
CREATE POLICY "Admins can manage all files" ON files 
  FOR ALL USING (public.has_role(auth.uid(), 'admin'));

-- Hardware orders
CREATE POLICY "Authenticated users can view hardware orders" ON hardware_orders 
  FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Operators can manage hardware orders" ON hardware_orders 
  FOR ALL USING (public.has_role(auth.uid(), 'operator'));

-- Unified orders  
CREATE POLICY "Authenticated users can view unified orders" ON unified_orders 
  FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Operators can manage unified orders" ON unified_orders 
  FOR ALL USING (public.has_role(auth.uid(), 'operator'));