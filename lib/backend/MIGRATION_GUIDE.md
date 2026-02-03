# Migration Guide: SharedPreferences to Supabase

This guide helps you migrate existing data from SharedPreferences to Supabase database.

## Overview

The migration involves:
1. Reading existing data from SharedPreferences
2. Transforming it to match the new schema
3. Creating records in Supabase
4. Updating code to use Supabase services instead of SharedPreferences

## Pre-Migration Checklist

- [ ] Backup all existing data
- [ ] Ensure Supabase is properly initialized
- [ ] Create a test company in the database
- [ ] Verify authentication is working

## Step 1: Create Company Profile

First, create your company profile in Supabase:

```dart
import 'package:scaffolding_sale/backend/services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> migrateCompanyData() async {
  final prefs = await SharedPreferences.getInstance();
  final companyService = CompanyService();

  // Read old data
  final companyName = prefs.getString('companyName') ?? '';
  final companyAddress = prefs.getString('companyAddress') ?? '';
  final companyGst = prefs.getString('companyGst') ?? '';
  final companyPhone = prefs.getString('companyPhone') ?? '';
  final companyLogoPath = prefs.getString('companyLogoPath');
  final terms = prefs.getString('terms');

  // Create company in Supabase
  final company = await companyService.createCompany(
    name: companyName,
    address: companyAddress,
    gstNumber: companyGst,
    phone: companyPhone,
    logoUrl: companyLogoPath,
    termsAndConditions: terms,
  );

  print('Company created: ${company['id']}');
  return company['id'];
}
```

## Step 2: Migrate Bank Details

```dart
Future<void> migrateBankDetails(String companyId) async {
  final prefs = await SharedPreferences.getInstance();
  final companyService = CompanyService();

  // Read old bank details (stored as JSON string)
  final bankDetailsJson = prefs.getString('bankDetails');
  if (bankDetailsJson != null && bankDetailsJson.isNotEmpty) {
    final bankDetailsList = json.decode(bankDetailsJson) as List;

    for (var bank in bankDetailsList) {
      await companyService.addBankDetails(
        companyId: companyId,
        bankName: bank['bankName'] ?? '',
        accountNumber: bank['accountNumber'] ?? '',
        ifscCode: bank['ifscCode'] ?? '',
        accountHolderName: bank['accountHolderName'] ?? '',
        branch: bank['branch'],
        upiId: bank['upiId'],
        isPrimary: bank['isPrimary'] ?? false,
      );
    }

    print('Bank details migrated');
  }
}
```

## Step 3: Migrate Parties (Customers & Suppliers)

```dart
Future<void> migrateParties(String companyId) async {
  final prefs = await SharedPreferences.getInstance();
  final partyService = PartyService();

  // Read old parties list
  final partiesJson = prefs.getStringList('parties_list') ?? [];

  for (var partyJsonString in partiesJson) {
    final party = json.decode(partyJsonString);

    await partyService.createParty(
      companyId: companyId,
      partyType: 'customer', // or determine from data
      name: party['name'] ?? '',
      companyName: party['company'] ?? '',
      gstNumber: party['gst'] ?? '',
      mobile: party['mobile'] ?? '',
      billingAddress: party['address'] ?? '',
      state: party['state'] ?? '',
    );
  }

  print('Parties migrated: ${partiesJson.length}');
}
```

## Step 4: Migrate Stock Categories

```dart
Future<void> migrateCategories(String companyId) async {
  final prefs = await SharedPreferences.getInstance();
  final stockService = StockService();

  final categoriesJson = prefs.getString('categories');
  if (categoriesJson != null && categoriesJson.isNotEmpty) {
    final categories = json.decode(categoriesJson) as List;

    for (var category in categories) {
      await stockService.createCategory(
        companyId: companyId,
        name: category['name'] ?? '',
        hsnCode: category['hsnCode'] ?? '',
        imageUrl: category['image'],
      );
    }

    print('Categories migrated: ${categories.length}');
  }
}
```

## Step 5: Migrate Stock Items

