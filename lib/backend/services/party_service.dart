import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_service.dart';

class PartyService {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<Map<String, dynamic>>> getParties({
    required String companyId,
    String? partyType,
    bool? isActive,
  }) async {
    var query = _client.from('parties').select().eq('company_id', companyId);

    if (partyType != null) {
      query = query.eq('party_type', partyType);
    }

    if (isActive != null) {
      query = query.eq('is_active', isActive);
    }

    final response = await query.order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getParty(String partyId) async {
    final response = await _client
        .from('parties')
        .select()
        .eq('id', partyId)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>> createParty({
    required String companyId,
    required String partyType,
    required String name,
    String? companyName,
    String? gstNumber,
    String? mobile,
    String? email,
    String? billingAddress,
    String? shippingAddress,
    String? state,
    String? pincode,
    String? notes,
  }) async {
    final data = {
      'company_id': companyId,
      'party_type': partyType,
      'name': name,
      'company_name': companyName,
      'gst_number': gstNumber,
      'mobile': mobile,
      'email': email,
      'billing_address': billingAddress,
      'shipping_address': shippingAddress,
      'state': state,
      'pincode': pincode,
      'notes': notes,
      'is_active': true,
    };

    final response = await _client
        .from('parties')
        .insert(data)
        .select()
        .single();

    return response;
  }

  Future<Map<String, dynamic>> updateParty({
    required String partyId,
    String? partyType,
    String? name,
    String? companyName,
    String? gstNumber,
    String? mobile,
    String? email,
    String? billingAddress,
    String? shippingAddress,
    String? state,
    String? pincode,
    String? notes,
    bool? isActive,
  }) async {
    final data = <String, dynamic>{'updated_at': DateTime.now().toIso8601String()};

    if (partyType != null) data['party_type'] = partyType;
    if (name != null) data['name'] = name;
    if (companyName != null) data['company_name'] = companyName;
    if (gstNumber != null) data['gst_number'] = gstNumber;
    if (mobile != null) data['mobile'] = mobile;
    if (email != null) data['email'] = email;
    if (billingAddress != null) data['billing_address'] = billingAddress;
    if (shippingAddress != null) data['shipping_address'] = shippingAddress;
    if (state != null) data['state'] = state;
    if (pincode != null) data['pincode'] = pincode;
    if (notes != null) data['notes'] = notes;
    if (isActive != null) data['is_active'] = isActive;

    final response = await _client
        .from('parties')
        .update(data)
        .eq('id', partyId)
        .select()
        .single();

    return response;
  }

  Future<void> deleteParty(String partyId) async {
    await _client.from('parties').delete().eq('id', partyId);
  }

  Future<List<Map<String, dynamic>>> searchParties({
    required String companyId,
    required String searchTerm,
    String? partyType,
  }) async {
    var query = _client
        .from('parties')
        .select()
        .eq('company_id', companyId)
        .or('name.ilike.%$searchTerm%,mobile.ilike.%$searchTerm%,company_name.ilike.%$searchTerm%');

    if (partyType != null) {
      query = query.eq('party_type', partyType);
    }

    final response = await query.limit(20);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getPartyContacts(String partyId) async {
    final response = await _client
        .from('party_contacts')
        .select()
        .eq('party_id', partyId)
        .order('is_primary', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> addPartyContact({
    required String partyId,
    required String contactPerson,
    String? designation,
    String? phone,
    String? email,
    bool isPrimary = false,
  }) async {
    final data = {
      'party_id': partyId,
      'contact_person': contactPerson,
      'designation': designation,
      'phone': phone,
      'email': email,
      'is_primary': isPrimary,
    };

    final response = await _client
        .from('party_contacts')
        .insert(data)
        .select()
        .single();

    return response;
  }
}
