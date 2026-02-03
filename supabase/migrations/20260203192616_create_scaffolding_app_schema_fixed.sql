/*
  # Scaffolding & Shuttering Application - Complete Database Schema

  ## Overview
  Complete database schema for a scaffolding and shuttering rental/sales business management system.

  ## 1. New Tables

  ### Company & Settings
    - `companies` - Company profile, branding, GST details
    - `company_settings` - Company configuration
    - `attendance_settings` - Attendance tracking configuration
    - `bank_details` - Company bank accounts
    - `catalogue_media` - Product catalogue photos/videos

  ### Authentication & Users
    - `user_profiles` (extends auth.users) - System users with roles and permissions

  ### Parties (Customers & Suppliers)
    - `parties` - Customers and suppliers
    - `party_contacts` - Contact persons for parties

  ### Stock & Inventory
    - `stock_categories` - Item categories with HSN codes
    - `stock_items` - Inventory items with rates
    - `stock_transactions` - Inventory movement tracking

  ### Staff Management
    - `staff` - Employee records
    - `attendance_records` - Daily attendance
    - `leave_requests` - Leave applications
    - `holidays` - Company holidays
    - `salary_records` - Salary calculations
    - `salary_slips` - Generated salary slips

  ### Transportation
    - `transporters` - Logistics providers
    - `vehicles` - Fleet vehicles
    - `drivers` - Driver information

  ### Invoices & Bills
    - `invoices` - Bills/Challans (Rent/Sale/Purchase)
    - `invoice_items` - Line items in invoices
    - `invoice_areas` - Area-based rental charges
    - `invoice_other_charges` - Additional charges

  ### Payments & Accounting
    - `payments` - Payment records
    - `ledger_entries` - Accounting ledger
    - `expenses` - Business expenses

  ### Communication
    - `posts` - Union posts and announcements
    - `reminders` - Payment and other reminders

  ## 2. Security
    - RLS enabled on all tables
    - Policies for authenticated users based on company access
*/

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- 1. COMPANY & SETTINGS TABLES
-- =============================================

CREATE TABLE IF NOT EXISTS companies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  address text,
  gst_number text,
  phone text,
  phones text[], 
  email text,
  logo_url text,
  name_image_url text,
  stamp_url text,
  terms_and_conditions text,
  iso_number text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS company_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  setting_key text NOT NULL,
  setting_value jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(company_id, setting_key)
);

CREATE TABLE IF NOT EXISTS attendance_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  start_time time NOT NULL DEFAULT '09:00:00',
  end_time time NOT NULL DEFAULT '18:00:00',
  working_days boolean[] DEFAULT ARRAY[true, true, true, true, true, true, false],
  location_mode text DEFAULT 'optional',
  allow_staff_view boolean DEFAULT true,
  radius_meters int DEFAULT 100,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(company_id)
);

