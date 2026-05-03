import 'package:flutter/material.dart';
import 'package:food_waste_app/data/models/customer_order.dart';
import 'package:food_waste_app/data/models/tracking_step.dart';
import 'package:food_waste_app/data/services/api_client.dart';
import 'package:food_waste_app/widgets/tracking_status_badge.dart';
import 'package:food_waste_app/widgets/pickup_code_card.dart';
import 'package:food_waste_app/widgets/tracking_timeline.dart';
import 'package:food_waste_app/widgets/bottom_nav_bar.dart';
import 'package:food_waste_app/screens/rescue_home_screen.dart';

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
  bool _cancelLoading = false;

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
        title: 'Sipariş Alındı',
        description: 'Talebiniz restorana ulaştı.',
        isCompleted: currentIndex > 0,
        isCurrent: currentIndex == 0,
      ),
      TrackingStep(
        title: 'Onaylandı',
        description: 'Restoran hazırlığa başladı.',
        isCompleted: currentIndex > 1,
        isCurrent: currentIndex == 1,
      ),
      TrackingStep(
        title: 'Teslime Hazır',
        description: 'Paketiniz sizi bekliyor!',
        isCompleted: currentIndex > 2,
        isCurrent: currentIndex == 2,
      ),
      TrackingStep(
        title: 'Tamamlandı',
        description: 'Afiyet olsun!',
        isCompleted: currentIndex >= 3,
        isCurrent: currentIndex == 3,
      ),
    ];
  }

  bool _canCancel(String status) {
    final normalized = status.toLowerCase();
    return normalized == 'pending' || normalized == 'confirmed';
  }

  Future<void> _cancelOrder() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Siparişi İptal Et'),
        content: const Text('Bu taptaze ürünlerin israf olmasını istemeyiz. Yine de iptal etmek istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Evet, İptal Et', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _cancelLoading = true);
    try {
      await widget.apiClient.cancelOrder(widget.orderId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sipariş başarıyla iptal edildi.')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('ApiException: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _cancelLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F8),
      appBar: AppBar(
        title: Text(
          'Sipariş Takibi #${widget.orderId}',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) {
            Navigator.pop(context, true);
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
  builder: (_) => RescueHomeScreen(
    initialIndex: index == 0 ? 0 : 3,
    apiClient: widget.apiClient,
  ),
),
              (route) => false,
            );
          }
        },
      ),
      body: FutureBuilder<CustomerOrder>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332)));
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final order = snapshot.data!;
          final steps = _buildSteps(order.status);
          final canCancel = _canCancel(order.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      TrackingStatusBadge(text: order.status),
                      const SizedBox(height: 16),
                      PickupCodeCard(code: '#${order.id}'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildInfoCard(
                  title: "Sipariş Özeti",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...order.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${item.productName} x${item.quantity}",
                                    style: const TextStyle(fontSize: 15)),
                                const Text("Hazırlanıyor",
                                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          )),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Toplam Tutar",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("${order.totalAmount.toStringAsFixed(2)} TL",
                              style: const TextStyle(
                                  color: Color(0xFF1B4332),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Text("Teslimat Süreci",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4332))),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TrackingTimeline(steps: steps),
                ),

                if (canCancel) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: _cancelLoading ? null : _cancelOrder,
                      icon: _cancelLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.cancel_outlined),
                      label: Text(_cancelLoading ? 'İşleniyor...' : 'Siparişi İptal Et'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

