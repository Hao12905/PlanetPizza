import 'package:flutter/material.dart';
import 'package:project129/models/cart_item.dart';
import 'package:project129/screens/contact_screen.dart';
import 'package:project129/screens/notification_screen.dart';
import 'auth/views/sign_in_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _gold = Color(0xFFD4AF37);
  static const _panel = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartManager(),
      builder: (context, child) {
        final user = CartManager().currentUser;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          appBar: AppBar(
            title: const Text(
              'Tài khoản',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 18),
                _buildLoyaltyCard(user),
                const SizedBox(height: 24),
                _buildMenuSection(context, user),
                const SizedBox(height: 24),
                _buildLogoutButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(UserModel? user) {
    return Column(
      children: [
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _gold.withOpacity(0.12),
            border: Border.all(color: _gold, width: 2),
          ),
          child: const Icon(Icons.person_rounded, color: _gold, size: 58),
        ),
        const SizedBox(height: 18),
        Text(
          user?.username ?? 'Khách vãng lai',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          user?.email ?? 'Chưa đăng nhập',
          style: TextStyle(color: Colors.white.withOpacity(0.42), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildLoyaltyCard(UserModel? user) {
    final points = user?.loyaltyPoints ?? 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _gold.withOpacity(0.32)),
        boxShadow: [
          BoxShadow(
            color: _gold.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _gold.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.stars_rounded, color: _gold, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Điểm tích lũy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cứ 10.000đ mua hàng = 1 điểm',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$points',
            style: const TextStyle(
              color: _gold,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'đ',
            style: TextStyle(color: _gold, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, UserModel? user) {
    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildMenuItem(Icons.person_outline_rounded, 'Thông tin cá nhân',
              () => _showUserInfo(context, user)),
          _buildMenuItem(Icons.shopping_bag_outlined, 'Lịch sử đơn hàng', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NotificationScreen()),
            );
          }),
          _buildMenuItem(Icons.location_on_outlined, 'Địa chỉ nhận hàng',
              () => _showAddressSheet(context, user)),
          _buildMenuItem(Icons.payment_rounded, 'Phương thức thanh toán',
              () => _showPaymentSheet(context, user)),
          _buildMenuItem(Icons.favorite_border_rounded, 'Món ăn yêu thích',
              () => _showFavoritesSheet(context)),
          _buildMenuItem(Icons.contact_support_outlined, 'Liên hệ', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContactScreen()),
            );
          }),
          _buildMenuItem(Icons.settings_outlined, 'Cài đặt',
              () => _showSettingsSheet(context, user),
              isLast: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap,
      {bool isLast = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _gold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: _gold, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          size: 16, color: Colors.white.withOpacity(0.2)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      shape: isLast
          ? null
          : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.03))),
    );
  }

  void _showUserInfo(BuildContext context, UserModel? user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text(
          'Thông tin cá nhân',
          style: TextStyle(color: _gold, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Họ tên', user?.username ?? 'N/A'),
            _buildInfoRow('Email', user?.email ?? 'N/A'),
            _buildInfoRow('SĐT', user?.phone ?? 'N/A'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressSheet(BuildContext context, UserModel? user) {
    final controller = TextEditingController(text: user?.defaultAddress ?? '');
    _showAppSheet(
      context,
      title: 'Địa chỉ nhận hàng',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Địa chỉ mặc định sẽ được tự điền khi bạn thanh toán.',
            style: TextStyle(color: Colors.white54, height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
                'Nhập địa chỉ nhận hàng', Icons.location_on_outlined),
          ),
          const SizedBox(height: 18),
          _buildPrimaryButton('Lưu địa chỉ', () async {
            await CartManager().updateUserPreferences(
              defaultAddress: controller.text.trim(),
            );
            if (context.mounted) Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  void _showPaymentSheet(BuildContext context, UserModel? user) {
    var selected = user?.linkedPaymentMethod.isNotEmpty == true
        ? user!.linkedPaymentMethod
        : 'cash';

    _showAppSheet(
      context,
      title: 'Liên kết thanh toán',
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPaymentTile(
              icon: Icons.payments_rounded,
              title: 'Tiền mặt khi nhận hàng',
              subtitle: 'Thanh toán trực tiếp cho shipper.',
              selected: selected == 'cash',
              onTap: () => setSheetState(() => selected = 'cash'),
            ),
            const SizedBox(height: 10),
            _buildPaymentTile(
              icon: Icons.qr_code_2_rounded,
              title: 'Chuyển khoản VietQR',
              subtitle: 'Dùng tài khoản BIDV 1040295282.',
              selected: selected == 'bank_transfer',
              onTap: () => setSheetState(() => selected = 'bank_transfer'),
            ),
            const SizedBox(height: 18),
            _buildPrimaryButton('Lưu phương thức', () async {
              await CartManager().updateUserPreferences(
                linkedPaymentMethod: selected,
              );
              if (context.mounted) Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected
              ? _gold.withOpacity(0.12)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? _gold : Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? _gold : Colors.white54),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
            Icon(selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? _gold : Colors.white24),
          ],
        ),
      ),
    );
  }

  void _showFavoritesSheet(BuildContext context) {
    final favorites = CartManager().favoriteFoodCounts;
    _showAppSheet(
      context,
      title: 'Món ăn yêu thích',
      child: favorites.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'Chưa có dữ liệu. Món yêu thích sẽ dựa trên món bạn mua lại nhiều lần.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, height: 1.4),
                ),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: favorites.take(8).map((entry) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0x22D4AF37),
                    child: Icon(Icons.favorite_rounded, color: _gold),
                  ),
                  title: Text(entry.key,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('Đã mua ${entry.value} lần',
                      style: const TextStyle(color: Colors.white38)),
                );
              }).toList(),
            ),
    );
  }

  void _showSettingsSheet(BuildContext context, UserModel? user) {
    var notificationsEnabled = user?.notificationsEnabled ?? true;
    var language = user?.language ?? 'Tiếng Việt';

    _showAppSheet(
      context,
      title: 'Cài đặt',
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: _gold,
              value: notificationsEnabled,
              onChanged: (value) async {
                setSheetState(() => notificationsEnabled = value);
                await CartManager().updateUserPreferences(
                  notificationsEnabled: value,
                );
              },
              title: const Text('Bật thông báo',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('Nhận cập nhật đơn hàng và ưu đãi.',
                  style: TextStyle(color: Colors.white38)),
            ),
            const Divider(color: Colors.white10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.language_rounded, color: _gold),
              title: const Text('Ngôn ngữ',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle:
                  Text(language, style: const TextStyle(color: Colors.white38)),
              trailing: DropdownButton<String>(
                value: language,
                dropdownColor: _panel,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(
                      value: 'Tiếng Việt', child: Text('Tiếng Việt')),
                  DropdownMenuItem(value: 'English', child: Text('English')),
                ],
                onChanged: (value) async {
                  if (value == null) return;
                  setSheetState(() => language = value);
                  await CartManager().updateUserPreferences(language: value);
                },
              ),
            ),
            const Divider(color: Colors.white10),
            _buildSettingsRow(
                Icons.info_outline_rounded, 'Phiên bản app', '1.0.0'),
            const Divider(color: Colors.white10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.support_agent_rounded, color: _gold),
              title: const Text('Trung tâm hỗ trợ',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('Liên hệ khi cần hỗ trợ đơn hàng.',
                  style: TextStyle(color: Colors.white38)),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: Colors.white24),
              onTap: () => _showSupportDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsRow(IconData icon, String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: _gold),
      title: Text(title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: const TextStyle(color: Colors.white38)),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Trung tâm hỗ trợ',
            style: TextStyle(color: _gold, fontWeight: FontWeight.bold)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hotline: 0355428605', style: TextStyle(color: Colors.white)),
            SizedBox(height: 10),
            Text('Email: support@planetpizza.vn',
                style: TextStyle(color: Colors.white)),
            SizedBox(height: 10),
            Text('Thời gian hỗ trợ: 08:00 - 22:00',
                style: TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng')),
        ],
      ),
    );
  }

  void _showAppSheet(BuildContext context,
      {required String title, required Widget child}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          decoration: const BoxDecoration(
            color: Color(0xFF151515),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900)),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white54),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24),
      prefixIcon: Icon(icon, color: _gold, size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: _gold)),
    );
  }

  Widget _buildPrimaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _gold,
          foregroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          CartManager().logout();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const SignInScreen()),
            (route) => false,
          );
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          foregroundColor: Colors.redAccent,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded),
            SizedBox(width: 12),
            Text(
              'Đăng xuất tài khoản',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
