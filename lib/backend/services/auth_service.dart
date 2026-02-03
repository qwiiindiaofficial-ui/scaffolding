import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import '../supabase_service.dart';
import 'dart:math';

class AuthService {
  final SupabaseClient _client = SupabaseService.client;

  static void _sendOTPViaSMS(String phone, String otp) async {
    String url =
        "http://hindit.co.in/API/pushsms.aspx?loginID=T1Techcanopus&password=tech1234&mobile=${phone}&text=$otp is your OTP to register. DO NOT share with anyone. The OTP expires in 10 mins. TECHCANOPUS&senderid=TECNPS&route_id=3&Unicode=0&IP=x.x.x.x&Template_id=1707171101520604654";

    try {
      final response = await http.get(Uri.parse(url));
      print(response.body);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "OTP Sent Successfully");
      } else {
        Fluttertoast.showToast(msg: "Failed To Send OTP");
      }
    } catch (error) {
      print('Error sending OTP: $error');
    }
  }

  Future<void> sendOTPToPhone(String phoneNumber) async {
    try {
      String otp = (100000 + Random().nextInt(900000)).toString();

      await _client.from('otp_sessions').insert({
        'phone_number': phoneNumber,
        'otp_code': otp,
        'is_verified': false,
        'attempts': 0,
      });

      _sendOTPViaSMS(phoneNumber, otp);
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    try {
      final response = await _client
          .from('otp_sessions')
          .select()
          .eq('phone_number', phoneNumber)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        throw Exception('No OTP session found');
      }

      final expiresAt = DateTime.parse(response['expires_at']);
      if (DateTime.now().isAfter(expiresAt)) {
        throw Exception('OTP has expired');
      }

      if (response['otp_code'] != otp) {
        int attempts = response['attempts'] ?? 0;
        await _client
            .from('otp_sessions')
            .update({'attempts': attempts + 1})
            .eq('id', response['id']);
        throw Exception('Invalid OTP');
      }

      await _client
          .from('otp_sessions')
          .update({'is_verified': true})
          .eq('id', response['id']);

      return true;
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  Future<AuthResponse> signUpWithPassword(
    String phoneNumber,
    String password,
  ) async {
    final email = '${phoneNumber.replaceAll('+', '')}@app.local';
    return await _client.auth.signUp(
      email: email,
      password: password,
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
