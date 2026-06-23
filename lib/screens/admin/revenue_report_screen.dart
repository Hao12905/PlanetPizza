import 'package:flutter/material.dart';
import 'package:project129/models/cart_item.dart';

class RevenueReportScreen extends StatelessWidget {
  const RevenueReportScreen({super.key});

  static const _gold = Color(0xFFD4AF37);

  String _formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (match) => "${match[1]}.")}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'Báo cáo Doanh thu',
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
          final validOrders =
              orders.where((order) => order.status != 'cancelled').toList();
          final revenue =
              validOrders.fold(0, (total, order) => total + order.totalAmount);
          final average =
              validOrders.isEmpty ? 0 : revenue ~/ validOrders.length;
          final completed =
              orders.where((order) => order.status == 'completed').length;
          final pending =
              orders.where((order) => order.status == 'pending').length;
          final cancelled =
              orders.where((order) => order.status == 'cancelled').length;

          return RefreshIndicator(
            onRefresh: CartManager().refreshOrders,
            color: _gold,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildHeroRevenue(revenue),
                const SizedBox(height: 18),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    _buildMetric('Tổng đơn', orders.length.toString(),
                        Icons.receipt_long_rounded, Colors.blueAccent),
                    _buildMetric('Đơn hoàn tất', completed.toString(),
                        Icons.check_circle_rounded, Colors.greenAccent),
                    _buildMetric('Đang chờ', pending.toString(),
                        Icons.pending_actions_rounded, Colors.orangeAccent),
                    _buildMetric('Trung bình', _formatCurrency(average),
                        Icons.trending_up_rounded, Colors.purpleAccent),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tình trạng đơn hàng',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                _buildStatusRow('Đang xử lý',
                    orders.length - completed - cancelled, Colors.orangeAccent),
                _buildStatusRow('Hoàn tất', completed, Colors.greenAccent),
                _buildStatusRow('Đã hủy', cancelled, Colors.redAccent),
                const SizedBox(height: 24),
                const Text(
                  'Đơn gần đây',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                if (orders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text('Chưa có dữ liệu doanh thu',
                          style: TextStyle(color: Colors.white38)),
                    ),
                  )
                else
                  ...orders.take(8).map(_buildRecentOrder),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroRevenue(int revenue) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _gold.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.pie_chart_rounded, color: _gold, size: 30),
          const SizedBox(height: 18),
          const Text('Doanh thu hợp lệ',
              style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 6),
          Text(
            _formatCurrency(revenue),
            style: const TextStyle(
                color: Colors.white, fontSize: 31, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Không tính các đơn đã hủy.',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
              Text(title,
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String title, int count, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
              child:
                  Text(title, style: const TextStyle(color: Colors.white70))),
          Text(count.toString(),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildRecentOrder(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.id,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                    order.customerName.isEmpty
                        ? order.userEmail
                        : order.customerName,
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Text(_formatCurrency(order.totalAmount),
              style:
                  const TextStyle(color: _gold, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
