import 'package:flutter/material.dart';
import 'package:sandwich_shop/views/app_styles.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'views/checkout_screen.dart';
import 'views/profile_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Sandwich Shop App',
      home: OrderScreen(maxQuantity: 5),
    );
  }
}

class OrderScreen extends StatefulWidget {
  final int maxQuantity;

  const OrderScreen({super.key, this.maxQuantity = 10});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final Cart _cart = Cart();
  final TextEditingController _notesController = TextEditingController();

  SandwichType _selectedSandwichType = SandwichType.veggieDelight;
  bool _isFootlong = true;
  BreadType _selectedBreadType = BreadType.white;
  int _quantity = 1;

  // Last confirmation message to show in the UI
  String? _confirmationMessage;

  @override
  void initState() {
    super.initState();
    _notesController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _addToCart() {
    if (_quantity > 0) {
      final sandwich = Sandwich(
        type: _selectedSandwichType,
        isFootlong: _isFootlong,
        breadType: _selectedBreadType,
      );

      final sizeText = _isFootlong ? 'footlong' : 'six-inch';

      final noteText = _notesController.text.trim();
      final notePart = noteText.isEmpty ? 'No notes added.' : 'Note: $noteText';

      final confirmationMessage =
          'Added $_quantity $sizeText ${sandwich.name} sandwich(es) '
          'on ${_selectedBreadType.name} bread.\n$notePart';

      setState(() {
        _cart.add(sandwich, quantity: _quantity);
        _confirmationMessage = confirmationMessage;
      });

      // What you see in the terminal
      debugPrint(confirmationMessage);

      // Quick SnackBar so they see immediate feedback
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(confirmationMessage),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  VoidCallback? _getAddToCartCallback() {
    if (_quantity > 0) {
      return _addToCart;
    }
    return null;
  }

  List<DropdownMenuEntry<SandwichType>> _buildSandwichTypeEntries() {
    final entries = <DropdownMenuEntry<SandwichType>>[];
    for (final type in SandwichType.values) {
      final sandwich = Sandwich(
        type: type,
        isFootlong: true,
        breadType: BreadType.white,
      );
      entries.add(
        DropdownMenuEntry<SandwichType>(
          value: type,
          label: sandwich.name,
        ),
      );
    }
    return entries;
  }

  List<DropdownMenuEntry<BreadType>> _buildBreadTypeEntries() {
    final entries = <DropdownMenuEntry<BreadType>>[];
    for (final bread in BreadType.values) {
      entries.add(
        DropdownMenuEntry<BreadType>(
          value: bread,
          label: bread.name,
        ),
      );
    }
    return entries;
  }

  String _getCurrentImagePath() {
    final sandwich = Sandwich(
      type: _selectedSandwichType,
      isFootlong: _isFootlong,
      breadType: _selectedBreadType,
    );
    return sandwich.image;
  }

  void _onSandwichTypeChanged(SandwichType? value) {
    if (value != null) {
      setState(() {
        _selectedSandwichType = value;
      });
    }
  }

  void _onSizeChanged(bool value) {
    setState(() {
      _isFootlong = value;
    });
  }

  void _onBreadTypeChanged(BreadType? value) {
    if (value != null) {
      setState(() {
        _selectedBreadType = value;
      });
    }
  }

  void _increaseQuantity() {
    if (_quantity < widget.maxQuantity) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decreaseQuantity() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
      });
    }
  }

  VoidCallback? _getDecreaseCallback() {
    if (_quantity > 0) {
      return _decreaseQuantity;
    }
    return null;
  }

