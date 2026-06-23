import 'package:flutter/material.dart';
import 'package:project129/models/cart_item.dart';
import 'package:project129/screens/pizza_customization_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<_MenuCategory> _categories = const [
    _MenuCategory(
      name: 'Hot Deals',
      title: 'Combo đang cháy',
      subtitle: 'Ưu đãi nhiều topping, giá tốt cho nhóm bạn.',
      icon: Icons.local_fire_department_rounded,
      accent: Color(0xFFFFB000),
      image: 'assets/1.jpg',
    ),
    _MenuCategory(
      name: 'Classic',
      title: 'Pizza kinh điển',
      subtitle: 'Hương vị dễ ăn, phù hợp bữa trưa và gia đình.',
      icon: Icons.lunch_dining_rounded,
      accent: Color(0xFF4ADE80),
      image: 'assets/3.jpg',
    ),
    _MenuCategory(
      name: 'Gourmet',
      title: 'Dòng cao cấp',
      subtitle: 'Nguyên liệu nổi bật, đậm chất nhà hàng.',
      icon: Icons.workspace_premium_rounded,
      accent: Color(0xFFFF6B6B),
      image: 'assets/4.png',
    ),
    _MenuCategory(
      name: 'Drinks',
      title: 'Đồ uống mát lạnh',
      subtitle: 'Kết hợp cùng pizza để bữa ăn tròn vị.',
      icon: Icons.local_drink_rounded,
      accent: Color(0xFF38BDF8),
      image: 'assets/Coca-Cola.png',
    ),
  ];

  _MenuCategory get _activeCategory => _categories[_selectedCategory];

  String _formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (match) => "${match[1]}.")}đ';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartManager(),
      builder: (context, child) {
        final allItems = CartManager().availablePizzas;
        final query = _searchQuery.trim().toLowerCase();
        final visibleItems = allItems.where((item) {
          final matchesSearch = query.isEmpty ||
              item.name.toLowerCase().contains(query) ||
              item.desc.toLowerCase().contains(query);
          final matchesCategory = item.category == _activeCategory.name;
          return matchesSearch && matchesCategory;
        }).toList();

        final featured = visibleItems.isNotEmpty
            ? visibleItems.first
            : allItems.firstWhere(
                (item) => item.category == _activeCategory.name,
                orElse: () => allItems.first,
              );

        return Scaffold(
          backgroundColor: const Color(0xFF0B0D10),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHero()),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildCategoryTabs()),
              SliverToBoxAdapter(child: _buildCategorySpotlight(featured)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                  child: _buildSectionHeader(
                    query.isEmpty ? _activeCategory.title : 'Kết quả tìm kiếm',
                    '${visibleItems.length} món',
                  ),
                ),
              ),
              if (visibleItems.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState())
              else
                _buildMenuGrid(visibleItems),
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHero() {
    return Container(
      height: 330,
      decoration: const BoxDecoration(
        color: Color(0xFF111418),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
        image: DecorationImage(
          image: AssetImage('assets/Background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(34)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.25),
                      const Color(0xFF0B0D10).withOpacity(0.94),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 34,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPill(
                    icon: _activeCategory.icon,
                    label: 'Planet Pizza',
                    color: _activeCategory.accent,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pizza nóng,\ngiao nhanh.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      height: 1.04,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _activeCategory.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF161A20),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon:
                Icon(Icons.search_rounded, color: _activeCategory.accent),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    tooltip: 'Xóa tìm kiếm',
                    icon:
                        const Icon(Icons.close_rounded, color: Colors.white38),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            hintText: 'Tìm pizza, topping hoặc đồ uống...',
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 17),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 108,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? category.accent : const Color(0xFF15191F),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? category.accent
                      : Colors.white.withOpacity(0.07),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: category.accent.withOpacity(0.28),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    category.icon,
                    color: isSelected ? Colors.black : category.accent,
                    size: 28,
                  ),
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: _categories.length,
      ),
    );
  }

  Widget _buildCategorySpotlight(PizzaModel featured) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: GestureDetector(
        onTap: () => _openCustomization(featured),
        child: Container(
          height: 162,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF161A20),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _activeCategory.accent.withOpacity(0.22)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPill(
                      icon: Icons.star_rounded,
                      label: _activeCategory.title,
                      color: _activeCategory.accent,
                      compact: true,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      featured.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      featured.desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: Colors.white54, height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _activeCategory.accent.withOpacity(0.18),
                    ),
                  ),
                  Image.asset(
                    featured.image,
                    width: 118,
                    height: 118,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.local_pizza_rounded,
                      color: _activeCategory.accent,
                      size: 56,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverPadding _buildMenuGrid(List<PizzaModel> items) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildMenuCard(items[index], index),
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildMenuCard(PizzaModel item, int index) {
    final isDrink = item.category == 'Drinks';
    return GestureDetector(
      onTap: () => _openCustomization(item),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF15191F),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Hero(
                  tag: item.tag,
                  child: Image.asset(
                    item.image,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      isDrink
                          ? Icons.local_drink_rounded
                          : Icons.local_pizza_rounded,
                      color: _activeCategory.accent,
                      size: 70,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              item.desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 12, height: 1.3),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatCurrency(item.price),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _activeCategory.accent,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _activeCategory.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.black, size: 22),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 82, horizontal: 28),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded,
              size: 76, color: _activeCategory.accent.withOpacity(0.45)),
          const SizedBox(height: 18),
          const Text(
            'Không tìm thấy món phù hợp',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thử đổi từ khóa hoặc chọn một danh mục khác.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          action,
          style: TextStyle(
              color: _activeCategory.accent, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    required Color color,
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black, size: compact ? 14 : 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  void _openCustomization(PizzaModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PizzaCustomizationScreen(
          pizza: {
            'name': item.name,
            'desc': item.desc,
            'price': _formatCurrency(item.price),
            'image': item.image,
            'tag': item.tag,
            'category': item.category,
          },
        ),
      ),
    );
  }
}

class _MenuCategory {
  final String name;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String image;

  const _MenuCategory({
    required this.name,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.image,
  });
}
