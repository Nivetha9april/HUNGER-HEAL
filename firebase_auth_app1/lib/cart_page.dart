import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../global_cart.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String _selectedService = 'Volunteer Service';

  // Sample delivery cost based on pickup location
  double _getDeliveryCharge(String location) {
    switch (location.toLowerCase()) {
      case 'chennai':
        return 20;
      case 'coimbatore':
        return 40;
      case 'madurai':
        return 30;
      case 'salem':
        return 35;
      default:
        return 25;
    }
  }

  // Calculate total price (base item + delivery)
  double _calculateTotalPrice() {
    if (_selectedService == 'Self Service') return 0;

    double total = 0;
    for (var item in cartItems) {
      double deliveryCharge = _getDeliveryCharge(item.pickupLocation);
      total += deliveryCharge;
    }
    return total;
  }

  Future<void> _submitCartToBackend() async {
    for (var item in cartItems) {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/submitCart"), // use localhost if using physical device
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "foodName": item.foodName,
          "foodType": item.foodType,
          "quantity": item.quantity,
          "expiryDate": item.expiryDate,
          "pickupLocation": item.pickupLocation,
          "donationDate": DateTime.now().toIso8601String(),
          "serviceType": _selectedService == "Self Service" ? "Self" : "Volunteer",
          "totalPrice": _calculateTotalPrice(),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Data sent to backend successfully");
      } else {
        print("❌ Failed to send data: ${response.body}");
      }
    }

    setState(() {
      cartItems.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("  Your HungerHeal request is confirmed")),
    );
  }

  void _selectServiceType(BuildContext context) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Select Service Type", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text("Volunteer Service", style: TextStyle(color: Colors.white)),
              value: 'Volunteer Service',
              groupValue: _selectedService,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<String>(
              title: const Text("Self Service", style: TextStyle(color: Colors.white)),
              value: 'Self Service',
              groupValue: _selectedService,
              onChanged: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedService = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _calculateTotalPrice();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("My Cart", style: TextStyle(color: Color(0xFFED254E))),
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(child: Text("Your cart is empty", style: TextStyle(color: Colors.white)))
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final deliveryCost = _getDeliveryCharge(item.pickupLocation);
                      const basePrice = 50;

                      return Card(
                        color: Colors.grey[900],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(12),
                        child: ListTile(
                          title: Text(item.foodName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Type: ${item.foodType}", style: const TextStyle(color: Colors.white70)),
                              Text("Quantity: Serves ${item.quantity}", style: const TextStyle(color: Colors.white70)),
                              Text("Pickup: ${item.pickupLocation}", style: const TextStyle(color: Colors.white70)),
                             
                              Text("Delivery: ₹$deliveryCost", style: const TextStyle(color: Colors.orangeAccent)),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_forever, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                cartItems.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(color: Colors.grey[850], boxShadow: [
                const BoxShadow(color: Colors.black45, blurRadius: 5, offset: Offset(0, -2)),
              ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Selected Service: $_selectedService", style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text("Total Items: ${cartItems.length}", style: const TextStyle(color: Colors.white70)),
                  Text("Total Price: ₹$totalPrice", style: const TextStyle(color: Colors.greenAccent, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFED254E),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onPressed: () => _selectServiceType(context),
                        child: const Text("Change Service Type"),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onPressed: () async {
                            await _submitCartToBackend();
                          },
                          child: const Text("Proceed to Checkout"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