CREATE TABLE IF NOT EXISTS bank_details (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  bank_name text NOT NULL,
  account_number text NOT NULL,
  ifsc_code text NOT NULL,
  branch text,
  account_holder_name text NOT NULL,
  upi_id text,
  qr_code_url text,
  is_primary boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS catalogue_media (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  media_type text NOT NULL CHECK (media_type IN ('photo', 'video')),
  media_url text NOT NULL,
  description text,
  display_order int DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- =============================================
-- 2. AUTHENTICATION & USERS
-- =============================================

CREATE TABLE IF NOT EXISTS user_profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  phone_number text UNIQUE NOT NULL,
  full_name text,
  role text DEFAULT 'viewer' CHECK (role IN ('admin', 'editor', 'viewer')),
  profile_photo_url text,
  aadhar_number text,
  aadhar_document_url text,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- =============================================
-- 3. PARTIES (CUSTOMERS & SUPPLIERS)
-- =============================================

CREATE TABLE IF NOT EXISTS parties (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  party_type text NOT NULL CHECK (party_type IN ('customer', 'supplier', 'both')),
  name text NOT NULL,
  company_name text,
  gst_number text,
  mobile text,
  email text,
  billing_address text,
  shipping_address text,
  state text,
  pincode text,
  is_active boolean DEFAULT true,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS party_contacts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  party_id uuid REFERENCES parties(id) ON DELETE CASCADE,
  contact_person text NOT NULL,
  designation text,
  phone text,
  email text,
  is_primary boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- =============================================
-- 4. STOCK & INVENTORY
-- =============================================

CREATE TABLE IF NOT EXISTS stock_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  hsn_code text,
  image_url text,
  description text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(company_id, name)
);

CREATE TABLE IF NOT EXISTS stock_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  category_id uuid REFERENCES stock_categories(id) ON DELETE SET NULL,
  name text NOT NULL,
  size text,
  hsn_code text,
  quantity int DEFAULT 0,
  available_quantity int DEFAULT 0,
  dispatched_quantity int DEFAULT 0,
  unit text DEFAULT 'pcs',
  weight_per_unit numeric(10,2) DEFAULT 0,
  rent_rate numeric(10,2) DEFAULT 0,
  sale_rate numeric(10,2) DEFAULT 0,
  image_url text,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS stock_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  stock_item_id uuid REFERENCES stock_items(id) ON DELETE CASCADE,
  transaction_type text NOT NULL CHECK (transaction_type IN ('purchase', 'sale', 'rental_out', 'rental_return', 'adjustment')),
  quantity int NOT NULL,
  reference_type text,
  reference_id uuid,
  transaction_date timestamptz DEFAULT now(),
  notes text,
  created_by uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now()
);

-- =============================================
-- 5. STAFF MANAGEMENT
-- =============================================

CREATE TABLE IF NOT EXISTS staff (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  mobile text,
  email text,
  address text,
  gender text CHECK (gender IN ('male', 'female', 'other')),
  date_of_birth date,
  designation text,
  photo_url text,
  aadhar_number text,
  aadhar_document_url text,
  expense_allowance numeric(10,2) DEFAULT 0,
  area_rate numeric(10,2) DEFAULT 0,
  area_unit text DEFAULT 'sqft',
  time_rate numeric(10,2) DEFAULT 0,
  time_unit text DEFAULT 'hour',
  is_active boolean DEFAULT true,
  joining_date date DEFAULT CURRENT_DATE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS attendance_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  staff_id uuid REFERENCES staff(id) ON DELETE CASCADE,
  attendance_date date NOT NULL,
  status text NOT NULL CHECK (status IN ('present', 'absent', 'half_day', 'holiday', 'leave')),
  check_in_time time,
  check_out_time time,
  selfie_url text,
  location_lat numeric(10,6),
  location_lng numeric(10,6),
  notes text,
  marked_by uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now(),
  UNIQUE(staff_id, attendance_date)
);

CREATE TABLE IF NOT EXISTS leave_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  staff_id uuid REFERENCES staff(id) ON DELETE CASCADE,
  leave_type text NOT NULL CHECK (leave_type IN ('casual', 'sick', 'earned', 'unpaid')),
  from_date date NOT NULL,
  to_date date NOT NULL,
  days int NOT NULL,
  reason text,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  approved_by uuid REFERENCES auth.users(id),
  approval_notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS holidays (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  holiday_date date NOT NULL,
  name text NOT NULL,
  is_optional boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  UNIQUE(company_id, holiday_date)
);

CREATE TABLE IF NOT EXISTS salary_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  staff_id uuid REFERENCES staff(id) ON DELETE CASCADE,
  month int NOT NULL,
  year int NOT NULL,
  days_present numeric(5,2) DEFAULT 0,
  days_absent int DEFAULT 0,
  days_half int DEFAULT 0,
  basic_salary numeric(10,2) DEFAULT 0,
  allowances numeric(10,2) DEFAULT 0,
  deductions numeric(10,2) DEFAULT 0,
  gross_salary numeric(10,2) DEFAULT 0,
  net_salary numeric(10,2) DEFAULT 0,
  payment_date date,
  payment_mode text,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(staff_id, month, year)
);

CREATE TABLE IF NOT EXISTS salary_slips (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  salary_record_id uuid REFERENCES salary_records(id) ON DELETE CASCADE,
  slip_url text NOT NULL,
  generated_at timestamptz DEFAULT now()
);

-- =============================================
-- 6. TRANSPORTATION
-- =============================================

CREATE TABLE IF NOT EXISTS transporters (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  contact_person text,
  phone text,
  email text,
  address text,
  gst_number text,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS vehicles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  transporter_id uuid REFERENCES transporters(id) ON DELETE CASCADE,
  vehicle_number text NOT NULL,
  vehicle_type text,
  capacity text,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  UNIQUE(vehicle_number)
);

