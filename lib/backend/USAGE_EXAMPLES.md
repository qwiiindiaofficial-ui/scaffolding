# Supabase Backend Services - Usage Guide

This guide demonstrates how to use the Supabase backend services in your Flutter application.

## 1. Authentication Service

### Sign In with Phone Number
```dart
import 'package:scaffolding_sale/backend/services/services.dart';

final authService = AuthService();

// Send OTP
try {
  final response = await authService.signInWithPhone('+919876543210');
  print('OTP sent successfully');
} catch (e) {
  print('Error sending OTP: $e');
}

// Verify OTP
try {
  final response = await authService.verifyOTP('+919876543210', '123456');
  final user = response.user;
  print('Logged in: ${user?.id}');
} catch (e) {
  print('Error verifying OTP: $e');
}
```

### Create/Update User Profile
```dart
// Create user profile after first login
final profile = await authService.createUserProfile(
  userId: user.id,
  companyId: 'company-uuid',
  phoneNumber: '+919876543210',
  fullName: 'John Doe',
  role: 'admin',
);

// Update user profile
await authService.updateUserProfile(
  userId: user.id,
  fullName: 'John Updated',
  profilePhotoUrl: 'https://example.com/photo.jpg',
);
```

## 2. Company Service

### Get/Update Company Details
```dart
import 'package:scaffolding_sale/backend/services/services.dart';

final companyService = CompanyService();

// Get company
final company = await companyService.getCompany('company-uuid');
print('Company: ${company?['name']}');

// Update company
await companyService.updateCompany(
  companyId: 'company-uuid',
  name: 'ABC Scaffolding Pvt Ltd',
  gstNumber: 'GST123456',
  address: '123 Main Street',
  phone: '+919876543210',
);

// Add bank details
await companyService.addBankDetails(
  companyId: 'company-uuid',
  bankName: 'State Bank of India',
  accountNumber: '1234567890',
  ifscCode: 'SBIN0001234',
  accountHolderName: 'ABC Scaffolding',
  isPrimary: true,
);
```

## 3. Party Service (Customers & Suppliers)

### Create and Manage Parties
```dart
import 'package:scaffolding_sale/backend/services/services.dart';

final partyService = PartyService();

// Create customer
final customer = await partyService.createParty(
  companyId: 'company-uuid',
  partyType: 'customer',
  name: 'Customer Name',
  companyName: 'Customer Company Ltd',
  gstNumber: 'GST987654',
  mobile: '+919876543210',
  billingAddress: '456 Street',
  state: 'Maharashtra',
);

// Get all customers
final customers = await partyService.getParties(
  companyId: 'company-uuid',
  partyType: 'customer',
  isActive: true,
);

// Search parties
final results = await partyService.searchParties(
  companyId: 'company-uuid',
  searchTerm: 'ABC',
  partyType: 'customer',
);
```

## 4. Stock Service

### Manage Inventory
```dart
import 'package:scaffolding_sale/backend/services/services.dart';

final stockService = StockService();

// Create category
final category = await stockService.createCategory(
  companyId: 'company-uuid',
  name: 'Scaffolding Pipe',
  hsnCode: '7308',
);

// Create stock item
final item = await stockService.createStockItem(
  companyId: 'company-uuid',
  categoryId: category['id'],
  name: 'MS Pipe 6ft',
  size: '6ft',
  hsnCode: '7308',
  quantity: 1000,
  rentRate: 5.0,
  saleRate: 250.0,
  unit: 'pcs',
  weightPerUnit: 12.5,
);

// Get all stock items
final items = await stockService.getStockItems(
  companyId: 'company-uuid',
  isActive: true,
);

// Create stock transaction
await stockService.createStockTransaction(
  companyId: 'company-uuid',
  stockItemId: item['id'],
  transactionType: 'rental_out',
  quantity: 50,
  notes: 'Rented to Customer ABC',
);
```

