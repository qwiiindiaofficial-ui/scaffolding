# Scaffolding & Shuttering App - Backend Documentation

## Overview

This application now uses **Supabase** as the backend database. All data that was previously stored in SharedPreferences has been migrated to a proper PostgreSQL database with Row Level Security (RLS).

## Features

### Database Schema

The database includes the following modules:

1. **Company Management**
   - Company profile and branding
   - Bank details
   - Catalogue media (photos/videos)
   - Company settings

2. **Authentication & Users**
   - Phone-based authentication
   - User profiles with roles (Admin, Editor, Viewer)
   - Role-based access control

3. **Parties (Customers & Suppliers)**
   - Customer and supplier management
   - Contact persons
   - Full address and GST details

4. **Stock & Inventory**
   - Categories with HSN codes
   - Stock items with rental and sale rates
   - Stock transactions for tracking movements

5. **Staff Management**
   - Employee records
   - Attendance tracking (with selfie and location)
   - Leave management
   - Salary records and slips
   - Holiday management

6. **Invoices & Bills**
   - Rental invoices
   - Sale invoices
   - Purchase invoices
   - Service invoices
   - Support for:
     - Invoice items
     - Area-based charges
     - Other charges
     - GST calculations (CGST/SGST/IGST)

7. **Payments & Accounting**
   - Payment records
   - Ledger entries
   - Expense tracking
   - Party balance tracking

8. **Transportation**
   - Transporter management
   - Vehicle fleet
   - Driver details with license tracking

9. **Communication**
   - Union posts and announcements
   - Payment reminders
   - Attendance reminders

## Setup Instructions

### 1. Environment Variables

Create a `.env` file in the project root with your Supabase credentials:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

You can find these in your Supabase project settings under API.

### 2. Install Dependencies

Run the following command to install required packages:

```bash
flutter pub get
```

### 3. Initialize Supabase

The app automatically initializes Supabase when it starts (see `lib/main.dart`).

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(MyApp());
}
```

### 4. Database Setup

The database schema has already been created with the following tables:

**Company & Settings:**
- `companies`
- `company_settings`
- `attendance_settings`
- `bank_details`
- `catalogue_media`

**Users:**
- `user_profiles`

**Parties:**
- `parties`
- `party_contacts`

**Stock:**
- `stock_categories`
- `stock_items`
- `stock_transactions`

**Staff:**
- `staff`
- `attendance_records`
- `leave_requests`
- `holidays`
- `salary_records`
- `salary_slips`

**Invoices:**
- `invoices`
- `invoice_items`
- `invoice_areas`
- `invoice_other_charges`

**Payments:**
- `payments`
- `ledger_entries`
- `expenses`

**Transportation:**
- `transporters`
- `vehicles`
- `drivers`

**Communication:**
- `posts`
- `reminders`

## Security (Row Level Security)

All tables have Row Level Security (RLS) enabled. Users can only access data from their own company.

### User Roles

- **Admin**: Full access - can create, read, update, and delete all data
- **Editor**: Can create, read, and update data (cannot delete critical records)
- **Viewer**: Read-only access to all data

## Services

The backend is organized into service classes for different modules:

- `AuthService` - Authentication and user management
- `CompanyService` - Company profile and settings
- `PartyService` - Customer and supplier management
- `StockService` - Inventory management
- `StaffService` - Employee and attendance management
- `InvoiceService` - Invoice and bill management
- `PaymentService` - Payment and ledger management
- `TransporterService` - Transporter and vehicle management
- `PostService` - Posts and reminders

## Usage

### Import Services

```dart
import 'package:scaffolding_sale/backend/services/services.dart';
```

### Example: Creating a Customer

```dart
final partyService = PartyService();

try {
  final customer = await partyService.createParty(
    companyId: 'your-company-id',
    partyType: 'customer',
    name: 'ABC Construction',
    gstNumber: 'GST123456',
    mobile: '+919876543210',
    billingAddress: '123 Main Street',
  );

  print('Customer created: ${customer['id']}');
} catch (e) {
  print('Error: $e');
}
```

See `USAGE_EXAMPLES.md` for comprehensive examples of all services.

## Migration from SharedPreferences

All data previously stored in SharedPreferences should be migrated to Supabase:

| Old Storage (SharedPreferences) | New Storage (Supabase) |
|--------------------------------|------------------------|
| `parties_list` | `parties` table |
| `stock_items` | `stock_items` table |
| `categories` | `stock_categories` table |
| `companyName`, `companyAddress`, etc. | `companies` table |
| `transporters_data` | `transporters`, `vehicles`, `drivers` tables |
| `staff_list` | `staff` table |
| `attendance_settings` | `attendance_settings` table |
| Posts (static) | `posts` table |

### Migration Steps

1. Export existing data from SharedPreferences
2. Transform data to match new schema
3. Import data using service methods
4. Verify data integrity
5. Remove SharedPreferences calls from codebase

See `MIGRATION_GUIDE.md` for detailed migration instructions.

## Authentication Flow

1. User enters phone number
2. OTP is sent via SMS
3. User verifies OTP
4. User profile is created/updated
5. User is assigned to a company
6. User can access data based on their role

## API Rate Limits

Supabase has the following rate limits on the free tier:

- 50,000 monthly active users
- 500 MB database space
- 1 GB file storage
- 2 GB bandwidth

For production use, consider upgrading to a paid plan.

## Offline Support

Currently, the app requires an internet connection. For offline support:

1. Use local SQLite database
2. Sync with Supabase when online
3. Handle conflicts appropriately

This can be implemented in a future update.

## Troubleshooting

### Error: "Supabase not initialized"

Make sure `SupabaseService.initialize()` is called before using any services.

### Error: "Row Level Security policy violation"

Check that:
1. User is authenticated
2. User has proper role assigned
3. User's company_id matches the resource being accessed

### Error: "Missing environment variables"

Ensure `.env` file exists with correct Supabase credentials.

## Support

For issues or questions:
1. Check the usage examples
2. Review the migration guide
3. Contact the development team

## Future Enhancements

- [ ] Offline support with local database sync
- [ ] Real-time updates using Supabase Realtime
- [ ] File storage for photos, documents using Supabase Storage
- [ ] Advanced reporting and analytics
- [ ] Multi-language support
- [ ] Push notifications for reminders
