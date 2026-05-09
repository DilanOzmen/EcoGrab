import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:food_waste_app/core/app_colors.dart';
import 'package:food_waste_app/data/models/seller_order.dart';
import 'package:food_waste_app/data/services/api_client.dart';

class SellerOrderApprovalScreen extends StatefulWidget {
  const SellerOrderApprovalScreen({super.key});

  @override
  State<SellerOrderApprovalScreen> createState() =>
      _SellerOrderApprovalScreenState();
}

class _SellerOrderApprovalScreenState
    extends State<SellerOrderApprovalScreen> {
  final ApiClient _apiClient = ApiClient();

  late Future<List<SellerOrder>> _ordersFuture;

  bool _updating = false;

  @override
  void initState() {
    super.initState();

    _ordersFuture = _apiClient.getSellerOrders(
      onlyActive: true,
    );
  }

  Future<void> _refresh() async {
    final refreshedFuture = _apiClient.getSellerOrders(
      onlyActive: true,
    );

    setState(() {
      _ordersFuture = refreshedFuture;
    });

    await refreshedFuture;
  }

  Future<void> _updateStatus(
    int orderId,
    String status,
  ) async {
    if (_updating) return;

    setState(() {
      _updating = true;
    });

    try {
      await _apiClient.updateSellerOrderStatus(
        orderId: orderId,
        status: status,
      );

      if (!mounted) return;

      final refreshedFuture = _apiClient.getSellerOrders(
        onlyActive: true,
      );

      setState(() {
        _ordersFuture = refreshedFuture;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'Cancelled'
                ? 'Sipariş iptal edildi.'
                : status == 'Completed'
                    ? 'Sipariş tamamlandı.'
                    : status == 'ReadyForPickup'
                        ? 'Sipariş teslime hazır.'
                        : 'Sipariş onaylandı.',
          ),
        ),
      );

      await refreshedFuture;
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('ApiException: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updating = false;
        });
      }
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;

      case 'confirmed':
        return Colors.blue;

      case 'readyforpickup':
        return AppColors.primaryGreen;

      case 'completed':
        return Colors.green;

      case 'cancelled':
        return AppColors.error;

      default:
        return Colors.grey;
    }
  }

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Bekliyor';

      case 'confirmed':
        return 'Onaylandı';

      case 'readyforpickup':
        return 'Teslime Hazır';

      case 'completed':
        return 'Tamamlandı';

      case 'cancelled':
        return 'İptal Edildi';

      default:
        return status;
    }
  }

  Widget _actions(SellerOrder order) {
    final status = order.status.toLowerCase();

    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _updating
                  ? null
                  : () => _updateStatus(
                        order.orderId,
                        'Confirmed',
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Onayla'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: _updating
                  ? null
                  : () => _updateStatus(
                        order.orderId,
                        'Cancelled',
                      ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(
                  color: AppColors.error.withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Reddet'),
            ),
          ),
        ],
      );
    }

    if (status == 'confirmed') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _updating
              ? null
              : () => _updateStatus(
                    order.orderId,
                    'ReadyForPickup',
                  ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('Teslime Hazır Yap'),
        ),
      );
    }

    if (status == 'readyforpickup') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _updating
              ? null
              : () => _updateStatus(
                    order.orderId,
                    'Completed',
                  ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('Tamamla'),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: _statusColor(order.status).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          _statusText(order.status),
          style: GoogleFonts.manrope(
            color: _statusColor(order.status),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        iconTheme: const IconThemeData(
          color: AppColors.primaryGreen,
        ),

        title: Text(
          'Sipariş Kontrolü',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      body: FutureBuilder<List<SellerOrder>>(
        future: _ordersFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot.error
                      .toString()
                      .replaceAll(
                        'ApiException: ',
                        '',
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,

              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                children: [
                  const SizedBox(height: 180),

                  Center(
                    child: Text(
                      'Aktif sipariş bulunmuyor.',
                      style: GoogleFonts.manrope(
                        color: AppColors.textSoft,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Filter out orders with no items
          final ordersWithItems =
              orders.where((order) => order.items.isNotEmpty).toList();

          if (ordersWithItems.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,

              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                children: [
                  const SizedBox(height: 180),

                  Center(
                    child: Text(
                      'Ürün bulunmayan siparişler filtrelendi.',
                      style: GoogleFonts.manrope(
                        color: AppColors.textSoft,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryGreen,

            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: ordersWithItems.length,

              itemBuilder: (context, index) {
                final order = ordersWithItems[index];

                final color = _statusColor(order.status);

                final itemSummary = order.items
                    .map(
                      (item) =>
                          '${item.productName} x${item.quantity}',
                    )
                    .join(', ');

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),

                    border: Border.all(
                      color: AppColors.surfaceContainer,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.035,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,

                            decoration: BoxDecoration(
                              color: color.withValues(
                                alpha: 0.12,
                              ),

                              borderRadius:
                                  BorderRadius.circular(16),
                            ),

                            child: Icon(
                              Icons.receipt_long_outlined,
                              color: color,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                Text(
                                  'Sipariş #${order.orderId}',

                                  style: GoogleFonts
                                      .plusJakartaSans(
                                    fontWeight:
                                        FontWeight.w900,

                                    color:
                                        AppColors.textDark,
                                  ),
                                ),

                                Text(
                                  order.customerName
                                          .isNotEmpty
                                      ? order.customerName
                                      : 'Müşteri #${order.customerId}',

                                  style: GoogleFonts
                                      .manrope(
                                    color:
                                        AppColors.textSoft,

                                    fontSize: 12,

                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),

                            decoration: BoxDecoration(
                              color: color.withValues(
                                alpha: 0.12,
                              ),

                              borderRadius:
                                  BorderRadius.circular(
                                999,
                              ),
                            ),

                            child: Text(
                              _statusText(order.status),

                              style: GoogleFonts.manrope(
                                color: color,
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Text(
                        itemSummary.isNotEmpty
                            ? itemSummary
                            : 'Ürün bilgisi yok',

                        style: GoogleFonts.manrope(
                          color: AppColors.textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Toplam: ₺${order.totalAmount.toStringAsFixed(2)}',

                        style:
                            GoogleFonts.plusJakartaSans(
                          color: AppColors.primaryGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 14),

                      _actions(order),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}