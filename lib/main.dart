import 'dart:convert';
import 'package:ai_email/pooja_medm/home.dart';
import 'package:ai_email/working_signin_retuen_authoriazation_code/auth_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/dfareporting/v4.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:http/http.dart' as http;
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:shared_preferences/shared_preferences.dart';

import 'Utils/shar_prefs.dart';
import 'gLink.dart';
import 'googemap.dart';
import 's.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        appId: "1:1081118767810:android:032675d200f0c33e17195b",
        projectId: "ai-email-d1f7c",
        apiKey: 'AIzaSyDJYni4GMFKkC2sqOgPwzQuY5EQxl7aiIc',
        messagingSenderId: '1081118767810',
      ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Sign-In App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

final _googleSignIn = GoogleSignIn(scopes: [
  'email',
  'https://www.googleapis.com/auth/gmail.readonly',
  'https://www.googleapis.com/auth/gmail.send']);

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  var token;

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
      await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
      await _auth.signInWithCredential(credential);
      final User? user = authResult.user;
      return user;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<void> readGmailEmails() async {
    try {
      final client = await _googleSignIn.currentUser?.authHeaders;
      print("=======$client");
      print("=---------------------------------------------------=====");
      print("======AUTH authHeaders ===${_googleSignIn.currentUser?.authHeaders}");
      print("======AUTH authorization code ===${_googleSignIn.currentUser!.serverAuthCode}");
      print("header::::::::::${_googleSignIn.currentUser!.authHeaders.then((authHeaders) {
        print(authHeaders.values);
      })}");
      print("SERVER user name---=== ${_googleSignIn.currentUser!.serverAuthCode}");
      token = client;
      if (client != null) {
        final http.Client httpClient = http.Client();
        final gmail.GmailApi gmailApi = gmail.GmailApi(httpClient);
        print('::::::::$gmailApi');
        final gmail.ListMessagesResponse messages =
        await gmailApi.users.messages.list('me');

        // Process the messages
        messages.messages?.forEach((message) async {
          final fullMessage =
          await gmailApi.users.messages.get('me', message.id!);
          final subject = fullMessage.payload?.headers
              ?.firstWhere(
                (header) => header.name == 'Subject',
          )
              ?.value;
          print('Subject: $subject');
        });
      }
    } catch (error) {
      print('=======================Error reading emails :=========== $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sign-In App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await signIn(); // Sign in or ensure the user is signed in
                await readGmailEmails();
              },
              child: const Text('Sign In with Google'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final GoogleSignIn googleSignIn = GoogleSignIn();
                await googleSignIn.signOut();
              },
              child: const Text('Sign Out'),
            ),
            ElevatedButton(
              onPressed: () {
                readGmailEmails();
              },
              child: const Text(' read Gmail Email'),
            ),
            ElevatedButton(
              onPressed: () {
                print("===-------TOKEN -------$token");
                String header = "$token";

                // RegExp regExp = RegExp(r'Bearer (\S+)');
                // Match? match = regExp.firstMatch(header);
                //
                // if (match != null) {
                //   String bearerToken = match.group(1)!; // Use the non-null assertion operator
                //   print('Bearer Token: $bearerToken');
                // } else {
                //   print('Bearer Token not found in the header.');
                // }
                sendEmail(
                    "Bearer ya29.a0AfB_byDxV7qj4FO_qVMEDG3WusPpwbADonTIErFyXxq-_XA6U3gnC5rd9ArmNW0ygFGB--pV2_cwjhFCcD0pfH2ufydRZgAutm2ny2rNTrFj2ygbUQSlf_9juFHr4gehMxMjQcc8LTnFVhxnBS1uyuVjVKoe4ckGfckaCgYKAboSARASFQHGX2MiRG_2CUUodpFlrw5VLMKJYA0170");
              },
              child: const Text(' read Gmail Email'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ));
              },
              child: const Text(' Home PAge'),
            ),
            ElevatedButton(
              onPressed: () async {
                Future<void> requestStoragePermission() async {
                  print(
                      "=============================requestStoragePermission=====<=29====CALLED");
                  final storagePermission = Permission.location;
                  if (await storagePermission.status.isGranted) {
                    await storagePermission.request();
                    print("await homeController.whenRefreshFile();");
                  } else {
                    await storagePermission.request();
                  }
                }

                await requestStoragePermission();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(),
                    ));
              },
              child: const Text(' MAPS'),
            ),
            ElevatedButton(onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => homePage(),
                  ));
            }, child: Text("GOOGLE LINK")),
            ElevatedButton(onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInDemo(),
                  ));
            }, child: Text("GOOGLE WORKING ")),

          ],
        ),
      ),
    );
  }
}

Future<void> sendEmail(String accessToken) async {
  try {
    final GoogleSignInAccount? googleSignInAccount = _googleSignIn.currentUser;

    if (googleSignInAccount != null) {
      const String recipient = 'ua.empiric@gmail.com';

      final http.Client httpClient = http.Client();
      final http.Request sendRequest = http.Request(
        'POST',
        Uri.parse('https://www.googleapis.com/gmail/v1/users/me/-/send'),
      );
      sendRequest.headers['Authorization'] = 'Bearer $accessToken';
      sendRequest.headers['Content-Type'] = 'application/json';

      // Replace with your actual email content
      const String subject = 'Test Subject';
      const String messageBody =
          'Testing is an essential part of any process, helping to identify potential issues, validate functionality, and ensure overall effectiveness. A well-executed test message serves as a valuable trial, allowing individuals to assess communication channels or systems. It provides insights into the reliability and performance of the intended platform, ensuring that messages are conveyed accurately and efficiently. Through testing, one can refine and optimize the messaging process, contributing to a more seamless and effective communication experience.';

      final String mimeMessage = '''
From: ${googleSignInAccount.email}
To: $recipient
Subject: $subject

$messageBody
''';

      final String base64EncodedContent =
      base64Encode(utf8.encode(mimeMessage));

      sendRequest.body = '{"raw": "$base64EncodedContent"}';

      final http.StreamedResponse response = await httpClient.send(sendRequest);

      if (response.statusCode == 200) {
        final String responseBody = await response.stream.bytesToString();
        print('Send Email Response: $responseBody');
      } else {
        print('Failed to send email. Status code: ${response.statusCode}');
      }
    } else {
      print('User not signed in.');
    }
  } catch (error) {
    print('Error sending email: $error');
  }
}

Future<void> signIn() async {
  try {
    await _googleSignIn.signIn();
  } catch (error) {
    print('Error signing in: $error');
  }
}