import 'dart:convert';

import 'package:ai_email/Utils/shar_prefs.dart';
import 'package:http/http.dart' as http;
import 'api_utils.dart';

Future<void> sendMail({
  required String accessToken,
  required String email,
  required String title,
  required String content,
}) async {
  try {
    final http.Client httpClient = http.Client();
    final http.Request sendRequest = http.Request(
      'POST',
      Uri.parse('https://www.googleapis.com/gmail/v1/users/me/messages/send'),
    );
    print("==========header========${sendRequest.headers}");
    String bearertoken = await loadFromSharedPreferences("accessToken");
    //String bearertoken = "ya29.a0AfB_byDKfbRKcItWqaXxgDadKtHGWy6fDk9R-GS-qdl7ujSupxJ8yAtX87UwHKViSgnUdft-VAdS1G4LCqqdesHiFfn_RK8bsn0-ZAELS3H1uExwOpUmcxtx2Xp38tnpYjaf-nXrpZJp1NitgyMyXqBc2alfog-2kmr-aCgYKAbUSARASFQHGX2MiwPaHCMxYh9HSr7inQJ4NtA0171";
    print("=====-=-=-=-=-=-=-=-=-=-=BEARER TOKEN===$bearertoken");
    sendRequest.headers['Authorization'] = 'Bearer $bearertoken';
    sendRequest.headers['Content-Type'] = 'application/json';

    // Replace with your actual email content
    String subject = title;
    String messageBody = content;

    final String mimeMessage = '''
From: thisissendfromuser
To: $email
Subject: $subject

$messageBody
''';

    final String base64EncodedContent = base64Encode(utf8.encode(mimeMessage));

    sendRequest.body = '{"raw": "$base64EncodedContent"}';

    final http.StreamedResponse response = await httpClient.send(sendRequest);

    if (response.statusCode == 200) {
      final String responseBody = await response.stream.bytesToString();
      print('Send Email Response: $responseBody');
    } else {
      print('Failed to send email. Status code: ${response.statusCode}');
      //refresh token code here
      await apiUtils.refreshToken();
    }
  } catch (error) {
    print('Error sending email: $error');
  }
}
