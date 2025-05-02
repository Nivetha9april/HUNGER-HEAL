import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileUpdatePage extends StatefulWidget {
  const ProfileUpdatePage({super.key});

  @override
  _ProfileUpdatePage createState() => _ProfileUpdatePage();
}

class _ProfileUpdatePage extends State<ProfileUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isEditing = false; // Track edit mode
  String _userType = ''; // Store user type (donor, recipient, volunteer)

  // Controllers for user details
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fetch user data from Firestore
  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String? foundType;
      DocumentSnapshot? userDoc;

      List<String> collections = ["donors", "recipients", "volunteers"];
      for (String collection in collections) {
        DocumentSnapshot snapshot =
            await _firestore.collection(collection).doc(user.uid).get();
        if (snapshot.exists) {
          foundType = collection;
          userDoc = snapshot;
          break;
        }
      }

      if (userDoc != null && userDoc.exists) {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

        setState(() {
          _userType = foundType!;
          _nameController.text = data?["name"] ?? "";
          _emailController.text = data?["email"] ?? "";
          _phoneController.text = data?["phone"] ?? "";
          _addressController.text = data?["address"] ?? "";
        });
      }
    }
  }

  // Save changes to Firestore
  Future<void> _updateUserData() async {
    User? user = _auth.currentUser;
    if (user != null && _userType.isNotEmpty) {
      await _firestore.collection(_userType).doc(user.uid).update({
        "name": _nameController.text,
        "phone": _phoneController.text,
        "address": _addressController.text,
      });

      setState(() {
        _isEditing = false; // Disable edit mode
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.redAccent,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
        ],
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Profile Details",
                  style: TextStyle(color: Colors.white, fontSize: 20)),

              SizedBox(height: 20),

              // Name
              TextFormField(
                controller: _nameController,
                enabled: _isEditing,
                style: TextStyle(color: Colors.white),
                decoration: _inputDecoration("Name"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter your name" : null,
              ),

              SizedBox(height: 10),

              // Email (Always Read-Only)
              TextFormField(
                controller: _emailController,
                enabled: false, // Email is not editable
                style: TextStyle(color: Colors.white),
                decoration: _inputDecoration("Email"),
              ),

              SizedBox(height: 10),

              // Phone
              TextFormField(
                controller: _phoneController,
                enabled: _isEditing,
                style: TextStyle(color: Colors.white),
                decoration: _inputDecoration("Phone"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter your phone" : null,
              ),

              SizedBox(height: 10),

              // Address
              TextFormField(
                controller: _addressController,
                enabled: _isEditing,
                style: TextStyle(color: Colors.white),
                decoration: _inputDecoration("Address"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter your address" : null,
              ),

              SizedBox(height: 20),

              // Save Button (Only visible in edit mode)
              if (_isEditing)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _updateUserData();
                    }
                  },
                  child: Text("Save Changes"),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Input field styling
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
