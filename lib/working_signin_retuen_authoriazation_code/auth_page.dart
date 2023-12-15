import 'dart:convert';

import 'package:ai_email/Utils/api_utils.dart';
import 'package:ai_email/Utils/email_model.dart';
import 'package:ai_email/Utils/shar_prefs.dart';
import 'package:ai_email/working_signin_retuen_authoriazation_code/emailscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignInDemo extends StatefulWidget {
  @override
  State createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        //'openid',
        //'profile'
        'email',
        'https://www.googleapis.com/auth/gmail.readonly',
        'https://www.googleapis.com/auth/gmail.send'
      ],
      forceCodeForRefreshToken: true,
      serverClientId: "546137572569-6tf9m1lr24qe4pqocvneesbmpt5uj5n9.apps.googleusercontent.com");

  Future<void> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      String ServerAuthCode = googleSignInAccount!.serverAuthCode.toString();
       apiUtils.getAccessAndRefreshToken(ServerAuthCode) ;
       saveToSharedPreferences(key: 'userEmail', value: googleSignInAccount.email);
       saveToSharedPreferences(key: 'userName', value: googleSignInAccount.displayName.toString());


      //_googleSignIn.signInSilently();

      // if (googleSignInAccount != null) {
      //   // Successfully signed in
      //   print('User signed in: ${googleSignInAccount.authentication.then((value) {
      //     print("====--------------=AUTHENTICATION===VALUEE=====${value.s}");
      //   },)}');
      //   print('=============User SERVER AUTH CODE in: ${googleSignInAccount.authHeaders.then((value) {
      //     print("========VALUEE=====$value");
      //   },)}');
      //
      //   getAuthorizationCode();
      // } else {
      //   // User canceled the sign-in
      //   print('User canceled sign-in');
      // }
    } catch (error) {
      // Handle sign-in errors
      print('Error during sign-in: $error');
    }
  }

  String emailToken = "";
  String ServerAuthCode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Sign-In Demo'),
      ),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: signInWithGoogle,
              child: Text('Sign in with Google'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _googleSignIn.signOut();
                await prefs.clear();
                print('User signed out.');
              } catch (error) {
                print('Error signing out: $error');
              }
            },
            child: Text('Sign out'),
          ),
          ElevatedButton(
            onPressed: () async {
              bool isSuucess = await apiUtils.checkTokenIsActive();
              if(isSuucess){
                sendMail(
                    accessToken: emailToken,
                    email: 'akashmavani2019@gmail.com',
                    title: 'heyy good day',
                    content: "send from the user response",
                );
              }else{
                await apiUtils.refreshToken();
                sendMail(
                  accessToken: emailToken,
                  email: 'akashmavani2015@gmail.com',
                  title: 'heyy good day',
                  content: "send from the user response",
                );
              }
            },
            child: Text('Send mail'),
          ),
          ElevatedButton(
            onPressed: () async {
              String name = await loadFromSharedPreferences('userName');
              Navigator.push(context, MaterialPageRoute(builder: (context) => EmailScreen(name)));
            },
            child: Text('Show mail'),
          ),
        ],
      ),
    );
  }
}



