import 'package:flutter/material.dart';

class ChallanModel {
  String challanNo = '';
  String date = '';
  String challanType = 'Outward Challan';

  // Bill Type (only for Tax Invoice, Estimate, Quotation)
  String billType = 'Sale'; // 'Sale' or 'Rent'
  DateTime? fromDate;
  DateTime? toDate;
  int days = 0;

  // Company Details
  String companyName = '';
  String companyAddress = '';
  String companyGst = '';
  String companyPhone = '';
  String? companyLogoPath;
  String? companyNameImagePath;
  String? companyStampPath;
  String terms = '';
  String isoNumber = '';

  // Bill To Details
  String billToMobile = '';
  String billToCompany = '';
  String billToGst = '';
  String billToAddress = '';

  // Ship To Details
  String shipToAddress = '';
  String contactPerson = '';
  String contactNo = '';

  // Transport Details
  String ewayBillNo = '';
  String vehicleNumber = '';
  String driverName = '';
  String driverMobile = '';
  String drivingLicense = '';

  // GST Details
  String gstType = 'CGST-SGST';
  double gstRate = 18;

  // Items and Charges
  List<ChallanItem> items = [];
  List<AreaModel> areas = [];
  List<OtherChargeModel> otherCharges = [];

  ChallanModel();

  double get subtotal {
    double total = 0;
    // Add item amounts
    for (var item in items) {
      total += double.tryParse(item.amount) ?? 0;
    }
    // Add area amounts
    for (var area in areas) {
      double length = double.tryParse(area.length) ?? 0;
      double width = double.tryParse(area.width) ?? 0;
      double height = double.tryParse(area.height) ?? 0;
      double rate = double.tryParse(area.rate) ?? 0;
      double areaAmount = length * width * height * rate;
      if (billType == 'Rent') {
        areaAmount *= area.days;
      }
      total += areaAmount;
    }
    // Add other charges
    for (var charge in otherCharges) {
      total += charge.amount;
    }
    return total;
  }

  double get gstAmount {
    if ((challanType != 'Tax Invoice' &&
            challanType != 'Estimate' &&
            challanType != 'Quotation') ||
        gstType == 'No GST') {
      return 0;
    }
    return subtotal * gstRate / 100;
  }

  double get totalAmount {
    double total = subtotal;
    if ((challanType == 'Tax Invoice' ||
            challanType == 'Estimate' ||
            challanType == 'Quotation') &&
        gstType != 'No GST') {
      total += gstAmount;
    }
    return total;
  }

  Map<String, dynamic> toMap() {
    return {
      'challanNo': challanNo,
      'date': date,
      'challanType': challanType,
      'billType': billType,
      'fromDate': fromDate?.toIso8601String(),
      'toDate': toDate?.toIso8601String(),
      'days': days,
      'companyName': companyName,
      'companyAddress': companyAddress,
      'companyGst': companyGst,
      'companyPhone': companyPhone,
      'companyLogoPath': companyLogoPath,
      'companyNameImagePath': companyNameImagePath,
      'companyStampPath': companyStampPath,
      'terms': terms,
      'isoNumber': isoNumber,
      'billToMobile': billToMobile,
      'billToCompany': billToCompany,
      'billToGst': billToGst,
      'billToAddress': billToAddress,
      'shipToAddress': shipToAddress,
      'contactPerson': contactPerson,
      'contactNo': contactNo,
      'ewayBillNo': ewayBillNo,
      'vehicleNumber': vehicleNumber,
      'driverName': driverName,
      'driverMobile': driverMobile,
      'drivingLicense': drivingLicense,
      'gstType': gstType,
      'gstRate': gstRate,
      'items': items.map((item) => item.toMap()).toList(),
      'areas': areas.map((area) => area.toMap()).toList(),
      'otherCharges': otherCharges.map((charge) => charge.toMap()).toList(),
    };
  }

