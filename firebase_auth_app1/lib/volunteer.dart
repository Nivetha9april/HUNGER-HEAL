import 'package:flutter/material.dart';
import 'volunteer_map.dart'; // Ensure this file exists

class VolunteerPage extends StatefulWidget {
  const VolunteerPage({super.key});

  @override
  _VolunteerPageState createState() => _VolunteerPageState();
}

class _VolunteerPageState extends State<VolunteerPage> {
  List<Map<String, String>> deliveries = [
    {"food": "Rice & Curry", "pickup": "Community Center", "drop": "Shelter Home", "location": "Anna Nagar"},
    {"food": "Bread & Soup", "pickup": "Food Bank", "drop": "School", "location": "Koyambedu"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Upcoming Deliveries',
          style: TextStyle(color: Color(0xFFED254E), fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: List.generate(deliveries.length, (index) {
            return buildDeliveryBox(context, index);
          }),
        ),
      ),
    );
  }

  Widget buildDeliveryBox(BuildContext context, int index) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('From: ${deliveries[index]["pickup"]}', 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          Text('To: ${deliveries[index]["drop"]}', 
              style: const TextStyle(fontSize: 14, color: Colors.black)),
          const SizedBox(height: 5),
          Text('Deliver: ${deliveries[index]["food"]}', 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovingVehicleMap(),

                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Accept'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    deliveries.removeAt(index); // Remove from list on deny
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Deny'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
