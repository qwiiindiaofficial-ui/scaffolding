import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_service.dart';

class InvoiceService {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<Map<String, dynamic>>> getInvoices({
    required String companyId,
    String? invoiceType,
    String? status,
    String? partyId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    var query = _client
        .from('invoices')
        .select('*, parties(name, company_name)')
        .eq('company_id', companyId);

    if (invoiceType != null) {
      query = query.eq('invoice_type', invoiceType);
    }

    if (status != null) {
      query = query.eq('status', status);
    }

    if (partyId != null) {
      query = query.eq('party_id', partyId);
    }

    if (fromDate != null) {
      query = query.gte('invoice_date', fromDate.toIso8601String().split('T')[0]);
    }

    if (toDate != null) {
      query = query.lte('invoice_date', toDate.toIso8601String().split('T')[0]);
    }

    final response = await query.order('invoice_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getInvoice(String invoiceId) async {
    final response = await _client
        .from('invoices')
        .select('*, parties(name, company_name, gst_number, mobile, billing_address), transporter:transporters(name)')
        .eq('id', invoiceId)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>> createInvoice({
    required String companyId,
    String? partyId,
    required String invoiceType,
    required String documentType,
    required String invoiceNumber,
    required DateTime invoiceDate,
    String status = 'draft',
    DateTime? fromDate,
    DateTime? toDate,
    int? days,
    String? billToName,
    String? billToCompany,
    String? billToGst,
    String? billToMobile,
    String? billToAddress,
    String? shipToAddress,
    String? contactPerson,
    String? contactNumber,
    String? ewayBillNo,
    String? vehicleNumber,
    String? driverName,
    String? driverMobile,
    String? driverLicense,
    String? transporterId,
    String gstType = 'cgst_sgst',
    double gstRate = 0,
    String? paymentTerms,
    String? notes,
  }) async {
    final data = {
      'company_id': companyId,
      'party_id': partyId,
      'invoice_type': invoiceType,
      'document_type': documentType,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate.toIso8601String().split('T')[0],
      'status': status,
      'from_date': fromDate?.toIso8601String().split('T')[0],
      'to_date': toDate?.toIso8601String().split('T')[0],
      'days': days,
      'bill_to_name': billToName,
      'bill_to_company': billToCompany,
      'bill_to_gst': billToGst,
      'bill_to_mobile': billToMobile,
      'bill_to_address': billToAddress,
      'ship_to_address': shipToAddress,
      'contact_person': contactPerson,
      'contact_number': contactNumber,
      'eway_bill_no': ewayBillNo,
      'vehicle_number': vehicleNumber,
      'driver_name': driverName,
      'driver_mobile': driverMobile,
      'driver_license': driverLicense,
      'transporter_id': transporterId,
      'gst_type': gstType,
      'gst_rate': gstRate,
      'payment_terms': paymentTerms,
      'notes': notes,
      'created_by': SupabaseService.currentUserId,
    };

    final response = await _client
        .from('invoices')
        .insert(data)
        .select()
        .single();

    return response;
  }

  Future<Map<String, dynamic>> updateInvoice({
    required String invoiceId,
    String? partyId,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    int? days,
    String? billToName,
    String? billToCompany,
    String? billToGst,
    String? billToMobile,
    String? billToAddress,
    String? shipToAddress,
    String? contactPerson,
    String? contactNumber,
    String? ewayBillNo,
    String? vehicleNumber,
    String? driverName,
    String? driverMobile,
    String? driverLicense,
    String? transporterId,
    String? gstType,
    double? gstRate,
    double? subtotal,
    double? cgstAmount,
    double? sgstAmount,
    double? igstAmount,
    double? otherChargesTotal,
    double? roundOff,
    double? totalAmount,
    double? paidAmount,
    double? dueAmount,
    String? paymentTerms,
    String? notes,
  }) async {
    final data = <String, dynamic>{'updated_at': DateTime.now().toIso8601String()};

    if (partyId != null) data['party_id'] = partyId;
    if (status != null) data['status'] = status;
    if (fromDate != null) data['from_date'] = fromDate.toIso8601String().split('T')[0];
    if (toDate != null) data['to_date'] = toDate.toIso8601String().split('T')[0];
    if (days != null) data['days'] = days;
    if (billToName != null) data['bill_to_name'] = billToName;
    if (billToCompany != null) data['bill_to_company'] = billToCompany;
    if (billToGst != null) data['bill_to_gst'] = billToGst;
    if (billToMobile != null) data['bill_to_mobile'] = billToMobile;
    if (billToAddress != null) data['bill_to_address'] = billToAddress;
    if (shipToAddress != null) data['ship_to_address'] = shipToAddress;
    if (contactPerson != null) data['contact_person'] = contactPerson;
    if (contactNumber != null) data['contact_number'] = contactNumber;
    if (ewayBillNo != null) data['eway_bill_no'] = ewayBillNo;
    if (vehicleNumber != null) data['vehicle_number'] = vehicleNumber;
    if (driverName != null) data['driver_name'] = driverName;
    if (driverMobile != null) data['driver_mobile'] = driverMobile;
    if (driverLicense != null) data['driver_license'] = driverLicense;
    if (transporterId != null) data['transporter_id'] = transporterId;
    if (gstType != null) data['gst_type'] = gstType;
    if (gstRate != null) data['gst_rate'] = gstRate;
    if (subtotal != null) data['subtotal'] = subtotal;
    if (cgstAmount != null) data['cgst_amount'] = cgstAmount;
    if (sgstAmount != null) data['sgst_amount'] = sgstAmount;
    if (igstAmount != null) data['igst_amount'] = igstAmount;
    if (otherChargesTotal != null) data['other_charges_total'] = otherChargesTotal;
    if (roundOff != null) data['round_off'] = roundOff;
    if (totalAmount != null) data['total_amount'] = totalAmount;
    if (paidAmount != null) data['paid_amount'] = paidAmount;
    if (dueAmount != null) data['due_amount'] = dueAmount;
    if (paymentTerms != null) data['payment_terms'] = paymentTerms;
    if (notes != null) data['notes'] = notes;

    final response = await _client
        .from('invoices')
        .update(data)
        .eq('id', invoiceId)
        .select()
        .single();

    return response;
  }

  Future<void> deleteInvoice(String invoiceId) async {
    await _client.from('invoices').delete().eq('id', invoiceId);
  }

  Future<List<Map<String, dynamic>>> getInvoiceItems(String invoiceId) async {
    final response = await _client
        .from('invoice_items')
        .select()
        .eq('invoice_id', invoiceId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> addInvoiceItem({
    required String invoiceId,
    String? stockItemId,
    required String itemName,
    String? hsnCode,
    String? size,
    required double quantity,
    String unit = 'pcs',
    double weightPerUnit = 0,
    double totalWeight = 0,
    required double rate,
    double? rentPerDay,
    DateTime? fromDate,
    DateTime? toDate,
    int? days,
    required double amount,
  }) async {
    final data = {
      'invoice_id': invoiceId,
      'stock_item_id': stockItemId,
      'item_name': itemName,
      'hsn_code': hsnCode,
      'size': size,
      'quantity': quantity,
      'unit': unit,
      'weight_per_unit': weightPerUnit,
      'total_weight': totalWeight,
      'rate': rate,
      'rent_per_day': rentPerDay,
      'from_date': fromDate?.toIso8601String().split('T')[0],
      'to_date': toDate?.toIso8601String().split('T')[0],
      'days': days,
      'amount': amount,
    };

    final response = await _client
        .from('invoice_items')
        .insert(data)
        .select()
        .single();

    return response;
  }

  Future<void> deleteInvoiceItem(String itemId) async {
    await _client.from('invoice_items').delete().eq('id', itemId);
  }

  Future<List<Map<String, dynamic>>> getInvoiceAreas(String invoiceId) async {
    final response = await _client
        .from('invoice_areas')
        .select()
        .eq('invoice_id', invoiceId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> addInvoiceArea({
    required String invoiceId,
    required String areaName,
    String? hsnCode,
    double? length,
    double? width,
    double? height,
    String unit = 'feet',
    required double rate,
    DateTime? fromDate,
    DateTime? toDate,
    int? days,
    required double amount,
  }) async {
    final data = {
      'invoice_id': invoiceId,
      'area_name': areaName,
      'hsn_code': hsnCode,
      'length': length,
      'width': width,
      'height': height,
      'unit': unit,
      'rate': rate,
      'from_date': fromDate?.toIso8601String().split('T')[0],
      'to_date': toDate?.toIso8601String().split('T')[0],
      'days': days,
      'amount': amount,
    };

    final response = await _client
        .from('invoice_areas')
        .insert(data)
        .select()
        .single();

    return response;
  }

  Future<void> deleteInvoiceArea(String areaId) async {
    await _client.from('invoice_areas').delete().eq('id', areaId);
  }

  Future<List<Map<String, dynamic>>> getInvoiceOtherCharges(String invoiceId) async {
    final response = await _client
        .from('invoice_other_charges')
        .select()
        .eq('invoice_id', invoiceId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> addInvoiceOtherCharge({
    required String invoiceId,
    String? hsnCode,
    required String description,
    double quantity = 1,
    String unit = 'nos',
    required double rate,
    required double amount,
  }) async {
    final data = {
      'invoice_id': invoiceId,
      'hsn_code': hsnCode,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'rate': rate,
      'amount': amount,
    };

    final response = await _client
        .from('invoice_other_charges')
        .insert(data)
        .select()
        .single();

    return response;
  }

  Future<void> deleteInvoiceOtherCharge(String chargeId) async {
    await _client.from('invoice_other_charges').delete().eq('id', chargeId);
  }

  Future<String> generateInvoiceNumber({
    required String companyId,
    required String invoiceType,
  }) async {
    final prefix = invoiceType.substring(0, 3).toUpperCase();
    final year = DateTime.now().year.toString().substring(2);

    final result = await _client
        .from('invoices')
        .select('invoice_number')
        .eq('company_id', companyId)
        .like('invoice_number', '$prefix-$year-%')
        .order('invoice_number', ascending: false)
        .limit(1);

    if (result.isEmpty) {
      return '$prefix-$year-0001';
    }

    final lastNumber = result[0]['invoice_number'].toString().split('-').last;
    final nextNumber = (int.parse(lastNumber) + 1).toString().padLeft(4, '0');
    return '$prefix-$year-$nextNumber';
  }
}
