import 'dart:convert';
import 'package:http/http.dart' as http;

class DialogflowService {
  final String projectId = "YOUR_PROJECT_ID";
  final String authToken = "YOUR_DIALOGFLOW_TOKEN"; // Use client access token

  Future<String> sendMessage(String message) async {
    final url = Uri.parse("https://dialogflow.googleapis.com/v2/projects/$projectId/agent/sessions/12345:detectIntent");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $authToken",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "queryInput": {
          "text": {"text": message, "languageCode": "en"}
        }
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['queryResult']['fulfillmentText'] ?? "I didn't understand.";
    } else {
      return "Error connecting to Dialogflow.";
    }
  }
}
