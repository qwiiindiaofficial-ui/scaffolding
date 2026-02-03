import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_service.dart';

class StaffService {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<Map<String, dynamic>>> getStaff({
    required String companyId,
    bool? isActive,
  }) async {
    var query = _client.from('staff').select().eq('company_id', companyId);

    if (isActive != null) {
      query = query.eq('is_active', isActive);
    }

    final response = await query.order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getStaffMember(String staffId) async {
    final response = await _client
        .from('staff')
        .select()
        .eq('id', staffId)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>> createStaff({
    required String companyId,
    required String name,
    String? mobile,
    String? email,
    String? address,
    String? gender,
    DateTime? dateOfBirth,
    String? designation,
    String? photoUrl,
    String? aadharNumber,
    String? aadharDocumentUrl,
    double expenseAllowance = 0,
    double areaRate = 0,
    String areaUnit = 'sqft',
    double timeRate = 0,
    String timeUnit = 'hour',
    DateTime? joiningDate,
  }) async {
    final data = {
      'company_id': companyId,
      'name': name,
      'mobile': mobile,
      'email': email,
      'address': address,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'designation': designation,
      'photo_url': photoUrl,
      'aadhar_number': aadharNumber,
      'aadhar_document_url': aadharDocumentUrl,
      'expense_allowance': expenseAllowance,
      'area_rate': areaRate,
      'area_unit': areaUnit,
      'time_rate': timeRate,
      'time_unit': timeUnit,
      'joining_date': joiningDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'is_active': true,
    };

    final response = await _client
        .from('staff')
        .insert(data)
        .select()
        .single();

    return response;
  }

  Future<Map<String, dynamic>> updateStaff({
    required String staffId,
    String? name,
    String? mobile,
    String? email,
    String? address,
    String? gender,
    DateTime? dateOfBirth,
    String? designation,
    String? photoUrl,
    String? aadharNumber,
    String? aadharDocumentUrl,
    double? expenseAllowance,
    double? areaRate,
    String? areaUnit,
    double? timeRate,
    String? timeUnit,
    bool? isActive,
  }) async {
    final data = <String, dynamic>{'updated_at': DateTime.now().toIso8601String()};

    if (name != null) data['name'] = name;
    if (mobile != null) data['mobile'] = mobile;
    if (email != null) data['email'] = email;
    if (address != null) data['address'] = address;
    if (gender != null) data['gender'] = gender;
    if (dateOfBirth != null) data['date_of_birth'] = dateOfBirth.toIso8601String();
    if (designation != null) data['designation'] = designation;
    if (photoUrl != null) data['photo_url'] = photoUrl;
    if (aadharNumber != null) data['aadhar_number'] = aadharNumber;
    if (aadharDocumentUrl != null) data['aadhar_document_url'] = aadharDocumentUrl;
    if (expenseAllowance != null) data['expense_allowance'] = expenseAllowance;
    if (areaRate != null) data['area_rate'] = areaRate;
    if (areaUnit != null) data['area_unit'] = areaUnit;
    if (timeRate != null) data['time_rate'] = timeRate;
    if (timeUnit != null) data['time_unit'] = timeUnit;
    if (isActive != null) data['is_active'] = isActive;

    final response = await _client
        .from('staff')
        .update(data)
        .eq('id', staffId)
        .select()
        .single();

    return response;
  }

  Future<void> deleteStaff(String staffId) async {
    await _client.from('staff').delete().eq('id', staffId);
  }

  Future<Map<String, dynamic>> markAttendance({
    required String companyId,
    required String staffId,
    required DateTime attendanceDate,
    required String status,
    String? checkInTime,
    String? checkOutTime,
    String? selfieUrl,
    double? locationLat,
    double? locationLng,
    String? notes,
  }) async {
    final data = {
      'company_id': companyId,
      'staff_id': staffId,
      'attendance_date': attendanceDate.toIso8601String().split('T')[0],
      'status': status,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'selfie_url': selfieUrl,
      'location_lat': locationLat,
      'location_lng': locationLng,
      'notes': notes,
      'marked_by': SupabaseService.currentUserId,
    };

    final response = await _client
        .from('attendance_records')
        .upsert(data)
        .select()
        .single();

    return response;
  }

  Future<List<Map<String, dynamic>>> getAttendanceRecords({
    required String staffId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    var query = _client
        .from('attendance_records')
        .select()
        .eq('staff_id', staffId);

    if (fromDate != null) {
      query = query.gte('attendance_date', fromDate.toIso8601String().split('T')[0]);
    }

    if (toDate != null) {
      query = query.lte('attendance_date', toDate.toIso8601String().split('T')[0]);
    }

    final response = await query.order('attendance_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createLeaveRequest({
    required String companyId,
    required String staffId,
    required String leaveType,
    required DateTime fromDate,
    required DateTime toDate,
    required int days,
    String? reason,
  }) async {
    final data = {
      'company_id': companyId,
      'staff_id': staffId,
      'leave_type': leaveType,
      'from_date': fromDate.toIso8601String().split('T')[0],
      'to_date': toDate.toIso8601String().split('T')[0],
      'days': days,
      'reason': reason,
      'status': 'pending',
    };

    final response = await _client
        .from('leave_requests')
        .insert(data)
        .select()
        .single();

    return response;
  }

  Future<Map<String, dynamic>> approveLeave({
    required String leaveRequestId,
    String? approvalNotes,
  }) async {
    final data = {
      'status': 'approved',
      'approved_by': SupabaseService.currentUserId,
      'approval_notes': approvalNotes,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _client
        .from('leave_requests')
        .update(data)
        .eq('id', leaveRequestId)
        .select()
        .single();

    return response;
  }

  Future<Map<String, dynamic>> rejectLeave({
    required String leaveRequestId,
    String? approvalNotes,
  }) async {
    final data = {
      'status': 'rejected',
      'approved_by': SupabaseService.currentUserId,
      'approval_notes': approvalNotes,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _client
        .from('leave_requests')
        .update(data)
        .eq('id', leaveRequestId)
        .select()
        .single();

    return response;
  }

  Future<List<Map<String, dynamic>>> getLeaveRequests({
    required String companyId,
    String? staffId,
    String? status,
  }) async {
    var query = _client
        .from('leave_requests')
        .select('*, staff(name)')
        .eq('company_id', companyId);

    if (staffId != null) {
      query = query.eq('staff_id', staffId);
    }

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createSalaryRecord({
    required String companyId,
    required String staffId,
    required int month,
    required int year,
    double daysPresent = 0,
    int daysAbsent = 0,
    int daysHalf = 0,
    double basicSalary = 0,
    double allowances = 0,
    double deductions = 0,
    double grossSalary = 0,
    double netSalary = 0,
    DateTime? paymentDate,
    String? paymentMode,
    String? notes,
  }) async {
    final data = {
      'company_id': companyId,
      'staff_id': staffId,
      'month': month,
      'year': year,
      'days_present': daysPresent,
      'days_absent': daysAbsent,
      'days_half': daysHalf,
      'basic_salary': basicSalary,
      'allowances': allowances,
      'deductions': deductions,
      'gross_salary': grossSalary,
      'net_salary': netSalary,
      'payment_date': paymentDate?.toIso8601String().split('T')[0],
      'payment_mode': paymentMode,
      'notes': notes,
    };

    final response = await _client
        .from('salary_records')
        .upsert(data)
        .select()
        .single();

    return response;
  }

  Future<List<Map<String, dynamic>>> getSalaryRecords({
    required String staffId,
    int? year,
  }) async {
    var query = _client
        .from('salary_records')
        .select()
        .eq('staff_id', staffId);

    if (year != null) {
      query = query.eq('year', year);
    }

    final response = await query.order('year', ascending: false).order('month', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
}
