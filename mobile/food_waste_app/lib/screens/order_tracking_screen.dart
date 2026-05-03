import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:food_waste_app/core/app_colors.dart';
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
        description: 'Paketiniz sizi bekliyor.',
        isCompleted: currentIndex > 2,
        isCurrent: currentIndex == 2,
      ),
      TrackingStep(
        title: 'Tamamlandı',
        description: 'Afiyet olsun.',
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Siparişi İptal Et'),
        content: const Text(
          'Bu taptaze ürünlerin israf olmasını istemeyiz. Yine de iptal etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Evet, İptal Et',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Text(
          'Sipariş Takibi',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
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
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final order = snapshot.data!;
          final steps = _buildSteps(order.status);
          final canCancel = _canCancel(order.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _hero(order),
                const SizedBox(height: 20),
                _summaryCard(order),
                const SizedBox(height: 22),
                Text(
                  'Teslimat Süreci',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: _cardDecoration(),
                  child: TrackingTimeline(steps: steps),
                ),
                if (canCancel) ...[
                  const SizedBox(height: 22),
                  _cancelButton(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _hero(CustomerOrder order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -36,
            top: -44,
            child: Icon(
              Icons.eco,
              size: 150,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sipariş #${order.id}',
                style: GoogleFonts.manrope(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${order.totalAmount.toStringAsFixed(2)} TL',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  TrackingStatusBadge(text: order.status),
                  const SizedBox(width: 12),
                  PickupCodeCard(code: '#${order.id}'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(CustomerOrder order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.receipt_long_rounded, 'Sipariş Özeti'),
          const SizedBox(height: 14),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.productName} x${item.quantity}',
                      style: GoogleFonts.manrope(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    'Hazırlanıyor',
                    style: GoogleFonts.manrope(
                      color: AppColors.textSoft,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Toplam Tutar',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '${order.totalAmount.toStringAsFixed(2)} TL',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: _cancelLoading ? null : _cancelOrder,
        icon: _cancelLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.cancel_outlined),
        label: Text(_cancelLoading ? 'İşleniyor...' : 'Siparişi İptal Et'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.45)),
          backgroundColor: AppColors.error.withValues(alpha: 0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _cardTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.surfaceContainer),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.035),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}