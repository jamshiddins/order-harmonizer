import { z } from 'zod';

// Схемы валидации для аутентификации
export const signInSchema = z.object({
  email: z
    .string()
    .min(1, 'Email обязателен')
    .email('Некорректный email адрес')
    .max(254, 'Email слишком длинный')
    .regex(/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/, 'Некорректный формат email'),
  password: z
    .string()
    .min(1, 'Пароль обязателен')
    .min(6, 'Пароль должен содержать минимум 6 символов')
    .max(128, 'Пароль слишком длинный')
});

export const signUpSchema = z.object({
  email: z
    .string()
    .min(1, 'Email обязателен')
    .email('Некорректный email адрес')
    .max(254, 'Email слишком длинный')
    .regex(/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/, 'Некорректный формат email'),
  password: z
    .string()
    .min(6, 'Пароль должен содержать минимум 6 символов')
    .max(128, 'Пароль слишком длинный')
    .regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, 'Пароль должен содержать заглавную букву, строчную букву и цифру'),
  fullName: z
    .string()
    .min(1, 'Полное имя обязательно')
    .max(100, 'Имя слишком длинное')
    .regex(/^[a-zA-Zа-яА-ЯёЁ\s-'\.]+$/, 'Имя содержит недопустимые символы')
    .transform(val => sanitizeInput(val))
});

// Схема валидации для загрузки файлов
export const fileUploadSchema = z.object({
  file: z
    .instanceof(File)
    .refine(file => file.size > 0, 'Файл не должен быть пустым')
    .refine(file => file.size <= 50 * 1024 * 1024, 'Файл не должен превышать 50MB')
    .refine(
      file => ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 
               'application/vnd.ms-excel', 
               'text/csv'].includes(file.type),
      'Разрешены только Excel и CSV файлы'
    ),
  originalName: z
    .string()
    .min(1, 'Имя файла обязательно')
    .max(255, 'Имя файла слишком длинное')
    .regex(/^[a-zA-Z0-9._\-\s()]+\.(xlsx|xls|csv)$/i, 'Недопустимое имя файла')
    .transform(val => sanitizeInput(val))
});

// Схема для профиля пользователя
export const profileUpdateSchema = z.object({
  fullName: z
    .string()
    .min(1, 'Полное имя обязательно')
    .max(100, 'Имя слишком длинное')
    .regex(/^[a-zA-Zа-яА-ЯёЁ\s-'\.]+$/, 'Имя содержит недопустимые символы')
    .transform(val => sanitizeInput(val))
    .optional(),
  email: z
    .string()
    .email('Некорректный email адрес')
    .max(254, 'Email слишком длинный')
    .optional()
});

// Функция для санитизации входных данных
export const sanitizeInput = (input: string): string => {
  return input
    .trim()
    .replace(/[<>]/g, '') // Удаляем потенциально опасные символы
    .replace(/javascript:/gi, '') // Удаляем javascript: протокол
    .replace(/on\w+=/gi, '') // Удаляем event handlers
    .replace(/data:/gi, '') // Удаляем data: URLs
    .substring(0, 1000); // Ограничиваем длину
};

// Функция для валидации URL
export const validateUrl = (url: string): boolean => {
  try {
    const parsedUrl = new URL(url);
    return ['http:', 'https:'].includes(parsedUrl.protocol);
  } catch {
    return false;
  }
};

// Функция для экранирования HTML
export const escapeHtml = (unsafe: string): string => {
  return unsafe
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
};

// Типы для TypeScript
export type SignInFormData = z.infer<typeof signInSchema>;
export type SignUpFormData = z.infer<typeof signUpSchema>;
export type FileUploadData = z.infer<typeof fileUploadSchema>;
export type ProfileUpdateData = z.infer<typeof profileUpdateSchema>;