import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class GoAuth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Sign-In Example',
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

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Sign-In Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleGoogleSignIn,
          child: Text('Sign In with Google'),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      AuthResponse authResponse = await googleSignIn();
      // Handle successful sign-in
      print('User signed in: ${authResponse.user}');
      // You can navigate to another screen or perform additional actions here
    } catch (error) {
      // Handle sign-in error
      print('Error signing in: $error');
      // Display an error message or take appropriate action
    }
  }

  Future<AuthResponse> googleSignIn() async {
    const webClientId = 'your-web-client-id.apps.googleusercontent.com';
    const iosClientId = 'your-ios-client-id.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );

    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Google Sign-In canceled by user.';
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      var supabase;
      return await supabase.auth.signInWithIdToken(
        provider: Provider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (error) {
      // Handle sign-in error
      throw 'Error signing in with Google: $error';
    }
  }
}
