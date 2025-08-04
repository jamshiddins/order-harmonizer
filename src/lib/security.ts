// Security utilities and CSP configuration

// Content Security Policy заголовки
export const getCSPHeader = (): string => {
  const cspDirectives = [
    "default-src 'self'",
    "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://bnydsueacjdhxvweosoe.supabase.co",
    "style-src 'self' 'unsafe-inline'",
    "img-src 'self' data: https: blob:",
    "font-src 'self' data:",
    "connect-src 'self' https://bnydsueacjdhxvweosoe.supabase.co wss://bnydsueacjdhxvweosoe.supabase.co",
    "media-src 'self'",
    "object-src 'none'",
    "frame-src 'none'",
    "base-uri 'self'",
    "form-action 'self'",
    "upgrade-insecure-requests"
  ];
  
  return cspDirectives.join('; ');
};

// Проверка происхождения запроса (CSRF защита)
export const validateOrigin = (origin: string, allowedOrigins: string[]): boolean => {
  return allowedOrigins.includes(origin);
};

// Генерация безопасного токена
export const generateSecureToken = (): string => {
  const array = new Uint8Array(32);
  crypto.getRandomValues(array);
  return Array.from(array, byte => byte.toString(16).padStart(2, '0')).join('');
};

// Проверка силы пароля
export const checkPasswordStrength = (password: string): {
  score: number;
  feedback: string[];
} => {
  const feedback: string[] = [];
  let score = 0;

  if (password.length >= 8) score += 1;
  else feedback.push('Пароль должен содержать минимум 8 символов');

  if (/[a-z]/.test(password)) score += 1;
  else feedback.push('Добавьте строчные буквы');

  if (/[A-Z]/.test(password)) score += 1;
  else feedback.push('Добавьте заглавные буквы');

  if (/\d/.test(password)) score += 1;
  else feedback.push('Добавьте цифры');

  if (/[!@#$%^&*(),.?":{}|<>]/.test(password)) score += 1;
  else feedback.push('Добавьте специальные символы');

  if (password.length >= 12) score += 1;

  return { score, feedback };
};

// Логирование событий безопасности
export const logSecurityEvent = (event: {
  type: 'login' | 'signup' | 'logout' | 'file_upload' | 'auth_error' | 'validation_error';
  userId?: string;
  details?: string;
  ipAddress?: string;
  userAgent?: string;
}) => {
  // В production здесь была бы отправка в систему мониторинга
  console.log('[SECURITY EVENT]', {
    timestamp: new Date().toISOString(),
    ...event
  });
};

// Ограничение частоты запросов (простая версия)
interface RateLimitEntry {
  count: number;
  resetTime: number;
}

const rateLimitMap = new Map<string, RateLimitEntry>();

export const checkRateLimit = (
  identifier: string, 
  maxRequests: number = 5, 
  windowMs: number = 15 * 60 * 1000 // 15 минут
): boolean => {
  const now = Date.now();
  const entry = rateLimitMap.get(identifier);

  if (!entry || now > entry.resetTime) {
    rateLimitMap.set(identifier, {
      count: 1,
      resetTime: now + windowMs
    });
    return true;
  }

  if (entry.count >= maxRequests) {
    return false;
  }

  entry.count++;
  return true;
};

// Очистка карты rate limit
setInterval(() => {
  const now = Date.now();
  for (const [key, entry] of rateLimitMap.entries()) {
    if (now > entry.resetTime) {
      rateLimitMap.delete(key);
    }
  }
}, 5 * 60 * 1000); // Очистка каждые 5 минут

// Проверка подозрительной активности
export const detectSuspiciousActivity = (events: Array<{
  timestamp: number;
  type: string;
  userId?: string;
}>): boolean => {
  const recentEvents = events.filter(event => 
    Date.now() - event.timestamp < 60000 // последняя минута
  );

  // Слишком много попыток входа
  const loginAttempts = recentEvents.filter(e => e.type === 'login').length;
  if (loginAttempts > 10) return true;

  // Слишком много ошибок валидации
  const validationErrors = recentEvents.filter(e => e.type === 'validation_error').length;
  if (validationErrors > 20) return true;

  return false;
};