CREATE TABLE IF NOT EXISTS drivers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  transporter_id uuid REFERENCES transporters(id) ON DELETE CASCADE,
  name text NOT NULL,
  phone text,
  license_number text,
  license_expiry_date date,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- =============================================
-- 7. INVOICES & BILLS
-- =============================================

CREATE TABLE IF NOT EXISTS invoices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  party_id uuid REFERENCES parties(id) ON DELETE SET NULL,
  invoice_type text NOT NULL CHECK (invoice_type IN ('sale', 'rental', 'purchase', 'service')),
  document_type text NOT NULL CHECK (document_type IN ('tax_invoice', 'estimate', 'quotation', 'outward_challan', 'gate_pass', 'enquiry')),
  invoice_number text NOT NULL,
  invoice_date date NOT NULL,
  status text DEFAULT 'draft' CHECK (status IN ('draft', 'enquiry', 'quotation', 'current', 'billed', 'cancelled')),
  from_date date,
  to_date date,
  days int,
  bill_to_name text,
  bill_to_company text,
  bill_to_gst text,
  bill_to_mobile text,
  bill_to_address text,
  ship_to_address text,
  contact_person text,
  contact_number text,
  eway_bill_no text,
  vehicle_number text,
  driver_name text,
  driver_mobile text,
  driver_license text,
  transporter_id uuid REFERENCES transporters(id),
  gst_type text DEFAULT 'cgst_sgst' CHECK (gst_type IN ('cgst_sgst', 'igst', 'no_gst')),
  gst_rate numeric(5,2) DEFAULT 0,
  subtotal numeric(12,2) DEFAULT 0,
  cgst_amount numeric(12,2) DEFAULT 0,
  sgst_amount numeric(12,2) DEFAULT 0,
  igst_amount numeric(12,2) DEFAULT 0,
  other_charges_total numeric(12,2) DEFAULT 0,
  round_off numeric(8,2) DEFAULT 0,
  total_amount numeric(12,2) DEFAULT 0,
  paid_amount numeric(12,2) DEFAULT 0,
  due_amount numeric(12,2) DEFAULT 0,
  payment_terms text,
  notes text,
  created_by uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(company_id, invoice_number)
);

CREATE TABLE IF NOT EXISTS invoice_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id uuid REFERENCES invoices(id) ON DELETE CASCADE,
  stock_item_id uuid REFERENCES stock_items(id) ON DELETE SET NULL,
  item_name text NOT NULL,
  hsn_code text,
  size text,
  quantity numeric(10,2) NOT NULL,
  unit text DEFAULT 'pcs',
  weight_per_unit numeric(10,2) DEFAULT 0,
  total_weight numeric(10,2) DEFAULT 0,
  rate numeric(10,2) NOT NULL,
  rent_per_day numeric(10,2),
  from_date date,
  to_date date,
  days int,
  amount numeric(12,2) NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS invoice_areas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id uuid REFERENCES invoices(id) ON DELETE CASCADE,
  area_name text NOT NULL,
  hsn_code text,
  length numeric(10,2),
  width numeric(10,2),
  height numeric(10,2),
  unit text DEFAULT 'feet',
  rate numeric(10,2) NOT NULL,
  from_date date,
  to_date date,
  days int,
  amount numeric(12,2) NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS invoice_other_charges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id uuid REFERENCES invoices(id) ON DELETE CASCADE,
  hsn_code text,
  description text NOT NULL,
  quantity numeric(10,2) DEFAULT 1,
  unit text DEFAULT 'nos',
  rate numeric(10,2) NOT NULL,
  amount numeric(12,2) NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- =============================================
-- 8. PAYMENTS & ACCOUNTING
-- =============================================

