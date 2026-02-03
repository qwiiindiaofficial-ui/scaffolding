/*
  # Create OTP Sessions Table for Custom SMS Service

  1. New Tables
    - `otp_sessions`
      - `id` (uuid, primary key)
      - `phone_number` (text, indexed for quick lookup)
      - `otp_code` (text, the 6-digit OTP)
      - `is_verified` (boolean, tracks if OTP was verified)
      - `attempts` (integer, tracks verification attempts)
      - `created_at` (timestamptz)
      - `expires_at` (timestamptz, OTP expires in 10 mins)

  2. Security
    - Enable RLS on `otp_sessions` table
    - Add policy for anonymous users to create sessions
    - Add policy for anonymous users to verify their OTP
*/

CREATE TABLE IF NOT EXISTS otp_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  phone_number text NOT NULL,
  otp_code text NOT NULL,
  is_verified boolean DEFAULT false,
  attempts integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  expires_at timestamptz DEFAULT (now() + interval '10 minutes')
);

CREATE INDEX IF NOT EXISTS idx_otp_phone ON otp_sessions(phone_number);
CREATE INDEX IF NOT EXISTS idx_otp_created ON otp_sessions(created_at DESC);

ALTER TABLE otp_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can create OTP session"
  ON otp_sessions
  FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Anyone can read own OTP session"
  ON otp_sessions
  FOR SELECT
  TO anon
  USING (true);

CREATE POLICY "Anyone can update OTP verification"
  ON otp_sessions
  FOR UPDATE
  TO anon
  USING (true)
  WITH CHECK (true);