  // Permanent cart summary text
  String _cartSummaryText() {
    final itemLabel = _cart.totalItems == 1 ? 'item' : 'items';
    return 'Cart: ${_cart.totalItems} $itemLabel • £${_cart.totalPrice.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // no custom leading -> hamburger appears automatically with drawer
        title: Row(
          children: [
            SizedBox(
              height: 40,
              child: Image.asset('assets/images/logo.png'),
            ),
            const SizedBox(width: 8),
            const Text(
              'Sandwich Counter',
              style: heading1,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(cart: _cart),
                ),
              );
            },
          ),
        ],
      ),
      drawer: _AppDrawer(cart: _cart),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // PERMANENT CART SUMMARY AT THE TOP
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  _cartSummaryText(),
                  key: const Key('cart_summary'),
                  style: heading2,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 12),

              // CONFIRMATION MESSAGE CARD (ALSO NEAR TOP)
              if (_confirmationMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Card(
                    color: Colors.green.shade50,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        _confirmationMessage!,
                        key: const Key('confirmation_message'),
                        style: normalText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Big sandwich image
              SizedBox(
                height: 300,
                child: Image.asset(
                  _getCurrentImagePath(),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text(
                        'Image not found',
                        style: normalText,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Sandwich type dropdown
              DropdownMenu<SandwichType>(
                width: double.infinity,
                label: const Text('Sandwich Type'),
                textStyle: normalText,
                initialSelection: _selectedSandwichType,
                onSelected: _onSandwichTypeChanged,
                dropdownMenuEntries: _buildSandwichTypeEntries(),
              ),

              const SizedBox(height: 20),

              // Six-inch / Footlong switch
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Six-inch', style: normalText),
                  Switch(
                    value: _isFootlong,
                    onChanged: _onSizeChanged,
                  ),
                  const Text('Footlong', style: normalText),
                ],
              ),

              const SizedBox(height: 20),

              // Bread dropdown
              DropdownMenu<BreadType>(
                width: double.infinity,
                label: const Text('Bread Type'),
                textStyle: normalText,
                initialSelection: _selectedBreadType,
                onSelected: _onBreadTypeChanged,
                dropdownMenuEntries: _buildBreadTypeEntries(),
              ),

              const SizedBox(height: 20),

              // Quantity selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Quantity: ', style: normalText),
                  IconButton(
                    onPressed: _getDecreaseCallback(),
                    icon: const Icon(Icons.remove),
                  ),
                  Text('$_quantity', style: heading2),
                  IconButton(
                    onPressed: _increaseQuantity,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Notes field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Add a note (e.g., no onions)',
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Add to Cart button
              Center(
                child: StyledButton(
                  onPressed: _getAddToCartCallback(),
                  icon: Icons.add_shopping_cart,
                  label: 'Add to Cart',
                  backgroundColor: Colors.green,
                ),
              ),

              const SizedBox(height: 16),

              // View Cart button (opens CartScreen)
              Center(
                child: StyledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartScreen(cart: _cart),
                      ),
                    );
                  },
                  icon: Icons.shopping_cart,
                  label: 'View Cart',
                  backgroundColor: Colors.blue,
                ),
              ),

              const SizedBox(height: 16),

              // ✅ Profile button at bottom of OrderScreen
              Center(
                child: StyledButton(
                  key: const Key('profile_nav_button'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  icon: Icons.person,
                  label: 'Profile',
                  backgroundColor: Colors.purple,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class StyledButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;

  const StyledButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle myButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      textStyle: normalText,
    );

    return ElevatedButton(
      onPressed: onPressed,
      style: myButtonStyle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final Cart cart;

  const _AppDrawer({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Text(
              'Sandwich Shop',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Order'),
            onTap: () {
              Navigator.pop(context); // stay / return to OrderScreen
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Cart'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(cart: cart),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  final Cart cart;

  const CartScreen({super.key, required this.cart});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<void> _navigateToCheckout() async {
    if (widget.cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(cart: widget.cart),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        widget.cart.clear();
      });

      final String orderId = result['orderId'] as String;
      final String estimatedTime = result['estimatedTime'] as String;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Order $orderId confirmed! Estimated time: $estimatedTime'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );

      Navigator.pop(context); // back to order screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = widget.cart.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      drawer: _AppDrawer(cart: widget.cart),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: cartItems.isEmpty
                  ? const Center(
                      child: Text('Your cart is empty'),
                    )
                  : ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        final price = widget.cart.calculatePriceFor(item);

                        return ListTile(
                          title: Text(
                            '${item.quantity} × ${item.sandwich.type}',
                          ),
                          subtitle: Text(
                            '${item.sandwich.isFootlong ? 'Footlong' : 'Six-inch'} • ${item.sandwich.breadType}',
                          ),
                          trailing: Text(
                            '£${price.toStringAsFixed(2)}',
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            StyledButton(
              onPressed: widget.cart.items.isEmpty ? null : _navigateToCheckout,
              icon: Icons.payment,
              label: 'Checkout',
              backgroundColor: Colors.orange,
            ),
            const SizedBox(height: 20),
            StyledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icons.arrow_back,
              label: 'Back to Order',
              backgroundColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
