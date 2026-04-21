import 'package:supabase_flutter/supabase_flutter.dart';

class AssignmentService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Update assignment status
  static Future<void> updateAssignmentStatus(
    String assignmentId,
    String newStatus, {
    String? notes,
  }) async {
    try {
      // Get current user session
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('No active session');
      }

      final token = session.accessToken;

      // Validate status
      const validStatuses = [
        'accepted',
        'in_progress',
        'completed',
        'rejected',
        'cancelled'
      ];

      if (!validStatuses.contains(newStatus)) {
        throw Exception(
            'Invalid status: $newStatus. Must be one of: ${validStatuses.join(", ")}');
      }

      // Prepare body
      final body = {
        'assignment_id': assignmentId,
        'status': newStatus,
        if (notes != null) 'notes': notes,
      };

      // Call edge function with headers
      await _supabase.functions.invoke(
        'update-assignment-status',
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('✅ Assignment status updated to: $newStatus');
    } catch (e) {
      print('❌ Error updating assignment status: $e');
      rethrow;
    }
  }

  /// Accept order assignment
  static Future<void> acceptOrder(String assignmentId) async {
    await updateAssignmentStatus(assignmentId, 'accepted');
  }

  /// Start working on order
  static Future<void> startOrder(String assignmentId) async {
    await updateAssignmentStatus(assignmentId, 'in_progress');
  }

  /// Complete order
  static Future<void> completeOrder(String assignmentId) async {
    await updateAssignmentStatus(assignmentId, 'completed');
  }

  /// Reject order
  static Future<void> rejectOrder(String assignmentId, {String? reason}) async {
    await updateAssignmentStatus(assignmentId, 'rejected', notes: reason);
  }

  /// Cancel order
  static Future<void> cancelOrder(String assignmentId, {String? reason}) async {
    await updateAssignmentStatus(assignmentId, 'cancelled', notes: reason);
  }
}
