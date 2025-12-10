import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sandwich_shop/views/app_styles.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));

    final DateTime now = DateTime.now();
    final int timestamp = now.millisecondsSinceEpoch;
    final String orderId = 'ORD$timestamp';

    // Get the shared cart instance
    final Cart cart = Provider.of<Cart>(context, listen: false);

    // This map is what CartScreen receives as "result"
    final Map<String, Object> orderConfirmation = {
      'orderId': orderId,
      'totalAmount': cart.totalPrice,
      'itemCount': cart.totalItems,
      'estimatedTime': '15–20 minutes',
    };

    if (mounted) {
      Navigator.pop(context, orderConfirmation);
    }
  }

  double _calculateItemPrice(Sandwich sandwich, int quantity) {
    final PricingRepository repo = PricingRepository();
    return repo.calculatePrice(
      quantity: quantity,
      isFootlong: sandwich.isFootlong,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 100,
            child: Image.asset('assets/images/logo.png'),
          ),
        ),
        title: const Text('Checkout', style: heading1),
        actions: [
          // Cart indicator in the app bar
          Consumer<Cart>(
            builder: (context, cart, child) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_cart),
                    const SizedBox(width: 4),
                    Text('${cart.totalItems}'),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Consumer<Cart>(
          builder: (context, cart, child) {
            final List<Widget> children = [];

            // Title
            children.add(const Text('Order Summary', style: heading2));
            children.add(const SizedBox(height: 20));

            // One row per cart line
            for (final entry in cart.items) {
              final Sandwich sandwich = entry.sandwich;
              final int quantity = entry.quantity;
              final double itemPrice = _calculateItemPrice(sandwich, quantity);

              children.add(
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${quantity}x ${sandwich.name}',
                      style: normalText,
                    ),
                    Text(
                      '£${itemPrice.toStringAsFixed(2)}',
                      style: normalText,
                    ),
                  ],
                ),
              );
              children.add(const SizedBox(height: 8));
            }

            children.add(const Divider());
            children.add(const SizedBox(height: 10));

            // Total row
            children.add(
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: heading2),
                  Text(
                    '£${cart.totalPrice.toStringAsFixed(2)}',
                    style: heading2,
                  ),
                ],
              ),
            );

            children.add(const SizedBox(height: 40));

            // Fake payment method text
            children.add(
              const Text(
                'Payment Method: Card ending in 1234',
                style: normalText,
                textAlign: TextAlign.center,
              ),
            );

            children.add(const SizedBox(height: 20));

            if (_isProcessing) {
              // Show loader while processing
              children.add(
                const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              children.add(const SizedBox(height: 20));
              children.add(
                const Text(
                  'Processing payment...',
                  style: normalText,
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              // Confirm button
              children.add(
                ElevatedButton(
                  onPressed: _processPayment,
                  child: const Text('Confirm Payment', style: normalText),
                ),
              );
            }

            return Column(
              children: children,
            );
          },
        ),
      ),
    );
  }
}
