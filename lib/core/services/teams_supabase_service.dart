import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeamsSupabaseService {
  static final TeamsSupabaseService instance = TeamsSupabaseService._();
  TeamsSupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  /// Resolves the business_id for the current user.
  /// Checks team_members first, then businesses (if owner/admin).
  Future<String?> getCurrentBusinessId() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      // 1. Check team_members
      final teamRes = await _client
          .from('team_members')
          .select('business_id')
          .eq('user_id', user.id)
          .eq('status', 'active')
          .maybeSingle();

      if (teamRes != null && teamRes['business_id'] != null) {
        return teamRes['business_id'] as String;
      }

      // 2. Check if user is owner of a business
      final bizRes = await _client
          .from('businesses')
          .select('id')
          .eq('owner_user_id', user.id)
          .maybeSingle();

      if (bizRes != null && bizRes['id'] != null) {
        return bizRes['id'] as String;
      }

      // 3. Fallback to any first active business (for demo/testing)
      final anyBiz = await _client
          .from('businesses')
          .select('id')
          .limit(1)
          .maybeSingle();

      return anyBiz?['id'] as String?;
    } catch (e) {
      debugPrint('Error getting business ID: $e');
      return null;
    }
  }

  // ===========================================================================
  // ATTENDANCE
  // ===========================================================================

  /// Fetches today's attendance record for the logged-in user.
  Future<Map<String, dynamic>?> fetchTodayAttendance() async {
    final user = currentUser;
    if (user == null) return null;

    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final res = await _client
          .from('staff_attendance')
          .select()
          .eq('user_id', user.id)
          .eq('attendance_date', todayStr)
          .maybeSingle();

      return res;
    } catch (e) {
      debugPrint('Error fetching today attendance: $e');
      return null;
    }
  }

  /// Check-in for today.
  Future<Map<String, dynamic>?> checkIn({String? notes}) async {
    final user = currentUser;
    if (user == null) return null;

    final businessId = await getCurrentBusinessId();
    if (businessId == null) throw Exception('No associated business found.');

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    final res = await _client
        .from('staff_attendance')
        .upsert({
          'business_id': businessId,
          'user_id': user.id,
          'attendance_date': todayStr,
          'check_in_time': now.toIso8601String(),
          'status': 'present',
          if (notes != null) 'notes': notes,
        }, onConflict: 'user_id,attendance_date')
        .select()
        .single();

    return res;
  }

  /// Check-out for today.
  Future<Map<String, dynamic>?> checkOut() async {
    final user = currentUser;
    if (user == null) return null;

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    final res = await _client
        .from('staff_attendance')
        .update({
          'check_out_time': now.toIso8601String(),
        })
        .eq('user_id', user.id)
        .eq('attendance_date', todayStr)
        .select()
        .single();

    return res;
  }

  /// Fetches recent attendance history for the logged-in user.
  Future<List<Map<String, dynamic>>> fetchRecentAttendance({int limit = 14}) async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final res = await _client
          .from('staff_attendance')
          .select()
          .eq('user_id', user.id)
          .order('attendance_date', ascending: false)
          .limit(limit);

      return (res as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error fetching attendance history: $e');
      return [];
    }
  }

  // ===========================================================================
  // LEAVES
  // ===========================================================================

  /// Fetches leaves for the logged-in user.
  Future<List<Map<String, dynamic>>> fetchLeaves() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final res = await _client
          .from('staff_leaves')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (res as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error fetching leaves: $e');
      return [];
    }
  }

  /// Submits a leave request.
  Future<Map<String, dynamic>?> submitLeaveRequest({
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    final user = currentUser;
    if (user == null) return null;

    final businessId = await getCurrentBusinessId();
    if (businessId == null) throw Exception('No associated business found.');

    final res = await _client
        .from('staff_leaves')
        .insert({
          'business_id': businessId,
          'user_id': user.id,
          'leave_type': leaveType,
          'start_date': DateFormat('yyyy-MM-dd').format(startDate),
          'end_date': DateFormat('yyyy-MM-dd').format(endDate),
          'reason': reason,
          'status': 'pending',
        })
        .select()
        .single();

    return res;
  }

  // ===========================================================================
  // ANNOUNCEMENTS
  // ===========================================================================

  /// Fetches announcements for the current business.
  Future<List<Map<String, dynamic>>> fetchAnnouncements() async {
    final businessId = await getCurrentBusinessId();
    if (businessId == null) return [];

    try {
      final res = await _client
          .from('business_announcements')
          .select()
          .eq('business_id', businessId)
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false);

      return (res as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
      return [];
    }
  }

  // ===========================================================================
  // TEMPAHAN (BOOKINGS ASSIGNED TO STAFF)
  // ===========================================================================

  /// Fetches tempahan assigned to this staff or business.
  Future<List<Map<String, dynamic>>> fetchMyTempahan() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      // Find staff id from team_members
      final member = await _client
          .from('team_members')
          .select('id, business_id')
          .eq('user_id', user.id)
          .maybeSingle();

      var query = _client.from('bookings').select();

      if (member != null) {
        query = query.or('staff_id.eq.${member['id']},business_id.eq.${member['business_id']}');
      } else {
        final bizId = await getCurrentBusinessId();
        if (bizId != null) {
          query = query.eq('business_id', bizId);
        }
      }

      final res = await query.order('booking_date').order('booking_time');
      return (res as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error fetching tempahan: $e');
      return [];
    }
  }

  // ===========================================================================
  // NOTIFICATIONS
  // ===========================================================================

  /// Fetches notifications for the logged-in user.
  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final res = await _client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(30);

      return (res as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  /// Mark notification as read.
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }
}