  factory ChallanModel.fromMap(Map<String, dynamic> map) {
    ChallanModel challan = ChallanModel();
    challan.challanNo = map['challanNo'] ?? '';
    challan.date = map['date'] ?? '';
    challan.challanType = map['challanType'] ?? 'Outward Challan';
    challan.billType = map['billType'] ?? 'Sale';
    challan.fromDate =
        map['fromDate'] != null ? DateTime.parse(map['fromDate']) : null;
    challan.toDate =
        map['toDate'] != null ? DateTime.parse(map['toDate']) : null;
    challan.days = map['days'] ?? 0;
    challan.companyName = map['companyName'] ?? '';
    challan.companyAddress = map['companyAddress'] ?? '';
    challan.companyGst = map['companyGst'] ?? '';
    challan.companyPhone = map['companyPhone'] ?? '';
    challan.companyLogoPath = map['companyLogoPath'];
    challan.companyNameImagePath = map['companyNameImagePath'];
    challan.companyStampPath = map['companyStampPath'];
    challan.terms = map['terms'] ?? '';
    challan.isoNumber = map['isoNumber'] ?? '';
    challan.billToMobile = map['billToMobile'] ?? '';
    challan.billToCompany = map['billToCompany'] ?? '';
    challan.billToGst = map['billToGst'] ?? '';
    challan.billToAddress = map['billToAddress'] ?? '';
    challan.shipToAddress = map['shipToAddress'] ?? '';
    challan.contactPerson = map['contactPerson'] ?? '';
    challan.contactNo = map['contactNo'] ?? '';
    challan.ewayBillNo = map['ewayBillNo'] ?? '';
    challan.vehicleNumber = map['vehicleNumber'] ?? '';
    challan.driverName = map['driverName'] ?? '';
    challan.driverMobile = map['driverMobile'] ?? '';
    challan.drivingLicense = map['drivingLicense'] ?? '';
    challan.gstType = map['gstType'] ?? 'CGST-SGST';
    challan.gstRate = (map['gstRate'] ?? 18).toDouble();
    challan.items = (map['items'] as List?)
            ?.map((item) => ChallanItem.fromMap(item))
            .toList() ??
        [];
    challan.areas = (map['areas'] as List?)
            ?.map((area) => AreaModel.fromMap(area))
            .toList() ??
        [];
    challan.otherCharges = (map['otherCharges'] as List?)
            ?.map((charge) => OtherChargeModel.fromMap(charge))
            .toList() ??
        [];
    return challan;
  }
}

class ChallanItem {
  String itemName = '';
  String quantity = '';
  String hsnCode = '';
  String perPieceWeight = '';
  String totalWeight = '';
  String rate = '';
  String rentPerDay = '';
  String amount = '';
  DateTime? fromDate;
  DateTime? toDate;
  int days = 0;

  ChallanItem();

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'quantity': quantity,
      'hsnCode': hsnCode,
      'perPieceWeight': perPieceWeight,
      'totalWeight': totalWeight,
      'rate': rate,
      'rentPerDay': rentPerDay,
      'amount': amount,
      'fromDate': fromDate?.toIso8601String(),
      'toDate': toDate?.toIso8601String(),
      'days': days,
    };
  }

  factory ChallanItem.fromMap(Map<String, dynamic> map) {
    ChallanItem item = ChallanItem();
    item.itemName = map['itemName'] ?? '';
    item.quantity = map['quantity'] ?? '';
    item.hsnCode = map['hsnCode'] ?? '';
    item.perPieceWeight = map['perPieceWeight'] ?? '';
    item.totalWeight = map['totalWeight'] ?? '0';
    item.rate = map['rate'] ?? '';
    item.rentPerDay = map['rentPerDay'] ?? '';
    item.amount = map['amount'] ?? '0';
    item.fromDate =
        map['fromDate'] != null ? DateTime.parse(map['fromDate']) : null;
    item.toDate = map['toDate'] != null ? DateTime.parse(map['toDate']) : null;
    item.days = map['days'] ?? 0;
    return item;
  }
}

class AreaModel {
  String hsnCode;
  String areaname;
  String length = '';
  String width = '';
  String height = '';
  String rate = '';
  DateTime? fromDate;
  DateTime? toDate;
  int days = 0;

  AreaModel({
    this.length = '',
    this.width = '',
    this.areaname = "",
    this.height = '',
    this.rate = '',
    this.hsnCode = "",
  });

  Map<String, dynamic> toMap() => {
        'length': length,
        'width': width,
        'height': height,
        'rate': rate,
        'fromDate': fromDate?.toIso8601String(),
        'toDate': toDate?.toIso8601String(),
        'days': days,
        'areaname': areaname,
        'hsnCode': hsnCode
      };

  factory AreaModel.fromMap(Map<String, dynamic> map) => AreaModel(
      areaname: map['areaname'] ?? "",
      length: map['length'] ?? '',
      width: map['width'] ?? '',
      height: map['height'] ?? '',
      rate: map['rate'] ?? '',
      hsnCode: map['hsnCode'] ?? "")
    ..fromDate =
        map['fromDate'] != null ? DateTime.parse(map['fromDate']) : null
    ..toDate = map['toDate'] != null ? DateTime.parse(map['toDate']) : null
    ..days = map['days'] ?? 0;
}

