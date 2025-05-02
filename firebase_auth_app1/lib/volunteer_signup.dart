import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'custom_widgets.dart';
import 'step_info1.dart';

class VolunteerSignupPage extends StatefulWidget {
  const VolunteerSignupPage({super.key});

  @override
  _VolunteerSignupPageState createState() => _VolunteerSignupPageState();
}

class _VolunteerSignupPageState extends State<VolunteerSignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController proofIdController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signupVolunteer() async {
    try {
      if (nameController.text.trim().isEmpty ||
          emailController.text.trim().isEmpty ||
          phoneController.text.trim().isEmpty ||
          proofIdController.text.trim().isEmpty ||
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

      // Store data in Firestore in the 'volunteers' collection
      await _firestore.collection('volunteers').doc(userId).set({
        'name': nameController.text.trim(),
        'email': email,
        'phone': phoneController.text.trim(),
        'proof_id': proofIdController.text.trim(),
        'address': addressController.text.trim(),
        'role': 'volunteer',
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
      appBar: AppBar(
        title: Text("Volunteer Signup"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            customTextField(controller: nameController, label: "Name"),
            customTextField(controller: emailController, label: "Email"),
            customTextField(controller: phoneController, label: "Phone"),
            customTextField(controller: proofIdController, label: "Proof ID"),
            customTextField(controller: addressController, label: "Address"),
            customTextField(
              controller: passwordController,
              label: "Password",
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: signupVolunteer, child: Text("Sign Up")),
          ],
        ),
      ),
    );
  }
}
