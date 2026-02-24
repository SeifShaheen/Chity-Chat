import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> sendMessageNotification(
    String recipientToken, String senderName, String message) async {
  final String serverKey = dotenv.env['FCM_SERVER_KEY']!;

  await http.post(
    Uri.parse('https://fcm.googleapis.com/fcm/send'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    },
    body: jsonEncode({
      'notification': {
        'title': 'New message from $senderName',
        'body': message,
      },
      'priority': 'high',
      'to': recipientToken,
    }),
  );
}
