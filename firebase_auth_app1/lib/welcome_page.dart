import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chatbot_screen.dart';
import 'volunteer.dart';
import 'foodrecepient.dart';
import 'foodprovider.dart';
import 'live_location.dart';
import 'notifications.dart'; 
import 'profile_update.dart';// ✅ Import Notifications Screen
 // ✅ Import Profile Update Page

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String name = "User";
  String role = "";
  String userAddress = "Fetching address...";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      DocumentSnapshot donorDoc = await FirebaseFirestore.instance.collection('donors').doc(userId).get();
      if (donorDoc.exists) {
        setState(() {
          name = donorDoc['name'] ?? "User";
          role = "Donor";
          userAddress = donorDoc['address'] ?? "Address not available";
        });
        return;
      }

      DocumentSnapshot recipientDoc = await FirebaseFirestore.instance.collection('recipients').doc(userId).get();
      if (recipientDoc.exists) {
        setState(() {
          name = recipientDoc['name'] ?? "User";
          role = "Recipient";
          userAddress = recipientDoc['address'] ?? "Address not available";
        });
        return;
      }

      DocumentSnapshot volunteerDoc = await FirebaseFirestore.instance.collection('volunteers').doc(userId).get();
      if (volunteerDoc.exists) {
        setState(() {
          name = volunteerDoc['name'] ?? "User";
          role = "Volunteer";
          userAddress = volunteerDoc['address'] ?? "Address not available";
        });
        return;
      }

      setState(() {
        name = "User";
        role = "Unknown";
        userAddress = "Address not available";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        name,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  // ✅ Notification Button with Correct Navigation
                  IconButton(
                    icon: Icon(Icons.notifications, color: Colors.redAccent, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NotificationsScreen()), // ✅ Fixed Navigation
                      );
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.map, color: Colors.blueAccent),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      userAddress,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            Text(
              "CLICK HERE FOR YOUR SERVICE",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFED254E),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ServiceButton(title: "Food Provider", role: "Food Provider"),
                SizedBox(width: 10),
                ServiceButton(title: "Recipient", role: "Recipient"),
                SizedBox(width: 10),
                ServiceButton(title: "Volunteer", role: "Volunteer"),
              ],
            ),
            Spacer(),

            BottomNavBar(),
          ],
        ),
      ),
    );
  }
}

// ✅ Service Button Widget
class ServiceButton extends StatelessWidget {
  final String title;
  final String role;

  const ServiceButton({super.key, required this.title, required this.role});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (role == "Recipient") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FoodRecipientPage()));
        } else if (role == "Volunteer") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => VolunteerPage()));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FoodProviderPage()));
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFED254E),
        minimumSize: Size(110, 50),
      ),
      child: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}

// ✅ Bottom Navigation Bar Widget
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.location_on, size: 28, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LiveLocationPage()));
            },
          ),
          IconButton(icon: Icon(Icons.home, size: 28, color: Colors.black), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.chat, size: 28, color: Colors.redAccent),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatbotScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.person, size: 28, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileUpdatePage()));
            },
          ),
        ],
      ),
    );
  }
}
