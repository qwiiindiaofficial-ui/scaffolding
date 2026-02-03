import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:scaffolding_sale/controllers/app_controller.dart';

// ============================================
// TOAST NOTIFICATIONS
// ============================================

void showSuccess(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.green,
    textColor: Colors.white,
  );
}

void showError(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.red,
    textColor: Colors.white,
  );
}

void showInfo(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.blue,
    textColor: Colors.white,
  );
}

// ============================================
// LOADING DIALOGS
// ============================================

void showLoadingDialog([String message = 'Please wait...']) {
  Get.defaultDialog(
    title: '',
    content: Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(message),
      ],
    ),
    barrierDismissible: false,
  );
}

void closeLoadingDialog() {
  if (Get.isDialogOpen ?? false) {
    Get.back();
  }
}

// ============================================
// ERROR HANDLING
// ============================================

void handleError(dynamic error) {
  String message = 'An error occurred';

  if (error is Exception) {
    message = error.toString().replaceFirst('Exception: ', '');
  } else if (error is String) {
    message = error;
  }

  showError(message);
  print('Error: $message');
}

// ============================================
// AUTHENTICATION HELPERS
// ============================================

bool isUserAuthenticated() {
  final appController = AppController.to;
  return appController.isAuthenticated.value && appController.currentUser.value != null;
}

bool canEdit() {
  final appController = AppController.to;
  return appController.isAdmin() || appController.isEditor();
}

bool canDelete() {
  final appController = AppController.to;
  return appController.isAdmin();
}

String? getUserCompanyId() {
  final appController = AppController.to;
  return appController.companyId;
}

String? getCurrentUserId() {
  final appController = AppController.to;
  return appController.userId;
}

// ============================================
// FORM VALIDATION
// ============================================

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    return null;
  }

  static String? validateRequired(String? value, [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a number';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  static String? validateGST(String? value) {
    if (value == null || value.isEmpty) {
      return 'GST number is required';
    }
    final gstRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    if (!gstRegex.hasMatch(value)) {
      return 'Please enter a valid GST number';
    }
    return null;
  }
}

// ============================================
// DATE & TIME HELPERS
// ============================================

String formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

String formatDateTime(DateTime dateTime) {
  return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
}

int getDaysDifference(DateTime from, DateTime to) {
  return to.difference(from).inDays + 1;
}

// ============================================
// NUMBER FORMATTING
// ============================================

String formatCurrency(double amount) {
  return '₹${amount.toStringAsFixed(2)}';
}

String formatNumber(double number) {
  return number.toStringAsFixed(2);
}

String formatWholeNumber(int number) {
  return number.toString();
}

// ============================================
// COMMON DIALOGS
// ============================================

void showConfirmDialog({
  required String title,
  required String message,
  required VoidCallback onConfirm,
  String confirmText = 'Yes',
  String cancelText = 'No',
}) {
  Get.defaultDialog(
    title: title,
    content: Text(message),
    textConfirm: confirmText,
    textCancel: cancelText,
    onConfirm: () {
      Get.back();
      onConfirm();
    },
    onCancel: () {
      Get.back();
    },
  );
}

// ============================================
// LIST FILTERING & SORTING
// ============================================

T? findById<T>(List<T> list, String id, String Function(T) getIdFunc) {
  try {
    return list.firstWhere((item) => getIdFunc(item) == id);
  } catch (e) {
    return null;
  }
}

List<T> filterByName<T>(List<T> list, String query, String Function(T) getNameFunc) {
  if (query.isEmpty) return list;
  return list
      .where((item) =>
          getNameFunc(item).toLowerCase().contains(query.toLowerCase()))
      .toList();
}

// ============================================
// PAGINATION HELPERS
// ============================================

class PaginationHelper {
  static const int defaultPageSize = 20;

  static int calculatePages(int totalItems, [int pageSize = defaultPageSize]) {
    return (totalItems / pageSize).ceil();
  }

  static List<T> paginate<T>(List<T> list, int pageNumber, [int pageSize = defaultPageSize]) {
    final start = (pageNumber - 1) * pageSize;
    final end = (start + pageSize).clamp(0, list.length);

    if (start >= list.length) return [];
    return list.sublist(start, end);
  }
}

// ============================================
// DEBUGGING
// ============================================

void logDebug(String tag, String message) {
  print('[$tag] $message');
}

void logError(String tag, String message) {
  print('[$tag] ERROR: $message');
}

void logSuccess(String tag, String message) {
  print('[$tag] SUCCESS: $message');
}
