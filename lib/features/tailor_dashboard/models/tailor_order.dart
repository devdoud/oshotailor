enum TailorOrderStatus {
  pending,
  accepted,
  inProgress,
  completed,
  rejected,
  cancelled,
  unknown,
}

class TailorOrder {
  TailorOrder({
    required this.id,
    required this.orderId,
    required this.assignmentId,
    required this.status,
    required this.clientName,
    required this.clientPhone,
    required this.modelName,
    required this.amount,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.notes,
    required this.orderItems,
    required this.raw,
  });

  final String id;
  final String orderId;
  final String assignmentId;
  final TailorOrderStatus status;
  final String clientName;
  final String clientPhone;
  final String modelName;
  final double amount;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final String notes;
  final List<Map<String, dynamic>> orderItems;
  final Map<String, dynamic> raw;

  bool get canAcceptOrReject => status == TailorOrderStatus.pending;
  bool get canStart => status == TailorOrderStatus.accepted;
  bool get canComplete => status == TailorOrderStatus.inProgress;

  String get statusLabel {
    switch (status) {
      case TailorOrderStatus.pending:
        return 'En attente';
      case TailorOrderStatus.accepted:
        return 'Acceptee';
      case TailorOrderStatus.inProgress:
        return 'En cours';
      case TailorOrderStatus.completed:
        return 'Terminee';
      case TailorOrderStatus.rejected:
        return 'Refusee';
      case TailorOrderStatus.cancelled:
        return 'Annulee';
      case TailorOrderStatus.unknown:
        return 'Inconnue';
    }
  }

  factory TailorOrder.fromJson(Map<String, dynamic> json) {
    final orderId = _readString(json, ['order_id', 'id']);
    final assignmentId = _readString(json, ['assignment_id', 'id']);

    final orderDetails = json['order'];
    final Map<String, dynamic> sourceForDetails = 
        (orderDetails is Map) ? Map<String, dynamic>.from(orderDetails) : json;

    // Extraire les infos depuis order_items s'il existe
    final orderItemsData = sourceForDetails['order_items'];
    List<Map<String, dynamic>> parsedItems = [];
    Map<String, dynamic> firstItem = {};
    
    if (orderItemsData is List && orderItemsData.isNotEmpty) {
      parsedItems = orderItemsData.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      if (parsedItems.isNotEmpty) {
        firstItem = parsedItems.first;
      }
    }
    
    // Extraction de la vignette/photo du produit (thumbnail) et du nom du modèle
    String? orderThumbnail;
    String? resolvedModelName;
    
    if (parsedItems.isNotEmpty) {
      final firstItemData = parsedItems.first;
      final productData = firstItemData['product'] ?? firstItemData['products'] ?? {};
      
      // Essayer d'abord la table imbriquée 'product'
      if (productData is Map && productData.isNotEmpty) {
        orderThumbnail = _readString(Map<String, dynamic>.from(productData), ['thumbnail', 'image', 'image_url', 'photo']);
        resolvedModelName = _readString(Map<String, dynamic>.from(productData), ['name', 'title', 'model_name']);
      }
      
      // Fallback sur order_items
      if (orderThumbnail == null || orderThumbnail.isEmpty) {
        orderThumbnail = _readString(firstItemData, ['thumbnail', 'image', 'photo_url']);
      }
      if (resolvedModelName == null || resolvedModelName.isEmpty) {
        resolvedModelName = _readString(firstItemData, ['model_name', 'service_name', 'title', 'name', 'product_name']);
      }
    }
    
    if (orderThumbnail != null && orderThumbnail.isEmpty) orderThumbnail = null;
    if (resolvedModelName == null || resolvedModelName.isEmpty) {
      resolvedModelName = _readString(sourceForDetails, ['model_name', 'service_name', 'title'], fallback: 'Modèle non précisé');
    }

    return TailorOrder(
      id: orderId.isNotEmpty ? orderId : assignmentId,
      orderId: orderId,
      assignmentId: assignmentId,
      status: _parseStatus(_readString(json, ['status'])),
      clientName: _readString(
        sourceForDetails,
        ['client_name', 'customer_name', 'client', 'reference', 'ref', 'order_number'],
        fallback: orderId.isNotEmpty 
          ? 'Cmd #${orderId.length > 8 ? orderId.substring(0, 8) : orderId}' 
          : 'Ref: Inconnue',
      ),
      clientPhone: _readString(
        sourceForDetails,
        ['client_phone', 'customer_phone', 'phone'],
      ),
      modelName: resolvedModelName,
      amount: _readDouble(sourceForDetails, ['total_amount', 'amount', 'price']),
      thumbnailUrl: orderThumbnail,
      createdAt: _readDateTime(json, ['assigned_at', 'created_at']),
      notes: _readString(
        json,
        ['notes', 'special_instructions', 'description'],
      ),
      orderItems: parsedItems,
      raw: Map<String, dynamic>.from(json),
    );
  }

  static TailorOrderStatus _parseStatus(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
      case 'neworder':
      case 'new_order':
        return TailorOrderStatus.pending;
      case 'accepted':
        return TailorOrderStatus.accepted;
      case 'in_progress':
      case 'processing':
        return TailorOrderStatus.inProgress;
      case 'completed':
        return TailorOrderStatus.completed;
      case 'rejected':
        return TailorOrderStatus.rejected;
      case 'cancelled':
        return TailorOrderStatus.cancelled;
      default:
        return TailorOrderStatus.unknown;
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
      
      // Gérer si le champ est un objet multi-langues (ex: {"fr": "Robe", "en": "Dress"})
      if (value is Map) {
        if (value.containsKey('fr') && value['fr'] != null) {
          value = value['fr'];
        } else if (value.containsKey('en') && value['en'] != null) {
          value = value['en'];
        } else if (value.isNotEmpty) {
          value = value.values.first;
        }
      }

      final stringValue = value.toString().trim();
      if (stringValue.isNotEmpty) {
        return stringValue;
      }
    }
    return fallback;
  }

  static double _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return 0;
  }

  static DateTime _readDateTime(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }
      final parsed = DateTime.tryParse(value.toString());
      if (parsed != null) {
        return parsed;
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
