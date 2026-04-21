import 'package:get/get.dart';

enum OrderStatus { newOrder, processing, completed, delivered, cancelled }

class OrderModel {
  final String id;
  final String tailorId;
  final String customerName;
  final String customerPhone;
  final String modelName;
  final double amount;
  final OrderStatus status;
  final DateTime createdAt;
  final String? thumbnailUrl;
  final List<Map<String, dynamic>>? orderItems;
  final Map<String, dynamic> raw;

  OrderModel({
    required this.id,
    required this.tailorId,
    required this.customerName,
    required this.customerPhone,
    required this.modelName,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.thumbnailUrl,
    this.orderItems,
    this.raw = const {},
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final orderData = Map<String, dynamic>.from(json);
    final String modelName = _extractModelName(orderData);

    final String customerName = _readString(orderData, [
      'customer_name',
      'client_name',
      'customer',
      'client',
    ]);

    final String customerPhone = _readString(orderData, [
      'customer_phone',
      'phone',
    ]);

    final String? thumbnailUrl = _extractThumbnail(orderData);

    return OrderModel(
      id: orderData['id']?.toString() ?? '',
      tailorId: orderData['tailor_id']?.toString() ?? '',
      customerName: customerName,
      customerPhone: customerPhone,
      modelName: modelName.isNotEmpty ? modelName : 'Modèle non précisé',
      amount: _readDouble(orderData, ['amount', 'total_amount', 'price']),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == (orderData['status'] ?? 'newOrder'),
        orElse: () => OrderStatus.newOrder,
      ),
      createdAt: DateTime.tryParse(orderData['created_at']?.toString() ?? '') ??
          DateTime.now(),
      thumbnailUrl: thumbnailUrl,
      orderItems: orderData['order_items'] is List
          ? (orderData['order_items'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : [],
      raw: orderData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tailor_id': tailorId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'model_name': modelName,
      'amount': amount,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      if (thumbnailUrl != null) 'thumbnail': thumbnailUrl,
    };
  }

  static String? _extractThumbnail(Map<String, dynamic> json) {
    final image = _readString(json, [
      'thumbnail',
      'image',
      'image_url',
      'photo',
      'photo_url',
    ]);
    if (image.isNotEmpty) return image;

    if (json['order_items'] is List) {
      final items = json['order_items'] as List;
      if (items.isNotEmpty && items.first is Map) {
        final firstItem = Map<String, dynamic>.from(items.first as Map);
        final product = firstItem['product'] ?? firstItem['products'] ?? {};
        if (product is Map && product.isNotEmpty) {
          final productMap = Map<String, dynamic>.from(product);
          final productImage = _readString(productMap, [
            'thumbnail',
            'image',
            'image_url',
            'photo',
            'photo_url',
          ]);
          if (productImage.isNotEmpty) return productImage;
        }

        final itemImage = _readString(firstItem, [
          'thumbnail',
          'image',
          'photo_url',
          'photo',
        ]);
        if (itemImage.isNotEmpty) return itemImage;
      }
    }

    return null;
  }

  static String _extractModelName(Map<String, dynamic> json) {
    final rootName = _readString(json, [
      'model_name',
      'name',
      'title',
      'service_name',
      'product_name',
    ]);
    if (rootName.isNotEmpty) return rootName;

    if (json['order_items'] is List) {
      final items = json['order_items'] as List;
      if (items.isNotEmpty && items.first is Map) {
        final firstItem = Map<String, dynamic>.from(items.first as Map);
        final product = firstItem['product'] ?? firstItem['products'];
        if (product is Map) {
          final productMap = Map<String, dynamic>.from(product);
          final productName = _readString(productMap, [
            'name',
            'title',
            'model_name',
            'service_name',
            'product_name',
          ]);
          if (productName.isNotEmpty) return productName;
        }

        final itemName = _readString(firstItem, [
          'model_name',
          'service_name',
          'title',
          'name',
          'product_name',
        ]);
        if (itemName.isNotEmpty) return itemName;
      }
    }

    return 'Modèle non précisé';
  }

  static String _readString(Map<String, dynamic> json, List<String> keys,
      {String fallback = ''}) {
    final preferredLanguages = _preferredLanguageCodes();

    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      if (value is Map<String, dynamic>) {
        for (final language in preferredLanguages) {
          final localizedValue = value[language];
          if (localizedValue is String && localizedValue.trim().isNotEmpty) {
            return localizedValue.trim();
          }
        }

        // Fallback to any available localized string if preferred languages are missing.
        if (value['fr'] is String && (value['fr'] as String).trim().isNotEmpty) {
          return (value['fr'] as String).trim();
        }
        if (value['en'] is String && (value['en'] as String).trim().isNotEmpty) {
          return (value['en'] as String).trim();
        }

        for (final entry in value.entries) {
          if (entry.value is String && (entry.value as String).trim().isNotEmpty) {
            return (entry.value as String).trim();
          }
        }
      }
    }
    return fallback;
  }

  static List<String> _preferredLanguageCodes() {
    final locale = Get.locale ?? Get.deviceLocale;
    if (locale == null) {
      return ['fr', 'en'];
    }

    final languages = <String>[];
    if (locale.languageCode.isNotEmpty) {
      languages.add(locale.languageCode.toLowerCase());
    }
    if (locale.countryCode?.isNotEmpty == true) {
      languages.add('${locale.languageCode.toLowerCase()}_${locale.countryCode!.toLowerCase()}');
    }
    languages.addAll(['fr', 'en']);
    return languages;
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
}
