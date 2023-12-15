import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}
String email = "";
String title = "";
String content = "";
TextEditingController emailCon = TextEditingController();
TextEditingController titleCon = TextEditingController();
TextEditingController contentCon = TextEditingController();

class _HomePageState extends State<HomePage> {
  late FirebaseAuth _firebaseAuth;
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
    try {
      final GoogleSignInAccount? googleSignInAccount =
          _googleSignIn.currentUser;

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
        final String accessToken = googleSignInAuthentication.accessToken!;
        print('AccessToken: $accessToken');

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
            // await sendEmail(accessToken);
          });
        } else {
          print(
              'Failed to fetch messages. Status code: ${response.statusCode}');
        }
      } else {
        await signIn();
      }
    } catch (error) {
      print('Error reading emails: $error');
    }
  }

  Future<void> sendEmail(
      {required String accessToken, required String email, required String title, required String content}) async {
    try {
      print(
          "=============================Curent USER====${_googleSignIn.currentUser} ");
      final GoogleSignInAccount? googleSignInAccount =
          _googleSignIn.currentUser;

      if (googleSignInAccount != null) {
        String recipient = "$email";

        final http.Client httpClient = http.Client();
        final http.Request sendRequest = http.Request(
          'POST',
          Uri.parse('https://www.googleapis.com/gmail/v1/users/me/messages/send'),
        );
        print("==========header========${sendRequest.headers}");
        sendRequest.headers['Authorization'] = 'Bearer $accessToken';
        sendRequest.headers['Content-Type'] = 'application/json';

        // Replace with your actual email content
        String subject = title;
        String messageBody = content;

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
      } else {
        print('User not signed in.');
      }
    } catch (error) {
      print('Error sending email: $error');
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      print('User signed out');
    } catch (error) {
      print('Error signing out: $error');
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: GridView.builder(
            //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //       mainAxisExtent: 200,
            //       crossAxisCount: 2,
            //     ),
            //     shrinkWrap: true,
            //     itemCount: uiListData.length,
            //     itemBuilder: (context, index) {
            //       return GestureDetector(
            //         onTap: () async {
            //           if (_googleSignIn.currentUser == null) {
            //             await signIn();
            //           }
            //
            //           await readGmailEmails();
            //           // Navigator.push(context, MaterialPageRoute(
            //           //   builder: (context) {
            //           //     return Placeholder();
            //           //     // return EmailScreen(
            //           //     //     _googleSignIn.currentUser!.displayName);
            //           //   },
            //           // ));
            //         },
            //         child: Container(
            //           margin: const EdgeInsets.all(4.0),
            //           decoration: BoxDecoration(
            //             color: Colors.blue.shade100,
            //             borderRadius: BorderRadius.circular(8.0),
            //           ),
            //           child: Padding(
            //             padding: const EdgeInsets.all(15.0),
            //             child: Column(
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Padding(
            //                   padding: const EdgeInsets.symmetric(vertical: 10.0),
            //                   child: Row(
            //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                     children: [
            //                       Container(
            //                         decoration: BoxDecoration(
            //                           color: Colors.blue.shade50,
            //                           borderRadius: BorderRadius.circular(8.0),
            //                         ),
            //                         child: Padding(
            //                           padding: const EdgeInsets.all(8.0),
            //                           child: Icon(
            //                             uiListData[index]['icon'],
            //                             color: Colors.cyan,
            //                           ),
            //                         ),
            //                       ),
            //                       const Icon(
            //                         Icons.favorite_border_outlined,
            //                         color: Colors.black38,
            //                       ),
            //                     ],
            //                   ),
            //                 ),
            //                 Text(
            //                   uiListData[index]['name'],
            //                   style: const TextStyle(
            //                     fontSize: 16,
            //                     color: Colors.cyan,
            //                     fontWeight: FontWeight.w500,
            //                   ),
            //                 ),
            //                 Text(
            //                   uiListData[index]['desc'],
            //                   style: const TextStyle(
            //                     fontSize: 12,
            //                     color: Colors.grey,
            //                     fontWeight: FontWeight.w500,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),
            ElevatedButton(
              onPressed: () async {
                if (_googleSignIn.currentUser == null) {

                  await signIn();
                }
                await readGmailEmails();
                // Navigator.push(context, MaterialPageRoute(
                //   builder: (context) {
                //     return Placeholder();
                //     // return EmailScreen(
                //     //     _googleSignIn.currentUser!.displayName);
                //   },
                // ));
              },
              child: const Text('Sign In'),
            ),
            ElevatedButton(
              onPressed: logout,
              child: const Text('Sign Out'),
            ),
            TextField(
              controller: emailCon,
              onChanged: (v) {
                setState(() {
                  email = v;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Enter your Email',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
              ),
            ),
            TextField(
              controller: titleCon,
              onChanged: (v) {
                setState(() {
                  title = v;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Enter your title',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
              ),
            ),
            TextField(
              controller: contentCon,
              onChanged: (v) {
                setState(() {
                  content = v;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Enter your content',
                hintText: "Testing is an essential part of any process, helping to identify potential issues, validate functionality, and ensure overall effectiveness. A well-executed test message serves as a valuable trial, allowing individuals to assess communication channels or systems. It provides insights into the reliability and performance of the intended platform, ensuring that messages are conveyed accurately and efficiently. Through testing, one can refine and optimize the messaging process, contributing to a more seamless and effective communication experience.",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // List ls = [
                //   "akashmavani2015@gmail.com",
                //   "akashmavani2016@gmail.com",
                //   "akashmavani2019@gmail.com"
                // ];
                // ls.forEach((element) async{
                //    sendEmail('ya29.a0AfB_byBKF22JmQEVWcePBp7UdKBiL2ZN7z5VxSz2vRGmDmQ30wPjGsRtGU4NHtYdLfC5YvxMhsp5aR10eT7PL4MrC08wWaAa5lsTLzwbWFEsebjplHX9VLbtNplXKnG3t89-tad-TEBFvYxvMDuBt0VXwGC9AOE5kwaCgYKATISARASFQHGX2Migmfkl5Abe0Nmtwp7vm7qXg0169',"${element}");
                // });
                sendEmail(
                  accessToken: 'ya29.a0AfB_byCDrxuiGuPaU0z6cCJGmwfdIFnOSem02EJpZeGW-unIw43loywIEVSDqXTm4ajhPS4j964hgHyF2-5BdbCD11Wku2ey6_CpP4HhKfDAmUg3AzdWLa-K-RybwKO97lL34Vs117LkSQgGdxgYK0F4r1SAgReoWI2VaCgYKAUYSARASFQHGX2MiJubIY_i4EjQRnmGF7K8UIQ0171',
                  email: email,
                  title: title,
                  content: content,
                );
                title = "";
                content = "";
                email = "";
                emailCon.clear();
                titleCon.clear();
                contentCon.clear();
              },
              child: const Text('Send mail'),
            ),
            ElevatedButton(onPressed: () {

              Future<List<String>> fetchSignInMethodsForEmail() async {
                print("F====FUNC CALLED====");
                try {
                  User user = _firebaseAuth.currentUser!;
                  print("=====USER ====$user");
                  if (!user.isAnonymous && _firebaseAuth.currentUser?.email != null) {
                    print("====------=${_firebaseAuth.fetchSignInMethodsForEmail(_firebaseAuth.currentUser!.email!)}");
                    return _firebaseAuth.fetchSignInMethodsForEmail(_firebaseAuth.currentUser!.email!);
                  } else {
                    print("----------------user repository - fetchSignInMethodsForEmail: user is anonymous");
                    return <String>[];
                  }
                } catch (e) {
                  print(e);
                  return <String>[];
                }
              }
              fetchSignInMethodsForEmail();
            }, child: Text("READ MAIl"))

          ],
        ),
      ),
    );
  }
}
