import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendMessageNotification(
    String recipientToken, String senderName, String message) async {
  const String serverKey = 'AIzaSyBulkYJG3tv8O5XHKwM2KNzveo5TAkwZbQ';

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