CREATE TABLE IF NOT EXISTS payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  party_id uuid REFERENCES parties(id) ON DELETE SET NULL,
  invoice_id uuid REFERENCES invoices(id) ON DELETE SET NULL,
  payment_type text NOT NULL CHECK (payment_type IN ('received', 'paid')),
  payment_date date NOT NULL,
  amount numeric(12,2) NOT NULL,
  payment_mode text NOT NULL CHECK (payment_mode IN ('cash', 'upi', 'cheque', 'bank_transfer', 'card')),
  reference_number text,
  notes text,
  created_by uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ledger_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  party_id uuid REFERENCES parties(id) ON DELETE CASCADE,
  entry_date date NOT NULL,
  entry_type text NOT NULL CHECK (entry_type IN ('invoice', 'payment', 'adjustment')),
  reference_type text,
  reference_id uuid,
  reference_number text,
  debit_amount numeric(12,2) DEFAULT 0,
  credit_amount numeric(12,2) DEFAULT 0,
  balance numeric(12,2) DEFAULT 0,
  description text,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS expenses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  expense_date date NOT NULL,
  category text NOT NULL,
  amount numeric(10,2) NOT NULL,
  payment_mode text NOT NULL,
  description text,
  receipt_url text,
  created_by uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- =============================================
-- 9. COMMUNICATION
-- =============================================

CREATE TABLE IF NOT EXISTS posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  created_by uuid REFERENCES auth.users(id),
  title text,
  content text NOT NULL,
  image_url text,
  post_type text DEFAULT 'announcement' CHECK (post_type IN ('announcement', 'news', 'update')),
  is_pinned boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS reminders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  reminder_type text NOT NULL CHECK (reminder_type IN ('payment', 'attendance', 'due', 'custom')),
  party_id uuid REFERENCES parties(id) ON DELETE CASCADE,
  invoice_id uuid REFERENCES invoices(id) ON DELETE SET NULL,
  reminder_date date NOT NULL,
  message text NOT NULL,
  is_sent boolean DEFAULT false,
  sent_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

CREATE INDEX IF NOT EXISTS idx_user_profiles_company ON user_profiles(company_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_phone ON user_profiles(phone_number);
CREATE INDEX IF NOT EXISTS idx_parties_company ON parties(company_id);
CREATE INDEX IF NOT EXISTS idx_parties_type ON parties(party_type);
CREATE INDEX IF NOT EXISTS idx_staff_company ON staff(company_id);
CREATE INDEX IF NOT EXISTS idx_staff_active ON staff(is_active);
CREATE INDEX IF NOT EXISTS idx_attendance_staff_date ON attendance_records(staff_id, attendance_date);
CREATE INDEX IF NOT EXISTS idx_stock_items_company ON stock_items(company_id);
CREATE INDEX IF NOT EXISTS idx_stock_items_category ON stock_items(category_id);
CREATE INDEX IF NOT EXISTS idx_invoices_company ON invoices(company_id);
CREATE INDEX IF NOT EXISTS idx_invoices_party ON invoices(party_id);
CREATE INDEX IF NOT EXISTS idx_invoices_date ON invoices(invoice_date);
CREATE INDEX IF NOT EXISTS idx_invoices_status ON invoices(status);
CREATE INDEX IF NOT EXISTS idx_invoices_type ON invoices(invoice_type);
CREATE INDEX IF NOT EXISTS idx_payments_company ON payments(company_id);
CREATE INDEX IF NOT EXISTS idx_payments_party ON payments(party_id);
CREATE INDEX IF NOT EXISTS idx_payments_date ON payments(payment_date);
CREATE INDEX IF NOT EXISTS idx_ledger_party ON ledger_entries(party_id);
CREATE INDEX IF NOT EXISTS idx_stock_transactions_item ON stock_transactions(stock_item_id);

-- =============================================
-- ROW LEVEL SECURITY
-- =============================================

ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE bank_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE catalogue_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE parties ENABLE ROW LEVEL SECURITY;
ALTER TABLE party_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE leave_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE holidays ENABLE ROW LEVEL SECURITY;
ALTER TABLE salary_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE salary_slips ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_other_charges ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE ledger_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE transporters ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;

-- =============================================
-- RLS POLICIES
-- =============================================

-- Companies
CREATE POLICY "Users can read own company"
  ON companies FOR SELECT
  TO authenticated
  USING (
    id IN (
      SELECT company_id FROM user_profiles WHERE id = auth.uid()
    )
  );

CREATE POLICY "Admins can update own company"
  ON companies FOR UPDATE
  TO authenticated
  USING (
    id IN (
      SELECT company_id FROM user_profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  )
  WITH CHECK (
    id IN (
      SELECT company_id FROM user_profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- User Profiles
CREATE POLICY "Users can read company user profiles"
  ON user_profiles FOR SELECT
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id FROM user_profiles WHERE id = auth.uid()
    )
  );

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- Parties
CREATE POLICY "Users can read company parties"
  ON parties FOR SELECT
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id FROM user_profiles WHERE id = auth.uid()
    )
  );

