// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // ✅ Import for loading JSON
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/dialogflow/v2.dart';

// ignore: use_key_in_widget_constructors
class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];

  // Speech & TTS
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  final bool _isSpeakingEnabled = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
  }

  // 🔹 Fetch Contact Details from Firestore
  Future<String> _fetchContactDetails(String name) async {
    try {
      Future<String?> searchInCollection(String collection) async {
        var snapshot = await FirebaseFirestore.instance
            .collection(collection)
            .where("name", isEqualTo: name)
            .get();

        if (snapshot.docs.isNotEmpty) {
          var contact = snapshot.docs.first.data();
          return "${contact["name"]} (📞 ${contact["phone"]}, 📧 ${contact["email"]})";
        }
        return null;
      }

      String? result;
      result = await searchInCollection("donors");
      result ??= await searchInCollection("volunteers");
      result ??= await searchInCollection("recipients");

      return result ?? "Sorry, no contact details found for $name.";
    } catch (e) {
      return "Error fetching contact details.";
    }
  }

  // 🔹 Fetch Response from Dialogflow (✅ updated)
  Future<String> _fetchDialogflowResponse(String message) async {
    try {
      // ✅ Load JSON using rootBundle (not File)
      final serviceAccount = await rootBundle.loadString('assets/images/hungerheal-service-account.json');
      final credentials = ServiceAccountCredentials.fromJson(serviceAccount);

      final client = await clientViaServiceAccount(
        credentials,
        [DialogflowApi.cloudPlatformScope],
      );

      final url = Uri.parse("https://dialogflow.googleapis.com/v2/projects/hungerhealbot-hdg9/agent/sessions/12345:detectIntent");

      final response = await client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "queryInput": {
            "text": {
              "text": message,
              "languageCode": "en"
            }
          }
        }),
      );

      client.close();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["queryResult"]["fulfillmentText"] ?? "Sorry, I didn't understand.";
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Failed to fetch response: $e";
    }
  }

  // 🔹 Handle User Messages
  void _sendMessage(String message) {
    if (message.isNotEmpty) {
      setState(() {
        _messages.add({"sender": "user", "text": message});
        _getBotResponse(message);
        _messageController.clear();
      });
    }
  }

  // 🔹 Generate Bot Responses
  void _getBotResponse(String userMessage) async {
    String botResponse;

    if (userMessage.toLowerCase().contains("hello")) {
      botResponse = "Hello! How can I assist you today?";
    } else if (userMessage.toLowerCase().contains("location")) {
      botResponse = "Your registered location is: Tambaram, Chennai.";
    } else if (userMessage.toLowerCase().contains("food")) {
      botResponse = "You can donate or request food via our app!";
    } else if (userMessage.toLowerCase().startsWith("contact")) {
      String name = userMessage.substring(8).trim();
      botResponse = await _fetchContactDetails(name);
    } else {
      botResponse = await _fetchDialogflowResponse(userMessage);
    }

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _messages.add({"sender": "bot", "text": botResponse});
      });

      if (_isSpeakingEnabled) {
        _speak(botResponse);
      }
    });
  }

  // 🔹 Text-to-Speech
  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  // 🔹 Speech-to-Text
  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print("Status: $status"),
      onError: (error) => print("Error: $error"),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _messageController.text = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
    _sendMessage(_messageController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chatbot"), backgroundColor: Colors.redAccent),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isUser = message["sender"] == "user";

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.redAccent : Colors.grey[800],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message["text"]!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
                Expanded(
                  child: TextField(controller: _messageController, style: TextStyle(color: Colors.white)),
                ),
                IconButton(icon: Icon(Icons.send, color: Colors.redAccent), onPressed: () => _sendMessage(_messageController.text)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
