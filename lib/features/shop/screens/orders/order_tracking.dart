import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/appbar/appbar.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: OAppBar(title: Text('track_order'.tr), showBackArrow: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(OSizes.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.box, color: OColors.primary, size: 32),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Commande #45892", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Estimé: 14 Dec 2024", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              Text("Statut de la commande", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),

              // Timeline
              _buildTimelineStep(context, 'order_status_confirmed'.tr, 'tracking_confirmed_sub'.tr, true, true),
              _buildTimelineStep(context, 'order_status_processing'.tr, 'tracking_processing_sub'.tr, true, true),
              _buildTimelineStep(context, 'order_status_shipping'.tr, 'tracking_shipping_sub'.tr, false, true), // Active
              _buildTimelineStep(context, 'order_status_delivered'.tr, 'tracking_delivered_sub'.tr, false, false, isLast: true),

              const SizedBox(height: 32),

              // Map Placeholder (Image)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: const [
                       Icon(Iconsax.map, size: 40, color: Colors.grey),
                       SizedBox(height: 8),
                       Text("Suivi en temps réel (Simulation)", style: TextStyle(color: Colors.grey))
                     ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep(BuildContext context, String title, String subtitle, bool isCompleted, bool isActive, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? OColors.primary : (isActive ? Colors.white : Colors.grey[300]),
                border: isActive && !isCompleted ? Border.all(color: OColors.primary, width: 5) : null,
              ),
              child: isCompleted ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
            ),
             if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: isCompleted ? OColors.primary : Colors.grey[300],
              )
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: (isCompleted || isActive) ? Colors.black : Colors.grey)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const SizedBox(height: 32), // Spacing for timeline
            ],
          ),
        )
      ],
    );
  }
}
