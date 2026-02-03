# Complete Backend Integration Guide - Scaffolding App

## Overview

This guide provides step-by-step instructions for integrating the Supabase backend into all 77+ screens of the scaffolding application. The infrastructure is already set up:

✅ Supabase database with 25+ tables
✅ Backend service classes (9 services)
✅ Data models (Company, Party, Stock, Staff, Invoice, Payment, Transporter, Post)
✅ Global AppController using GetX for state management
✅ Splash screen with auth integration
✅ Helper utilities for UI operations

## Architecture

```
AppController (GetX) - Global State
    ├── AuthService
    ├── CompanyService
    ├── PartyService
    ├── StockService
    ├── StaffService
    ├── InvoiceService
    ├── PaymentService
    ├── TransporterService
    └── PostService
```

## Screen Integration Template

Use this template to integrate any screen with the backend:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffolding_sale/controllers/app_controller.dart';
import 'package:scaffolding_sale/backend/models.dart';
import 'package:scaffolding_sale/utils/app_helpers.dart';

class ScreenName extends StatefulWidget {
  const ScreenName({super.key});

  @override
  State<ScreenName> createState() => _ScreenNameState();
}

class _ScreenNameState extends State<ScreenName> {
  final appController = AppController.to;
  final RxList<DataModel> items = <DataModel>[].obs;
  final isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;

      // Get company ID from app controller
      final companyId = appController.companyId;
      if (companyId == null) {
        showError('Company not found');
        return;
      }

      // Call service method
      final data = await appController.partyService.getParties(
        companyId: companyId,
      );

      // Map to models
      items.value = data.map((item) => Party.fromMap(item)).toList();

    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createItem(DataModel item) async {
    try {
      showLoadingDialog('Creating...');

      final companyId = appController.companyId;
      if (companyId == null) throw Exception('Company not found');

      // Call service
      final result = await appController.partyService.createParty(
        companyId: companyId,
        name: item.name,
        // ... other fields
      );

      showSuccess('Created successfully');
      closeLoadingDialog();
      loadData(); // Refresh list

    } catch (e) {
      closeLoadingDialog();
      handleError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen Title')),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              title: Text(item.name),
              // ... build UI
            );
          },
        );
      }),
      floatingActionButton: !canEdit()
          ? null
          : FloatingActionButton(
              onPressed: () => _showCreateDialog(),
              child: const Icon(Icons.add),
            ),
    );
  }

  void _showCreateDialog() {
    // Show dialog for creation
  }
}
```

## Priority Integration Order

### Phase 1: Authentication (COMPLETED)
- [x] Splash Screen
- [ ] Phone Number Screen
- [ ] OTP Verification Screen
- [ ] User Registration Screen

### Phase 2: Core Data (HIGH PRIORITY)
1. **Customers/Parties** - Foundation for invoices/payments
   - `lib/screens/home/Customers.dart`
   - `lib/screens/home/search_party.dart`
   - `lib/screens/home/new account.dart`
   - Service: `PartyService`
   - Replace SharedPreferences key: `parties_list`

2. **Stock/Inventory** - Foundation for invoices
   - `lib/screens/home/stock.dart`
   - `lib/screens/home/item.dart`
   - Service: `StockService`
   - Replace SharedPreferences keys: `stock_items`, `categories`

3. **Invoices/Bills** - Central feature
   - `lib/screens/home/sale/Bills.dart`
   - `lib/screens/home/rental/menu/bill/bills.dart`
   - Service: `InvoiceService`

### Phase 3: Transactional Data (MEDIUM PRIORITY)
4. **Staff Management**
   - `lib/screens/home/Staff Management/staffmanagement.dart`
   - Service: `StaffService`
   - Replace SharedPreferences key: `staff_list`

5. **Payments**
   - `lib/screens/All Payment.dart`
   - `lib/screens/Expenese.dart`
   - Service: `PaymentService`

### Phase 4: Supporting Features (LOWER PRIORITY)
6. **Company Details**
   - `lib/companydetails.dart`
   - Service: `CompanyService`
   - Replace SharedPreferences keys: `companyName`, `companyAddress`, etc.

7. **Transporter Management**
   - `lib/transporter/screens/`
   - Service: `TransporterService`

8. **Posts/Announcements**
   - `lib/screens/home/Union/`
   - Service: `PostService`

## Common Integration Patterns

### Pattern 1: List Screen (Read-Only)

```dart
Future<void> loadData() async {
  try {
    isLoading.value = true;
    final companyId = appController.companyId ?? '';

    final data = await appController.partyService.getParties(
      companyId: companyId,
    );

    items.value = data.map((item) => Party.fromMap(item)).toList();
  } catch (e) {
    handleError(e);
  } finally {
    isLoading.value = false;
  }
}
```

### Pattern 2: CRUD Screen

```dart
// CREATE
Future<void> createItem() async {
  try {
    showLoadingDialog();
    final result = await appController.partyService.createParty(
      companyId: appController.companyId ?? '',
      name: nameController.text,
      mobile: mobileController.text,
      // ... other fields
    );
    closeLoadingDialog();
    showSuccess('Item created');
    loadData();
  } catch (e) {
    closeLoadingDialog();
    handleError(e);
  }
}