class OtherChargeModel {
  String hsnCode;
  String description;
  double quantity;
  double rate;
  double amount;
  String unit;

  // Text controllers for UI binding
  final TextEditingController hsnController;
  final TextEditingController descController;
  final TextEditingController qtyController;
  final TextEditingController rateController;
  final TextEditingController amtController;

  OtherChargeModel({
    this.hsnCode = '',
    this.description = '',
    this.quantity = 0.0,
    this.rate = 0.0,
    this.amount = 0.0,
    this.unit = 'Kgs',
  })  : hsnController = TextEditingController(text: hsnCode),
        descController = TextEditingController(text: description),
        qtyController = TextEditingController(
            text: quantity.toInt() == 0 ? "" : quantity.toString()),
        rateController = TextEditingController(
            text: rate.toInt() == 0 ? "" : rate.toString()),
        amtController = TextEditingController(
            text: amount.toInt() == 0 ? "" : amount.toStringAsFixed(2));

  Map<String, dynamic> toMap() => {
        'hsnCode': hsnCode,
        'description': description,
        'quantity': quantity,
        'rate': rate,
        'amount': amount,
      };

  factory OtherChargeModel.fromMap(Map<String, dynamic> map) {
    final model = OtherChargeModel(
      hsnCode: map['hsnCode'] ?? '',
      description: map['description'] ?? '',
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      rate: (map['rate'] ?? 0.0).toDouble(),
      amount: (map['amount'] ?? 0.0).toDouble(),
    );

    // Set initial controller values
    model.hsnController.text = model.hsnCode;
    model.descController.text = model.description;
    model.qtyController.text = model.quantity.toString();
    model.rateController.text = model.rate.toString();
    model.amtController.text = model.amount.toStringAsFixed(2);

    return model;
  }
}

// ============================================
// SUPABASE MODELS - NEW BACKEND MODELS
// ============================================

