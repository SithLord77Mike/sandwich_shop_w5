import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';

void main() {
  group('Cart', () {
    test('adding items increases totalItems', () {
      final cart = Cart(pricingRepository: PricingRepository());

      final sandwich = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: false,
        breadType: BreadType.white,
      );

      cart.add(sandwich, quantity: 2);

      expect(cart.totalItems, 2);
    });

    test('totalPrice uses PricingRepository for footlong', () {
      final cart = Cart(pricingRepository: PricingRepository());

      final footlong = Sandwich(
        type: SandwichType.tunaMelt,
        isFootlong: true,
        breadType: BreadType.wheat,
      );

      cart.add(footlong, quantity: 1);

      // In the provided repo, a single footlong is £11.
      expect(cart.totalPrice, 11);
    });
  });
}
