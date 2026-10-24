import 'package:flutter_test/flutter_test.dart';
import 'package:osho/features/personalization/models/user_model.dart';
import 'package:osho/features/tailor_dashboard/models/tailor_order.dart';

Map<String, dynamic> assignment({
  String status = 'pending',
  Map<String, dynamic>? order,
}) =>
    {
      'assignment_id': 'asg-1',
      'order_id': 'ord-12345678',
      'status': status,
      'assigned_at': '2026-10-21T10:30:00Z',
      'notes': 'Manches longues',
      'order': order ??
          {
            'client_name': 'Aïssatou Diallo',
            'client_phone': '+1 404 555 0142',
            'total_amount': 185000,
            'order_items': [
              {
                'quantity': 1,
                'product': {
                  'name': {'fr': 'Grand boubou', 'en': 'Grand boubou (EN)'},
                  'thumbnail': 'https://example.com/boubou.jpg',
                },
              }
            ],
          },
    };

void main() {
  group('TailorOrder.fromJson', () {
    test('reads the nested order, product name and amount', () {
      final o = TailorOrder.fromJson(assignment());
      expect(o.orderId, 'ord-12345678');
      expect(o.assignmentId, 'asg-1');
      expect(o.clientName, 'Aïssatou Diallo');
      expect(o.clientPhone, '+1 404 555 0142');
      expect(o.modelName, 'Grand boubou');
      expect(o.thumbnailUrl, 'https://example.com/boubou.jpg');
      expect(o.amount, 185000);
      expect(o.notes, 'Manches longues');
      expect(o.createdAt, DateTime.utc(2026, 10, 21, 10, 30));
      expect(o.orderItems, hasLength(1));
    });

    test('maps server statuses to the four tabs', () {
      const expected = {
        'pending': TailorOrderStatus.pending,
        'new_order': TailorOrderStatus.pending,
        'accepted': TailorOrderStatus.accepted,
        'in_progress': TailorOrderStatus.inProgress,
        'processing': TailorOrderStatus.inProgress,
        'completed': TailorOrderStatus.completed,
        'rejected': TailorOrderStatus.rejected,
        'cancelled': TailorOrderStatus.cancelled,
        'something_else': TailorOrderStatus.unknown,
      };
      expected.forEach((raw, status) {
        expect(TailorOrder.fromJson(assignment(status: raw)).status, status,
            reason: raw);
      });
    });

    test('only the matching status allows each action', () {
      final pending = TailorOrder.fromJson(assignment(status: 'pending'));
      expect(pending.canAcceptOrReject, isTrue);
      expect(pending.canStart, isFalse);
      expect(pending.canComplete, isFalse);

      final accepted = TailorOrder.fromJson(assignment(status: 'accepted'));
      expect(accepted.canAcceptOrReject, isFalse);
      expect(accepted.canStart, isTrue);

      final inProgress =
          TailorOrder.fromJson(assignment(status: 'in_progress'));
      expect(inProgress.canComplete, isTrue);
    });

    test('status labels are French, with accents', () {
      expect(TailorOrder.fromJson(assignment(status: 'accepted')).statusLabel,
          'Acceptée');
      expect(TailorOrder.fromJson(assignment(status: 'completed')).statusLabel,
          'Terminée');
      expect(TailorOrder.fromJson(assignment(status: 'rejected')).statusLabel,
          'Refusée');
    });

    test('falls back when the order has no client or items', () {
      final o = TailorOrder.fromJson(assignment(order: {}));
      expect(o.clientName, 'Cmd #ord-1234');
      expect(o.modelName, 'Modèle non précisé');
      expect(o.amount, 0);
      expect(o.thumbnailUrl, isNull);
    });
  });

  group('UserModel', () {
    final user = UserModel(
      id: 'u-1',
      email: 'atelier@osho.app',
      firstName: 'Atelier',
      lastName: 'Koffi',
      username: 'koffi',
      phone: '+229 01 02 03 04',
      profilePicture: '',
      role: 'tailor',
    );

    test('a profile update never carries role, email or id', () {
      final payload = user.toProfileUpdateJson();
      expect(payload.keys, unorderedEquals(['full_name', 'phone', 'avatar_url']));
      expect(payload['full_name'], 'Atelier Koffi');
    });

    test('toJson never carries the role', () {
      expect(user.toJson().containsKey('role'), isFalse);
    });

    test('fromJson splits the full name', () {
      final u = UserModel.fromJson(
          {'id': 'u-1', 'full_name': 'Atelier Koffi Mensah', 'role': 'tailor'});
      expect(u.firstName, 'Atelier');
      expect(u.lastName, 'Koffi Mensah');
      expect(u.role, 'tailor');
    });
  });
}
