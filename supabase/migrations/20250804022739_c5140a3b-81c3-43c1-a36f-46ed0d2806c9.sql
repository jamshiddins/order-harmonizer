-- =====================================================
-- CRITICAL SECURITY FIXES - DATABASE LEVEL
-- =====================================================

-- 1. FIX PRIVILEGE ESCALATION IN PROFILES TABLE
-- Current policy allows users to update their own role - CRITICAL VULNERABILITY

-- Drop the existing dangerous policy
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;

-- Create separate policies for profile updates vs role updates
CREATE POLICY "Users can update their basic profile info" 
ON public.profiles 
FOR UPDATE 
USING (auth.uid() = user_id)
WITH CHECK (
  auth.uid() = user_id AND 
  -- Prevent users from changing their own role
  role = (SELECT role FROM public.profiles WHERE user_id = auth.uid())
);

-- Only admins can change roles
CREATE POLICY "Admins can update user roles" 
ON public.profiles 
FOR UPDATE 
USING (has_role(auth.uid(), 'admin'::character varying))
WITH CHECK (has_role(auth.uid(), 'admin'::character varying));

-- 2. ADD AUDIT LOGGING FOR ROLE CHANGES
CREATE TABLE public.role_change_audit (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    changed_user_id UUID NOT NULL,
    old_role CHARACTER VARYING,
    new_role CHARACTER VARYING,
    changed_by UUID REFERENCES auth.users(id),
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reason TEXT
);

-- Enable RLS on audit table
ALTER TABLE public.role_change_audit ENABLE ROW LEVEL SECURITY;

-- Only admins can view audit logs
CREATE POLICY "Admins can view role change audit" 
ON public.role_change_audit 
FOR SELECT 
USING (has_role(auth.uid(), 'admin'::character varying));

-- Create trigger to log role changes
CREATE OR REPLACE FUNCTION public.log_role_changes()
RETURNS TRIGGER AS $$
BEGIN
    -- Only log if role actually changed
    IF OLD.role IS DISTINCT FROM NEW.role THEN
        INSERT INTO public.role_change_audit (
            changed_user_id, 
            old_role, 
            new_role, 
            changed_by
        ) VALUES (
            NEW.user_id,
            OLD.role,
            NEW.role,
            auth.uid()
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Add the trigger
CREATE TRIGGER role_change_audit_trigger
    AFTER UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.log_role_changes();

-- 3. SECURE USER_ROLES TABLE (if users try to bypass profiles)
-- Add better RLS policies for user_roles
DROP POLICY IF EXISTS "Users can view their own roles" ON public.user_roles;
DROP POLICY IF EXISTS "Admins can manage all roles" ON public.user_roles;

-- More secure policies
CREATE POLICY "Users can view their own roles" 
ON public.user_roles 
FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all roles" 
ON public.user_roles 
FOR SELECT 
USING (has_role(auth.uid(), 'admin'::character varying));

CREATE POLICY "Admins can insert roles" 
ON public.user_roles 
FOR INSERT 
WITH CHECK (has_role(auth.uid(), 'admin'::character varying));

CREATE POLICY "Admins can update roles" 
ON public.user_roles 
FOR UPDATE 
USING (has_role(auth.uid(), 'admin'::character varying))
WITH CHECK (has_role(auth.uid(), 'admin'::character varying));

CREATE POLICY "Admins can delete roles" 
ON public.user_roles 
FOR DELETE 
USING (has_role(auth.uid(), 'admin'::character varying));

-- 4. REMOVE SECURITY DEFINER FROM UNNECESSARY VIEWS
-- Convert problematic views to regular views
DROP VIEW IF EXISTS public.v_complete_orders;
CREATE VIEW public.v_complete_orders AS
SELECT 
    u.*,
    f.original_name as source_filename,
    f.uploaded_at as file_uploaded_at,
    CASE 
        WHEN u.match_score >= 5 THEN 'ОТЛИЧНО'
        WHEN u.match_score >= 4 THEN 'ХОРОШО'
        WHEN u.match_score >= 2 THEN 'СРЕДНЕ'
        ELSE 'ПЛОХО'
    END as match_quality
FROM public.unified_orders u
LEFT JOIN public.files f ON f.id::TEXT = ANY(u.source_files);

-- Add RLS to the view (inherits from underlying tables)
ALTER VIEW public.v_complete_orders SET (security_barrier = true);

-- 5. FIX SEARCH PATHS IN ALL SECURITY DEFINER FUNCTIONS
-- Update has_role function to be more secure
CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role character varying)
RETURNS boolean
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id
      AND role = _role
  )
$$;

-- 6. ADD INPUT VALIDATION TRIGGER FOR SENSITIVE OPERATIONS
CREATE OR REPLACE FUNCTION public.validate_profile_changes()
RETURNS TRIGGER AS $$
BEGIN
    -- Validate email format
    IF NEW.email IS NOT NULL AND NEW.email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email format';
    END IF;
    
    -- Validate role values
    IF NEW.role NOT IN ('admin', 'operator', 'viewer') THEN
        RAISE EXCEPTION 'Invalid role value';
    END IF;
    
    -- Validate full_name length
    IF NEW.full_name IS NOT NULL AND LENGTH(NEW.full_name) > 255 THEN
        RAISE EXCEPTION 'Full name too long';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Add validation trigger
CREATE TRIGGER validate_profile_trigger
    BEFORE INSERT OR UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_profile_changes();

-- 7. CREATE ADMIN-ONLY USER MANAGEMENT FUNCTIONS
CREATE OR REPLACE FUNCTION public.admin_update_user_role(
    target_user_id UUID,
    new_role CHARACTER VARYING,
    reason TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
BEGIN
    -- Check if caller is admin
    IF NOT has_role(auth.uid(), 'admin'::character varying) THEN
        RAISE EXCEPTION 'Insufficient privileges';
    END IF;
    
    -- Update the role
    UPDATE public.profiles 
    SET role = new_role, updated_at = NOW()
    WHERE user_id = target_user_id;
    
    -- Log the change with reason
    INSERT INTO public.role_change_audit (
        changed_user_id, 
        new_role, 
        changed_by, 
        reason
    ) VALUES (
        target_user_id,
        new_role,
        auth.uid(),
        reason
    );
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Grant execute permission only to authenticated users
REVOKE ALL ON FUNCTION public.admin_update_user_role FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_update_user_role TO authenticated;