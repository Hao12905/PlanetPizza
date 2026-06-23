import 'package:flutter/material.dart';
import 'package:project129/models/cart_item.dart';
import 'home/views/home_screen.dart';
import 'cart_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'admin/admin_dashboard.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _userScreens = [
    const HomeScreen(),
    const CartScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartManager(),
      builder: (context, child) {
        // 1. Kiểm tra quyền Admin trước
        if (CartManager().isAdmin) {
          return const AdminDashboard();
        }

        // 2. Giao diện cho Khách hàng
        final int cartCount = CartManager().itemCount;
        
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _userScreens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 25, offset: const Offset(0, -5)),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color(0xFF1A1A1A),
              selectedItemColor: const Color(0xFFD4AF37),
              unselectedItemColor: Colors.white24,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              elevation: 0,
              items: [
                const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Trang chủ'),
                BottomNavigationBarItem(
                  icon: Badge(
                    label: Text('$cartCount'),
                    isLabelVisible: cartCount > 0,
                    backgroundColor: Colors.redAccent,
                    child: const Icon(Icons.shopping_basket_rounded),
                  ), 
                  label: 'Giỏ hàng'
                ),
                const BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Thông báo'),
                const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Tài khoản'),
              ],
            ),
          ),
        );
      },
    );
  }
}
