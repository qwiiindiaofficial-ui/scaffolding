import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_service.dart';

class CompanyService {
  final SupabaseClient _client = SupabaseService.client;

  Future<Map<String, dynamic>?> getCompany(String companyId) async {
    final response = await _client
        .from('companies')
        .select()
        .eq('id', companyId)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>> createCompany({
    required String name,
    String? address,
    String? gstNumber,
    String? phone,
    List<String>? phones,
    String? email,
    String? logoUrl,
    String? nameImageUrl,
    String? stampUrl,
    String? termsAndConditions,
    String? isoNumber,
  }) async {
    final data = {
      'name': name,
      'address': address,
      'gst_number': gstNumber,
      'phone': phone,
      'phones': phones,
      'email': email,
      'logo_url': logoUrl,
      'name_image_url': nameImageUrl,
      'stamp_url': stampUrl,
      'terms_and_conditions': termsAndConditions,
      'iso_number': isoNumber,
    };

    final response = await _client
        .from('companies')
        .insert(data)
        .select()
        .single();

    return response;
  }

  Future<Map<String, dynamic>> updateCompany({
    required String companyId,
    String? name,
    String? address,
    String? gstNumber,
    String? phone,
    List<String>? phones,
    String? email,
    String? logoUrl,
    String? nameImageUrl,
    String? stampUrl,
    String? termsAndConditions,
    String? isoNumber,
  }) async {
    final data = <String, dynamic>{'updated_at': DateTime.now().toIso8601String()};

    if (name != null) data['name'] = name;
    if (address != null) data['address'] = address;
    if (gstNumber != null) data['gst_number'] = gstNumber;
    if (phone != null) data['phone'] = phone;
    if (phones != null) data['phones'] = phones;
    if (email != null) data['email'] = email;
    if (logoUrl != null) data['logo_url'] = logoUrl;
    if (nameImageUrl != null) data['name_image_url'] = nameImageUrl;
    if (stampUrl != null) data['stamp_url'] = stampUrl;
    if (termsAndConditions != null) data['terms_and_conditions'] = termsAndConditions;
    if (isoNumber != null) data['iso_number'] = isoNumber;

    final response = await _client
        .from('companies')
        .update(data)
        .eq('id', companyId)
        .select()
        .single();

    return response;
  }

  Future<List<Map<String, dynamic>>> getBankDetails(String companyId) async {
    final response = await _client
        .from('bank_details')
        .select()
        .eq('company_id', companyId)
        .order('is_primary', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> addBankDetails({
    required String companyId,
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    required String accountHolderName,
    String? branch,
    String? upiId,
    String? qrCodeUrl,
    bool isPrimary = false,
  }) async {
    final data = {
      'company_id': companyId,
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'account_holder_name': accountHolderName,
      'branch': branch,
      'upi_id': upiId,
      'qr_code_url': qrCodeUrl,
      'is_primary': isPrimary,
    };

    final response = await _client
        .from('bank_details')
        .insert(data)
        .select()
        .single();

    return response;
  }

  Future<List<Map<String, dynamic>>> getCatalogueMedia(String companyId) async {
    final response = await _client
        .from('catalogue_media')
        .select()
        .eq('company_id', companyId)
        .order('display_order');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> addCatalogueMedia({
    required String companyId,
    required String mediaType,
    required String mediaUrl,
    String? description,
    int displayOrder = 0,
  }) async {
    final data = {
      'company_id': companyId,
      'media_type': mediaType,
      'media_url': mediaUrl,
      'description': description,
      'display_order': displayOrder,
    };

    final response = await _client
        .from('catalogue_media')
        .insert(data)
        .select()
        .single();

    return response;
  }

  Future<void> deleteCatalogueMedia(String mediaId) async {
    await _client.from('catalogue_media').delete().eq('id', mediaId);
  }
}