// UPDATE
Future<void> updateItem(String itemId) async {
  try {
    showLoadingDialog();
    await appController.partyService.updateParty(
      partyId: itemId,
      name: nameController.text,
      mobile: mobileController.text,
    );
    closeLoadingDialog();
    showSuccess('Item updated');
    loadData();
  } catch (e) {
    closeLoadingDialog();
    handleError(e);
  }
}

// DELETE
Future<void> deleteItem(String itemId) async {
  showConfirmDialog(
    title: 'Confirm Delete',
    message: 'Are you sure?',
    onConfirm: () async {
      try {
        showLoadingDialog();
        await appController.partyService.deleteParty(itemId);
        closeLoadingDialog();
        showSuccess('Item deleted');
        loadData();
      } catch (e) {
        closeLoadingDialog();
        handleError(e);
      }
    },
  );
}
```

### Pattern 3: Search/Filter Screen

```dart
Future<void> searchItems(String query) async {
  try {
    isLoading.value = true;
    final companyId = appController.companyId ?? '';

    final data = await appController.partyService.searchParties(
      companyId: companyId,
      searchTerm: query,
    );

    items.value = data.map((item) => Party.fromMap(item)).toList();
  } catch (e) {
    handleError(e);
  } finally {
    isLoading.value = false;
  }
}
```

### Pattern 4: Detail Screen

```dart
Future<void> loadDetail(String itemId) async {
  try {
    isLoading.value = true;

    final data = await appController.partyService.getParty(itemId);
    if (data != null) {
      item.value = Party.fromMap(data);
    }
  } catch (e) {
    handleError(e);
  } finally {
    isLoading.value = false;
  }
}
```

## Screen-by-Screen Integration Checklist

### Authentication Flow
- [ ] `phonenumber.dart` - Integrate with AuthService.signInWithPhone()
- [ ] `otp.dart` - Integrate with AuthService.verifyOTP()
- [ ] `form.dart` - Integrate with createUserProfile()

### Party Management
- [ ] `Customers.dart` - Load parties from PartyService
- [ ] `search_party.dart` - Implement search
- [ ] `new account.dart` - Create new party
- [ ] `company detail.dart` - View party details

### Stock Management
- [ ] `stock.dart` - Display stock items and categories
- [ ] `item.dart` - Manage individual items
- [ ] `Union/union.dart` - Union stock summary
- [ ] `Union/edit.dart` - Edit union stock
- [ ] `Union/view.dart` - View union stock

### Sales Module
- [ ] `sale/sale.dart` - Create sale invoice
- [ ] `sale/Bills.dart` - View sale bills
- [ ] `sale/salebills.dart` - Manage sale bills
- [ ] `sale/detail.dart` - Invoice detail view
- [ ] `sale/Service.dart` - Service sales

### Rental Module
- [ ] `rental/rental.dart` - Create rental invoice
- [ ] `rental/menu/bill/bills.dart` - Rental bills
- [ ] `rental/slip/slip.dart` - Rental slips
- [ ] `rental/menu/transport.dart` - Transport assignment

### Staff Module
- [ ] `Staff Management/staffmanagement.dart` - List staff
- [ ] `Staff Management/Add Staff.dart` - Create staff
- [ ] `Staff Management/Attendance.dart` - Mark attendance
- [ ] `Staff Management/Attendance Management.dart` - Manage attendance
- [ ] `Staff Management/leave.dart` - Manage leaves
- [ ] `Staff Management/Salary detail.dart` - Salary info
- [ ] `Staff Management/SalarySlip.dart` - Generate slip

### Financial Module
- [ ] `All Payment.dart` - View payments
- [ ] `Expenese.dart` - Track expenses
- [ ] `All Bills.dart` - View all bills

### Company Settings
- [ ] `companydetails.dart` - Company profile
- [ ] `BankDetail.dart` - Bank details
- [ ] `Catalogue.dart` - Catalogue media

### Other
- [ ] `More.dart` - Navigation menu
- [ ] `Union/` folder - Union features
- [ ] Transporter screens - Transporter management

## Testing Checklist

For each integrated screen, test:

- [ ] Data loads correctly from Supabase
- [ ] Create operation works and reflects in list
- [ ] Update operation works correctly
- [ ] Delete operation works correctly
- [ ] Search/filter functionality works
- [ ] Pagination works (if applicable)
- [ ] Error handling shows proper messages
- [ ] Loading states display correctly
- [ ] Authentication check works
- [ ] Proper error messages for network failures

## Key Implementation Points

### 1. Always Check Company ID
```dart
final companyId = appController.companyId;
if (companyId == null) {
  showError('Company not found');
  return;
}
```

### 2. Always Wrap in Try-Catch
```dart
try {
  // service call
} catch (e) {
  handleError(e);
} finally {
  isLoading.value = false;
}
```

### 3. Use Rxn for Observables
```dart
final item = Rxn<Party>();
final items = <Party>[].obs;
final isLoading = false.obs;
```

### 4. Use Obx for Reactivity
```dart
Obx(() => Text(appController.currentUser.value?.fullName ?? 'Guest'))
```

### 5. Convert Maps to Models
```dart
final items = data.map((item) => Party.fromMap(item)).toList();
```

## Removing SharedPreferences

For each screen that used SharedPreferences, follow this pattern:

**Before:**
```dart
final prefs = await SharedPreferences.getInstance();
final partiesJson = prefs.getStringList('parties_list') ?? [];
final parties = partiesJson.map((e) => json.decode(e)).toList();
```

**After:**
```dart
final parties = await appController.partyService.getParties(
  companyId: appController.companyId ?? '',
);
final items = parties.map((item) => Party.fromMap(item)).toList();
```

## Environment Setup

Your `.env` file already has:
- `SUPABASE_URL` = Your project URL
- `SUPABASE_ANON_KEY` = Your anon key

These are automatically loaded by `SupabaseService.initialize()`.

## Debugging

Enable debug logging in AppController:
```dart
// Add to AppController
void logDebug(String message) {
  if (kDebugMode) {
    print('[AppController] $message');
  }
}
```

Monitor app state:
```dart
// In any screen
watch(() {
  print('Auth state: ${appController.isAuthenticated.value}');
  print('Company: ${appController.currentCompany.value?.name}');
  print('User: ${appController.currentUser.value?.fullName}');
});
```

## Next Steps

1. **Start with Splash Screen** - Already done ✅
2. **Integrate Customers/Parties** - Foundation for other features
3. **Integrate Stock** - Needed for invoices
4. **Integrate Invoices** - Core feature
5. **Integrate Staff** - Important for operations
6. **Integrate Payments** - Financial tracking
7. **Integrate remaining screens**

## Build & Test

When all screens are integrated:

```bash
# Get dependencies
flutter pub get

# Build APK
flutter build apk --release

# Build Web
flutter build web --release

# Run on device
flutter run --release
```

## Production Checklist

- [ ] All screens use Supabase backend
- [ ] No SharedPreferences usage (except for local caching)
- [ ] All error messages are user-friendly
- [ ] Loading states are visible
- [ ] RLS policies are tested
- [ ] User roles (Admin/Editor/Viewer) are enforced
- [ ] Offline scenarios handled gracefully
- [ ] App builds without errors
- [ ] All features tested on device

---

**Questions?** Refer to:
- `lib/backend/USAGE_EXAMPLES.md` - Code examples
- `lib/backend/README.md` - Backend documentation
- `lib/controllers/app_controller.dart` - Global state
