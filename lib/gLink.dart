import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInMethodsPage extends StatefulWidget {
  @override
  _SignInMethodsPageState createState() => _SignInMethodsPageState();
}

class _SignInMethodsPageState extends State<SignInMethodsPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In Methods'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await linkEmail('test@example.com', 'password123');
              },
              child: Text('Link Email'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await linkGoogle();
              },
              child: Text('Link Google'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await fetchSignInMethodsForEmail();
              },
              child: Text('Fetch Sign In Methods'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchSignInMethodsForEmail() async {
    try {
      User user = _firebaseAuth.currentUser!;
      if (!user.isAnonymous && _firebaseAuth.currentUser?.email != null) {
        List<String> signInMethods =
        await _firebaseAuth.fetchSignInMethodsForEmail(_firebaseAuth.currentUser!.email!);

        // Use signInMethods as needed (e.g., print, show in UI)
        print('Sign In Methods: $signInMethods');
      } else {
        print('User is anonymous');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> linkEmail(String email, String password) async {
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);

    try {
      await _firebaseAuth.currentUser?.linkWithCredential(credential);
      print('Email linked successfully');
    } catch (e) {
      print('Failed to link email: $e');
    }
  }

  Future<void> linkGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential =
        GoogleAuthProvider.credential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

        await _firebaseAuth.currentUser?.linkWithCredential(credential);
        print('Google linked successfully');
      }
    } catch (e) {
      print('Failed to link Google: $e');
    }
  }
}

