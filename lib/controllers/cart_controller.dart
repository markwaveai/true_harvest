// lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:task_new/models/cart_item.dart';
import 'package:task_new/models/product_model.dart';

final cartProvider = ChangeNotifierProvider<CartProvider>(
  (ref) => CartProvider(),
);

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get subtotal => totalPrice;

  int get itemCount => _items.length;

  // Clear all items from cart
  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
  }

  void addToCart(Product product, String unit) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id && item.selectedUnit == unit,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product, selectedUnit: unit, quantity: 1));
    }
    notifyListeners();
  }

  void removeFromCart(String productId, String unit) {
    _items.removeWhere(
      (item) => item.product.id == productId && item.selectedUnit == unit,
    );
    notifyListeners();
  }

  // In cart_controller.dart
  void updateQuantity(Product products, String unit, int newQuantity) {
    final index = _items.indexWhere(
      (item) => item.product.id == products.id && item.selectedUnit == unit,
    );

    if (index >= 0) {
      // Update existing item
      if (newQuantity > 0) {
        _items[index] = _items[index].copyWith(quantity: newQuantity);
      } else {
        _items.removeAt(index);
      }
    } else if (newQuantity > 0) {
      // Add new item if it doesn't exist
      // You'll need to get the product from your products list
      // For now, we'll use a placeholder product
      final product = Product(
        id: products.id,
        category: products.category,
        name: products.name,
        imageUrl: products.imageUrl,
        isFavorite: products.isFavorite,
        description: products.description,
        features: products.features,
        units: products.units,
      );

      _items.add(
        CartItem(product: product, selectedUnit: unit, quantity: newQuantity),
      );
    }
    notifyListeners();
  }

  // Buy Now functionality - clears cart and adds only the specified product
  Future<void> buyNow(Product product, String unit, int quantity) async {
    // Clear existing cart
    await clearCart();
    
    // Add only the specified product with the given quantity
    updateQuantity(product, unit, quantity);
  }
}
