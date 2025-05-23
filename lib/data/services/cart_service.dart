import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_project/data/models/product_model.dart';

/// Model class for cart items that includes product and quantity information
class CartItem {
  final Product product;
  int quantity;
  final DateTime addedAt;

  CartItem({
    required this.product,
    this.quantity = 1,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  /// Calculate total price for this cart item
  double get totalPrice => (product.price ?? 0.0) * quantity;

  /// Calculate discounted price if discount percentage is available
  double get discountedTotalPrice {
    if (product.discountPercentage != null && product.discountPercentage! > 0) {
      final discountAmount = totalPrice * (product.discountPercentage! / 100);
      return totalPrice - discountAmount;
    }
    return totalPrice;
  }

  /// Convert cart item to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  /// Create cart item from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.product.id == product.id;
  }

  @override
  int get hashCode => product.id.hashCode;
}

/// Service class for managing shopping cart functionality
/// Handles adding, removing, updating cart items and calculating totals
class CartService extends ChangeNotifier {
  // Private list to store cart items
  final List<CartItem> _cartItems = [];

  // Getters for cart data
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  int get itemCount => _cartItems.length;
  int get totalQuantity =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _cartItems.isEmpty;
  bool get isNotEmpty => _cartItems.isNotEmpty;

  /// Get total price of all items in cart (without discounts)
  double get totalPrice {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Get total discounted price of all items in cart
  double get totalDiscountedPrice {
    return _cartItems.fold(0.0, (sum, item) => sum + item.discountedTotalPrice);
  }

  /// Get total savings from discounts
  double get totalSavings {
    return totalPrice - totalDiscountedPrice;
  }

  /// Add product to cart or increase quantity if already exists
  void addToCart(Product product, {int quantity = 1}) {
    try {
      // Check if product already exists in cart
      final existingItemIndex = _cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingItemIndex != -1) {
        // Product already exists, increase quantity
        _cartItems[existingItemIndex].quantity += quantity;
      } else {
        // New product, add to cart
        _cartItems.add(CartItem(product: product, quantity: quantity));
      }

      // Notify listeners about cart changes
      notifyListeners();

      debugPrint('Added ${product.title} to cart. Quantity: $quantity');
    } catch (e) {
      debugPrint('Error adding product to cart: $e');
      rethrow;
    }
  }

  /// Remove product from cart completely
  void removeFromCart(int productId) {
    try {
      final removedItem =
          _cartItems.where((item) => item.product.id == productId).firstOrNull;
      _cartItems.removeWhere((item) => item.product.id == productId);

      notifyListeners();

      if (removedItem != null) {
        debugPrint('Removed ${removedItem.product.title} from cart');
      }
    } catch (e) {
      debugPrint('Error removing product from cart: $e');
      rethrow;
    }
  }

  /// Update quantity of a specific product in cart
  void updateQuantity(int productId, int newQuantity) {
    try {
      if (newQuantity <= 0) {
        removeFromCart(productId);
        return;
      }

      final itemIndex = _cartItems.indexWhere(
        (item) => item.product.id == productId,
      );

      if (itemIndex != -1) {
        _cartItems[itemIndex].quantity = newQuantity;
        notifyListeners();

        debugPrint(
            'Updated ${_cartItems[itemIndex].product.title} quantity to $newQuantity');
      }
    } catch (e) {
      debugPrint('Error updating product quantity: $e');
      rethrow;
    }
  }

