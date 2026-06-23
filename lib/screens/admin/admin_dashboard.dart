import 'package:flutter/material.dart';
import 'package:project129/models/cart_item.dart';
import 'manage_users_screen.dart';
import 'manage_pizzas_screen.dart';
import 'manage_orders_screen.dart';
import 'revenue_report_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartManager(),
      builder: (context, child) {
        final totalRevenue = CartManager().completedRevenue;
        final orderCount = CartManager().orderHistory.length;
        final userCount = CartManager().allUsers.length;
        final pizzaCount = CartManager().availablePizzas.length;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          appBar: AppBar(
            title: const Text('Admin Dashboard',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white70),
                onPressed: () => CartManager().logout(),
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: 25),
                _buildStatsGrid(
                    totalRevenue, orderCount, userCount, pizzaCount),
                const SizedBox(height: 30),
                const Text('Quản lý hệ thống',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildAdminMenu(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Xin chào, ${CartManager().currentUser?.username ?? 'Admin'}!',
            style: const TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        const Text('Hôm nay bạn muốn kiểm tra gì?',
            style: TextStyle(color: Colors.white54, fontSize: 14)),
      ],
    );
  }

  Widget _buildStatsGrid(int revenue, int orders, int users, int products) {
    String formatCurrency(int amount) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Doanh thu', formatCurrency(revenue), Icons.auto_graph,
            Colors.green),
        _buildStatCard(
            'Đơn hàng', orders.toString(), Icons.shopping_bag, Colors.orange),
        _buildStatCard(
            'Khách hàng', users.toString(), Icons.people, Colors.blue),
        _buildStatCard('Sản phẩm', products.toString(), Icons.restaurant_menu,
            Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text(title,
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAdminMenu(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Quản lý Món ăn',
        'icon': Icons.add_business_rounded,
        'color': Colors.amber,
        'screen': const ManagePizzasScreen()
      },
      {
        'title': 'Quản lý Đơn hàng',
        'icon': Icons.list_alt_rounded,
        'color': Colors.blue,
        'screen': const ManageOrdersScreen()
      },
      {
        'title': 'Quản lý Người dùng',
        'icon': Icons.manage_accounts_rounded,
        'color': Colors.teal,
        'screen': const ManageUsersScreen()
      },
      {
        'title': 'Báo cáo Doanh thu',
        'icon': Icons.pie_chart_rounded,
        'color': Colors.redAccent,
        'screen': const RevenueReportScreen()
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: item['color'].withOpacity(0.1),
              child: Icon(item['icon'], color: item['color'], size: 20),
            ),
            title: Text(item['title'],
                style: const TextStyle(color: Colors.white, fontSize: 15)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white24),
            onTap: () {
              if (item['screen'] != null) {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => item['screen']));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Chức năng đang được phát triển')));
              }
            },
          ),
        );
      },
    );
  }
}