CREATE POLICY "Editors can insert parties"
  ON parties FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id IN (
      SELECT company_id FROM user_profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'editor')
    )
  );

CREATE POLICY "Editors can update parties"
  ON parties FOR UPDATE
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id FROM user_profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'editor')
    )
  )
  WITH CHECK (
    company_id IN (
      SELECT company_id FROM user_profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'editor')
    )
  );

CREATE POLICY "Admins can delete parties"
  ON parties FOR DELETE
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id FROM user_profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Stock Items
CREATE POLICY "Users can read company stock items"
  ON stock_items FOR SELECT
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id FROM user_profiles WHERE id = auth.uid()
    )
  );

CREATE POLICY "Editors can manage stock items"
  ON stock_items FOR ALL
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id FROM user_profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'editor')
    )
  )
  WITH CHECK (
    company_id IN (
      SELECT company_id FROM user_profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'editor')
    )
  );

-- Staff
CREATE POLICY "Users can read company staff"
  ON staff FOR SELECT
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id FROM user_profiles WHERE id = auth.uid()
    )
  );

CREATE POLICY "Editors can manage staff"
  ON staff FOR ALL
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id FROM user_profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'editor')
    )
  )
  WITH CHECK (
    company_id IN (
      SELECT company_id FROM user_profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'editor')
    )
  );

-- Invoices
CREATE POLICY "Users can read company invoices"
  ON invoices FOR SELECT
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id FROM user_profiles WHERE id = auth.uid()
    )
  );

CREATE POLICY "Editors can manage invoices"
  ON invoices FOR ALL
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id FROM user_profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'editor')
    )
  )
  WITH CHECK (
    company_id IN (
      SELECT company_id FROM user_profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'editor')
    )
  );

-- Invoice Items
CREATE POLICY "Users can read invoice items"
  ON invoice_items FOR SELECT
  TO authenticated
  USING (
    invoice_id IN (
      SELECT id FROM invoices WHERE company_id IN (
        SELECT company_id FROM user_profiles WHERE id = auth.uid()
      )
    )
  );

CREATE POLICY "Editors can manage invoice items"
  ON invoice_items FOR ALL
  TO authenticated
  USING (
    invoice_id IN (
      SELECT id FROM invoices WHERE company_id IN (
        SELECT company_id FROM user_profiles 
        WHERE id = auth.uid() AND role IN ('admin', 'editor')
      )
    )
  )
  WITH CHECK (
    invoice_id IN (
      SELECT id FROM invoices WHERE company_id IN (
        SELECT company_id FROM user_profiles 
        WHERE id = auth.uid() AND role IN ('admin', 'editor')
      )
    )
  );

-- Payments
CREATE POLICY "Users can read company payments"
  ON payments FOR SELECT
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id FROM user_profiles WHERE id = auth.uid()
    )
  );

CREATE POLICY "Editors can manage payments"
  ON payments FOR ALL
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id FROM user_profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'editor')
    )
  )
  WITH CHECK (
    company_id IN (
      SELECT company_id FROM user_profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'editor')
    )
  );