  /// Increase quantity of a product by 1
  void incrementQuantity(int productId) {
    try {
      final itemIndex = _cartItems.indexWhere(
        (item) => item.product.id == productId,
      );

      if (itemIndex != -1) {
        _cartItems[itemIndex].quantity++;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error incrementing product quantity: $e');
      rethrow;
    }
  }

  /// Decrease quantity of a product by 1
  void decrementQuantity(int productId) {
    try {
      final itemIndex = _cartItems.indexWhere(
        (item) => item.product.id == productId,
      );

      if (itemIndex != -1) {
        if (_cartItems[itemIndex].quantity > 1) {
          _cartItems[itemIndex].quantity--;
          notifyListeners();
        } else {
          // Remove item if quantity becomes 0
          removeFromCart(productId);
        }
      }
    } catch (e) {
      debugPrint('Error decrementing product quantity: $e');
      rethrow;
    }
  }

  /// Clear all items from cart
  void clearCart() {
    try {
      _cartItems.clear();
      notifyListeners();
      debugPrint('Cart cleared');
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      rethrow;
    }
  }

  /// Check if a product is in the cart
  bool isInCart(int productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  /// Get quantity of a specific product in cart
  int getQuantity(int productId) {
    final item =
        _cartItems.where((item) => item.product.id == productId).firstOrNull;
    return item?.quantity ?? 0;
  }

  /// Get cart item by product ID
  CartItem? getCartItem(int productId) {
    return _cartItems.where((item) => item.product.id == productId).firstOrNull;
  }

  /// Get cart summary for checkout
  Map<String, dynamic> getCartSummary() {
    return {
      'totalItems': itemCount,
      'totalQuantity': totalQuantity,
      'subtotal': totalPrice,
      'totalDiscount': totalSavings,
      'finalTotal': totalDiscountedPrice,
      'items': _cartItems
          .map((item) => {
                'productId': item.product.id,
                'title': item.product.title,
                'quantity': item.quantity,
                'unitPrice': item.product.price,
                'totalPrice': item.totalPrice,
                'discountedPrice': item.discountedTotalPrice,
              })
          .toList(),
    };
  }

  /// Save cart to local storage (JSON string format)
  String saveCartToJson() {
    try {
      final cartData = {
        'items': _cartItems.map((item) => item.toJson()).toList(),
        'savedAt': DateTime.now().toIso8601String(),
      };
      return jsonEncode(cartData);
    } catch (e) {
      debugPrint('Error saving cart to JSON: $e');
      return '{}';
    }
  }

  /// Load cart from local storage (JSON string format)
  void loadCartFromJson(String jsonString) {
    try {
      if (jsonString.isEmpty) return;

      final cartData = jsonDecode(jsonString);
      _cartItems.clear();

      if (cartData['items'] != null) {
        for (var itemData in cartData['items']) {
          _cartItems.add(CartItem.fromJson(itemData));
        }
      }

      notifyListeners();
      debugPrint('Cart loaded from storage. Items: ${_cartItems.length}');
    } catch (e) {
      debugPrint('Error loading cart from JSON: $e');
      _cartItems.clear();
      notifyListeners();
    }
  }

  /// Get products sorted by date added (newest first)
  List<CartItem> getItemsSortedByDate() {
    final sortedItems = List<CartItem>.from(_cartItems);
    sortedItems.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return sortedItems;
  }

  /// Get products sorted by price (highest first)
  List<CartItem> getItemsSortedByPrice() {
    final sortedItems = List<CartItem>.from(_cartItems);
    sortedItems.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
    return sortedItems;
  }

  /// Get products sorted by name (A-Z)
  List<CartItem> getItemsSortedByName() {
    final sortedItems = List<CartItem>.from(_cartItems);
    sortedItems.sort(
        (a, b) => (a.product.title ?? '').compareTo(b.product.title ?? ''));
    return sortedItems;
  }

  /// Validate cart items (check for valid products and quantities)
  bool validateCart() {
    try {
      _cartItems.removeWhere((item) =>
          item.product.id == null ||
          item.quantity <= 0 ||
          item.product.price == null);

      if (_cartItems.isEmpty) {
        notifyListeners();
      }

      return _cartItems.isNotEmpty;
    } catch (e) {
      debugPrint('Error validating cart: $e');
      return false;
    }
  }

  /// Calculate estimated shipping cost (placeholder implementation)
  double calculateShippingCost() {
    if (isEmpty) return 0.0;

    // Free shipping for orders over $50
    if (totalDiscountedPrice > 50) return 0.0;

    // Flat rate shipping
    return 5.99;
  }

  /// Calculate estimated tax (placeholder implementation)
  double calculateTax({double taxRate = 0.08}) {
    return totalDiscountedPrice * taxRate;
  }

  /// Get final order total including shipping and tax
  double getFinalTotal({double taxRate = 0.08}) {
    return totalDiscountedPrice +
        calculateShippingCost() +
        calculateTax(taxRate: taxRate);
  }

  /// Get recently added items (last 5)
  List<CartItem> getRecentlyAddedItems({int limit = 5}) {
    final recentItems = getItemsSortedByDate();
    return recentItems.take(limit).toList();
  }

  @override
  void dispose() {
    _cartItems.clear();
    super.dispose();
  }
}
