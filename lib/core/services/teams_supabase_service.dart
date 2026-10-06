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
      // 1. Check team_members by user_id
      final teamRes = await _client
          .from('team_members')
          .select('business_id')
          .eq('user_id', user.id)
          .eq('status', 'active')
          .maybeSingle();

      if (teamRes != null && teamRes['business_id'] != null) {
        return teamRes['business_id'] as String;
      }

      // 1b. If not linked by user_id yet, check by email and auto-link to this staff user
      if (user.email != null && user.email!.isNotEmpty) {
        final inviteRes = await _client
            .from('team_members')
            .select('id, business_id')
            .ilike('email', user.email!.trim())
            .maybeSingle();

        if (inviteRes != null && inviteRes['business_id'] != null) {
          try {
            await _client.from('team_members').update({
              'user_id': user.id,
              'status': 'active',
            }).eq('id', inviteRes['id']);
          } catch (e) {
            debugPrint('Error linking team member user_id: $e');
          }
          return inviteRes['business_id'] as String;
        }
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

      // 3. If not linked, return null so UI prompts staff to enter Staff Code or request invite
      return null;
    } catch (e) {
      debugPrint('Error getting business ID: $e');
      return null;
    }
  }

  /// Global ValueNotifier for today's attendance so Home and Attendance screens are 100% in sync.
  final ValueNotifier<Map<String, dynamic>?> attendanceNotifier = ValueNotifier<Map<String, dynamic>?>(null);

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
          .eq('date', todayStr)
          .maybeSingle();

      attendanceNotifier.value = res;
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
          'date': todayStr,
          'check_in_time': now.toIso8601String(),
          'status': 'present',
          if (notes != null) 'notes': notes,
        }, onConflict: 'business_id,user_id,date')
        .select()
        .single();

    attendanceNotifier.value = res;
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
        .eq('date', todayStr)
        .select()
        .single();

    attendanceNotifier.value = res;
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
          .order('date', ascending: false)
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

  // ===========================================================================
  // STAFF PROFILE MANAGEMENT
  // ===========================================================================

  /// Fetches the current logged in staff's team member and business profile.
  Future<Map<String, dynamic>?> fetchStaffProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      // 1. Try to find by user_id
      var member = await _client
          .from('team_members')
          .select('*, businesses(business_name, business_industry, address_line, business_city, state)')
          .eq('user_id', user.id)
          .maybeSingle();

      // 2. If not linked by user_id yet, try matching by email and auto-link
      if (member == null && user.email != null && user.email!.isNotEmpty) {
        final emailMatch = await _client
            .from('team_members')
            .select('*, businesses(business_name, business_industry, address_line, business_city, state)')
            .ilike('email', user.email!.trim())
            .maybeSingle();

        if (emailMatch != null) {
          try {
            await _client.from('team_members').update({
              'user_id': user.id,
              'status': 'active',
            }).eq('id', emailMatch['id']);
          } catch (e) {
            debugPrint('Auto-link error: $e');
          }
          member = emailMatch;
        }
      }

      return member != null ? Map<String, dynamic>.from(member) : null;
    } catch (e) {
      debugPrint('Error fetching staff profile: $e');
      return null;
    }
  }

  /// Updates the current staff member's info (name, phone, designation, etc.)
  Future<void> updateStaffProfile(Map<String, dynamic> updates) async {
    final user = currentUser;
    if (user == null) throw Exception('User not logged in');

    // First try update by user_id
    final res = await _client
        .from('team_members')
        .update(updates)
        .eq('user_id', user.id)
        .select();

    if ((res as List).isEmpty && user.email != null) {
      // Fallback by email if user_id was not linked yet
      final fallbackRes = await _client
          .from('team_members')
          .update({
            ...updates,
            'user_id': user.id,
            'status': 'active',
          })
          .ilike('email', user.email!.trim())
          .select();

      if ((fallbackRes as List).isEmpty) {
        throw Exception(
          'No team record found for ${user.email}. Please link using your Staff Code first.',
        );
      }
    }
  }

  /// Reliably and safely links the current logged-in staff member using a Staff Code (e.g. STF-001).
  Future<Map<String, dynamic>> linkStaffWithCode(String rawCode) async {
    final user = currentUser;
    if (user == null) {
      return {'success': false, 'message': 'You must be logged in to link your account.'};
    }

    var code = rawCode.trim().toUpperCase();
    if (code.startsWith('NGAM_STAFF:')) {
      code = code.replaceFirst('NGAM_STAFF:', '').trim();
    }
    if (code.isEmpty) {
      return {'success': false, 'message': 'Please enter a valid Staff Code.'};
    }

    try {
      // 1. Try PostgreSQL RPC first if configured
      try {
        final rpcRes = await _client.rpc('fn_link_staff_by_code', params: {
          'p_staff_code': code,
          'p_user_id': user.id,
          'p_user_email': user.email ?? '',
        });
        if (rpcRes != null && rpcRes is Map) {
          final resMap = Map<String, dynamic>.from(rpcRes);
          if (resMap['success'] == true) {
            return resMap;
          }
        }
      } catch (_) {
        // Fallback to direct table query if RPC is not deployed yet
      }

      // 2. Direct table lookup and update
      final member = await _client
          .from('team_members')
          .select('id, name, designation, businesses(id, business_name)')
          .ilike('staff_code', code)
          .maybeSingle();

      if (member == null) {
        return {
          'success': false,
          'message': 'Staff code "$code" was not found. Please verify with your store owner.',
        };
      }

      final bizName = (member['businesses'] as Map?)?['business_name'] ?? 'your business';

      await _client.from('team_members').update({
        'user_id': user.id,
        'status': 'active',
        if (user.email != null && user.email!.isNotEmpty) 'email': user.email!.trim(),
      }).eq('id', member['id']);

      return {
        'success': true,
        'message': 'Successfully linked to $bizName!',
        'business_name': bizName,
      };
    } catch (e) {
      debugPrint('Error linking staff code: $e');
      return {
        'success': false,
        'message': 'Failed to link: $e',
      };
    }
  }

  /// ==========================================
  /// SMART WALK-IN QUEUE
  /// ==========================================

  /// Fetch active and recent queue tickets for today
  Future<List<Map<String, dynamic>>> fetchQueueTickets() async {
    try {
      final businessId = await getCurrentBusinessId();
      if (businessId == null) return [];

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();

      final res = await _client
          .from('queue_tickets')
          .select()
          .eq('business_id', businessId)
          .gte('created_at', startOfDay)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('Error fetching queue tickets: $e');
      return [];
    }
  }

  /// Call a queue ticket to station
  Future<bool> callQueueTicket({
    required String ticketId,
    required String staffName,
    required String station,
  }) async {
    try {
      await _client.from('queue_tickets').update({
        'status': 'calling',
        'assigned_staff_name': staffName,
        'station_or_chair': station,
        'called_at': DateTime.now().toIso8601String(),
      }).eq('id', ticketId);
      return true;
    } catch (e) {
      debugPrint('Error calling queue ticket: $e');
      return false;
    }
  }

  /// Start serving a queue ticket
  Future<bool> startServingQueueTicket({
    required String ticketId,
    required String staffName,
    required String station,
  }) async {
    try {
      await _client.from('queue_tickets').update({
        'status': 'serving',
        'assigned_staff_name': staffName,
        'station_or_chair': station,
        'serving_at': DateTime.now().toIso8601String(),
      }).eq('id', ticketId);
      return true;
    } catch (e) {
      debugPrint('Error starting serving queue ticket: $e');
      return false;
    }
  }

  /// Complete a queue ticket
  Future<bool> completeQueueTicket({required String ticketId}) async {
    try {
      await _client.from('queue_tickets').update({
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', ticketId);
      return true;
    } catch (e) {
      debugPrint('Error completing queue ticket: $e');
      return false;
    }
  }

  /// Cancel a queue ticket
  Future<bool> cancelQueueTicket({required String ticketId}) async {
    try {
      await _client.from('queue_tickets').update({
        'status': 'cancelled',
      }).eq('id', ticketId);
      return true;
    } catch (e) {
      debugPrint('Error cancelling queue ticket: $e');
      return false;
    }
  }
}

