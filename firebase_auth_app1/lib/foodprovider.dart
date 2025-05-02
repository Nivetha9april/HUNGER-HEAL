// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class FoodProviderPage extends StatefulWidget {
  const FoodProviderPage({super.key});

  @override
  _FoodProviderPageState createState() => _FoodProviderPageState();
}

class _FoodProviderPageState extends State<FoodProviderPage> {
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _foodTypeController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _pickupLocationController = TextEditingController();

  bool _isMakingDonation = false;
  String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> addFoodListing() async {
    int extractedQuantity = int.tryParse(
          RegExp(r'\d+').firstMatch(_quantityController.text)?.group(0) ?? '0') ?? 0;

    final url = Uri.parse("http://127.0.0.1:5000/donations");

    final body = {
      'donorId': userId,
      'foodName': _foodNameController.text,
      'foodType': _foodTypeController.text,
      'expiryDate': _expiryDateController.text,
      'quantity': extractedQuantity,
      'pickupLocation': _pickupLocationController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Food listing added successfully!")),
        );
        setState(() => _isMakingDonation = false);
        _foodNameController.clear();
        _foodTypeController.clear();
        _expiryDateController.clear();
        _quantityController.clear();
        _pickupLocationController.clear();
      } else {
        print("Failed with status: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit donation")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting donation")),
      );
    }
  }

  Future<List<dynamic>> fetchUserDonations() async {
    final url = Uri.parse("http://127.0.0.1:5000/donations/$userId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load donations');
        return [];
      }
    } catch (e) {
      print('Error fetching donations: $e');
      return [];
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      _expiryDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Food Donations"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isMakingDonation ? buildDonationForm() : buildMainMenu(),
      ),
    );
  }

  Widget buildMainMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Make an Impact Today! 🌍\nDonate surplus food to help those in need.",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _isMakingDonation = true;
            });
          },
          icon: Icon(Icons.add),
          label: Text("Make a New Donation"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        ),
        SizedBox(height: 20),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: fetchUserDonations(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || !snapshot.hasData) {
                return Center(child: Text("Error fetching donations", style: TextStyle(color: Colors.white)));
              } else if (snapshot.data!.isEmpty) {
                return Center(child: Text("No donations made yet", style: TextStyle(color: Colors.white70)));
              }

              final donations = snapshot.data!;
              return ListView.builder(
                itemCount: donations.length,
                itemBuilder: (context, index) {
                  final donation = donations[index];
                  return Card(
                    color: Colors.white10,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(donation['food_name'], style: TextStyle(color: Colors.white)),
                      subtitle: Text(
                        "Quantity: ${donation['quantity']}\nExpiry: ${donation['expiry_date']}",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildDonationForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Add a Food Listing",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 10),
          buildTextField("Food Name", _foodNameController),
          buildTextField("Food Type", _foodTypeController),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: AbsorbPointer(
              child: buildTextField("Expiry Date (YYYY-MM-DD)", _expiryDateController),
            ),
          ),
          buildTextField("Quantity (Only Number)", _quantityController),
          buildTextField("Pickup Location", _pickupLocationController),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: addFoodListing,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text("Submit"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isMakingDonation = false;
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text("Cancel"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
