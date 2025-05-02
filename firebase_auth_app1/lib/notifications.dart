import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      "title": "Food Donation Request",
      "message": "A nearby recipient is in need of food. Tap to view details.",
      "time": "5 mins ago",
    },
    {
      "title": "New Volunteer Joined",
      "message": "A volunteer has signed up to help with food deliveries.",
      "time": "20 mins ago",
    },
  ];

  NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Colors.redAccent,
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text(
                "No new notifications",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.grey[900],
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Icon(Icons.notifications, color: Colors.redAccent),
                    title: Text(
                      notifications[index]["title"]!,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      notifications[index]["message"]!,
                      style: TextStyle(color: Colors.white70),
                    ),
                    trailing: Text(
                      notifications[index]["time"]!,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    onTap: () {
                      // You can add navigation or action here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Clicked: ${notifications[index]["title"]}"),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
