import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // Gemini API
import 'login_page.dart'; // Your login page

// Initialize Gemini API with your API key
final gemini = GenerativeModel(
  model: 'gemini-pro',
  apiKey: "AIzaSyByX2BPVNUtxkmOYcfp7MCRie1IgLxO9Cg", // Replace with your actual API key
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAW7Mxis9z09roxP6FTL4vESxmcroHRQE0",
      authDomain: "test1-5e594.firebaseapp.com",
      projectId: "test1-5e594",
      storageBucket: "test1-5e594.appspot.com",
      messagingSenderId: "875484146858",
      appId: "1:875484146858:android:f0f962e21801335e8034d3",
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.red,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(backgroundColor: Colors.red),
        textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.white)),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900],
          hintStyle: TextStyle(color: Colors.grey),
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
      ),
      home: LoginPage(), // Redirects to Login Page
    );
  }
}
