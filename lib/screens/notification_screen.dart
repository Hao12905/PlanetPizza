import 'package:flutter/material.dart';
import 'package:project129/models/cart_item.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const _gold = Color(0xFFD4AF37);
  static const _dark = Color(0xFF0A0A0A);
  static const _card = Color(0xFF1A1A1A);

  String _formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}đ';
  }

  String _formatDateTime(DateTime dateTime) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)} - ${twoDigits(dateTime.day)}/${twoDigits(dateTime.month)}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'preparing':
        return Colors.orangeAccent;
      case 'shipping':
        return Colors.lightBlueAccent;
      case 'completed':
        return Colors.greenAccent;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return _gold;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'preparing':
        return Icons.local_pizza_rounded;
      case 'shipping':
        return Icons.delivery_dining_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  String _statusTitle(String status) {
    switch (status) {
      case 'preparing':
        return 'Đơn hàng đang được chuẩn bị';
      case 'shipping':
        return 'Đơn hàng đang được giao';
      case 'completed':
        return 'Đơn hàng đã hoàn tất';
      case 'cancelled':
        return 'Đơn hàng đã bị hủy';
      default:
        return 'Đặt hàng thành công!';
    }
  }

  String _statusMessage(OrderModel order) {
    switch (order.status) {
      case 'preparing':
        return 'Bếp đang chuẩn bị ${order.items.length} món cho bạn.';
      case 'shipping':
        return 'Shipper đang giao đơn đến địa chỉ của bạn.';
      case 'completed':
        return 'Cảm ơn bạn đã đặt hàng tại Planet Pizza.';
      case 'cancelled':
        return 'Rất tiếc, đơn hàng này đã bị hủy. Bạn có thể đặt lại món khác bất cứ lúc nào.';
      default:
        return 'Đơn hàng gồm ${order.items.length} món đang chờ xác nhận.';
    }
  }

  List<OrderModel> _visibleOrders(CartManager manager) {
    final currentEmail = manager.currentUser?.email;
    final orders = manager.orderHistory;
    if (currentEmail == null || currentEmail.isEmpty) return orders;
    if (manager.currentUser?.role == 'admin') return orders;
    return orders
        .where((order) =>
            order.userEmail.isEmpty || order.userEmail == currentEmail)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final manager = CartManager();

    return Scaffold(
      backgroundColor: _dark,
      appBar: AppBar(
        title: const Text(
          'Thông báo & Đơn hàng',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: manager.refreshOrders,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: manager,
        builder: (context, child) {
          final history = _visibleOrders(manager);

          if (history.isEmpty) {
            return RefreshIndicator(
              color: _gold,
              onRefresh: manager.refreshOrders,
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 80,
                    color: Colors.white.withOpacity(0.05),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Bạn chưa có thông báo nào',
                      style: TextStyle(color: Colors.white24, fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: _gold,
            onRefresh: manager.refreshOrders,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final order = history[index];
                final color = _statusColor(order.status);
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: color.withOpacity(0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              order.id,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            _formatDateTime(order.dateTime),
                            style: const TextStyle(
                              color: Colors.white24,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(_statusIcon(order.status),
                              color: color, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _statusTitle(order.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _statusMessage(order),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                      const Divider(height: 30, color: Colors.white10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Giao đến:',
                                  style: TextStyle(
                                    color: Colors.white24,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  order.address,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatCurrency(order.totalAmount),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
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
