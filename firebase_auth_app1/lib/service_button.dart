import 'package:flutter/material.dart';
import 'foodprovider.dart';
import 'foodrecepient.dart';
import 'volunteer.dart';

class ServiceButton extends StatelessWidget {
  final String title;
  final String role;

  const ServiceButton({required this.title, required this.role, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: () {
        // Navigate based on role
        if (role == "Food Provider") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FoodProviderPage()));
        } else if (role == "Recipient") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FoodRecipientPage()));
        } else if (role == "Volunteer") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => VolunteerPage()));
        }
      },
      child: Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}
