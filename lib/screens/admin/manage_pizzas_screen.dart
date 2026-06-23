import 'package:flutter/material.dart';
import 'package:project129/models/cart_item.dart';

class ManagePizzasScreen extends StatelessWidget {
  const ManagePizzasScreen({super.key});

  void _showAddPizzaDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final imageController = TextEditingController(text: 'assets/1.png');
    String selectedCategory = 'Classic'; // Danh mục mặc định

    final List<String> categories = ['Hot Deals', 'Classic', 'Gourmet', 'Drinks'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Thêm món mới', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(nameController, 'Tên món'),
                _buildTextField(descController, 'Mô tả'),
                _buildTextField(priceController, 'Giá (VNĐ)', isNumber: true),
                _buildTextField(imageController, 'Đường dẫn ảnh (assets/...)'),
                const SizedBox(height: 15),
                const Text('Chọn danh mục:', style: TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    dropdownColor: const Color(0xFF1A1A1A),
                    isExpanded: true,
                    underline: const SizedBox(),
                    style: const TextStyle(color: Colors.white),
                    items: categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setDialogState(() {
                        selectedCategory = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
              onPressed: () {
                if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                  final newPizza = PizzaModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    desc: descController.text,
                    price: int.tryParse(priceController.text) ?? 0,
                    image: imageController.text,
                    tag: 'pizza_${DateTime.now().millisecondsSinceEpoch}',
                    category: selectedCategory, // Đã truyền thêm category
                  );
                  CartManager().addPizza(newPizza);
                  Navigator.pop(context);
                }
              },
              child: const Text('Thêm', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Quản lý món ăn', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFFD4AF37)),
            onPressed: () => _showAddPizzaDialog(context),
          )
        ],
      ),
      body: ListenableBuilder(
        listenable: CartManager(),
        builder: (context, child) {
          final pizzas = CartManager().availablePizzas;
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: pizzas.length,
            itemBuilder: (context, index) {
              final pizza = pizzas[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(pizza.image, width: 50, height: 50, fit: BoxFit.cover, 
                      errorBuilder: (_, __, ___) => const Icon(Icons.local_pizza, color: Colors.white24)),
                  ),
                  title: Text(pizza.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('${pizza.price}đ - ${pizza.category}', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => CartManager().removePizza(pizza.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