```dart
Future<void> migrateStockItems(String companyId) async {
  final prefs = await SharedPreferences.getInstance();
  final stockService = StockService();

  final stockItemsJson = prefs.getString('stock_items');
  if (stockItemsJson != null && stockItemsJson.isNotEmpty) {
    final items = json.decode(stockItemsJson) as List;

    // First, get all categories to map names to IDs
    final categories = await stockService.getCategories(companyId);
    final categoryMap = {
      for (var cat in categories) cat['name']: cat['id']
    };

    for (var item in items) {
      final categoryId = categoryMap[item['category']];

      await stockService.createStockItem(
        companyId: companyId,
        categoryId: categoryId,
        name: item['title'] ?? '',
        size: item['size'] ?? '',
        hsnCode: item['hsnCode'] ?? '',
        quantity: item['quantity'] ?? 0,
        rentRate: (item['rate'] ?? 0).toDouble(),
        saleRate: (item['saleRate'] ?? 0).toDouble(),
        weightPerUnit: (item['weight'] ?? 0).toDouble(),
        imageUrl: item['image'],
      );
    }

    print('Stock items migrated: ${items.length}');
  }
}
```

## Step 6: Migrate Staff

```dart
Future<void> migrateStaff(String companyId) async {
  final prefs = await SharedPreferences.getInstance();
  final staffService = StaffService();

  final staffJson = prefs.getString('staff_list');
  if (staffJson != null && staffJson.isNotEmpty) {
    final staffList = json.decode(staffJson) as List;

    for (var staff in staffList) {
      await staffService.createStaff(
        companyId: companyId,
        name: staff['name'] ?? '',
        mobile: staff['mobile'] ?? '',
        address: staff['address'] ?? '',
        gender: staff['gender'] ?? '',
        dateOfBirth: staff['dob'] != null
            ? DateTime.tryParse(staff['dob'])
            : null,
        designation: staff['designation'] ?? '',
        photoUrl: staff['photoPath'],
        aadharNumber: staff['aadharNumber'],
        aadharDocumentUrl: staff['aadharPath'],
        expenseAllowance: (staff['expenseAllowance'] ?? 0).toDouble(),
        areaRate: (staff['areaRate'] ?? 0).toDouble(),
        timeRate: (staff['timeRate'] ?? 0).toDouble(),
      );
    }

    print('Staff migrated: ${staffList.length}');
  }
}
```

## Step 7: Migrate Transporters

```dart
Future<void> migrateTransporters(String companyId) async {
  final prefs = await SharedPreferences.getInstance();
  final transporterService = TransporterService();

  final transportersJson = prefs.getString('transporters_data');
  if (transportersJson != null && transportersJson.isNotEmpty) {
    final transporters = json.decode(transportersJson) as List;

    for (var transporter in transporters) {
      // Create transporter
      final newTransporter = await transporterService.createTransporter(
        companyId: companyId,
        name: transporter['name'] ?? '',
        contactPerson: transporter['contactPerson'] ?? '',
        phone: transporter['phone'] ?? '',
        email: transporter['email'] ?? '',
      );

      // Add vehicles
      final vehicles = transporter['vehicles'] as List? ?? [];
      for (var vehicle in vehicles) {
        await transporterService.addVehicle(
          transporterId: newTransporter['id'],
          vehicleNumber: vehicle['vehicleNumber'] ?? '',
          vehicleType: vehicle['vehicleType'] ?? '',
          capacity: vehicle['capacity'] ?? '',
        );
      }

      // Add drivers
      final drivers = transporter['drivers'] as List? ?? [];
      for (var driver in drivers) {
        await transporterService.addDriver(
          transporterId: newTransporter['id'],
          name: driver['name'] ?? '',
          phone: driver['phone'] ?? '',
          licenseNumber: driver['license']?['licenseNumber'] ?? '',
          licenseExpiryDate: driver['license']?['expiryDate'] != null
              ? DateTime.tryParse(driver['license']['expiryDate'])
              : null,
        );
      }
    }

    print('Transporters migrated: ${transporters.length}');
  }
}
```

## Step 8: Migrate Attendance Settings

