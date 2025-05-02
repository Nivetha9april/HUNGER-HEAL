import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'custom_widgets.dart';
import 'step_info1.dart';

// ignore: use_key_in_widget_constructors
class DonorSignupPage extends StatefulWidget {
  @override
  _DonorSignupPageState createState() => _DonorSignupPageState();
}

class _DonorSignupPageState extends State<DonorSignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signupDonor() async {
    try {
      if (nameController.text.trim().isEmpty ||
          emailController.text.trim().isEmpty ||
          phoneController.text.trim().isEmpty ||
          addressController.text.trim().isEmpty ||
          passwordController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "All fields are required!",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String email = emailController.text.trim();
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email,
            password: passwordController.text.trim(),
          );

      // Send Email Verification
      await userCredential.user!.sendEmailVerification();

      String userId = userCredential.user!.uid;

      // Store data in Firestore in the 'donors' collection
      await _firestore.collection('donors').doc(userId).set({
        'name': nameController.text.trim(),
        'email': email,
        'phone': phoneController.text.trim(),
        'organization': organizationController.text.trim(),
        'address': addressController.text.trim(),
        'role': 'donor',
      });

      // ✅ Show Popup: Verification Email Sent
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text("Verify Email"),
              content: Text(
                "A verification email has been sent. Please verify before logging in.",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text("OK"),
                ),
              ],
            ),
      );
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => StepInfoPage()),
    );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Signup failed: ${e.message}",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Donor Signup"), backgroundColor: Colors.red),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            customTextField(controller: nameController, label: "Name"),
            customTextField(controller: emailController, label: "Email"),
            customTextField(controller: phoneController, label: "Phone"),
            customTextField(
              controller: organizationController,
              label: "Organization",
            ),
            customTextField(controller: addressController, label: "Address"),
            customTextField(
              controller: passwordController,
              label: "Password",
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: signupDonor, child: Text("Sign Up")),
          ],
        ),
      ),
    );
  }
}
