import 'package:flutter/material.dart';
import 'package:project129/models/cart_item.dart';

class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({super.key});

  static const _gold = Color(0xFFD4AF37);
  static const _statuses = {
    'pending': 'Chờ xác nhận',
    'preparing': 'Đang chuẩn bị',
    'shipping': 'Đang giao',
    'completed': 'Hoàn tất',
    'cancelled': 'Đã hủy',
  };

  String _formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (match) => "${match[1]}.")}đ';
  }

  String _formatDateTime(DateTime dateTime) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)} - ${twoDigits(dateTime.day)}/${twoDigits(dateTime.month)}/${dateTime.year}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'preparing':
        return Colors.orange;
      case 'shipping':
        return Colors.blueAccent;
      case 'completed':
        return Colors.greenAccent;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return _gold;
    }
  }

  String _paymentMethodLabel(String method) {
    return method == 'bank_transfer' ? 'Chuyển khoản' : 'Tiền mặt';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'Quản lý Đơn hàng',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: () => CartManager().refreshOrders(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: CartManager(),
        builder: (context, child) {
          final orders = CartManager().orderHistory;

          if (orders.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có đơn hàng nào',
                style: TextStyle(color: Colors.white38, fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: CartManager().refreshOrders,
            color: _gold,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) =>
                  _buildOrderCard(context, orders[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final statusColor = _statusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.id,
                  style: const TextStyle(
                      color: _gold, fontWeight: FontWeight.w900),
                ),
              ),
              _buildStatusBadge(order.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            order.customerName.isEmpty ? order.userEmail : order.customerName,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${order.phone} • ${_formatDateTime(order.dateTime)}',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white38, size: 16),
              const SizedBox(width: 6),
              Text(
                _paymentMethodLabel(order.paymentMethod),
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.address,
            style: const TextStyle(color: Colors.white70, height: 1.35),
          ),
          const Divider(height: 26, color: Colors.white10),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}x ${item.name}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                  Text(
                    _formatCurrency(item.totalPrice),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatCurrency(order.totalAmount),
                  style: const TextStyle(
                      color: _gold, fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
              PopupMenuButton<String>(
                color: const Color(0xFF242424),
                icon:
                    const Icon(Icons.more_horiz_rounded, color: Colors.white70),
                onSelected: (status) =>
                    CartManager().updateOrderStatus(order.id, status),
                itemBuilder: (context) => _statuses.entries
                    .map(
                      (entry) => PopupMenuItem(
                        value: entry.key,
                        child: Text(entry.value,
                            style: const TextStyle(color: Colors.white)),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statuses[status] ?? status,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }
}
