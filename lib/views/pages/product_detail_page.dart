import 'package:flutter/material.dart';
import 'package:flutter_project/data/models/product_model.dart';
import 'package:flutter_project/data/services/cart_service.dart';

/// Product detail page widget that displays comprehensive product information
/// Features: Image gallery, product info, reviews, specifications, add to cart
/// Provides detailed view of a single product with all available information
class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> 
    with SingleTickerProviderStateMixin {
  
  late CartService _cartService;
  late TabController _tabController;
  int _selectedImageIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    // Initialize services and controllers
    _cartService = CartService();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Add product to cart with selected quantity
  void _addToCart() {
    _cartService.addToCart(widget.product, quantity: _quantity);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.title} added to cart'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ),
    );
  }

  /// Buy now functionality - navigate to checkout with current product
  void _buyNow() {
    _cartService.addToCart(widget.product, quantity: _quantity);
    Navigator.pushNamed(context, '/checkout');
  }

  /// Toggle favorite status
  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite 
            ? 'Added to favorites' 
            : 'Removed from favorites'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Calculate discounted price
  double get _discountedPrice {
    if (widget.product.price == null) return 0.0;
    if (widget.product.discountPercentage == null) return widget.product.price!;
    
    final discount = widget.product.price! * (widget.product.discountPercentage! / 100);
    return widget.product.price! - discount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      /// Custom app bar with back button and actions
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Favorite button
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.black87,
            ),
          ),
          // Share button
          IconButton(
            onPressed: () {
              // Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality not implemented')),
              );
            },
            icon: const Icon(Icons.share, color: Colors.black87),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
          /// Main content area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Product image gallery
                  _buildImageGallery(),
                  
                  /// Product information section
                  _buildProductInfo(),
                  
                  /// Tabbed content (Details, Reviews, Specifications)
                  _buildTabbedContent(),
                ],
              ),
            ),
          ),
          
          /// Bottom action bar with add to cart and buy now
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  /// Build image gallery with indicator dots
  Widget _buildImageGallery() {
    final images = widget.product.images ?? 
        (widget.product.thumbnail != null ? [widget.product.thumbnail!] : []);
    
    return Container(
      height: 300,
      color: Colors.grey[50],
      child: images.isEmpty 
          ? _buildPlaceholderImage()
          : Column(
              children: [
                /// Main image display
                Expanded(
                  child: PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() => _selectedImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            images[index],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderImage(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                /// Image indicator dots
                if (images.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: images.asMap().entries.map((entry) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedImageIndex == entry.key
                                ? Colors.blue
                                : Colors.grey[300],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
    );
  }

  /// Build placeholder for missing images
  Widget _buildPlaceholderImage() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 80,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// Build product information section
  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Product title and brand
          Text(
            widget.product.title ?? 'No Title',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          if (widget.product.brand != null) ...[
            const SizedBox(height: 8),
            Text(
              'by ${widget.product.brand}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          /// Rating and reviews
          Row(
            children: [
              if (widget.product.rating != null) ...[
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < widget.product.rating!.floor()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.product.rating!.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              
              if (widget.product.reviews != null)
                Text(
                  '(${widget.product.reviews!.length} reviews)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          /// Price section
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${_discountedPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              
              if (widget.product.discountPercentage != null && 
                  widget.product.discountPercentage! > 0) ...[
                const SizedBox(width: 12),
                Text(
                  '\$${widget.product.price!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${widget.product.discountPercentage!.toInt()}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          /// Stock status
          Row(
            children: [
              Icon(
                widget.product.stock != null && widget.product.stock! > 0
                    ? Icons.check_circle
                    : Icons.cancel,
                color: widget.product.stock != null && widget.product.stock! > 0
                    ? Colors.green
                    : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.product.stock != null && widget.product.stock! > 0
                    ? 'In Stock (${widget.product.stock} available)'
                    : 'Out of Stock',
                style: TextStyle(
                  color: widget.product.stock != null && widget.product.stock! > 0
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          /// Quantity selector
          Row(
            children: [
              const Text(
                'Quantity:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      icon: const Icon(Icons.remove, size: 18),
                      padding: const EdgeInsets.all(8),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _quantity++),
                      icon: const Icon(Icons.add, size: 18),
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build tabbed content section
  Widget _buildTabbedContent() {
    return Column(
      children: [
        /// Tab bar
        Container(
          color: Colors.grey[50],
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Reviews'),
              Tab(text: 'Specifications'),
            ],
          ),
        ),
        
        /// Tab content
        Container(
          height: 300,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDetailsTab(),
              _buildReviewsTab(),
              _buildSpecificationsTab(),
            ],
          ),
        ),
      ],
    );
  }

  /// Build product details tab
  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.description ?? 'No description available.',
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
          
          if (widget.product.tags != null && widget.product.tags!.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Tags',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.product.tags!.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// Build reviews tab
  Widget _buildReviewsTab() {
    if (widget.product.reviews == null || widget.product.reviews!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Be the first to review this product',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.product.reviews!.length,
      itemBuilder: (context, index) {
        final review = widget.product.reviews![index];
        return _buildReviewCard(review);
      },
    );
  }

  /// Build individual review card
  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                review.reviewerName ?? 'Anonymous',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              if (review.rating != null)
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating!
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
            ],
          ),
          if (review.date != null) ...[
            const SizedBox(height: 4),
            Text(
              _formatDate(review.date!),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            review.comment ?? '',
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  /// Build specifications tab
  Widget _buildSpecificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (widget.product.sku != null)
            _buildSpecRow('SKU', widget.product.sku!),
          
          if (widget.product.weight != null)
            _buildSpecRow('Weight', '${widget.product.weight} kg'),
          
          if (widget.product.dimensions != null) ...[
            _buildSpecRow('Width', '${widget.product.dimensions!.width} cm'),
            _buildSpecRow('Height', '${widget.product.dimensions!.height} cm'),
            _buildSpecRow('Depth', '${widget.product.dimensions!.depth} cm'),
          ],
          
          if (widget.product.warrantyInformation != null)
            _buildSpecRow('Warranty', widget.product.warrantyInformation!),
          
          if (widget.product.shippingInformation != null)
            _buildSpecRow('Shipping', widget.product.shippingInformation!),
          
          if (widget.product.returnPolicy != null)
            _buildSpecRow('Return Policy', widget.product.returnPolicy!),
          
          if (widget.product.minimumOrderQuantity != null)
            _buildSpecRow('Min Order Qty', '${widget.product.minimumOrderQuantity}'),
        ],
      ),
    );
  }

  /// Build specification row
  Widget _buildSpecRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  /// Build bottom action bar
  Widget _buildBottomActionBar() {
    final isOutOfStock = widget.product.stock == null || widget.product.stock! <= 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            /// Add to Cart button
            Expanded(
              child: OutlinedButton(
                onPressed: isOutOfStock ? null : _addToCart,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: isOutOfStock ? Colors.grey : Colors.blue,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isOutOfStock ? 'Out of Stock' : 'Add to Cart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isOutOfStock ? Colors.grey : Colors.blue,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            /// Buy Now button
            Expanded(
              child: ElevatedButton(
                onPressed: isOutOfStock ? null : _buyNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOutOfStock ? Colors.grey : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isOutOfStock ? 'Unavailable' : 'Buy Now',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}