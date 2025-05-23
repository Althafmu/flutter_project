import 'package:flutter/material.dart';
import 'package:flutter_project/data/models/product_model.dart';
import 'package:flutter_project/data/services/product_service.dart';
import 'package:flutter_project/views/pages/cart_page.dart';
import 'package:flutter_project/views/pages/product_detail_page.dart';
import 'profile_page.dart';

/// Home page widget that displays the main interface of the app
/// Contains app bar, search functionality, categories, and product grid
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
      MaterialPageRoute(builder: (context) => CartPage()),
    );
  }

  /// Navigate to profile page
  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      /// Custom app bar with app name and action buttons
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'BuyIt',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          // Cart icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: Colors.black87),
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
            icon: const Icon(Icons.person_outline, color: Colors.black87),
            onPressed: _navigateToProfile,
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// Search bar section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: TextField(
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
                  ),
                ),

                /// Horizontal scrolling categories
                Container(
                  height: 50,
                  color: Colors.white,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) =>
                              _onCategorySelected(category),
                          backgroundColor: Colors.grey[100],
                          selectedColor: Colors.blue[100],
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.blue[800]
                                : Colors.grey[700],
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                /// Products grid
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? const Center(
                          child: Text(
                            'No products found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return _buildProductCard(product);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  /// Build individual product card widget
  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => _navigateToProductDetail(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            /// Product image
            Expanded(
              flex: 4, // Increased flex for image
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
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

            /// Product details - Using Container with fixed height instead of Expanded
            Container(
              height: 105, // Fixed height for text content
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Product title - More space allocated
                  Flexible(
                    flex: 3,
                    child: Text(
                      product.title ?? 'No Title',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13, // Slightly smaller font
                        height: 1.2, // Better line height
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// Product brand - Constrained height
                  if (product.brand != null)
                    Flexible(
                      flex: 1,
                      child: Text(
                        product.brand!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  const Spacer(),

                  /// Price and rating row - Fixed at bottom
                  SizedBox(
                    height: 20, // Fixed height for price/rating row
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// Price
                        Flexible(
                          flex: 2,
                          child: Text(
                            '\$${product.price?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.green,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 8),

                        /// Rating
                        if (product.rating != null)
                          Flexible(
                            flex: 1,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 14),
                                const SizedBox(width: 2),
                                Text(
                                  product.rating!.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                      ],
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
