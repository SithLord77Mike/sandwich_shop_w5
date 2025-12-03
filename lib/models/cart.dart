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

class Cart {
  final PricingRepository _pricingRepository;
  final List<CartItem> _items = [];

  Cart({PricingRepository? pricingRepository})
      : _pricingRepository = pricingRepository ?? PricingRepository();

  List<CartItem> get items => List.unmodifiable(_items);

  void add(Sandwich sandwich, {int quantity = 1}) {
    // Check if same sandwich already exists
    final existing = _items.where((item) =>
        item.sandwich.type == sandwich.type &&
        item.sandwich.isFootlong == sandwich.isFootlong &&
        item.sandwich.breadType == sandwich.breadType);

    if (existing.isNotEmpty) {
      existing.first.quantity += quantity;
    } else {
      _items.add(CartItem(sandwich: sandwich, quantity: quantity));
    }
  }

  void remove(Sandwich sandwich, {int quantity = 1}) {
    for (final item in _items) {
      if (item.sandwich.type == sandwich.type &&
          item.sandwich.isFootlong == sandwich.isFootlong &&
          item.sandwich.breadType == sandwich.breadType) {
        item.quantity -= quantity;
        if (item.quantity <= 0) {
          _items.remove(item);
        }
        break;
      }
    }
  }

  void clear() {
    _items.clear();
  }

  int get totalItems => _items.fold<int>(0, (sum, item) => sum + item.quantity);

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

  /// 🔹 Helper used by CartScreen & CheckoutScreen to get price for one line
  double calculatePriceFor(CartItem item) {
    return _pricingRepository.calculatePrice(
      quantity: item.quantity,
      isFootlong: item.sandwich.isFootlong,
    );
  }
}