-- Simplified policies for other tables
CREATE POLICY "Company users read" ON company_settings FOR SELECT TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid()));
CREATE POLICY "Company users read" ON attendance_settings FOR SELECT TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid()));
CREATE POLICY "Company users read" ON bank_details FOR SELECT TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid()));
CREATE POLICY "Company users read" ON catalogue_media FOR SELECT TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid()));
CREATE POLICY "Company users read" ON party_contacts FOR SELECT TO authenticated USING (party_id IN (SELECT id FROM parties WHERE company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid())));
CREATE POLICY "Company users read" ON stock_categories FOR SELECT TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid()));
CREATE POLICY "Company users read" ON stock_transactions FOR SELECT TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid()));
CREATE POLICY "Company users read" ON attendance_records FOR SELECT TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid()));
CREATE POLICY "Company users read" ON leave_requests FOR SELECT TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid()));
CREATE POLICY "Company users read" ON holidays FOR SELECT TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid()));
CREATE POLICY "Company users read" ON salary_records FOR SELECT TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid()));
CREATE POLICY "Company users read" ON salary_slips FOR SELECT TO authenticated USING (salary_record_id IN (SELECT id FROM salary_records WHERE company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid())));
CREATE POLICY "Company users read" ON invoice_areas FOR SELECT TO authenticated USING (invoice_id IN (SELECT id FROM invoices WHERE company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid())));
CREATE POLICY "Company users read" ON invoice_other_charges FOR SELECT TO authenticated USING (invoice_id IN (SELECT id FROM invoices WHERE company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid())));
CREATE POLICY "Company users read" ON ledger_entries FOR SELECT TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid()));
CREATE POLICY "Company users read" ON expenses FOR SELECT TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid()));
CREATE POLICY "Company users read" ON transporters FOR SELECT TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid()));
CREATE POLICY "Company users read" ON vehicles FOR SELECT TO authenticated USING (transporter_id IN (SELECT id FROM transporters WHERE company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid())));
CREATE POLICY "Company users read" ON drivers FOR SELECT TO authenticated USING (transporter_id IN (SELECT id FROM transporters WHERE company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid())));
CREATE POLICY "Company users read" ON posts FOR SELECT TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid()));
CREATE POLICY "Company users read" ON reminders FOR SELECT TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid()));

-- Editor write policies
CREATE POLICY "Editors manage" ON company_settings FOR ALL TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor'))) WITH CHECK (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor')));
CREATE POLICY "Editors manage" ON attendance_settings FOR ALL TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor'))) WITH CHECK (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor')));
CREATE POLICY "Editors manage" ON bank_details FOR ALL TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor'))) WITH CHECK (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor')));
CREATE POLICY "Editors manage" ON catalogue_media FOR ALL TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor'))) WITH CHECK (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor')));
CREATE POLICY "Editors manage" ON stock_categories FOR ALL TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor'))) WITH CHECK (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor')));
CREATE POLICY "Editors manage" ON stock_transactions FOR ALL TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor'))) WITH CHECK (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor')));
CREATE POLICY "Editors manage" ON attendance_records FOR ALL TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor'))) WITH CHECK (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor')));
CREATE POLICY "Editors manage" ON leave_requests FOR ALL TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor'))) WITH CHECK (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor')));
CREATE POLICY "Editors manage" ON holidays FOR ALL TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor'))) WITH CHECK (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor')));
CREATE POLICY "Editors manage" ON salary_records FOR ALL TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor'))) WITH CHECK (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor')));
CREATE POLICY "Editors manage" ON invoice_areas FOR ALL TO authenticated USING (invoice_id IN (SELECT id FROM invoices WHERE company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor')))) WITH CHECK (invoice_id IN (SELECT id FROM invoices WHERE company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor'))));
CREATE POLICY "Editors manage" ON invoice_other_charges FOR ALL TO authenticated USING (invoice_id IN (SELECT id FROM invoices WHERE company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor')))) WITH CHECK (invoice_id IN (SELECT id FROM invoices WHERE company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor'))));
CREATE POLICY "Editors manage" ON ledger_entries FOR ALL TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor'))) WITH CHECK (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor')));
CREATE POLICY "Editors manage" ON expenses FOR ALL TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor'))) WITH CHECK (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor')));
CREATE POLICY "Editors manage" ON transporters FOR ALL TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor'))) WITH CHECK (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor')));
CREATE POLICY "Editors manage" ON vehicles FOR ALL TO authenticated USING (transporter_id IN (SELECT id FROM transporters WHERE company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor')))) WITH CHECK (transporter_id IN (SELECT id FROM transporters WHERE company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor'))));
CREATE POLICY "Editors manage" ON drivers FOR ALL TO authenticated USING (transporter_id IN (SELECT id FROM transporters WHERE company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor')))) WITH CHECK (transporter_id IN (SELECT id FROM transporters WHERE company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor'))));
CREATE POLICY "Editors manage" ON posts FOR ALL TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor'))) WITH CHECK (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor')));
CREATE POLICY "Editors manage" ON reminders FOR ALL TO authenticated USING (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor'))) WITH CHECK (company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor')));
CREATE POLICY "Editors manage" ON party_contacts FOR ALL TO authenticated USING (party_id IN (SELECT id FROM parties WHERE company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor')))) WITH CHECK (party_id IN (SELECT id FROM parties WHERE company_id IN (SELECT company_id FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'editor'))));
