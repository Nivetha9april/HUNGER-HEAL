import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  void checkVerification(BuildContext context) async {
    await FirebaseAuth.instance.currentUser?.reload();
    if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  void resendVerification() async {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify Email")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Please verify your email before continuing."),
            ElevatedButton(
              onPressed: resendVerification,
              child: Text("Resend Email"),
            ),
            ElevatedButton(
              onPressed: () => checkVerification(context),
              child: Text("I Verified"),
            ),
          ],
        ),
      ),
    );
  }
}
