# Quick Start - Get App Building & Working in 30 Minutes

## Step 1: Build the Project (5 minutes)

```bash
cd /path/to/project
flutter pub get
flutter clean
flutter pub get

# For Android
flutter build apk --release

# Or for debug testing
flutter run
```

If build fails, it's likely due to the auth screens. Proceed to Step 2.

## Step 2: Fix Auth Screens (20 minutes)

### File 1: Update `lib/screens/auth/phonenumber.dart`

**Find**: The `PhoneNumberScreen` class button action

**Add these imports**:
```dart
import 'package:get/get.dart';
import 'package:scaffolding_sale/controllers/app_controller.dart';
import 'package:scaffolding_sale/utils/app_helpers.dart';
```

**Replace Send OTP button with**:
```dart
ElevatedButton(
  onPressed: () async {
    if (phoneNumber.isEmpty) {
      showError('Please enter phone number');
      return;
    }

    final appController = AppController.to;
    final success = await appController.loginWithPhone(phoneNumber);

    if (success) {
      showSuccess('OTP sent');
      Get.to(() => OTPScreen(phoneNumber: phoneNumber));
    }
  },
  child: const Text('Send OTP'),
)
```

### File 2: Update `lib/screens/auth/otp.dart`

**Add imports**:
```dart
import 'package:get/get.dart';
import 'package:scaffolding_sale/controllers/app_controller.dart';
import 'package:scaffolding_sale/screens/home/home.dart';
import 'package:scaffolding_sale/utils/app_helpers.dart';
```

**Replace Verify button with**:
```dart
ElevatedButton(
  onPressed: () async {
    final appController = AppController.to;
    final success = await appController.verifyOTP(
      widget.phoneNumber,
      otp,
    );

    if (success) {
      showSuccess('Logged in');
      Get.offAll(() => HomeScreen(phone: widget.phoneNumber));
    } else {
      showError('Invalid OTP');
    }
  },
  child: const Text('Verify'),
)
```

### File 3: Update `lib/screens/auth/register/form.dart`

**Add imports**:
```dart
import 'package:get/get.dart';
import 'package:scaffolding_sale/controllers/app_controller.dart';
import 'package:scaffolding_sale/screens/home/home.dart';
import 'package:scaffolding_sale/utils/app_helpers.dart';
```

**Replace submit button**:
```dart
ElevatedButton(
  onPressed: () async {
    try {
      showLoadingDialog();
      final appController = AppController.to;

      final company = await appController.companyService.createCompany(
        name: companyNameController.text,
        gstNumber: gstController.text,
        address: addressController.text,
        phone: phoneController.text,
      );

      await appController.createUserProfile(
        userId: appController.userId!,
        companyId: company['id'],
        phoneNumber: phoneController.text,
        fullName: nameController.text,
      );

      closeLoadingDialog();
      showSuccess('Account created');
      Get.offAll(() => HomeScreen(phone: phoneController.text));
    } catch (e) {
      closeLoadingDialog();
      showError(e.toString());
    }
  },
  child: const Text('Create Account'),
)
```

## Step 3: Build

```bash
flutter clean
flutter pub get
flutter build apk --release
```

## Testing Flow

1. Splash (3 sec) → Login screen
2. Enter phone → Click "Send OTP"
3. Enter OTP → Click "Verify"
4. Fill form → Click "Create Account"
5. Go to Home Screen ✅

## Key Points

- ✅ Supabase backend ready
- ✅ All services ready
- ✅ Just need to update 3 auth screens
- ✅ Then integrate other screens using INTEGRATION_GUIDE.md

## Next: Integrate Screens

Use `INTEGRATION_GUIDE.md` and `lib/backend/USAGE_EXAMPLES.md` to integrate remaining screens.

**Total production time**: 14-19 hours
