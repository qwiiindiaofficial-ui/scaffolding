import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_service.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.client;

  Future<AuthResponse> signInWithPhone(String phoneNumber) async {
    return await _client.auth.signInWithOtp(
      phone: phoneNumber,
    );
  }

  Future<AuthResponse> verifyOTP(String phoneNumber, String token) async {
    return await _client.auth.verifyOTP(
      phone: phoneNumber,
      token: token,
      type: OtpType.sms,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await _client
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>> createUserProfile({
    required String userId,
    required String companyId,
    required String phoneNumber,
    String? fullName,
    String? role,
    String? profilePhotoUrl,
    String? aadharNumber,
    String? aadharDocumentUrl,
  }) async {
    final data = {
      'id': userId,
      'company_id': companyId,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'role': role ?? 'viewer',
      'profile_photo_url': profilePhotoUrl,
      'aadhar_number': aadharNumber,
      'aadhar_document_url': aadharDocumentUrl,
      'is_active': true,
    };

    final response = await _client
        .from('user_profiles')
        .upsert(data)
        .select()
        .single();

    return response;
  }

  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? fullName,
    String? profilePhotoUrl,
    String? aadharNumber,
    String? aadharDocumentUrl,
  }) async {
    final data = <String, dynamic>{};
    if (fullName != null) data['full_name'] = fullName;
    if (profilePhotoUrl != null) data['profile_photo_url'] = profilePhotoUrl;
    if (aadharNumber != null) data['aadhar_number'] = aadharNumber;
    if (aadharDocumentUrl != null) data['aadhar_document_url'] = aadharDocumentUrl;
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _client
        .from('user_profiles')
        .update(data)
        .eq('id', userId)
        .select()
        .single();

    return response;
  }
}
