# Backend Setup Guide - Scaffolding & Shuttering App

## Overview

Your scaffolding and shuttering application now has a complete Supabase backend implementation. This guide will help you get started.

## What's Been Done

### 1. Database Schema ✅

A comprehensive database schema has been created in Supabase with **25+ tables** covering:

- **Company Management**: Company profile, bank details, settings, catalogue
- **Authentication**: User profiles with role-based access (Admin/Editor/Viewer)
- **Parties**: Customers and suppliers with contact management
- **Inventory**: Stock categories, items, and transaction tracking
- **Staff**: Employee records, attendance, leaves, salary management
- **Invoices**: Rental, sales, purchase, and service invoices with full GST support
- **Payments**: Payment tracking, ledger, and expense management
- **Transportation**: Transporters, vehicles, and driver management
- **Communication**: Posts and reminders

### 2. Row Level Security (RLS) ✅

All tables have RLS enabled with policies ensuring:
- Users can only access their company's data
- Role-based permissions (Admin, Editor, Viewer)
- Secure multi-tenant architecture

### 3. Flutter Service Layer ✅

9 comprehensive service classes have been created:

```
lib/backend/services/
├── auth_service.dart          # Authentication & user management
├── company_service.dart       # Company profile & settings
├── party_service.dart         # Customer/supplier management
├── stock_service.dart         # Inventory management
├── staff_service.dart         # Employee & attendance
├── invoice_service.dart       # Invoice & bill management
├── payment_service.dart       # Payments & ledger
├── transporter_service.dart   # Transportation management
└── post_service.dart          # Posts & reminders
```

### 4. Documentation ✅

- `README.md` - Complete backend documentation
- `USAGE_EXAMPLES.md` - Comprehensive usage examples for all services
- `MIGRATION_GUIDE.md` - Step-by-step guide to migrate from SharedPreferences

## Setup Steps

### Step 1: Install Dependencies

Run the following command in your project directory:

```bash
flutter pub get
```

This will install the newly added `supabase_flutter` package.

### Step 2: Configure Environment Variables

Your Supabase credentials are already configured in the `.env` file:

```env
SUPABASE_URL=<your-url>
SUPABASE_ANON_KEY=<your-key>
```

These are automatically loaded by the app. **Do not commit the .env file to version control**.

### Step 3: Verify Database Setup

1. Open your Supabase project dashboard
2. Go to Table Editor
3. Verify all tables are created:
   - companies
   - user_profiles
   - parties
   - stock_items
   - staff
   - invoices
   - payments
   - And 18 more tables...

### Step 4: Test the Setup

The app automatically initializes Supabase on startup (see `lib/main.dart`).

To verify it's working:

```dart
import 'package:scaffolding_sale/backend/services/services.dart';

// Test authentication
final authService = AuthService();
print('Supabase initialized: ${SupabaseService.client != null}');
```

## Next Steps

### Option 1: Start Fresh (New Installation)

If this is a new installation:

1. **Create your company**:
```dart
final company = await CompanyService().createCompany(
  name: 'Your Company Name',
  gstNumber: 'GST123456',
  address: 'Your Address',
  phone: '+91XXXXXXXXXX',
);
```

2. **Register first user as admin**:
```dart
// After OTP verification
await AuthService().createUserProfile(
  userId: user.id,
  companyId: company['id'],
  phoneNumber: '+91XXXXXXXXXX',
  role: 'admin',
);
```

3. **Start adding data** using the services (see USAGE_EXAMPLES.md)

### Option 2: Migrate Existing Data

If you have existing data in SharedPreferences:

1. Review `lib/backend/MIGRATION_GUIDE.md`
2. Run the migration script to move data to Supabase
3. Test thoroughly
4. Gradually replace SharedPreferences calls with service calls

## Usage Examples

### Creating a Customer

```dart
import 'package:scaffolding_sale/backend/services/services.dart';

final partyService = PartyService();

final customer = await partyService.createParty(
  companyId: 'your-company-id',
  partyType: 'customer',
  name: 'ABC Construction',
  gstNumber: 'GST123456',
  mobile: '+919876543210',
  billingAddress: '123 Main Street',
);
```

### Creating a Rental Invoice

```dart
final invoiceService = InvoiceService();

// Generate invoice number
final invoiceNumber = await invoiceService.generateInvoiceNumber(
  companyId: 'your-company-id',
  invoiceType: 'rental',
);

// Create invoice
final invoice = await invoiceService.createInvoice(
  companyId: 'your-company-id',
  partyId: customer['id'],
  invoiceType: 'rental',
  documentType: 'tax_invoice',
  invoiceNumber: invoiceNumber,
  invoiceDate: DateTime.now(),
  status: 'current',
);

// Add items
await invoiceService.addInvoiceItem(
  invoiceId: invoice['id'],
  itemName: 'MS Pipe 6ft',
  quantity: 50,
  rate: 5.0,
  amount: 250.0,
);
```