class Company {
  final String id;
  final String name;
  final String? address;
  final String? gstNumber;
  final String? phone;
  final List<String>? phones;
  final String? email;
  final String? logoUrl;
  final String? nameImageUrl;
  final String? stampUrl;
  final String? termsAndConditions;
  final String? isoNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Company({
    required this.id,
    required this.name,
    this.address,
    this.gstNumber,
    this.phone,
    this.phones,
    this.email,
    this.logoUrl,
    this.nameImageUrl,
    this.stampUrl,
    this.termsAndConditions,
    this.isoNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'],
      gstNumber: map['gst_number'],
      phone: map['phone'],
      phones: List<String>.from(map['phones'] ?? []),
      email: map['email'],
      logoUrl: map['logo_url'],
      nameImageUrl: map['name_image_url'],
      stampUrl: map['stamp_url'],
      termsAndConditions: map['terms_and_conditions'],
      isoNumber: map['iso_number'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class UserProfile {
  final String id;
  final String companyId;
  final String phoneNumber;
  final String? fullName;
  final String role;
  final String? profilePhotoUrl;
  final String? aadharNumber;
  final String? aadharDocumentUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.companyId,
    required this.phoneNumber,
    this.fullName,
    this.role = 'viewer',
    this.profilePhotoUrl,
    this.aadharNumber,
    this.aadharDocumentUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      fullName: map['full_name'],
      role: map['role'] ?? 'viewer',
      profilePhotoUrl: map['profile_photo_url'],
      aadharNumber: map['aadhar_number'],
      aadharDocumentUrl: map['aadhar_document_url'],
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Party {
  final String id;
  final String companyId;
  final String partyType;
  final String name;
  final String? companyName;
  final String? gstNumber;
  final String? mobile;
  final String? email;
  final String? billingAddress;
  final String? shippingAddress;
  final String? state;
  final String? pincode;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Party({
    required this.id,
    required this.companyId,
    required this.partyType,
    required this.name,
    this.companyName,
    this.gstNumber,
    this.mobile,
    this.email,
    this.billingAddress,
    this.shippingAddress,
    this.state,
    this.pincode,
    this.isActive = true,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Party.fromMap(Map<String, dynamic> map) {
    return Party(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      partyType: map['party_type'] ?? 'customer',
      name: map['name'] ?? '',
      companyName: map['company_name'],
      gstNumber: map['gst_number'],
      mobile: map['mobile'],
      email: map['email'],
      billingAddress: map['billing_address'],
      shippingAddress: map['shipping_address'],
      state: map['state'],
      pincode: map['pincode'],
      isActive: map['is_active'] ?? true,
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class StockCategory {
  final String id;
  final String companyId;
  final String name;
  final String? hsnCode;
  final String? imageUrl;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  StockCategory({
    required this.id,
    required this.companyId,
    required this.name,
    this.hsnCode,
    this.imageUrl,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockCategory.fromMap(Map<String, dynamic> map) {
    return StockCategory(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      name: map['name'] ?? '',
      hsnCode: map['hsn_code'],
      imageUrl: map['image_url'],
      description: map['description'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class StockItem {
  final String id;
  final String companyId;
  final String? categoryId;
  final String name;
  final String? size;
  final String? hsnCode;
  final int quantity;
  final int availableQuantity;
  final int dispatchedQuantity;
  final String unit;
  final double weightPerUnit;
  final double rentRate;
  final double saleRate;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  StockItem({
    required this.id,
    required this.companyId,
    this.categoryId,
    required this.name,
    this.size,
    this.hsnCode,
    this.quantity = 0,
    this.availableQuantity = 0,
    this.dispatchedQuantity = 0,
    this.unit = 'pcs',
    this.weightPerUnit = 0,
    this.rentRate = 0,
    this.saleRate = 0,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockItem.fromMap(Map<String, dynamic> map) {
    return StockItem(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      categoryId: map['category_id'],
      name: map['name'] ?? '',
      size: map['size'],
      hsnCode: map['hsn_code'],
      quantity: (map['quantity'] ?? 0).toInt(),
      availableQuantity: (map['available_quantity'] ?? 0).toInt(),
      dispatchedQuantity: (map['dispatched_quantity'] ?? 0).toInt(),
      unit: map['unit'] ?? 'pcs',
      weightPerUnit: (map['weight_per_unit'] ?? 0).toDouble(),
      rentRate: (map['rent_rate'] ?? 0).toDouble(),
      saleRate: (map['sale_rate'] ?? 0).toDouble(),
      imageUrl: map['image_url'],
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Staff {
  final String id;
  final String companyId;
  final String name;
  final String? mobile;
  final String? email;
  final String? address;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? designation;
  final String? photoUrl;
  final String? aadharNumber;
  final String? aadharDocumentUrl;
  final double expenseAllowance;
  final double areaRate;
  final String areaUnit;
  final double timeRate;
  final String timeUnit;
  final bool isActive;
  final DateTime joiningDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Staff({
    required this.id,
    required this.companyId,
    required this.name,
    this.mobile,
    this.email,
    this.address,
    this.gender,
    this.dateOfBirth,
    this.designation,
    this.photoUrl,
    this.aadharNumber,
    this.aadharDocumentUrl,
    this.expenseAllowance = 0,
    this.areaRate = 0,
    this.areaUnit = 'sqft',
    this.timeRate = 0,
    this.timeUnit = 'hour',
    this.isActive = true,
    required this.joiningDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Staff.fromMap(Map<String, dynamic> map) {
    return Staff(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      name: map['name'] ?? '',
      mobile: map['mobile'],
      email: map['email'],
      address: map['address'],
      gender: map['gender'],
      dateOfBirth: map['date_of_birth'] != null ? DateTime.parse(map['date_of_birth']) : null,
      designation: map['designation'],
      photoUrl: map['photo_url'],
      aadharNumber: map['aadhar_number'],
      aadharDocumentUrl: map['aadhar_document_url'],
      expenseAllowance: (map['expense_allowance'] ?? 0).toDouble(),
      areaRate: (map['area_rate'] ?? 0).toDouble(),
      areaUnit: map['area_unit'] ?? 'sqft',
      timeRate: (map['time_rate'] ?? 0).toDouble(),
      timeUnit: map['time_unit'] ?? 'hour',
      isActive: map['is_active'] ?? true,
      joiningDate: map['joining_date'] != null ? DateTime.parse(map['joining_date']) : DateTime.now(),
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Invoice {
  final String id;
  final String companyId;
  final String? partyId;
  final String invoiceType;
  final String documentType;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String status;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? days;
  final String? billToName;
  final String? billToCompany;
  final String? billToGst;
  final String? billToMobile;
  final String? billToAddress;
  final String? shipToAddress;
  final String? contactPerson;
  final String? contactNumber;
  final String? ewayBillNo;
  final String? vehicleNumber;
  final String? driverName;
  final String? driverMobile;
  final String? driverLicense;
  final String? transporterId;
  final String gstType;
  final double gstRate;
  final double subtotal;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double otherChargesTotal;
  final double roundOff;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final String? paymentTerms;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Invoice({
    required this.id,
    required this.companyId,
    this.partyId,
    required this.invoiceType,
    required this.documentType,
    required this.invoiceNumber,
    required this.invoiceDate,
    this.status = 'draft',
    this.fromDate,
    this.toDate,
    this.days,
    this.billToName,
    this.billToCompany,
    this.billToGst,
    this.billToMobile,
    this.billToAddress,
    this.shipToAddress,
    this.contactPerson,
    this.contactNumber,
    this.ewayBillNo,
    this.vehicleNumber,
    this.driverName,
    this.driverMobile,
    this.driverLicense,
    this.transporterId,
    this.gstType = 'cgst_sgst',
    this.gstRate = 0,
    this.subtotal = 0,
    this.cgstAmount = 0,
    this.sgstAmount = 0,
    this.igstAmount = 0,
    this.otherChargesTotal = 0,
    this.roundOff = 0,
    this.totalAmount = 0,
    this.paidAmount = 0,
    this.dueAmount = 0,
    this.paymentTerms,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      partyId: map['party_id'],
      invoiceType: map['invoice_type'] ?? 'sale',
      documentType: map['document_type'] ?? 'tax_invoice',
      invoiceNumber: map['invoice_number'] ?? '',
      invoiceDate: DateTime.parse(map['invoice_date'] ?? DateTime.now().toIso8601String()),
      status: map['status'] ?? 'draft',
      fromDate: map['from_date'] != null ? DateTime.parse(map['from_date']) : null,
      toDate: map['to_date'] != null ? DateTime.parse(map['to_date']) : null,
      days: map['days'],
      billToName: map['bill_to_name'],
      billToCompany: map['bill_to_company'],
      billToGst: map['bill_to_gst'],
      billToMobile: map['bill_to_mobile'],
      billToAddress: map['bill_to_address'],
      shipToAddress: map['ship_to_address'],
      contactPerson: map['contact_person'],
      contactNumber: map['contact_number'],
      ewayBillNo: map['eway_bill_no'],
      vehicleNumber: map['vehicle_number'],
      driverName: map['driver_name'],
      driverMobile: map['driver_mobile'],
      driverLicense: map['driver_license'],
      transporterId: map['transporter_id'],
      gstType: map['gst_type'] ?? 'cgst_sgst',
      gstRate: (map['gst_rate'] ?? 0).toDouble(),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      cgstAmount: (map['cgst_amount'] ?? 0).toDouble(),
      sgstAmount: (map['sgst_amount'] ?? 0).toDouble(),
      igstAmount: (map['igst_amount'] ?? 0).toDouble(),
      otherChargesTotal: (map['other_charges_total'] ?? 0).toDouble(),
      roundOff: (map['round_off'] ?? 0).toDouble(),
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
      paidAmount: (map['paid_amount'] ?? 0).toDouble(),
      dueAmount: (map['due_amount'] ?? 0).toDouble(),
      paymentTerms: map['payment_terms'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Payment {
  final String id;
  final String companyId;
  final String? partyId;
  final String? invoiceId;
  final String paymentType;
  final DateTime paymentDate;
  final double amount;
  final String paymentMode;
  final String? referenceNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.companyId,
    this.partyId,
    this.invoiceId,
    required this.paymentType,
    required this.paymentDate,
    required this.amount,
    required this.paymentMode,
    this.referenceNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      partyId: map['party_id'],
      invoiceId: map['invoice_id'],
      paymentType: map['payment_type'] ?? 'received',
      paymentDate: DateTime.parse(map['payment_date'] ?? DateTime.now().toIso8601String()),
      amount: (map['amount'] ?? 0).toDouble(),
      paymentMode: map['payment_mode'] ?? 'cash',
      referenceNumber: map['reference_number'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Transporter {
  final String id;
  final String companyId;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? gstNumber;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transporter({
    required this.id,
    required this.companyId,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.gstNumber,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transporter.fromMap(Map<String, dynamic> map) {
    return Transporter(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      name: map['name'] ?? '',
      contactPerson: map['contact_person'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      gstNumber: map['gst_number'],
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Post {
  final String id;
  final String companyId;
  final String? createdBy;
  final String? title;
  final String content;
  final String? imageUrl;
  final String postType;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.companyId,
    this.createdBy,
    this.title,
    required this.content,
    this.imageUrl,
    this.postType = 'announcement',
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      createdBy: map['created_by'],
      title: map['title'],
      content: map['content'] ?? '',
      imageUrl: map['image_url'],
      postType: map['post_type'] ?? 'announcement',
      isPinned: map['is_pinned'] ?? false,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
