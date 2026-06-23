import 'package:flutter/material.dart';
import 'package:project129/models/cart_item.dart';
import 'package:project129/screens/auth/views/sign_in_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _paymentMethod = 'cash';

  @override
  void dispose() {
    _customerNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}đ';
  }

  void _handleCheckout(BuildContext context, CartManager cart) {
    if (!cart.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng đăng nhập để thực hiện thanh toán')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
      return;
    }

    _customerNameController.text = _customerNameController.text.isNotEmpty
        ? _customerNameController.text
        : (cart.currentUser?.username ?? '');
    _phoneController.text = _phoneController.text.isNotEmpty
        ? _phoneController.text
        : (cart.currentUser?.phone ?? '');
    _addressController.text = _addressController.text.isNotEmpty
        ? _addressController.text
        : (cart.currentUser?.defaultAddress ?? '');
    if (cart.currentUser?.linkedPaymentMethod.isNotEmpty == true) {
      _paymentMethod = cart.currentUser!.linkedPaymentMethod;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: const Text('Thông tin giao hàng',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCheckoutTextField(_customerNameController,
                    'Tên khách hàng', Icons.person_outline_rounded),
                const SizedBox(height: 15),
                _buildCheckoutTextField(_addressController, 'Địa chỉ nhận hàng',
                    Icons.location_on_rounded),
                const SizedBox(height: 15),
                _buildCheckoutTextField(_phoneController, 'Số điện thoại',
                    Icons.phone_android_rounded,
                    isPhone: true),
                const SizedBox(height: 20),
                _buildPaymentSelector(
                  totalAmount: cart.totalAmount,
                  onChanged: (value) {
                    setState(() => _paymentMethod = value);
                    setDialogState(() {});
                  },
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white10),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Tóm tắt đơn hàng:',
                      style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                ...cart.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.quantity}x ${item.name}',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          Text(_formatCurrency(item.totalPrice),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    )),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng thanh toán:',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(_formatCurrency(cart.totalAmount),
                        style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (_customerNameController.text.isEmpty ||
                    _addressController.text.isEmpty ||
                    _phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vui lòng nhập đầy đủ thông tin')),
                  );
                  return;
                }

                String finalCustomerName = _customerNameController.text;
                String finalAddress = _addressController.text;
                String finalPhone = _phoneController.text;

                // Tạo đơn hàng và lưu vào lịch sử
                cart.checkout(
                  finalAddress,
                  finalPhone,
                  customerName: finalCustomerName,
                  paymentMethod: _paymentMethod,
                );

                Navigator.pop(context);
                _showSuccessDialog(context, finalAddress, finalPhone);
              },
              child: const Text('XÁC NHẬN',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  String _paymentMethodLabel(String method) {
    return method == 'bank_transfer' ? 'Chuyển khoản' : 'Tiền mặt';
  }

  Widget _buildPaymentSelector({
    required int totalAmount,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Phương thức thanh toán',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildPaymentOption(
                value: 'cash',
                title: 'Tiền mặt',
                icon: Icons.payments_rounded,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildPaymentOption(
                value: 'bank_transfer',
                title: 'Chuyển khoản',
                icon: Icons.account_balance_rounded,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
        if (_paymentMethod == 'bank_transfer') ...[
          const SizedBox(height: 14),
          _buildBankTransferQr(totalAmount),
        ],
      ],
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required IconData icon,
    required ValueChanged<String> onChanged,
  }) {
    final isSelected = _paymentMethod == value;

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD4AF37).withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.white10,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFD4AF37) : Colors.white38,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankTransferQr(int totalAmount) {
    final qrUrl = Uri.https(
      'img.vietqr.io',
      '/image/VCB-1040295282-compact2.png',
      {
        'amount': totalAmount.toString(),
        'addInfo': 'Thanh toan Planet Pizza',
        'accountName': 'HUYNH NHAT HAO',
      },
    ).toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.35)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              qrUrl,
              height: 220,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 220,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Không tải được mã VietQR',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Vietcombank',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'HUYNH NHAT HAO',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          const Text(
            '1040295282',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String address, String phone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.greenAccent, size: 80),
            const SizedBox(height: 20),
            const Text('ĐẶT HÀNG THÀNH CÔNG!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text('Đơn hàng sẽ được giao đến:',
                style: TextStyle(color: Colors.white.withOpacity(0.5))),
            const SizedBox(height: 5),
            Text(address,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Text('Số điện thoại: $phone',
                style: const TextStyle(color: Color(0xFFD4AF37))),
            const SizedBox(height: 8),
            Text('Thanh toán: ${_paymentMethodLabel(_paymentMethod)}',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37)),
                onPressed: () => Navigator.pop(context),
                child:
                    const Text('Xong', style: TextStyle(color: Colors.black)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool isPhone = false}) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartManager(),
      builder: (context, child) {
        final cart = CartManager();
        final items = cart.items;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          appBar: AppBar(
            title: const Text('Giỏ hàng của tôi',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: items.isEmpty
              ? _buildEmptyCart()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildCartItem(item, index);
                  },
                ),
          bottomNavigationBar:
              items.isEmpty ? null : _buildBottomBar(context, cart),
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.white10),
          SizedBox(height: 20),
          Text(
            'Giỏ hàng của bạn đang trống',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(item.image,
                width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white)),
                Text('Size ${item.size}',
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
                if (item.drink.isNotEmpty)
                  Text('Đồ uống: ${item.drink}',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 10),
                Text(_formatCurrency(item.totalPrice),
                    style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined,
                color: Colors.redAccent),
            onPressed: () => CartManager().removeItem(index),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CartManager cart) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng cộng',
                    style: TextStyle(fontSize: 16, color: Colors.white54)),
                Text(_formatCurrency(cart.totalAmount),
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _handleCheckout(context, cart),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  cart.isLoggedIn
                      ? 'THANH TOÁN NGAY'
                      : 'ĐĂNG NHẬP ĐỂ THANH TOÁN',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
