import 'dart:convert';
import 'package:ai_email/pooja_medm/spbase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'emailscreen.dart';


class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  final List<Map<String, dynamic>> uiListData = [
    {
      'name': 'Email',
      'desc': 'Write an email response to',
      'icon': Icons.email,
    },
    {
      'name': 'Text',
      'desc': 'Write a text response to',
      'icon': Icons.send,
    },
    {
      'name': 'Internet Search',
      'desc': 'Give me information from the internet',
      'icon': Icons.language_rounded,
    },
    {
      'name': 'Email',
      'desc': 'Create a unique image about anything',
      'icon': Icons.image,
    },
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
    'email',
    'https://www.googleapis.com/auth/gmail.readonly',
    'https://www.googleapis.com/auth/gmail.send'
  ]);

  Future<void> signIn() async {
    try {
      await _googleSignIn.signIn();

    } catch (error) {
      print('Error signing in: $error');
    }
  }

  Future<void> readGmailEmails() async {
    print("=---------------------------------------------------=====");
    print("======READ EMAIL GMAIL ===${_googleSignIn.currentUser?.authHeaders}");
    print("header::::::::::${_googleSignIn.currentUser!.authHeaders.then((authHeaders) {
      print(authHeaders.values);
    })}");
    print("SERVER user name---=== ${_googleSignIn.currentUser!.serverAuthCode}");
    try {
      final GoogleSignInAccount? googleSignInAccount =
          _googleSignIn.currentUser;

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
        final String accessToken = googleSignInAuthentication.accessToken!;
        final String authcode = googleSignInAuthentication.idToken!;

        print('AccessToken::::: $accessToken');
        print('auth code::::: $authcode');

        final http.Response response = await http.get(
          Uri.parse('https://www.googleapis.com/gmail/v1/users/me/messages'),
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final List<dynamic> messages = data['messages'];
          messages.forEach((message) async {
            final messageId = message['id'];
            final fullMessageResponse = await http.get(
              Uri.parse(
                  'https://www.googleapis.com/gmail/v1/users/me/messages/$messageId'),
              headers: {'Authorization': 'Bearer $accessToken'},
            );
            final Map<String, dynamic> fullMessageData =
            json.decode(fullMessageResponse.body);
            final subject = fullMessageData['payload']['headers'].firstWhere(
                  (header) => header['name'] == 'Subject',
            )['value'];
            await sendEmail(accessToken);
          });
        } else {
          print(
              'Failed to fetch messages. Status code: ${response.statusCode}');
        }
      }
    } catch (error) {
      print('Error reading emails: $error');
    }
  }

  Future<void> sendEmail(String accessToken) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          _googleSignIn.currentUser;

      if (googleSignInAccount != null) {
        const String recipient = 'example.empiric@gmail.com';

        final http.Client httpClient = http.Client();
        final http.Request sendRequest = http.Request(
          'POST',
          Uri.parse(
              'https://www.googleapis.com/gmail/v1/users/me/messages/send'),
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

        final http.StreamedResponse response =
        await httpClient.send(sendRequest);

        if (response.statusCode == 200) {
          final String responseBody = await response.stream.bytesToString();
          print('Send Email Response: $responseBody');
        } else {
          print('Failed to send email. Status code: ${response.statusCode}');
        }
      }
    } catch (error) {
      print('Error sending email: $error');
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      /*if (accessToken.isNotEmpty) {
        await revokeToken(accessToken!);


      }*/
      print('User signed out');
    } catch (error) {
      print('Error signing out: $error');
    }
  }

  Future<void> revokeToken(String accessToken) async {
    final response = await http.post(
      Uri.parse('https://oauth2.googleapis.com/revoke?token=$accessToken'),
    );

    if (response.statusCode == 200) {
      // Token revoked successfully
      print('Token revoked');
    } else {
      // Handle error
      print('Error revoking token: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Super AI',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.lime.shade200,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisExtent: 200,
                crossAxisCount: 2,
              ),
              shrinkWrap: true,
              itemCount: uiListData.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    if (index == 0) {
                      if (_googleSignIn.currentUser == null) {
                        print("*************************");
                        await signIn();
                      }
                      await readGmailEmails();
                      // print("+=====current USER =clientId===${_googleSignIn.clientId}");
                      // print("+=====current USER =serverClientId===${_googleSignIn.serverClientId}");
                      // print("+=====current USER =authHeaders===${_googleSignIn.currentUser!.authHeaders}");
                      // print("+=====current USER =authentication===${_googleSignIn.currentUser!.authentication}");
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) {
                      //       return EmailScreen(
                      //           _googleSignIn.currentUser?.displayName ??
                      //               "Test");
                      //     },
                      //   ),
                      // );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      uiListData[index]['icon'],
                                      color: Colors.cyan,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.favorite_border_outlined,
                                  color: Colors.black38,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            uiListData[index]['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.cyan,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            uiListData[index]['desc'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: logout,
            child: const Text('Sign Out'),
          ),
          ElevatedButton(
            onPressed: () async{
              Navigator.push(context, MaterialPageRoute(builder: (context) => GoAuth(),));
            },
            child: const Text('Supabas auth google'),
          ),
        ],
      ),
    );
  }

// Function to check if the access token is expired
// Future<bool> isGoogleSignInTokenNotExpired(GoogleSignInAccount googleSignInAccount) async {
//   try {
//     final GoogleSignInAuthentication googleSignInAuthentication =
//     await googleSignInAccount.authentication;
//
//     final DateTime accessTokenExpiration = googleSignInAuthentication.accessToken;
//
//     // Check if both access token and id token are not expired
//     return DateTime.now().isBefore(accessTokenExpiration);
//   } catch (error) {
//     print('Error checking token expiration: $error');
//     // If there's an error, assume the token is expired
//     return false;
//   }
// }
}

//:::::::::::::: Firebase Google SignIn Code ::::::::::::::::
/*class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<bool> signInWithGoogle() async {
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

      // Check if the login was successful
      if (user != null) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print(error);
      return false;
    }
  }

  List<dynamic> uiListData = [
    {
      'name': 'Email',
      'desc': 'Write an email response to',
      'icons': Icons.email,
    },
    {
      'name': 'Text',
      'desc': 'Write a text response to',
      'icons': Icons.send,
    },
    {
      'name': 'Internet Search',
      'desc': 'Give me information from the internet',
      'icons': Icons.language_rounded,
    },
    {
      'name': 'Email',
      'desc': 'Create a unique image about anything',
      'icons': Icons.image,
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Super AI',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.lime.shade200,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisExtent: 200,
            crossAxisCount: 2,
          ),
          shrinkWrap: true,
          itemCount: uiListData.length,
          // Update this to the actual number of items in your grid
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                bool isLogin;
                isLogin = await signInWithGoogle();
                if (isLogin == true) {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return EmailScreen();
                    },
                  ));
                }
              },
              child: Container(
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  uiListData[index]['icons'],
                                  color: Colors.cyan,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.favorite_border_outlined,
                              color: Colors.black38,
                            ),
                          ],
                        ),
                      ),

                      Text(
                        uiListData[index]['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.cyan,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        uiListData[index]['desc'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // You can replace this with your actual item data
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}*/
