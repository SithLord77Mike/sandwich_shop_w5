import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/models/sandwich.dart';

void main() {
  group('Sandwich model', () {
    test('name getter returns correct string', () {
      final sandwich = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: true,
        breadType: BreadType.white,
      );

      expect(sandwich.name, 'Veggie Delight');
    });

    test('image getter builds correct path for footlong', () {
      final sandwich = Sandwich(
        type: SandwichType.tunaMelt,
        isFootlong: true,
        breadType: BreadType.wheat,
      );

      expect(sandwich.image, 'assets/images/tunaMelt_footlong.png');
    });

    test('image getter builds correct path for six-inch', () {
      final sandwich = Sandwich(
        type: SandwichType.meatballMarinara,
        isFootlong: false,
        breadType: BreadType.wholemeal,
      );

      expect(
        sandwich.image,
        'assets/images/meatballMarinara_six_inch.png',
      );
    });
  });
}
