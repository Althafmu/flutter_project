import 'package:flutter/material.dart';
import 'package:flutter_project/data/models/product_model.dart';
import 'package:flutter_project/data/services/cart_service.dart';

/// Highly responsive Product detail page optimized for web
/// Features: Enhanced image gallery, responsive product info, reviews, specifications
/// Breakpoints: Mobile (<600), Tablet (600-1024), Desktop (1024-1440), Large Desktop (>1440)
/// Web optimizations: Hover effects, better spacing, keyboard navigation
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

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  @override
  void initState() {
    super.initState();
    _cartService = CartService();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Responsive helpers
  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;
  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;
  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint &&
      MediaQuery.of(context).size.width < desktopBreakpoint;
  bool _isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  double _getMaxWidth(BuildContext context) {
    if (_isLargeDesktop(context)) return 1440;
    if (_isDesktop(context)) return 1200;
    if (_isTablet(context)) return 1024;
    return double.infinity;
  }

  EdgeInsets _getPagePadding(BuildContext context) {
    if (_isLargeDesktop(context))
      return const EdgeInsets.symmetric(horizontal: 48);
    if (_isDesktop(context)) return const EdgeInsets.symmetric(horizontal: 32);
    if (_isTablet(context)) return const EdgeInsets.symmetric(horizontal: 24);
    return const EdgeInsets.symmetric(horizontal: 16);
  }

  /// Add product to cart with selected quantity
  void _addToCart() {
    _cartService.addToCart(widget.product, quantity: _quantity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.title} added to cart'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(_isMobile(context) ? 16 : 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ),
    );
  }

  void _buyNow() {
    _cartService.addToCart(widget.product, quantity: _quantity);
    Navigator.pushNamed(context, '/checkout');
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(_isMobile(context) ? 16 : 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  double get _discountedPrice {
    if (widget.product.price == null) return 0.0;
    if (widget.product.discountPercentage == null) return widget.product.price!;

    final discount =
        widget.product.price! * (widget.product.discountPercentage! / 100);
    return widget.product.price! - discount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: _getMaxWidth(context)),
                  padding: _getPagePadding(context),
                  child: _buildResponsiveLayout(context),
                ),
              ),
            ),
          ),
          _buildBottomActionBar(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Back',
      ),
      title: _isMobile(context)
          ? null
          : Text(
              widget.product.title ?? 'Product Details',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
      actions: [
        // Favorite button with hover effect
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _toggleFavorite,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.black54,
                size: 24,
              ),
            ),
          ),
        ),
        // Share button
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality not implemented'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.share, color: Colors.black54, size: 24),
            ),
          ),
        ),
        SizedBox(width: _isMobile(context) ? 8 : 16),
      ],
    );
  }

  Widget _buildResponsiveLayout(BuildContext context) {
    if (_isMobile(context)) {
      return _buildMobileLayout(context);
    } else if (_isTablet(context)) {
      return _buildTabletLayout(context);
    } else {
      return _buildDesktopLayout(context);
    }
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildImageGallery(context),
        const SizedBox(height: 16),
        _buildProductInfo(context),
        const SizedBox(height: 24),
        _buildTabbedContent(context),
        const SizedBox(height: 100), // Space for bottom bar
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: _buildImageGallery(context),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 5,
              child: _buildProductInfo(context),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildTabbedContent(context),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: _isLargeDesktop(context) ? 5 : 6,
              child: _buildImageGallery(context),
            ),
            SizedBox(width: _isLargeDesktop(context) ? 48 : 32),
            Expanded(
              flex: _isLargeDesktop(context) ? 4 : 5,
              child: _buildProductInfo(context),
            ),
          ],
        ),
        const SizedBox(height: 40),
        _buildTabbedContent(context),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    final images = widget.product.images ??
        (widget.product.thumbnail != null ? [widget.product.thumbnail!] : []);

    double height;
    if (_isMobile(context)) {
      height = 280;
    } else if (_isTablet(context)) {
      height = 400;
    } else if (_isDesktop(context)) {
      height = 500;
    } else {
      height = 600;
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: images.isEmpty
          ? _buildPlaceholderImage(context)
          : Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() => _selectedImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.all(_isMobile(context) ? 16 : 24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            images[index],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderImage(context),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (images.length > 1)
                  _buildImageIndicators(context, images.length),
              ],
            ),
    );
  }

  Widget _buildImageIndicators(BuildContext context, int count) {
    return Padding(
      padding: EdgeInsets.only(bottom: _isMobile(context) ? 16 : 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final isSelected = _selectedImageIndex == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 12 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isSelected ? Colors.blue : Colors.grey[300],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(_isMobile(context) ? 16 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: _isMobile(context) ? 60 : 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              'No Image Available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: _isMobile(context) ? 14 : 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_isMobile(context) ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductTitle(context),
          _buildProductBrand(context),
          const SizedBox(height: 16),
          _buildRatingSection(context),
          const SizedBox(height: 20),
          _buildPriceSection(context),
          const SizedBox(height: 20),
          _buildStockStatus(context),
          const SizedBox(height: 24),
          _buildQuantitySelector(context),
        ],
      ),
    );
  }

  Widget _buildProductTitle(BuildContext context) {
    double fontSize;
    if (_isMobile(context)) {
      fontSize = 22;
    } else if (_isTablet(context)) {
      fontSize = 26;
    } else if (_isDesktop(context)) {
      fontSize = 30;
    } else {
      fontSize = 34;
    }

    return Text(
      widget.product.title ?? 'No Title',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        height: 1.2,
      ),
    );
  }

  Widget _buildProductBrand(BuildContext context) {
    if (widget.product.brand == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        'by ${widget.product.brand}',
        style: TextStyle(
          fontSize: _isMobile(context) ? 16 : 18,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    if (widget.product.rating == null) return const SizedBox.shrink();

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Icon(
              index < widget.product.rating!.floor()
                  ? Icons.star
                  : index < widget.product.rating!
                      ? Icons.star_half
                      : Icons.star_border,
              color: Colors.amber,
              size: _isMobile(context) ? 18 : 20,
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          '${widget.product.rating!.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: _isMobile(context) ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (widget.product.reviews != null) ...[
          const SizedBox(width: 12),
          Text(
            '(${widget.product.reviews!.length} reviews)',
            style: TextStyle(
              fontSize: _isMobile(context) ? 12 : 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    double mainPriceSize;
    double originalPriceSize;

    if (_isMobile(context)) {
      mainPriceSize = 26;
      originalPriceSize = 16;
    } else if (_isTablet(context)) {
      mainPriceSize = 30;
      originalPriceSize = 18;
    } else {
      mainPriceSize = 34;
      originalPriceSize = 20;
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 12,
      children: [
        Text(
          '\$${_discountedPrice.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: mainPriceSize,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        if (widget.product.discountPercentage != null &&
            widget.product.discountPercentage! > 0) ...[
          Text(
            '\$${widget.product.price!.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: originalPriceSize,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey[500],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
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
    );
  }

  Widget _buildStockStatus(BuildContext context) {
    final inStock = widget.product.stock != null && widget.product.stock! > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: inStock ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: inStock ? Colors.green[200]! : Colors.red[200]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            inStock ? Icons.check_circle : Icons.cancel,
            color: inStock ? Colors.green[700] : Colors.red[700],
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            inStock
                ? 'In Stock (${widget.product.stock} available)'
                : 'Out of Stock',
            style: TextStyle(
              color: inStock ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.w600,
              fontSize: _isMobile(context) ? 14 : 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(BuildContext context) {
    return Row(
      children: [
        Text(
          'Quantity:',
          style: TextStyle(
            fontSize: _isMobile(context) ? 16 : 18,
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
              _buildQuantityButton(
                icon: Icons.remove,
                onPressed:
                    _quantity > 1 ? () => setState(() => _quantity--) : null,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _isMobile(context) ? 16 : 20,
                  vertical: 8,
                ),
                child: Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildQuantityButton(
                icon: Icons.add,
                onPressed: () => setState(() => _quantity++),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 18,
            color: onPressed != null ? Colors.black87 : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildTabbedContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue,
              indicatorWeight: 3,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: _isMobile(context) ? 14 : 16,
              ),
              tabs: const [
                Tab(text: 'Details'),
                Tab(text: 'Reviews'),
                Tab(text: 'Specifications'),
              ],
            ),
          ),
          Container(
            height: _isMobile(context) ? 300 : 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(context),
                _buildReviewsTab(context),
                _buildSpecificationsTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isMobile(context) ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: _isMobile(context) ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.description ?? 'No description available.',
            style: TextStyle(
              fontSize: _isMobile(context) ? 14 : 16,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          if (widget.product.tags != null &&
              widget.product.tags!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Tags',
              style: TextStyle(
                fontSize: _isMobile(context) ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.product.tags!.map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: _isMobile(context) ? 12 : 14,
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

  Widget _buildReviewsTab(BuildContext context) {
    if (widget.product.reviews == null || widget.product.reviews!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: _isMobile(context) ? 48 : 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: _isMobile(context) ? 16 : 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Be the first to review this product',
              style: TextStyle(
                fontSize: _isMobile(context) ? 12 : 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(_isMobile(context) ? 16 : 24),
      itemCount: widget.product.reviews!.length,
      itemBuilder: (context, index) {
        final review = widget.product.reviews![index];
        return _buildReviewCard(context, review);
      },
    );
  }

  Widget _buildReviewCard(BuildContext context, Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(_isMobile(context) ? 16 : 20),
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
              Expanded(
                child: Text(
                  review.reviewerName ?? 'Anonymous',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: _isMobile(context) ? 14 : 16,
                  ),
                ),
              ),
              if (review.rating != null)
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating! ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: _isMobile(context) ? 14 : 16,
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
                fontSize: _isMobile(context) ? 11 : 12,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            review.comment ?? '',
            style: TextStyle(
              fontSize: _isMobile(context) ? 13 : 14,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isMobile(context) ? 16 : 24),
      child: Column(
        children: [
          if (widget.product.sku != null)
            _buildSpecRow(context, 'SKU', widget.product.sku!),
          if (widget.product.weight != null)
            _buildSpecRow(context, 'Weight', '${widget.product.weight} kg'),
          if (widget.product.dimensions != null) ...[
            _buildSpecRow(
                context, 'Width', '${widget.product.dimensions!.width} cm'),
            _buildSpecRow(
                context, 'Height', '${widget.product.dimensions!.height} cm'),
            _buildSpecRow(
                context, 'Depth', '${widget.product.dimensions!.depth} cm'),
          ],
          if (widget.product.warrantyInformation != null)
            _buildSpecRow(
                context, 'Warranty', widget.product.warrantyInformation!),
          if (widget.product.shippingInformation != null)
            _buildSpecRow(
                context, 'Shipping', widget.product.shippingInformation!),
          if (widget.product.returnPolicy != null)
            _buildSpecRow(
                context, 'Return Policy', widget.product.returnPolicy!),
          if (widget.product.minimumOrderQuantity != null)
            _buildSpecRow(context, 'Min Order Qty',
                '${widget.product.minimumOrderQuantity}'),
        ],
      ),
    );
  }

  Widget _buildSpecRow(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _isMobile(context) ? 100 : 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: _isMobile(context) ? 14 : 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
                fontSize: _isMobile(context) ? 14 : 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final isOutOfStock =
        widget.product.stock == null || widget.product.stock! <= 0;

    return Container(
      padding: EdgeInsets.all(_isMobile(context) ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: _getMaxWidth(context)),
            child: _isMobile(context)
                ? _buildMobileActionButtons(context, isOutOfStock)
                : _buildDesktopActionButtons(context, isOutOfStock),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileActionButtons(BuildContext context, bool isOutOfStock) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Price summary for mobile
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total:\$ ${(_discountedPrice * _quantity).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Qty: $_quantity',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context: context,
                text: isOutOfStock ? 'Out of Stock' : 'Add to Cart',
                onPressed: isOutOfStock ? null : _addToCart,
                isPrimary: false,
                isOutOfStock: isOutOfStock,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context: context,
                text: isOutOfStock ? 'Unavailable' : 'Buy Now',
                onPressed: isOutOfStock ? null : _buyNow,
                isPrimary: true,
                isOutOfStock: isOutOfStock,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopActionButtons(BuildContext context, bool isOutOfStock) {
    return Row(
      children: [
        // Price and quantity info
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total: ${(_discountedPrice * _quantity).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: _isLargeDesktop(context) ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Quantity: $_quantity × ${_discountedPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Action buttons
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context: context,
                  text: isOutOfStock ? 'Out of Stock' : 'Add to Cart',
                  onPressed: isOutOfStock ? null : _addToCart,
                  isPrimary: false,
                  isOutOfStock: isOutOfStock,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  context: context,
                  text: isOutOfStock ? 'Unavailable' : 'Buy Now',
                  onPressed: isOutOfStock ? null : _buyNow,
                  isPrimary: true,
                  isOutOfStock: isOutOfStock,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String text,
    required VoidCallback? onPressed,
    required bool isPrimary,
    required bool isOutOfStock,
  }) {
    final buttonHeight = _isMobile(context) ? 48.0 : 52.0;
    final fontSize = _isMobile(context) ? 16.0 : 18.0;

    if (isPrimary) {
      return SizedBox(
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isOutOfStock ? Colors.grey[400] : Colors.blue,
            foregroundColor: Colors.white,
            elevation: isOutOfStock ? 0 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        height: buttonHeight,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isOutOfStock ? Colors.grey[400]! : Colors.blue,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: isOutOfStock ? Colors.grey[600] : Colors.blue,
            ),
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
