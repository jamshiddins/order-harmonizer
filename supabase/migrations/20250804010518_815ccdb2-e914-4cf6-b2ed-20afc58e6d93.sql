-- =====================================================
-- ИСПРАВЛЕНИЕ ПРЕДСТАВЛЕНИЙ (УБИРАЕМ SECURITY DEFINER)
-- =====================================================

-- Удаляем и пересоздаем представления без SECURITY DEFINER
DROP VIEW IF EXISTS public.v_complete_orders;
DROP VIEW IF EXISTS public.v_problematic_orders; 
DROP VIEW IF EXISTS public.v_file_processing_stats;

-- Создаем обычные представления (по умолчанию SECURITY INVOKER)
CREATE VIEW public.v_complete_orders AS
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
FROM public.unified_orders u
LEFT JOIN public.files f ON f.id = ANY(string_to_array(array_to_string(u.source_files, ','), ',')::int[]);

CREATE VIEW public.v_problematic_orders AS
SELECT 
    u.order_number,
    u.order_price,
    u.machine_code,
    u.creation_time,
    u.is_temporary,
    u.match_score,
    COUNT(e.id) as error_count,
    STRING_AGG(e.error_type, ', ') as error_types
FROM public.unified_orders u
LEFT JOIN public.order_errors e ON e.order_number = u.order_number
WHERE u.is_temporary = TRUE 
   OR u.match_score < 2 
   OR EXISTS (SELECT 1 FROM public.order_errors WHERE order_number = u.order_number AND resolution_status = 'open')
GROUP BY u.order_number, u.order_price, u.machine_code, u.creation_time, u.is_temporary, u.match_score;

CREATE VIEW public.v_file_processing_stats AS
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
FROM public.files f
ORDER BY f.uploaded_at DESC;