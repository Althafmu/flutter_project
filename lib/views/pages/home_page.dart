import 'package:flutter/material.dart';
import 'package:flutter_project/data/models/product_model.dart';
import 'package:flutter_project/data/services/product_service.dart';
import 'product_detail_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';

/// Responsive home page widget that adapts to different screen sizes
/// Optimized for mobile, tablet, and desktop viewing
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controllers and state variables
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  /// Load products from service and initialize categories
  Future<void> _loadProducts() async {
    try {
      setState(() => _isLoading = true);

      // Fetch products from service
      _allProducts = await _productService.getAllProducts();
      _filteredProducts = _allProducts;

      // Extract unique categories from product tags
      Set<String> categorySet = {'All'};
      for (var product in _allProducts) {
        if (product.tags != null) {
          categorySet.addAll(product.tags!);
        }
      }
      _categories = categorySet.toList();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error - show snackbar or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    }
  }

  /// Filter products based on search query and selected category
  void _filterProducts() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredProducts = _allProducts.where((product) {
        // Check if product matches search query
        bool matchesSearch = query.isEmpty ||
            (product.title?.toLowerCase().contains(query) ?? false) ||
            (product.description?.toLowerCase().contains(query) ?? false) ||
            (product.brand?.toLowerCase().contains(query) ?? false);

        // Check if product matches selected category
        bool matchesCategory = _selectedCategory == 'All' ||
            (product.tags?.contains(_selectedCategory) ?? false);

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  /// Handle category selection
  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterProducts();
  }

  /// Navigate to product detail page
  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product),
      ),
    );
  }

  /// Navigate to cart page
  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartPage()),
    );
  }

  /// Navigate to profile page
  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  /// Get responsive breakpoints
  bool get isMobile => MediaQuery.of(context).size.width < 600;
  bool get isTablet =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;
  bool get isDesktop => MediaQuery.of(context).size.width >= 1200;

  /// Get responsive grid columns based on screen size
  int get crossAxisCount {
    if (isDesktop) return 4;
    if (isTablet) return 3;
    return 2;
  }

  /// Get responsive child aspect ratio
  double get childAspectRatio {
    if (isDesktop) return 0.8;
    if (isTablet) return 0.75;
    return 0.7;
  }

  /// Get responsive padding
  EdgeInsets get responsivePadding {
    if (isDesktop) return const EdgeInsets.symmetric(horizontal: 32);
    if (isTablet) return const EdgeInsets.symmetric(horizontal: 24);
    return const EdgeInsets.symmetric(horizontal: 16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      /// Responsive app bar that adapts to screen size
      appBar: _buildResponsiveAppBar(),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : isDesktop
              ? _buildDesktopLayout()
              : _buildMobileTabletLayout(),
    );
  }

  /// Build responsive app bar
  PreferredSizeWidget _buildResponsiveAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      toolbarHeight: isDesktop ? 80 : 56,
      title: Row(
        children: [
          Text(
            'Buyit',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: isDesktop ? 28 : 24,
            ),
          ),
          // Desktop search bar in app bar
          if (isDesktop) ...[
            const SizedBox(width: 48),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: _buildSearchBar(),
              ),
            ),
          ],
        ],
      ),
      actions: [
        // Desktop navigation items
        if (isDesktop) ...[
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.category_outlined, color: Colors.black87),
            label: const Text('Categories',
                style: TextStyle(color: Colors.black87)),
          ),
          const SizedBox(width: 16),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.local_offer_outlined, color: Colors.black87),
            label: const Text('Deals', style: TextStyle(color: Colors.black87)),
          ),
          const SizedBox(width: 16),
        ],

        // Cart icon with badge
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: Colors.black87,
                size: isDesktop ? 28 : 24,
              ),
              onPressed: _navigateToCart,
            ),
            if (_cartItemCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$_cartItemCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),

        // Profile icon
        IconButton(
          icon: Icon(
            Icons.person_outline,
            color: Colors.black87,
            size: isDesktop ? 28 : 24,
          ),
          onPressed: _navigateToProfile,
        ),
        SizedBox(width: isDesktop ? 24 : 8),
      ],
    );
  }

  /// Build desktop layout with sidebar
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Desktop sidebar
        Container(
          width: 280,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Categories section
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.blue[800]
                                : Colors.grey[700],
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: Colors.blue[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onTap: () => _onCategorySelected(category),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Main content area
        Expanded(
          child: Column(
            children: [
              // Search bar for desktop (if not in app bar)
              if (!isDesktop)
                Container(
                  color: Colors.white,
                  padding: responsivePadding.copyWith(top: 16, bottom: 16),
                  child: _buildSearchBar(),
                ),

              // Products grid
              Expanded(
                child: _buildProductsGrid(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build mobile/tablet layout
  Widget _buildMobileTabletLayout() {
    return Column(
      children: [
        /// Search bar section
        Container(
          color: Colors.white,
          padding: responsivePadding.copyWith(top: 16, bottom: 16),
          child: _buildSearchBar(),
        ),

        /// Horizontal scrolling categories
        Container(
          height: isTablet ? 60 : 50,
          color: Colors.white,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: responsivePadding,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) => _onCategorySelected(category),
                  backgroundColor: Colors.grey[100],
                  selectedColor: Colors.blue[100],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.blue[800] : Colors.grey[700],
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        /// Products grid
        Expanded(child: _buildProductsGrid()),
      ],
    );
  }

  /// Build reusable search bar
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => _filterProducts(),
      decoration: InputDecoration(
        hintText: 'Search products...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  _filterProducts();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  /// Build responsive products grid
  Widget _buildProductsGrid() {
    if (_filteredProducts.isEmpty) {
      return const Center(
        child: Text(
          'No products found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: responsivePadding.copyWith(bottom: 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: isDesktop ? 24 : 16,
        mainAxisSpacing: isDesktop ? 24 : 16,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  /// Build responsive product card widget
  Widget _buildProductCard(Product product) {
    // Calculate discounted price
    double getDiscountedPrice() {
      if (product.price == null) return 0.0;
      if (product.discountPercentage == null) return product.price!;

      final discount = product.price! * (product.discountPercentage! / 100);
      return product.price! - discount;
    }

    final discountedPrice = getDiscountedPrice();
    final hasDiscount =
        product.discountPercentage != null && product.discountPercentage! > 0;

    return GestureDetector(
      onTap: () => _navigateToProductDetail(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Product image with hover effect on desktop and discount badge
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(isDesktop ? 16 : 12),
                        ),
                        color: Colors.grey[100],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(isDesktop ? 16 : 12),
                        ),
                        child: product.thumbnail != null
                            ? Image.network(
                                product.thumbnail!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported,
                                        size: 50, color: Colors.grey),
                              )
                            : const Icon(Icons.image_not_supported,
                                size: 50, color: Colors.grey),
                      ),
                    ),
                  ),

                  /// Discount badge
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${product.discountPercentage!.toInt()}% OFF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isDesktop ? 12 : 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            /// Product details with responsive padding
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 16 : 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Product title with responsive font size
                    Text(
                      product.title ?? 'No Title',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isDesktop ? 16 : 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    /// Product brand
                    if (product.brand != null)
                      Text(
                        product.brand!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isDesktop ? 14 : 12,
                        ),
                      ),

                    const Spacer(),

                    /// Price and rating row with responsive layout
                    if (isDesktop)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Price section with discount
                          if (hasDiscount)
                            Row(
                              children: [
                                Text(
                                  '\$${discountedPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '\$${product.price!.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              '\$${product.price?.toStringAsFixed(2) ?? '0.00'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.green,
                              ),
                            ),

                          const SizedBox(height: 4),

                          /// Rating
                          if (product.rating != null)
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  product.rating!.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Price section with discount for mobile
                          if (hasDiscount)
                            Row(
                              children: [
                                Text(
                                  '\$${discountedPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '\$${product.price!.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              '\$${product.price?.toStringAsFixed(2) ?? '0.00'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),

                          const SizedBox(height: 4),

                          /// Rating
                          if (product.rating != null)
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  product.rating!.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