## 5. Staff Service

### Manage Employees
```dart
import 'package:scaffolding_sale/backend/services/services.dart';

final staffService = StaffService();

// Create staff
final staff = await staffService.createStaff(
  companyId: 'company-uuid',
  name: 'Rajesh Kumar',
  mobile: '+919876543210',
  designation: 'Supervisor',
  gender: 'male',
  dateOfBirth: DateTime(1990, 1, 15),
  expenseAllowance: 500,
  areaRate: 10.0,
  timeRate: 150.0,
);

// Mark attendance
await staffService.markAttendance(
  companyId: 'company-uuid',
  staffId: staff['id'],
  attendanceDate: DateTime.now(),
  status: 'present',
  checkInTime: '09:00:00',
  checkOutTime: '18:00:00',
);

// Create leave request
await staffService.createLeaveRequest(
  companyId: 'company-uuid',
  staffId: staff['id'],
  leaveType: 'casual',
  fromDate: DateTime(2024, 3, 15),
  toDate: DateTime(2024, 3, 16),
  days: 2,
  reason: 'Personal work',
);

// Create salary record
await staffService.createSalaryRecord(
  companyId: 'company-uuid',
  staffId: staff['id'],
  month: 3,
  year: 2024,
  daysPresent: 26,
  daysAbsent: 2,
  basicSalary: 15000,
  allowances: 2000,
  grossSalary: 17000,
  netSalary: 17000,
);
```

## 6. Invoice Service

### Create and Manage Invoices
```dart
import 'package:scaffolding_sale/backend/services/services.dart';

final invoiceService = InvoiceService();

// Generate invoice number
final invoiceNumber = await invoiceService.generateInvoiceNumber(
  companyId: 'company-uuid',
  invoiceType: 'rental',
);

// Create rental invoice
final invoice = await invoiceService.createInvoice(
  companyId: 'company-uuid',
  partyId: 'party-uuid',
  invoiceType: 'rental',
  documentType: 'tax_invoice',
  invoiceNumber: invoiceNumber,
  invoiceDate: DateTime.now(),
  status: 'current',
  fromDate: DateTime.now(),
  toDate: DateTime.now().add(Duration(days: 30)),
  days: 30,
  billToName: 'Customer Name',
  billToCompany: 'Customer Company',
  gstType: 'cgst_sgst',
  gstRate: 18.0,
);

// Add invoice items
await invoiceService.addInvoiceItem(
  invoiceId: invoice['id'],
  stockItemId: 'stock-item-uuid',
  itemName: 'MS Pipe 6ft',
  hsnCode: '7308',
  quantity: 50,
  rate: 5.0,
  rentPerDay: 5.0,
  days: 30,
  amount: 7500.0,
);

// Add area-based charges
await invoiceService.addInvoiceArea(
  invoiceId: invoice['id'],
  areaName: 'Platform Area',
  length: 10,
  width: 8,
  height: 15,
  rate: 2.5,
  days: 30,
  amount: 9000.0,
);

// Add other charges
await invoiceService.addInvoiceOtherCharge(
  invoiceId: invoice['id'],
  description: 'Transportation',
  quantity: 1,
  rate: 5000,
  amount: 5000,
);

// Update invoice totals
await invoiceService.updateInvoice(
  invoiceId: invoice['id'],
  subtotal: 21500,
  cgstAmount: 1935,
  sgstAmount: 1935,
  totalAmount: 25370,
  dueAmount: 25370,
);

// Get invoices
final invoices = await invoiceService.getInvoices(
  companyId: 'company-uuid',
  invoiceType: 'rental',
  status: 'current',
);
```

## 7. Payment Service

