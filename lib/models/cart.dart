import 'package:flutter/foundation.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';

class CartItem {
  final Sandwich sandwich;
  int quantity;

  CartItem({
    required this.sandwich,
    this.quantity = 1,
  });
}

class Cart extends ChangeNotifier {
  final PricingRepository _pricingRepository;
  final List<CartItem> _items = [];

  Cart({PricingRepository? pricingRepository})
      : _pricingRepository = pricingRepository ?? PricingRepository();

  /// Read-only view of items so outside code can’t mutate the list.
  List<CartItem> get items => List.unmodifiable(_items);

  /// Add a sandwich (or increase quantity if same sandwich already exists).
  void add(Sandwich sandwich, {int quantity = 1}) {
    final int index = _items.indexWhere(
      (item) =>
          item.sandwich.type == sandwich.type &&
          item.sandwich.isFootlong == sandwich.isFootlong &&
          item.sandwich.breadType == sandwich.breadType,
    );

    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(sandwich: sandwich, quantity: quantity));
    }

    notifyListeners();
  }

  /// Remove quantity of a sandwich, or remove the line if it reaches 0.
  void remove(Sandwich sandwich, {int quantity = 1}) {
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      final bool same = item.sandwich.type == sandwich.type &&
          item.sandwich.isFootlong == sandwich.isFootlong &&
          item.sandwich.breadType == sandwich.breadType;

      if (same) {
        item.quantity -= quantity;
        if (item.quantity <= 0) {
          _items.removeAt(i);
        }
        notifyListeners();
        break;
      }
    }
  }

  /// Clear the cart.
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Total number of units (e.g. 2x A + 3x B = 5).
  int get totalItems => _items.fold<int>(0, (sum, item) => sum + item.quantity);

  /// Alias used in worksheet/tests sometimes.
  int get countOfItems => totalItems;

  /// Is the cart empty?
  bool get isEmpty => _items.isEmpty;

  /// Number of distinct lines.
  int get length => _items.length;

  /// Get quantity of a specific sandwich (0 if not present).
  int getQuantity(Sandwich sandwich) {
    final int index = _items.indexWhere(
      (item) =>
          item.sandwich.type == sandwich.type &&
          item.sandwich.isFootlong == sandwich.isFootlong &&
          item.sandwich.breadType == sandwich.breadType,
    );
    if (index == -1) {
      return 0;
    }
    return _items[index].quantity;
  }

  /// Total price of all items in the cart.
  double get totalPrice {
    double total = 0;
    for (final item in _items) {
      total += _pricingRepository.calculatePrice(
        quantity: item.quantity,
        isFootlong: item.sandwich.isFootlong,
      );
    }
    return total;
  }

  /// Helper: price for one line (used in CartScreen).
  double calculatePriceFor(CartItem item) {
    return _pricingRepository.calculatePrice(
      quantity: item.quantity,
      isFootlong: item.sandwich.isFootlong,
    );
  }
}
