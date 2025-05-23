import 'dart:convert';
import 'package:flutter_project/utils/url_constants.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

/// Service class for handling all product-related API operations
/// Provides methods for fetching, searching, and filtering products
class ProductService {
  // Cache for storing fetched products to reduce API calls
  List<Product>? _cachedProducts;
  DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 10);

  /// Fetch all products from the API
  /// Returns cached data if available and still valid
  Future<List<Product>> getAllProducts() async {
    try {
      // Return cached data if still valid
      if (_cachedProducts != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration) {
        return _cachedProducts!;
      }

      final response = await http.get(
        Uri.parse(UrlConstants.productUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['products'] != null) {
          List<Product> products = List<Product>.from(
            data['products'].map((item) => Product.fromJson(item)),
          );

          // Cache the fetched products
          _cachedProducts = products;
          _lastFetchTime = DateTime.now();

          return products;
        } else {
          throw Exception('Key "products" not found in the response');
        }
      } else {
        throw Exception('Failed to load products: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }

  /// Fetch a single product by ID
  Future<Product?> getProductById(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('${UrlConstants.productUrl}/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // Product not found
      } else {
        throw Exception('Failed to load product: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product by ID: $e');
      rethrow;
    }
  }

  /// Search products by query string
  /// Searches in title, description, brand, and tags
  Future<List<Product>> searchProducts(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllProducts();
      }

      final response = await http.get(
        Uri.parse(
            '${UrlConstants.productUrl}/search?q=${Uri.encodeComponent(query)}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['products'] != null) {
          List<Product> products = List<Product>.from(
            data['products'].map((item) => Product.fromJson(item)),
          );
          return products;
        } else {
          throw Exception('Key "products" not found in search response');
        }
      } else {
        throw Exception(
            'Failed to search products: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching products: $e');
      // Fallback to local search if API search fails
      return await _localSearch(query);
    }
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${UrlConstants.productUrl}/category/${Uri.encodeComponent(category)}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['products'] != null) {
          List<Product> products = List<Product>.from(
            data['products'].map((item) => Product.fromJson(item)),
          );
          return products;
        } else {
          throw Exception('Key "products" not found in category response');
        }
      } else {
        throw Exception(
            'Failed to load category products: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products by category: $e');
      // Fallback to local filtering if API call fails
      return await _localFilterByCategory(category);
    }
  }

  /// Get all available categories from products
  Future<List<String>> getCategories() async {
    try {
      final products = await getAllProducts();
      Set<String> categories = {};

      for (var product in products) {
        if (product.category != null) {
          categories.add(product.category!);
        }
        if (product.tags != null) {
          categories.addAll(product.tags!);
        }
      }

      return categories.toList()..sort();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  /// Get products with pagination
  Future<Map<String, dynamic>> getProductsWithPagination({
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${UrlConstants.productUrl}?limit=$limit&skip=$skip'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<Product> products = [];
        if (data['products'] != null) {
          products = List<Product>.from(
            data['products'].map((item) => Product.fromJson(item)),
          );
        }

        return {
          'products': products,
          'total': data['total'] ?? 0,
          'skip': data['skip'] ?? 0,
          'limit': data['limit'] ?? limit,
        };
      } else {
        throw Exception(
            'Failed to load paginated products: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching paginated products: $e');
      rethrow;
    }
  }

  /// Get featured or top-rated products
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    try {
      final allProducts = await getAllProducts();

      // Sort by rating and return top products
      final sortedProducts = List<Product>.from(allProducts);
      sortedProducts.sort((a, b) {
        final ratingA = a.rating ?? 0.0;
        final ratingB = b.rating ?? 0.0;
        return ratingB.compareTo(ratingA);
      });

      return sortedProducts.take(limit).toList();
    } catch (e) {
      print('Error fetching featured products: $e');
      return [];
    }
  }

  /// Local search fallback when API search fails
  Future<List<Product>> _localSearch(String query) async {
    try {
      final allProducts = await getAllProducts();
      final lowerQuery = query.toLowerCase();

      return allProducts.where((product) {
        return (product.title?.toLowerCase().contains(lowerQuery) ?? false) ||
            (product.description?.toLowerCase().contains(lowerQuery) ??
                false) ||
            (product.brand?.toLowerCase().contains(lowerQuery) ?? false) ||
            (product.tags
                    ?.any((tag) => tag.toLowerCase().contains(lowerQuery)) ??
                false);
      }).toList();
    } catch (e) {
      print('Error in local search: $e');
      return [];
    }
  }

  /// Local category filtering fallback
  Future<List<Product>> _localFilterByCategory(String category) async {
    try {
      final allProducts = await getAllProducts();

      return allProducts.where((product) {
        return product.category?.toLowerCase() == category.toLowerCase() ||
            (product.tags?.any(
                    (tag) => tag.toLowerCase() == category.toLowerCase()) ??
                false);
      }).toList();
    } catch (e) {
      print('Error in local category filtering: $e');
      return [];
    }
  }

  /// Clear cached data (useful for refresh functionality)
  void clearCache() {
    _cachedProducts = null;
    _lastFetchTime = null;
  }

  /// Check if cached data is available and valid
  bool get hasCachedData {
    return _cachedProducts != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;
  }

  /// Get the timestamp of last data fetch
  DateTime? get lastFetchTime => _lastFetchTime;

  /// Filter products by price range
  List<Product> filterByPriceRange(
      List<Product> products, double minPrice, double maxPrice) {
    return products.where((product) {
      final price = product.price ?? 0.0;
      return price >= minPrice && price <= maxPrice;
    }).toList();
  }

  /// Filter products by rating
  List<Product> filterByRating(List<Product> products, double minRating) {
    return products.where((product) {
      final rating = product.rating ?? 0.0;
      return rating >= minRating;
    }).toList();
  }

  /// Sort products by different criteria
  List<Product> sortProducts(List<Product> products, ProductSortBy sortBy) {
    final sortedProducts = List<Product>.from(products);

    switch (sortBy) {
      case ProductSortBy.priceAscending:
        sortedProducts
            .sort((a, b) => (a.price ?? 0.0).compareTo(b.price ?? 0.0));
        break;
      case ProductSortBy.priceDescending:
        sortedProducts
            .sort((a, b) => (b.price ?? 0.0).compareTo(a.price ?? 0.0));
        break;
      case ProductSortBy.ratingAscending:
        sortedProducts
            .sort((a, b) => (a.rating ?? 0.0).compareTo(b.rating ?? 0.0));
        break;
      case ProductSortBy.ratingDescending:
        sortedProducts
            .sort((a, b) => (b.rating ?? 0.0).compareTo(a.rating ?? 0.0));
        break;
      case ProductSortBy.nameAscending:
        sortedProducts.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
        break;
      case ProductSortBy.nameDescending:
        sortedProducts.sort((a, b) => (b.title ?? '').compareTo(a.title ?? ''));
        break;
    }

    return sortedProducts;
  }
}

/// Enum for different sorting options
enum ProductSortBy {
  priceAscending,
  priceDescending,
  ratingAscending,
  ratingDescending,
  nameAscending,
  nameDescending,
}
