import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MovingVehicleMap extends StatefulWidget {
  final Map<String, String> orderDetails; // Order details passed from the volunteer screen

  const MovingVehicleMap({super.key, required this.orderDetails});

  @override
  MovingVehicleMapState createState() => MovingVehicleMapState();
}

class MovingVehicleMapState extends State<MovingVehicleMap> {
  List<LatLng> routePoints = [];
  int currentIndex = 0;
  LatLng currentPosition = LatLng(13.0853, 80.2109); // Default start position
  Timer? timer;
  int arrivalTime = 9; // Estimated arrival in minutes

  @override
  void initState() {
    super.initState();
    fetchRoute(); // Fetch route when screen loads
  }

  /// Fetches a route from OSRM API
  Future<void> fetchRoute() async {
    LatLng start = LatLng(13.0853, 80.2109); // Anna Nagar Tower
    LatLng end = LatLng(13.0702, 80.2175); // Koyambedu Bus Stand

    final url = Uri.parse(
        "https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson");

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List coords = data['routes'][0]['geometry']['coordinates'];

      setState(() {
        routePoints = coords
            .map((point) => LatLng(point[1], point[0])) // Convert coordinates
            .toList();
        currentPosition = routePoints.first; // Start at first point
      });

      startMoving(); // Start vehicle movement
    }
  }

  /// Simulates the vehicle moving along the route
  void startMoving() {
    if (routePoints.isEmpty) return;

    timer = Timer.periodic(Duration(milliseconds: 700), (timer) {
      if (currentIndex < routePoints.length - 1) {
        setState(() {
          currentIndex++;
          currentPosition = routePoints[currentIndex];

          // Reduce the arrival time dynamically
          if (currentIndex % (routePoints.length ~/ 7) == 0 && arrivalTime > 1) {
            arrivalTime -= (arrivalTime > 2) ? 2 : 1; 
          }
        });
      } else {
        timer.cancel();
        setState(() {
          arrivalTime = 0; // Arrived at destination
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tracking Order - ${widget.orderDetails['food']}")),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: currentPosition,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      color: Colors.blue,
                      strokeWidth: 5.0,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentPosition,
                    width: 50,
                    height: 50,
                    child: Icon(Icons.motorcycle, color: Colors.red, size: 50),
                  ),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_basket, size: 40, color: Colors.red),
                  Text("Tracking Order: ${widget.orderDetails['food']}", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("Location: ${widget.orderDetails['location']}", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Text(
                    arrivalTime == 0 ? "Arrived!" : "Arriving in $arrivalTime min",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.message, color: Colors.blue),
                        label: Text("Message"),
                      ),
                      SizedBox(width: 20),
                      TextButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.phone, color: Colors.green),
                        label: Text("Call Driver"),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {},
                    child: Text("ORDER DETAILS", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