### Record Payments and Manage Ledger
```dart
import 'package:scaffolding_sale/backend/services/services.dart';

final paymentService = PaymentService();

// Create payment
await paymentService.createPayment(
  companyId: 'company-uuid',
  partyId: 'party-uuid',
  invoiceId: 'invoice-uuid',
  paymentType: 'received',
  paymentDate: DateTime.now(),
  amount: 10000,
  paymentMode: 'upi',
  referenceNumber: 'UPI123456',
  notes: 'Partial payment received',
);

// Get party ledger
final ledger = await paymentService.getLedgerEntries(
  partyId: 'party-uuid',
  fromDate: DateTime(2024, 1, 1),
  toDate: DateTime.now(),
);

// Get party summary
final summary = await paymentService.getPartySummary('party-uuid');
print('Balance: ${summary['balance']}');

// Create expense
await paymentService.createExpense(
  companyId: 'company-uuid',
  expenseDate: DateTime.now(),
  category: 'Transportation',
  amount: 5000,
  paymentMode: 'cash',
  description: 'Fuel and vehicle maintenance',
);
```

## 8. Transporter Service

### Manage Transporters, Vehicles, and Drivers
```dart
import 'package:scaffolding_sale/backend/services/services.dart';

final transporterService = TransporterService();

// Create transporter
final transporter = await transporterService.createTransporter(
  companyId: 'company-uuid',
  name: 'XYZ Transport',
  contactPerson: 'Ramesh',
  phone: '+919876543210',
  gstNumber: 'GST789456',
);

// Add vehicle
await transporterService.addVehicle(
  transporterId: transporter['id'],
  vehicleNumber: 'MH12AB1234',
  vehicleType: 'Truck',
  capacity: '10 Ton',
);

// Add driver
await transporterService.addDriver(
  transporterId: transporter['id'],
  name: 'Suresh Driver',
  phone: '+919876543210',
  licenseNumber: 'DL123456',
  licenseExpiryDate: DateTime(2026, 12, 31),
);

// Get transporter with all details
final details = await transporterService.getTransporterWithDetails(
  transporter['id'],
);
```

## 9. Post Service (Union/Announcements)

### Create Posts and Reminders
```dart
import 'package:scaffolding_sale/backend/services/services.dart';

final postService = PostService();

// Create post
await postService.createPost(
  companyId: 'company-uuid',
  title: 'Important Announcement',
  content: 'Office will be closed tomorrow for public holiday',
  postType: 'announcement',
  isPinned: true,
);

// Get all posts
final posts = await postService.getPosts(
  companyId: 'company-uuid',
);

// Create reminder
await postService.createReminder(
  companyId: 'company-uuid',
  reminderType: 'payment',
  partyId: 'party-uuid',
  invoiceId: 'invoice-uuid',
  reminderDate: DateTime.now().add(Duration(days: 3)),
  message: 'Payment due in 3 days for Invoice #INV-001',
);
```

## Error Handling

Always wrap service calls in try-catch blocks:

```dart
try {
  final result = await partyService.createParty(
    companyId: 'company-uuid',
    partyType: 'customer',
    name: 'Customer Name',
  );
  print('Success: ${result['id']}');
} catch (e) {
  print('Error: $e');
  // Show error message to user
}
```

## Authentication State Management

Listen to auth state changes:

```dart
import 'package:scaffolding_sale/backend/services/services.dart';

final authService = AuthService();

authService.authStateChanges.listen((data) {
  final session = data.session;
  if (session != null) {
    print('User logged in: ${session.user.id}');
    // Navigate to home screen
  } else {
    print('User logged out');
    // Navigate to login screen
  }
});
```

## Best Practices

1. **Always check authentication**: Ensure user is logged in before making API calls
2. **Handle errors gracefully**: Use try-catch blocks and show user-friendly messages
3. **Use transactions**: For operations that update multiple tables
4. **Optimize queries**: Only fetch data you need using select()
5. **Cache data**: Store frequently accessed data locally using SharedPreferences
6. **Validate input**: Validate data before sending to database
7. **Use constants**: Define table and column names as constants to avoid typos
