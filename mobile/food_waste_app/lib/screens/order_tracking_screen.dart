import 'package:flutter/material.dart';
import 'package:food_waste_app/data/models/customer_order.dart';
import 'package:food_waste_app/data/models/tracking_step.dart';
import 'package:food_waste_app/data/services/api_client.dart';
import 'package:food_waste_app/widgets/tracking_status_badge.dart';
import 'package:food_waste_app/widgets/pickup_code_card.dart';
import 'package:food_waste_app/widgets/tracking_timeline.dart';
import 'package:food_waste_app/widgets/bottom_nav_bar.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;
  final ApiClient apiClient;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.apiClient,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late Future<CustomerOrder> _orderFuture;

  @override
  void initState() {
    super.initState();
    _orderFuture = widget.apiClient.getOrderDetail(widget.orderId);
  }

  List<TrackingStep> _buildSteps(String status) {
    final statuses = ['Pending', 'Confirmed', 'ReadyForPickup', 'Completed'];
    final currentIndex = statuses.indexOf(status);

    return [
      TrackingStep(
        title: 'Bekliyor',
        description: 'Siparis alindi',
        isCompleted: currentIndex > 0,
        isCurrent: currentIndex == 0,
        completedAt: currentIndex > 0 ? '' : null,
      ),
      TrackingStep(
        title: 'Onaylandi',
        description: 'Restoran onayladi',
        isCompleted: currentIndex > 1,
        isCurrent: currentIndex == 1,
        completedAt: currentIndex > 1 ? '' : null,
      ),
      TrackingStep(
        title: 'Teslime Hazir',
        description: 'Alinmaya hazir',
        isCompleted: currentIndex > 2,
        isCurrent: currentIndex == 2,
        completedAt: currentIndex > 2 ? '' : null,
      ),
      TrackingStep(
        title: 'Tamamlandi',
        description: 'Teslim alindi',
        isCompleted: currentIndex >= 3,
        isCurrent: currentIndex == 3,
        completedAt: currentIndex >= 3 ? '' : null,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Siparis #${widget.orderId}')),
      bottomNavigationBar: const BottomNavBar(),
      body: FutureBuilder<CustomerOrder>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString().replaceAll('ApiException: ', ''),
                textAlign: TextAlign.center,
              ),
            );
          }

          final order = snapshot.data!;
          final steps = _buildSteps(order.status);
          final itemSummary = order.items.map((i) => '${i.productName} x${i.quantity}').join(', ');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TrackingStatusBadge(text: order.status),
                const SizedBox(height: 20),
                PickupCodeCard(code: '#${order.id}'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Urunler',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(itemSummary.isNotEmpty ? itemSummary : '-'),
                        const SizedBox(height: 8),
                        Text(
                          'Toplam: ${order.totalAmount.toStringAsFixed(2)} TL',
                          style: const TextStyle(
                            color: Color(0xFF0F5238),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TrackingTimeline(steps: steps),
              ],
            ),
          );
        },
      ),
    );
  }
}
