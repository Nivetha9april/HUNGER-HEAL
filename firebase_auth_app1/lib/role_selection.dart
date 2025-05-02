import 'package:flutter/material.dart';
import 'donor_signup.dart';
import 'volunteer_signup.dart';
import 'recipient_signup.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Your Role")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Choose your role to sign up", style: TextStyle(fontSize: 18)),
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
          ],
        ),
      ),
    );
  }
}
