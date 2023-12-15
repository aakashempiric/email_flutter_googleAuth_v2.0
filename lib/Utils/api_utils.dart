import 'dart:convert';

import 'package:ai_email/Utils/shar_prefs.dart';
import 'package:http/http.dart' as http;

final APIUtils apiUtils = APIUtils();

class APIUtils {
  void getAccessAndRefreshToken(String serverAuthCode) async {
    print("*********************************API CALL***************");
    var headers = {'Content-Type': 'text/plain'};
    var request = http.Request(
        'POST', Uri.parse('https://www.googleapis.com/oauth2/v4/token'));
    request.body =
        '''{\n"grant_type":"authorization_code",\n"client_id":"546137572569-6tf9m1lr24qe4pqocvneesbmpt5uj5n9.apps.googleusercontent.com",\n"client_secret":"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",\n"redirect_uri":"https://akash-testing-bc807.firebaseapp.com/__/auth/handler",\n"code":"$serverAuthCode",\n"access_type":"offline",\n"prompt":"consent",\n"include_granted_scopes":"true"\n}''';
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final map = Map<String, dynamic>.from(json.decode(body));
      saveToSharedPreferences(key: 'serverAuthCode', value: serverAuthCode);
      saveToSharedPreferences(key: 'accessToken', value: map['access_token']);
      saveToSharedPreferences(key: 'refreshToken', value: map['refresh_token']);
      print(
          "===========API RESPONSE=============access_token:- ${map['access_token']}");
      print(
          "===========API RESPONSE=============refresh_token :- ${map['refresh_token']}");
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<bool> checkTokenIsActive() async {
    try {
      String token = await loadFromSharedPreferences('accessToken');
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=$token'));
      request.bodyFields = {};

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200){
        final body = await response.stream.bytesToString();
        print("checkTokenIsActive :- $body");
        // final map = Map<String, dynamic>.from(json.decode(body));
        return true;
      } else {
        print("-=-=-=${response.reasonPhrase}");
        return false;
      }
    } catch (e) {
      print("====$e");
      return false;
    }
  }

  refreshToken() async {
    print("======RFERESH TOKEN API CALLED");
    try {
      String oldRefreshToken = await loadFromSharedPreferences("refreshToken");
      var headers = {'Content-Type': 'text/plain'};
      var request = http.Request(
          'POST', Uri.parse('https://www.googleapis.com/oauth2/v4/token'));
      request.body =
          '''{\n"grant_type":"refresh_token",\n"client_id":"546137572569-6tf9m1lr24qe4pqocvneesbmpt5uj5n9.apps.googleusercontent.com",\n"client_secret":"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",\n"redirect_uri":"https://akash-testing-bc807.firebaseapp.com/__/auth/handler",\n"refresh_token":"$oldRefreshToken"\n}''';
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // print(await response.stream.bytesToString());
        final body = await response.stream.bytesToString();
        final map = Map<String, dynamic>.from(json.decode(body));
        print("////////////${map['access_token']}");
        saveToSharedPreferences(key: "accessToken", value: map['access_token']);
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print(e);
    }
  }
}
