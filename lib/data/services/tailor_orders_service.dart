import 'package:supabase_flutter/supabase_flutter.dart';

class TailorOrdersService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch tailor orders from edge function
  static Future<List<dynamic>> getMyOrders({
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      // Get current user session
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('No active session');
      }

      final token = session.accessToken;

      // Build query string for statuses, matching the edge function expectations.
      final functionPath = status != null && status.isNotEmpty
          ? 'get-tailor-orders?statuses=${Uri.encodeQueryComponent(status)}'
          : 'get-tailor-orders';

      // Call edge function with headers
      final response = await _supabase.functions.invoke(
        functionPath,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      // Extract data from response
      final data = response.data;
      if (data is List) {
        return List<dynamic>.from(data);
      }
      if (data is Map) {
        if (data['data'] != null) {
          return List<dynamic>.from(data['data'] as List);
        }
        if (data['orders'] != null) {
          return List<dynamic>.from(data['orders'] as List);
        }
        if (data['assignments'] != null) {
          return List<dynamic>.from(data['assignments'] as List);
        }
      }

      print('⚠️ Unexpected edge function response: ${response.data}');
      return [];
    } catch (e) {
      print('❌ Error fetching tailor orders: $e');
      rethrow;
    }
  }

  /// Fetch all pending orders
  static Future<List<dynamic>> getPendingOrders({
    int limit = 50,
    int offset = 0,
  }) async {
    return getMyOrders(status: 'pending', limit: limit, offset: offset);
  }

  /// Fetch all accepted orders
  static Future<List<dynamic>> getAcceptedOrders({
    int limit = 50,
    int offset = 0,
  }) async {
    return getMyOrders(status: 'accepted', limit: limit, offset: offset);
  }

  /// Fetch all in-progress orders
  static Future<List<dynamic>> getInProgressOrders({
    int limit = 50,
    int offset = 0,
  }) async {
    return getMyOrders(
        status: 'in_progress', limit: limit, offset: offset);
  }

  /// Fetch all completed orders
  static Future<List<dynamic>> getCompletedOrders({
    int limit = 50,
    int offset = 0,
  }) async {
    return getMyOrders(status: 'completed', limit: limit, offset: offset);
  }

  /// Fetch a specific order by its ID from the tailor orders list.
  static Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final orders = await getMyOrders(limit: 1000, offset: 0);
      for (final rawOrder in orders) {
        if (rawOrder is Map<String, dynamic>) {
          final extractedOrderId = _readString(rawOrder, ['order_id', 'id']);
          final extractedAssignmentId = _readString(rawOrder, ['assignment_id', 'id']);

          if (extractedOrderId == orderId || extractedAssignmentId == orderId) {
            return rawOrder;
          }
        }
      }

      throw Exception('Order not found for id $orderId');
    } catch (e) {
      print('❌ Error fetching tailor order by id: $e');
      rethrow;
    }
  }

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      var value = json[key];
      if (value == null) {
        continue;
      }
      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isNotEmpty) {
          return trimmed;
        }
      }
      if (value is Map) {
        if (value.containsKey('fr') && value['fr'] is String) {
          final trimmed = (value['fr'] as String).trim();
          if (trimmed.isNotEmpty) {
            return trimmed;
          }
        }
        if (value.containsKey('en') && value['en'] is String) {
          final trimmed = (value['en'] as String).trim();
          if (trimmed.isNotEmpty) {
            return trimmed;
          }
        }
      }
    }
    return fallback;
  }
}
