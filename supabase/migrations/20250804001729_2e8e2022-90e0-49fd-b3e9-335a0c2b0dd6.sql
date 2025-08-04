-- =====================================================
-- ИСПРАВЛЕНИЕ ОШИБОК БЕЗОПАСНОСТИ - ВКЛЮЧЕНИЕ RLS
-- =====================================================

-- Включаем RLS для всех новых таблиц
ALTER TABLE sales_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE fiscal_receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE payme_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE click_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE uzum_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_changes ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- ПОЛИТИКИ RLS ДЛЯ SALES_REPORTS
-- =====================================================

CREATE POLICY "Authenticated users can view sales reports" 
ON sales_reports FOR SELECT 
USING (auth.role() = 'authenticated');

CREATE POLICY "Operators can manage sales reports" 
ON sales_reports FOR ALL 
USING (has_role(auth.uid(), 'operator'));

-- =====================================================
-- ПОЛИТИКИ RLS ДЛЯ FISCAL_RECEIPTS
-- =====================================================

CREATE POLICY "Authenticated users can view fiscal receipts" 
ON fiscal_receipts FOR SELECT 
USING (auth.role() = 'authenticated');

CREATE POLICY "Operators can manage fiscal receipts" 
ON fiscal_receipts FOR ALL 
USING (has_role(auth.uid(), 'operator'));

-- =====================================================
-- ПОЛИТИКИ RLS ДЛЯ PAYME_PAYMENTS
-- =====================================================

CREATE POLICY "Authenticated users can view payme payments" 
ON payme_payments FOR SELECT 
USING (auth.role() = 'authenticated');

CREATE POLICY "Operators can manage payme payments" 
ON payme_payments FOR ALL 
USING (has_role(auth.uid(), 'operator'));

-- =====================================================
-- ПОЛИТИКИ RLS ДЛЯ CLICK_PAYMENTS
-- =====================================================

CREATE POLICY "Authenticated users can view click payments" 
ON click_payments FOR SELECT 
USING (auth.role() = 'authenticated');

CREATE POLICY "Operators can manage click payments" 
ON click_payments FOR ALL 
USING (has_role(auth.uid(), 'operator'));

-- =====================================================
-- ПОЛИТИКИ RLS ДЛЯ UZUM_PAYMENTS
-- =====================================================

CREATE POLICY "Authenticated users can view uzum payments" 
ON uzum_payments FOR SELECT 
USING (auth.role() = 'authenticated');

CREATE POLICY "Operators can manage uzum payments" 
ON uzum_payments FOR ALL 
USING (has_role(auth.uid(), 'operator'));

-- =====================================================
-- ПОЛИТИКИ RLS ДЛЯ ORDER_CHANGES (ЛОГИ)
-- =====================================================

CREATE POLICY "Users can view order changes" 
ON order_changes FOR SELECT 
USING (auth.role() = 'authenticated');

CREATE POLICY "Operators can create order changes" 
ON order_changes FOR INSERT 
WITH CHECK (has_role(auth.uid(), 'operator'));

CREATE POLICY "Admins can manage all order changes" 
ON order_changes FOR ALL 
USING (has_role(auth.uid(), 'admin'));