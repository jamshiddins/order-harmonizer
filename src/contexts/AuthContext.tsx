import React, { createContext, useContext, useEffect, useState } from 'react';
import { User, Session } from '@supabase/supabase-js';
import { supabase } from '@/integrations/supabase/client';
import { toast } from '@/hooks/use-toast';
import { useProfile } from '@/hooks/useProfile';
import { signInSchema, signUpSchema, sanitizeInput, validateUrl } from '@/lib/validation';

interface Profile {
  id: string;
  user_id: string;
  email: string;
  full_name: string | null;
  role: 'admin' | 'operator' | 'viewer';
  created_at: string;
  updated_at: string;
}

interface AuthContextType {
  user: User | null;
  session: Session | null;
  profile: Profile | null;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<{ error: any }>;
  signUp: (email: string, password: string, fullName?: string) => Promise<{ error: any }>;
  signOut: () => Promise<void>;
  hasRole: (role: 'admin' | 'operator' | 'viewer') => boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);
  
  const { profile } = useProfile(user?.id);

  useEffect(() => {
    // Set up auth state listener
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (event, session) => {
        setSession(session);
        setUser(session?.user ?? null);
        setLoading(false);
      }
    );

    // Check for existing session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setUser(session?.user ?? null);
      setLoading(false);
    });

    return () => subscription.unsubscribe();
  }, []);

  const signIn = async (email: string, password: string) => {
    try {
      // Валидация с помощью Zod
      const validation = signInSchema.safeParse({ 
        email: sanitizeInput(email), 
        password 
      });
      
      if (!validation.success) {
        const errorMessage = validation.error.issues[0]?.message || 'Ошибка валидации';
        toast({
          title: "Ошибка валидации",
          description: errorMessage,
          variant: "destructive",
        });
        return { error: new Error(errorMessage) };
      }
      
      const { email: validatedEmail, password: validatedPassword } = validation.data;

      const { error } = await supabase.auth.signInWithPassword({
        email: validatedEmail,
        password: validatedPassword,
      });

      if (error) {
        // Handle specific error cases
        let errorMessage = error.message;
        if (error.message.includes('invalid_credentials')) {
          errorMessage = 'Неверный email или пароль';
        } else if (error.message.includes('email_not_confirmed')) {
          errorMessage = 'Подтвердите email адрес перед входом';
        } else if (error.message.includes('too_many_requests')) {
          errorMessage = 'Слишком много попыток входа. Попробуйте позже';
        }
        
        toast({
          title: "Ошибка входа",
          description: errorMessage,
          variant: "destructive",
        });
      }

      return { error };
    } catch (err) {
      console.error('Sign in error:', err);
      toast({
        title: "Ошибка входа",
        description: "Произошла неожиданная ошибка",
        variant: "destructive",
      });
      return { error: err };
    }
  };

  const signUp = async (email: string, password: string, fullName?: string) => {
    try {
      // Валидация с помощью Zod
      const validation = signUpSchema.safeParse({ 
        email: sanitizeInput(email), 
        password, 
        fullName: fullName ? sanitizeInput(fullName) : 'Пользователь'
      });
      
      if (!validation.success) {
        const errorMessage = validation.error.issues[0]?.message || 'Ошибка валидации';
        toast({
          title: "Ошибка валидации",
          description: errorMessage,
          variant: "destructive",
        });
        return { error: new Error(errorMessage) };
      }
      
      const { email: validatedEmail, password: validatedPassword, fullName: validatedFullName } = validation.data;

      // Проверяем URL для безопасности
      const redirectUrl = `${window.location.origin}/`;
      if (!validateUrl(redirectUrl)) {
        throw new Error('Некорректный URL для редиректа');
      }

      const { data, error } = await supabase.auth.signUp({
        email: validatedEmail,
        password: validatedPassword,
        options: {
          emailRedirectTo: redirectUrl,
          data: {
            full_name: validatedFullName,
          },
        },
      });

      if (error) {
        console.error('Signup error:', error);
        
        // Handle specific error cases
        let errorMessage = error.message;
        if (error.message.includes('already registered')) {
          errorMessage = 'Пользователь с таким email уже зарегистрирован';
        } else if (error.message.includes('weak password')) {
          errorMessage = 'Пароль слишком слабый. Используйте более сложный пароль';
        } else if (error.message.includes('invalid email')) {
          errorMessage = 'Некорректный email адрес';
        }
        
        toast({
          title: "Ошибка регистрации",
          description: errorMessage,
          variant: "destructive",
        });
        return { error };
      }

      if (data.user && !data.session) {
        toast({
          title: "Регистрация успешна",
          description: "Проверьте почту для подтверждения аккаунта",
        });
      } else if (data.session) {
        toast({
          title: "Регистрация успешна",
          description: "Добро пожаловать в систему!",
        });
      }

      return { error: null };
    } catch (err) {
      console.error('Signup exception:', err);
      const error = err as Error;
      toast({
        title: "Ошибка регистрации",
        description: error.message || "Произошла неожиданная ошибка",
        variant: "destructive",
      });
      return { error };
    }
  };

  const signOut = async () => {
    const { error } = await supabase.auth.signOut();
    if (error) {
      toast({
        title: "Ошибка выхода",
        description: error.message,
        variant: "destructive",
      });
    } else {
      setUser(null);
      setSession(null);
      toast({
        title: "Выход выполнен",
        description: "Вы успешно вышли из системы",
      });
    }
  };

  const hasRole = (role: 'admin' | 'operator' | 'viewer') => {
    if (!profile) return false;
    
    // Admin has access to everything
    if (profile.role === 'admin') return true;
    
    // Operator has access to operator and viewer
    if (profile.role === 'operator' && ['operator', 'viewer'].includes(role)) return true;
    
    // Viewer only has access to viewer
    if (profile.role === 'viewer' && role === 'viewer') return true;
    
    return false;
  };

  const value = {
    user,
    session,
    profile,
    loading,
    signIn,
    signUp,
    signOut,
    hasRole,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};