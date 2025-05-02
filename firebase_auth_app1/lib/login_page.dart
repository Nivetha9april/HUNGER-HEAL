import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_page.dart'; // Navigate here after login
import 'role_selection.dart'; // For new user signup

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> loginUser() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;

      // 🔥 Check if email is verified
      if (user != null && !user.emailVerified) {
        await _auth.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please verify your email before logging in."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String userId = user!.uid;
      String? name;
      String? role;

      // 🔍 Check in 'donors' collection
      var donorDoc = await _firestore.collection('donors').doc(userId).get();
      if (donorDoc.exists) {
        name = donorDoc['name'];
        role = 'donor';
      }

      // 🔍 Check in 'recipients' collection
      var recipientDoc =
          await _firestore.collection('recipients').doc(userId).get();
      if (recipientDoc.exists) {
        name = recipientDoc['name'];
        role = 'recipient';
      }

      // 🔍 Check in 'volunteers' collection
      var volunteerDoc =
          await _firestore.collection('volunteers').doc(userId).get();
      if (volunteerDoc.exists) {
        name = volunteerDoc['name'];
        role = 'volunteer';
      }

      if (name != null && role != null) {
        // ✅ Navigate to HomeScreen after login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WelcomePage(), // No parameters
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("User data not found.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please enter your email")));
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset email sent! Check your inbox.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: emailController,
              style: TextStyle(color: Colors.white), // Changed text color to white
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: Colors.white), // Label color to white
              ),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: TextStyle(color: Colors.white), // Changed text color to white
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: TextStyle(color: Colors.white), // Label color to white
              ),
            ),
            SizedBox(height: 10),

            // Forgot Password Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: resetPassword,
                child: Text("Forgot Password?"),
              ),
            ),

            SizedBox(height: 20),
            Center(
              child: ElevatedButton(onPressed: loginUser, child: Text("Login")),
            ),

            SizedBox(height: 20),

            // New User? Create Account Button
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoleSelectionPage(),
                    ),
                  );
                },
                child: Text("New User? Create an Account"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

