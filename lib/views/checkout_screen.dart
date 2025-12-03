import 'package:flutter/material.dart';
import '../models/cart.dart';

class CheckoutScreen extends StatefulWidget {
  final Cart cart;

  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool isProcessing = false;

  Future<void> _confirmPayment() async {
    setState(() {
      isProcessing = true;
    });

    // Fake payment delay
    await Future.delayed(const Duration(seconds: 2));

    final orderId = "ORD${DateTime.now().millisecondsSinceEpoch}";
    final confirmation = {
      'orderId': orderId,
      'totalAmount': widget.cart.totalPrice,
      'itemCount': widget.cart.totalItems,
      'estimatedTime': '15–20 minutes',
    };

    setState(() {
      isProcessing = false;
    });

    // Return confirmation back to the caller
    Navigator.pop(context, confirmation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // List of cart items
            Expanded(
              child: ListView(
                children: widget.cart.items.map((cartItem) {
                  final linePrice = widget.cart.calculatePriceFor(cartItem);

                  return ListTile(
                    title: Text(
                        "${cartItem.quantity} × ${cartItem.sandwich.type}"),
                    subtitle: Text(
                      "${cartItem.sandwich.isFootlong ? "Footlong" : "Six-inch"} • "
                      "${cartItem.sandwich.breadType}",
                    ),
                    trailing: Text("£${linePrice.toStringAsFixed(2)}"),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            // Total
            Text(
              "Total: £${widget.cart.totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // Confirm button / loader
            Center(
              child: isProcessing
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _confirmPayment,
                      child: const Text("Confirm Payment"),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
