import 'package:flutter/material.dart';
import 'donor_signup.dart';
import 'volunteer_signup.dart';
import 'recipient_signup.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("HungerHeal")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to HungerHeal",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Donor Signup
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DonorSignupPage()),
                );
              },
              child: Text("Sign Up as Donor"),
            ),
            SizedBox(height: 10),

            // Volunteer Signup
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VolunteerSignupPage(),
                  ),
                );
              },
              child: Text("Sign Up as Volunteer"),
            ),
            SizedBox(height: 10),

            // Recipient Signup
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipientSignupPage(),
                  ),
                );
              },
              child: Text("Sign Up as Recipient"),
            ),
            SizedBox(height: 20),

            // Already have an account? Login button
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text("Already have an account? Log in"),
            ),
          ],
        ),
      ),
    );
  }
}