### Recording a Payment

```dart
final paymentService = PaymentService();

await paymentService.createPayment(
  companyId: 'your-company-id',
  partyId: customer['id'],
  invoiceId: invoice['id'],
  paymentType: 'received',
  paymentDate: DateTime.now(),
  amount: 10000,
  paymentMode: 'upi',
);
```

See `lib/backend/USAGE_EXAMPLES.md` for more examples.

## Project Structure

```
lib/
├── backend/
│   ├── supabase_service.dart          # Core Supabase initialization
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── company_service.dart
│   │   ├── party_service.dart
│   │   ├── stock_service.dart
│   │   ├── staff_service.dart
│   │   ├── invoice_service.dart
│   │   ├── payment_service.dart
│   │   ├── transporter_service.dart
│   │   ├── post_service.dart
│   │   └── services.dart              # Barrel export file
│   ├── README.md                       # Backend documentation
│   ├── USAGE_EXAMPLES.md               # Usage examples
│   └── MIGRATION_GUIDE.md              # Migration guide
├── screens/                            # Your existing screens
├── widgets/                            # Your existing widgets
└── main.dart                           # Updated with Supabase init
```

## Key Features

### 🔒 Security
- Row Level Security on all tables
- Role-based access control
- Phone-based authentication
- Company data isolation

### 📊 Data Management
- Complete CRUD operations for all entities
- Automatic ledger tracking
- Stock transaction history
- Payment and invoice linkage

### 👥 Multi-User Support
- Admin, Editor, and Viewer roles
- Company-based data segregation
- User profile management

### 📱 Real-time Ready
- Database structure supports real-time updates
- Can enable Supabase Realtime in future

## Common Tasks

### Getting Current Company ID

```dart
final userId = SupabaseService.currentUserId;
final profile = await AuthService().getUserProfile(userId!);
final companyId = profile['company_id'];
```

### Checking User Role

```dart
final profile = await AuthService().getUserProfile(userId!);
final role = profile['role']; // 'admin', 'editor', or 'viewer'
```

### Error Handling

Always wrap service calls in try-catch:

```dart
try {
  final result = await partyService.createParty(...);
  // Handle success
} catch (e) {
  // Handle error
  print('Error: $e');
}
```

## Database Schema Diagram

```
companies (1)
├── user_profiles (many)
├── parties (many)
│   ├── party_contacts (many)
│   ├── invoices (many)
│   │   ├── invoice_items (many)
│   │   ├── invoice_areas (many)
│   │   └── invoice_other_charges (many)
│   ├── payments (many)
│   └── ledger_entries (many)
├── stock_categories (many)
│   └── stock_items (many)
│       └── stock_transactions (many)
├── staff (many)
│   ├── attendance_records (many)
│   ├── leave_requests (many)
│   └── salary_records (many)
├── transporters (many)
│   ├── vehicles (many)
│   └── drivers (many)
├── posts (many)
└── reminders (many)
```

## Troubleshooting

### App crashes on startup

Check that:
1. Supabase credentials are correct in `.env`
2. Flutter packages are installed (`flutter pub get`)
3. Check console for initialization errors

### "RLS policy violation" errors

Ensure:
1. User is authenticated
2. User has correct role
3. User's company_id matches the resource

### Cannot fetch data

Verify:
1. Database tables are created
2. RLS policies are enabled
3. Internet connection is active
4. Supabase project is running

## Support & Resources

- **Backend Documentation**: `lib/backend/README.md`
- **Usage Examples**: `lib/backend/USAGE_EXAMPLES.md`
- **Migration Guide**: `lib/backend/MIGRATION_GUIDE.md`
- **Supabase Docs**: https://supabase.com/docs

## Performance Tips

1. **Use pagination** for large datasets
2. **Index frequently queried fields** in Supabase
3. **Cache data locally** when appropriate
4. **Use select()** to fetch only needed columns
5. **Batch operations** when inserting multiple records

## Future Enhancements

Possible improvements:
- [ ] Real-time sync using Supabase Realtime
- [ ] File storage for images/documents
- [ ] Offline support with local database
- [ ] Advanced analytics and reports
- [ ] Push notifications
- [ ] Export data to Excel/PDF
- [ ] Multi-language support

## License

This backend implementation is part of your scaffolding application.

---

**Need Help?** Contact your development team or refer to the documentation files in `lib/backend/`.
