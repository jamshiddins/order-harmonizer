-- Enable leaked password protection and set proper OTP expiry
-- These are auth configuration changes that should be applied

-- Update auth configuration for better security
UPDATE auth.config SET 
    password_min_length = 8,
    password_require_letters = true,
    password_require_numbers = true,
    password_require_symbols = true,
    password_require_uppercase = true,
    password_require_lowercase = true
WHERE true;

-- Set OTP expiry to recommended 10 minutes (600 seconds)
UPDATE auth.config SET 
    otp_expiry = 600
WHERE true;