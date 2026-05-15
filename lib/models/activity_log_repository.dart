import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityLogRepository {
  static final ActivityLogRepository _instance = ActivityLogRepository._internal();
  final _supabase = Supabase.instance.client;

  factory ActivityLogRepository() => _instance;
  ActivityLogRepository._internal();

  Future<void> log(String action, String details) async {
    final user = _supabase.auth.currentUser;
    await _supabase.from('activity_logs').insert({
      'action': action,
      'details': details,
      'user_id': user?.id,
    });
  }

  Future<List<Map<String, dynamic>>> getRecentLogs() async {
    return await _supabase
        .from('activity_logs')
        .select()
        .order('created_at', ascending: false)
        .limit(20);
  }

  Future<void> clearAllLogs() async {
    await _supabase.from('activity_logs').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  }

  Future<void> clearLogsByAction(String action) async {
    await _supabase.from('activity_logs').delete().eq('action', action);
  }

  Future<void> deleteLatestLog() async {
    final latest = await getRecentLogs();
    if (latest.isNotEmpty) {
      await _supabase.from('activity_logs').delete().eq('id', latest.first['id']);
    }
  }
}