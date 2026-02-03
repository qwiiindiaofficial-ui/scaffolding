import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_service.dart';

class TransporterService {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<Map<String, dynamic>>> getTransporters({
    required String companyId,
    bool? isActive,
  }) async {
    var query = _client
        .from('transporters')
        .select()
        .eq('company_id', companyId);

    if (isActive != null) {
      query = query.eq('is_active', isActive);
    }

    final response = await query.order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getTransporter(String transporterId) async {
    final response = await _client
        .from('transporters')
        .select()
        .eq('id', transporterId)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>> createTransporter({
    required String companyId,
    required String name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? gstNumber,
  }) async {
    final data = {
      'company_id': companyId,
      'name': name,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'gst_number': gstNumber,
      'is_active': true,
    };

    final response = await _client
        .from('transporters')
        .insert(data)
        .select()
        .single();

    return response;
  }

  Future<Map<String, dynamic>> updateTransporter({
    required String transporterId,
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? gstNumber,
    bool? isActive,
  }) async {
    final data = <String, dynamic>{'updated_at': DateTime.now().toIso8601String()};

    if (name != null) data['name'] = name;
    if (contactPerson != null) data['contact_person'] = contactPerson;
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;
    if (address != null) data['address'] = address;
    if (gstNumber != null) data['gst_number'] = gstNumber;
    if (isActive != null) data['is_active'] = isActive;

    final response = await _client
        .from('transporters')
        .update(data)
        .eq('id', transporterId)
        .select()
        .single();

    return response;
  }

  Future<void> deleteTransporter(String transporterId) async {
    await _client.from('transporters').delete().eq('id', transporterId);
  }

  Future<List<Map<String, dynamic>>> getVehicles(String transporterId) async {
    final response = await _client
        .from('vehicles')
        .select()
        .eq('transporter_id', transporterId)
        .order('vehicle_number');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> addVehicle({
    required String transporterId,
    required String vehicleNumber,
    String? vehicleType,
    String? capacity,
  }) async {
    final data = {
      'transporter_id': transporterId,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'capacity': capacity,
      'is_active': true,
    };

    final response = await _client
        .from('vehicles')
        .insert(data)
        .select()
        .single();

    return response;
  }

  Future<Map<String, dynamic>> updateVehicle({
    required String vehicleId,
    String? vehicleNumber,
    String? vehicleType,
    String? capacity,
    bool? isActive,
  }) async {
    final data = <String, dynamic>{};

    if (vehicleNumber != null) data['vehicle_number'] = vehicleNumber;
    if (vehicleType != null) data['vehicle_type'] = vehicleType;
    if (capacity != null) data['capacity'] = capacity;
    if (isActive != null) data['is_active'] = isActive;

    final response = await _client
        .from('vehicles')
        .update(data)
        .eq('id', vehicleId)
        .select()
        .single();

    return response;
  }

  Future<void> deleteVehicle(String vehicleId) async {
    await _client.from('vehicles').delete().eq('id', vehicleId);
  }

  Future<List<Map<String, dynamic>>> getDrivers(String transporterId) async {
    final response = await _client
        .from('drivers')
        .select()
        .eq('transporter_id', transporterId)
        .order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> addDriver({
    required String transporterId,
    required String name,
    String? phone,
    String? licenseNumber,
    DateTime? licenseExpiryDate,
  }) async {
    final data = {
      'transporter_id': transporterId,
      'name': name,
      'phone': phone,
      'license_number': licenseNumber,
      'license_expiry_date': licenseExpiryDate?.toIso8601String().split('T')[0],
      'is_active': true,
    };

    final response = await _client
        .from('drivers')
        .insert(data)
        .select()
        .single();

    return response;
  }

  Future<Map<String, dynamic>> updateDriver({
    required String driverId,
    String? name,
    String? phone,
    String? licenseNumber,
    DateTime? licenseExpiryDate,
    bool? isActive,
  }) async {
    final data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (licenseNumber != null) data['license_number'] = licenseNumber;
    if (licenseExpiryDate != null) data['license_expiry_date'] = licenseExpiryDate.toIso8601String().split('T')[0];
    if (isActive != null) data['is_active'] = isActive;

    final response = await _client
        .from('drivers')
        .update(data)
        .eq('id', driverId)
        .select()
        .single();

    return response;
  }

  Future<void> deleteDriver(String driverId) async {
    await _client.from('drivers').delete().eq('id', driverId);
  }

  Future<Map<String, dynamic>?> getTransporterWithDetails(String transporterId) async {
    final transporter = await getTransporter(transporterId);
    if (transporter == null) return null;

    final vehicles = await getVehicles(transporterId);
    final drivers = await getDrivers(transporterId);

    return {
      ...transporter,
      'vehicles': vehicles,
      'drivers': drivers,
    };
  }
}
