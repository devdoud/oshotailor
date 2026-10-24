import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/features/shop/models/order_model.dart';
import 'package:osho/features/tailor_dashboard/models/tailor_order.dart';

/// À traiter → warn ; acceptée → neutre ; en cours → accent ;
/// terminée → ok ; refusée, annulée, livrée → effacé.
extension TailorOrderStatusTone on TailorOrderStatus {
  OTone get tone => switch (this) {
        TailorOrderStatus.pending => OTone.warn,
        TailorOrderStatus.accepted => OTone.neutral,
        TailorOrderStatus.inProgress => OTone.accent,
        TailorOrderStatus.completed => OTone.ok,
        TailorOrderStatus.rejected ||
        TailorOrderStatus.cancelled ||
        TailorOrderStatus.unknown =>
          OTone.quiet,
      };
}

extension OrderStatusUi on OrderStatus {
  String get label => switch (this) {
        OrderStatus.newOrder => 'Nouvelle',
        OrderStatus.processing => 'En cours',
        OrderStatus.completed => 'Terminée',
        OrderStatus.delivered => 'Livrée',
        OrderStatus.cancelled => 'Annulée',
      };

  OTone get tone => switch (this) {
        OrderStatus.newOrder => OTone.warn,
        OrderStatus.processing => OTone.accent,
        OrderStatus.completed => OTone.ok,
        OrderStatus.delivered || OrderStatus.cancelled => OTone.quiet,
      };
}
