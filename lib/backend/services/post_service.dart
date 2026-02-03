import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_service.dart';

class PostService {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<Map<String, dynamic>>> getPosts({
    required String companyId,
    String? postType,
    bool? isPinned,
  }) async {
    var query = _client
        .from('posts')
        .select('*, user_profiles!created_by(full_name)')
        .eq('company_id', companyId);

    if (postType != null) {
      query = query.eq('post_type', postType);
    }

    if (isPinned != null) {
      query = query.eq('is_pinned', isPinned);
    }

    final response = await query
        .order('is_pinned', ascending: false)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createPost({
    required String companyId,
    String? title,
    required String content,
    String? imageUrl,
    String postType = 'announcement',
    bool isPinned = false,
  }) async {
    final data = {
      'company_id': companyId,
      'created_by': SupabaseService.currentUserId,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'post_type': postType,
      'is_pinned': isPinned,
    };

    final response = await _client
        .from('posts')
        .insert(data)
        .select()
        .single();

    return response;
  }

  Future<Map<String, dynamic>> updatePost({
    required String postId,
    String? title,
    String? content,
    String? imageUrl,
    String? postType,
    bool? isPinned,
  }) async {
    final data = <String, dynamic>{'updated_at': DateTime.now().toIso8601String()};

    if (title != null) data['title'] = title;
    if (content != null) data['content'] = content;
    if (imageUrl != null) data['image_url'] = imageUrl;
    if (postType != null) data['post_type'] = postType;
    if (isPinned != null) data['is_pinned'] = isPinned;

    final response = await _client
        .from('posts')
        .update(data)
        .eq('id', postId)
        .select()
        .single();

    return response;
  }

  Future<void> deletePost(String postId) async {
    await _client.from('posts').delete().eq('id', postId);
  }

  Future<Map<String, dynamic>> createReminder({
    required String companyId,
    required String reminderType,
    required String partyId,
    String? invoiceId,
    required DateTime reminderDate,
    required String message,
  }) async {
    final data = {
      'company_id': companyId,
      'reminder_type': reminderType,
      'party_id': partyId,
      'invoice_id': invoiceId,
      'reminder_date': reminderDate.toIso8601String().split('T')[0],
      'message': message,
      'is_sent': false,
    };

    final response = await _client
        .from('reminders')
        .insert(data)
        .select()
        .single();

    return response;
  }

  Future<List<Map<String, dynamic>>> getReminders({
    required String companyId,
    String? reminderType,
    bool? isSent,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    var query = _client
        .from('reminders')
        .select('*, parties(name, company_name)')
        .eq('company_id', companyId);

    if (reminderType != null) {
      query = query.eq('reminder_type', reminderType);
    }

    if (isSent != null) {
      query = query.eq('is_sent', isSent);
    }

    if (fromDate != null) {
      query = query.gte('reminder_date', fromDate.toIso8601String().split('T')[0]);
    }

    if (toDate != null) {
      query = query.lte('reminder_date', toDate.toIso8601String().split('T')[0]);
    }

    final response = await query.order('reminder_date');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> markReminderAsSent(String reminderId) async {
    await _client.from('reminders').update({
      'is_sent': true,
      'sent_at': DateTime.now().toIso8601String(),
    }).eq('id', reminderId);
  }

  Future<void> deleteReminder(String reminderId) async {
    await _client.from('reminders').delete().eq('id', reminderId);
  }
}