```dart
Future<void> migrateAttendanceSettings(String companyId) async {
  final prefs = await SharedPreferences.getInstance();

  final settingsJson = prefs.getString('attendance_settings');
  if (settingsJson != null && settingsJson.isNotEmpty) {
    final settings = json.decode(settingsJson);

    // Create attendance settings in Supabase
    final client = SupabaseService.client;

    await client.from('attendance_settings').insert({
      'company_id': companyId,
      'start_time': settings['startTime'] ?? '09:00:00',
      'end_time': settings['endTime'] ?? '18:00:00',
      'working_days': settings['workingDays'] ?? [true, true, true, true, true, true, false],
      'location_mode': settings['locationMode'] ?? 'optional',
      'allow_staff_view': settings['allowStaffView'] ?? true,
      'radius_meters': settings['radiusMeters'] ?? 100,
    });

    print('Attendance settings migrated');
  }
}
```

## Step 9: Complete Migration Script

Here's a complete migration function that runs all steps:

```dart
import 'dart:convert';
import 'package:scaffolding_sale/backend/services/services.dart';
import 'package:scaffolding_sale/backend/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> runCompleteMigration() async {
  try {
    print('Starting migration...');

    // Step 1: Migrate company
    final companyId = await migrateCompanyData();

    // Step 2: Migrate bank details
    await migrateBankDetails(companyId);

    // Step 3: Migrate categories first (needed for stock items)
    await migrateCategories(companyId);

    // Step 4: Migrate stock items
    await migrateStockItems(companyId);

    // Step 5: Migrate parties
    await migrateParties(companyId);

    // Step 6: Migrate staff
    await migrateStaff(companyId);

    // Step 7: Migrate transporters
    await migrateTransporters(companyId);

    // Step 8: Migrate attendance settings
    await migrateAttendanceSettings(companyId);

    print('Migration completed successfully!');
    print('Company ID: $companyId');
    print('Save this Company ID - you will need it for user registration');

  } catch (e) {
    print('Migration failed: $e');
    rethrow;
  }
}
```

## Step 10: Update User Registration

After migration, update your user registration to link users to the company:

```dart
Future<void> registerUser(String phoneNumber, String companyId) async {
  final authService = AuthService();

  // After OTP verification
  final user = authService.currentUser;
  if (user != null) {
    await authService.createUserProfile(
      userId: user.id,
      companyId: companyId, // Use the migrated company ID
      phoneNumber: phoneNumber,
      role: 'admin', // First user should be admin
    );
  }
}
```

## Step 11: Clean Up

After successful migration and verification:

1. **Test thoroughly** - Verify all data is correctly migrated
2. **Backup SharedPreferences** - Keep a backup just in case
3. **Remove old code** - Gradually remove SharedPreferences calls
4. **Update UI** - Update screens to use new services

### Example: Updating a Screen

**Old Code (SharedPreferences):**
```dart
final prefs = await SharedPreferences.getInstance();
final partiesJson = prefs.getStringList('parties_list') ?? [];
final parties = partiesJson.map((e) => json.decode(e)).toList();
```

**New Code (Supabase):**
```dart
final partyService = PartyService();
final parties = await partyService.getParties(
  companyId: currentCompanyId,
  partyType: 'customer',
);
```

## Troubleshooting

### Error: "Duplicate key violation"

Some records may already exist. Use `upsert` instead of `insert` or check for existing records first.

### Error: "Foreign key violation"

Ensure parent records (like company, categories) are created before child records (like stock items).

### Data Mismatch

Compare counts:
```dart
// Old count
final oldCount = (prefs.getStringList('parties_list') ?? []).length;

// New count
final newParties = await partyService.getParties(companyId: companyId);
print('Old: $oldCount, New: ${newParties.length}');
```

## Rollback Plan

If migration fails:

1. Don't delete SharedPreferences data immediately
2. Keep old code in separate branch
3. Use feature flags to switch between old and new backend
4. Can run app with old SharedPreferences while fixing issues

## Post-Migration

After migration is complete:

1. Monitor database performance
2. Set up regular backups in Supabase dashboard
3. Review RLS policies for security
4. Optimize queries if needed
5. Plan for future features (real-time sync, offline support)

## Need Help?

If you encounter issues during migration:
1. Check Supabase logs in dashboard
2. Review RLS policies
3. Verify authentication state
4. Test with a small dataset first
