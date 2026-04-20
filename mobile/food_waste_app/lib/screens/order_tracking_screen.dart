import 'package:flutter/material.dart';
import 'package:food_waste_app/widgets/tracking_status_badge.dart';
import 'package:food_waste_app/widgets/pickup_code_card.dart';
import 'package:food_waste_app/widgets/tracking_timeline.dart';
import 'package:food_waste_app/widgets/store_location_card.dart';
import 'package:food_waste_app/widgets/freshness_card.dart';
import 'package:food_waste_app/widgets/bottom_nav_bar.dart';
import 'package:food_waste_app/data/models/tracking_step.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      TrackingStep(
        title: "Hazırlanıyor",
        description: "Sipariş hazırlanıyor",
        isCompleted: true,
        isCurrent: false,
        completedAt: "11:32",
      ),
      TrackingStep(
        title: "Teslime Hazır",
        description: "Sipariş hazır",
        isCompleted: false,
        isCurrent: true,
      ),
      TrackingStep(
        title: "Teslim Alındı",
        description: "Sipariş teslim edildi",
        isCompleted: false,
        isCurrent: false,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Sipariş Takibi")),
      bottomNavigationBar: const BottomNavBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TrackingStatusBadge(text: "12 dk içinde hazır"),
            const SizedBox(height: 20),
            const PickupCodeCard(code: "G - 4029"),
            const SizedBox(height: 20),
            TrackingTimeline(steps: steps),
            const SizedBox(height: 20),
            const StoreLocationCard(
              name: "Green Bowl Cafe",
              address: "Market Street",
            ),
            const SizedBox(height: 20),
            const FreshnessCard(percent: 85),
          ],
        ),
      ),
    );
  }
}