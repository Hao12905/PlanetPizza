import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project129/models/cart_item.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  static const _gold = Color(0xFFD4AF37);
  static const _background = Color(0xFF0A0A0A);
  static const _panel = Color(0xFF1A1A1A);
  static const _web3FormsAccessKey = '54a64bae-6dc1-44ee-b5c9-22ed50966c34';

  @override
  void initState() {
    super.initState();
    final user = CartManager().currentUser;
    _nameController.text = user?.username ?? '';
    _phoneController.text = user?.phone ?? '';
    _emailController.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gửi Tin Nhắn Cho Chúng Tôi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        height: 1.12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Nếu bạn có bất kỳ câu hỏi nào về đơn hàng hoặc dịch vụ, hãy điền vào form dưới đây.',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 15,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _panel,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final twoColumns = constraints.maxWidth >= 620;
                              final nameField = _buildField(
                                label: 'Họ và tên',
                                controller: _nameController,
                                hint: 'Nguyễn Văn A',
                                requiredField: true,
                              );
                              final phoneField = _buildField(
                                label: 'Số điện thoại',
                                controller: _phoneController,
                                hint: '0901234567',
                                keyboardType: TextInputType.phone,
                                requiredField: true,
                              );

                              if (!twoColumns) {
                                return Column(
                                  children: [
                                    nameField,
                                    const SizedBox(height: 18),
                                    phoneField,
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: nameField),
                                  const SizedBox(width: 18),
                                  Expanded(child: phoneField),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                          _buildField(
                            label: 'Địa chỉ Email',
                            controller: _emailController,
                            hint: 'example@gmail.com',
                            keyboardType: TextInputType.emailAddress,
                            requiredField: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập email';
                              }
                              return value.contains('@')
                                  ? null
                                  : 'Email không hợp lệ';
                            },
                          ),
                          const SizedBox(height: 18),
                          _buildField(
                            label: 'Chủ đề cần hỗ trợ',
                            controller: _subjectController,
                            hint: 'Tư vấn đặt món, góp ý dịch vụ...',
                          ),
                          const SizedBox(height: 18),
                          _buildField(
                            label: 'Nội dung chi tiết',
                            controller: _messageController,
                            hint: 'Vui lòng nhập nội dung lời nhắn tại đây...',
                            requiredField: true,
                            maxLines: 5,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _gold,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Text(
                                      'GỬI YÊU CẦU LIÊN HỆ',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Yêu cầu sẽ được gửi trực tiếp về email của shop.',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool requiredField = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
            children: [
              if (requiredField)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.redAccent),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator ??
              (value) {
                if (!requiredField) return null;
                return value == null || value.trim().isEmpty
                    ? 'Vui lòng nhập thông tin'
                    : null;
              },
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30),
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _gold, width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final subject = _subjectController.text.trim().isEmpty
        ? 'Yêu cầu liên hệ Planet Pizza'
        : _subjectController.text.trim();
    final message = _messageController.text.trim();

    try {
      try {
        await CartManager().submitContactRequest(
          name: name,
          phone: phone,
          email: email,
          subject: subject,
          message: message,
        );
      } catch (_) {
        // Firestore is only a backup log; Web3Forms is the actual email sender.
      }

      final response = await http.post(
        Uri.parse('https://api.web3forms.com/submit'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'access_key': _web3FormsAccessKey,
          'name': name,
          'email': email,
          'phone': phone,
          'subject': subject,
          'message': message,
          'from_name': 'Planet Pizza App',
        }),
      );

      final data = _decodeWeb3FormsResponse(response.body);
      final success = response.statusCode == 200 && data['success'] == true;
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi yêu cầu liên hệ')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message']?.toString() ??
                  'Không thể gửi yêu cầu. Mã lỗi ${response.statusCode}.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Không thể gửi yêu cầu. Vui lòng kiểm tra kết nối mạng.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Map<String, dynamic> _decodeWeb3FormsResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return {
      'success': false,
      'message': body.trim().isEmpty
          ? 'Không thể gửi yêu cầu. Vui lòng thử lại.'
          : body.trim(),
    };
  }
}
