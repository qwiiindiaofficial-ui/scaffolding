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
