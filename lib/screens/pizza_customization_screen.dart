import 'package:flutter/material.dart';
import 'package:project129/models/cart_item.dart';

class PizzaCustomizationScreen extends StatefulWidget {
  final Map<String, dynamic> pizza; // Nhận dữ liệu pizza từ HomeScreen

  const PizzaCustomizationScreen({super.key, required this.pizza});

  @override
  State<PizzaCustomizationScreen> createState() =>
      _PizzaCustomizationScreenState();
}

class _PizzaCustomizationScreenState extends State<PizzaCustomizationScreen> {
  late String _selectedSize;
  final Set<String> _selectedToppings = {};
  String _selectedDrink = '';
  int _quantity = 1;
  bool get _isDrink => widget.pizza['category'] == 'Drinks';

  // Giá cơ bản lấy từ pizza truyền vào, hoặc mặc định
  late int _basePrice;

  final Map<String, double> _sizeMultipliers = {'S': 0.8, 'M': 1.0, 'L': 1.3};

  final List<Topping> _toppings = [
    Topping(name: 'Thêm phô mai', price: 15000),
    Topping(name: 'Xúc xích', price: 25000),
    Topping(name: 'Thịt xông khói', price: 30000),
  ];

  final List<Drink> _drinks = [
    Drink(name: '', label: 'Không chọn', icon: Icons.block_rounded),
    Drink(name: 'Coca-Cola', image: 'assets/Coca-Cola.png'),
    Drink(name: 'Pepsi', image: 'assets/Pepsi.png'),
    Drink(name: 'Sprite', image: 'assets/Sprite.png'),
    Drink(name: 'Nước Cam Ép', image: 'assets/Nuoccamep.png'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedSize = 'M';
    // Chuyển đổi giá từ chuỗi (ví dụ "249.000đ") sang số nguyên
    String priceStr = widget.pizza['price']
        .toString()
        .replaceAll('.', '')
        .replaceAll('đ', '')
        .replaceAll('Ä‘', '');
    _basePrice = int.tryParse(priceStr) ?? 200000;
  }

  int get _unitPrice {
    double price = _basePrice * (_sizeMultipliers[_selectedSize] ?? 1.0);
    for (var toppingName in _selectedToppings) {
      price += _toppings.firstWhere((t) => t.name == toppingName).price;
    }
    return price.toInt();
  }

  int get _totalPrice => _unitPrice * _quantity;

  String _formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}đ';
  }

  void _addToCart() {
    final newItem = CartItem(
      name: widget.pizza['name'],
      size: _selectedSize,
      toppings: _selectedToppings.toList(),
      drink: _selectedDrink,
      quantity: _quantity,
      totalPrice: _totalPrice,
      image: widget.pizza['image'],
    );

    CartManager().addItem(newItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Đã thêm $_quantity món ${widget.pizza['name']} vào giỏ hàng!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFD4AF37),
        duration: const Duration(seconds: 1),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHeaderImage(),
              _buildMainInfo(),
              if (!_isDrink) ...[
                _buildSectionTitle('Chọn kích thước'),
                _buildSizeSelector(),
                _buildSectionTitle('Thêm topping'),
                _buildToppingList(),
                _buildSectionTitle('Đồ uống dùng kèm'),
                _buildDrinkSelector(),
              ] else ...[
                _buildSectionTitle('Số lượng'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    'Đồ uống sẽ được thêm trực tiếp vào giỏ hàng, không cần chọn size hoặc topping.',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.55), height: 1.5),
                  ),
                ),
              ],
              const SizedBox(height: 120),
            ],
          ),
          _buildBackButton(),
        ],
      ),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  Widget _buildHeaderImage() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Center(
        child: Hero(
          tag: widget.pizza['tag'] ?? 'pizza_hero',
          child: Image.asset(widget.pizza['image'], width: 250),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.1),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfo() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(widget.pizza['name'],
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              _buildQuantitySelector(),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.pizza['desc'],
            style: const TextStyle(
                fontSize: 14, color: Colors.white54, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          IconButton(
              icon: const Icon(Icons.remove, size: 18, color: Colors.white),
              onPressed: () => setState(() {
                    if (_quantity > 1) _quantity--;
                  })),
          Text('$_quantity',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16)),
          IconButton(
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              onPressed: () => setState(() => _quantity++)),
        ],
      ),
    );
  }

  Widget _buildSizeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: ['S', 'M', 'L'].map((size) {
          final isSelected = _selectedSize == size;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSize = size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: isSelected
                          ? const Color(0xFFD4AF37)
                          : Colors.white10),
                ),
                child: Center(
                  child: Text(size,
                      style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildToppingList() {
    return Column(
      children: _toppings.map((topping) {
        final isSelected = _selectedToppings.contains(topping.name);
        return CheckboxListTile(
          value: isSelected,
          onChanged: (val) => setState(() => val!
              ? _selectedToppings.add(topping.name)
              : _selectedToppings.remove(topping.name)),
          title: Text(topping.name,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          subtitle: Text('+ ${_formatCurrency(topping.price)}',
              style: const TextStyle(color: Color(0xFFD4AF37))),
          activeColor: const Color(0xFFD4AF37),
          checkColor: Colors.black,
          controlAffinity: ListTileControlAffinity.trailing,
        );
      }).toList(),
    );
  }

  Widget _buildDrinkSelector() {
    return SizedBox(
      height: 125,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _drinks.length,
        itemBuilder: (context, index) {
          final drink = _drinks[index];
          final isSelected = _selectedDrink == drink.name;
          return GestureDetector(
            onTap: () => setState(() => _selectedDrink = drink.name),
            child: Container(
              width: 86,
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color:
                        isSelected ? const Color(0xFFD4AF37) : Colors.white10,
                    width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (drink.image != null)
                    Image.asset(drink.image!, height: 42)
                  else
                    Icon(drink.icon,
                        color: isSelected
                            ? const Color(0xFFD4AF37)
                            : Colors.white54,
                        size: 34),
                  const SizedBox(height: 8),
                  Text(
                    drink.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          isSelected ? const Color(0xFFD4AF37) : Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  const Text('Tổng thanh toán',
                      style: TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 5),
                  Text(_formatCurrency(_totalPrice),
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                ])),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: _addToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: const Text('THÊM GIỎ HÀNG',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 30, 25, 15),
      child: Text(title,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}

class Topping {
  final String name;
  final int price;
  Topping({required this.name, required this.price});
}

class Drink {
  final String name;
  final String label;
  final String? image;
  final IconData? icon;

  Drink({
    required this.name,
    String? label,
    this.image,
    this.icon,
  }) : label = label ?? name;
}
