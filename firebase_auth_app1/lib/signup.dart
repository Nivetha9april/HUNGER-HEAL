import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SignupPage extends StatefulWidget {
  final String role;
  const SignupPage({super.key, required this.role});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  File? idProofImage;

  Future<void> pickIdProofImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        idProofImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadIdProof(String userId) async {
    if (idProofImage == null) return null;

    String filePath = "id_proofs/$userId.jpg";
    await _storage.ref(filePath).putFile(idProofImage!);
    return await _storage.ref(filePath).getDownloadURL();
  }

  void registerUser() async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      String userId = userCredential.user!.uid;
      String? idProofUrl;

      if (widget.role == "Volunteer") {
        idProofUrl = await uploadIdProof(userId);
      }

      Map<String, dynamic> userData = {
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'age': ageController.text,
        'role': widget.role,
      };

      if (widget.role == "Donor" || widget.role == "Recipient") {
        userData['address'] = addressController.text;
      }
      if (widget.role == "Recipient") {
        userData['organization'] = organizationController.text;
      }
      if (widget.role == "Volunteer") {
        userData['idProof'] = idProofUrl;
      }

      await _firestore
          .collection('${widget.role.toLowerCase()}s')
          .doc(userId)
          .set(userData);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Signup Successful!")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Signup failed: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up as ${widget.role}")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "Phone"),
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: "Age"),
            ),
            if (widget.role != "Volunteer")
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: "Address"),
              ),
            if (widget.role == "Recipient")
              TextField(
                controller: organizationController,
                decoration: InputDecoration(labelText: "Organization"),
              ),
            if (widget.role == "Volunteer")
              Column(
                children: [
                  ElevatedButton(
                    onPressed: pickIdProofImage,
                    child: Text("Upload ID Proof"),
                  ),
                  idProofImage != null
                      ? Image.file(idProofImage!, height: 100)
                      : Container(),
                ],
              ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: registerUser, child: Text("Sign Up")),
          ],
        ),
      ),
    );
  }
}
