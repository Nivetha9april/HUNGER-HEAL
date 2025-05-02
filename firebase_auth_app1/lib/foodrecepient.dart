import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';
import 'global_cart.dart';
import 'cart_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodRecipientPage extends StatefulWidget {
  const FoodRecipientPage({super.key});

  @override
  _FoodRecipientPageState createState() => _FoodRecipientPageState();
}

class _FoodRecipientPageState extends State<FoodRecipientPage> {
  List<dynamic> donations = [];
  bool isLoading = true;
  String currentUserId = FirebaseAuth.instance.currentUser!.uid; // Get current user's ID

  @override
  void initState() {
    super.initState();
    fetchDonations();
  }

  Future<void> fetchDonations() async {
    final url = Uri.parse("http://127.0.0.1:5000/donations"); // ✅ use localhost
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Debugging: Print current user ID and donation donorId for validation
        print('Current User ID: $currentUserId');
        for (var donation in data) {
          print('Donation donorId: ${donation['donorId']}');
        }

        // Filter donations to exclude those from the current user
        final filteredDonations = data.where((donation) {
          // Ensure both values are comparable (same type, trimmed, and lowercased)
          return donation['donorId']?.trim().toLowerCase() != currentUserId.trim().toLowerCase(); // Exclude current user's donations
        }).toList();

        setState(() {
          donations = filteredDonations;
          isLoading = false;
        });
      } else {
        print('Error fetching donations: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Exception fetching donations: $e');
      setState(() => isLoading = false);
    }
  }

  void addToCart(dynamic data) {
    final item = CartItem(
      id: data['donation_id'].toString(),
      foodName: data['food_name'],
      foodType: data['food_type'],
      quantity: data['quantity'],
      expiryDate: data['expiry_date'],
      pickupLocation: data['pickup_location'],
      donationDate: DateTime.tryParse(data['donation_date'] ?? '') ?? DateTime.now(),
    );

    cartItems.add(item);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${item.foodName} added to cart")),
    );

    setState(() {}); // refresh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Available Food",
          style: TextStyle(color: Color(0xFFED254E)),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => CartPage()));
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : donations.isEmpty
              ? const Center(child: Text("No food donations available", style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    final data = donations[index];
                    return Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.all(12),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          title: Text(
                            data['food_name'],
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text("Type: ${data['food_type']}", style: const TextStyle(color: Colors.white70)),
                              Text("Quantity: Serves ${data['quantity']}", style: const TextStyle(color: Colors.white70)),
                              Text("Expiry: ${data['expiry_date']}", style: const TextStyle(color: Colors.white70)),
                              Text("Pickup Location: ${data['pickup_location']}", style: const TextStyle(color: Colors.white70)),
                              Text("Donated At: ${data['donation_date']}", style: const TextStyle(color: Colors.white70)),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () => addToCart(data),
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text("Add to Cart"),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFED254E)),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.fastfood, color: Colors.redAccent, size: 30),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
