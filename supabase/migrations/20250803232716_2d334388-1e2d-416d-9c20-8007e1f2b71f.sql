-- Создаем тестового администратора
-- Сначала вставим в user_roles фиктивный UUID для теста системы ролей
-- В реальности эта запись будет создана триггером при регистрации
INSERT INTO user_roles (id, user_id, role) 
VALUES (
  gen_random_uuid(),
  '00000000-0000-0000-0000-000000000000'::uuid,
  'admin'
) ON CONFLICT DO NOTHING;

-- Также добавим оператора для тестирования
INSERT INTO user_roles (id, user_id, role)
VALUES (
  gen_random_uuid(), 
  '11111111-1111-1111-1111-111111111111'::uuid,
  'operator'
) ON CONFLICT DO NOTHING;