import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInDemo extends StatefulWidget {
  @override
  State createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
    //'openid',
    //'profile'
    'email',
    'https://www.googleapis.com/auth/gmail.readonly',
    // 'https://www.googleapis.com/auth/drive.readonly'
    'https://www.googleapis.com/auth/gmail.send'

    // 'https://www.googleapis.com/auth/cloud-platform'
  ],forceCodeForRefreshToken: true,
      //serverClientId:  "546137572569-6tf9m1lr24qe4pqocvneesbmpt5uj5n9.apps.googleusercontent.com");
      serverClientId:  "546137572569-6tf9m1lr24qe4pqocvneesbmpt5uj5n9.apps.googleusercontent.com");



  Future<void> signInWithGoogle() async {
    try {

      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();



      print("==BEFORE==SERVER AUTH CODE===${googleSignInAccount!.serverAuthCode.toString()}");
      print("==BEFORE==SERVER AUTH CODE===${googleSignInAccount!.id}");
      print("=BEFORE===ID TOKEN===${googleSignInAccount.authentication.then((value){
        print("-=BEFORE-=-=-=-=--${value.idToken}");
      })}");
      googleSignInAccount.authentication.then((value){
        print("----------${value.accessToken}");
      });

      _googleSignIn.signInSilently();

      print("==AFTER==SERVER AUTH CODE===${googleSignInAccount!.serverAuthCode.toString()}");
      print("==AFTER==SERVER AUTH CODE===${googleSignInAccount!.id}");
      print("=AFTER===ID TOKEN===${googleSignInAccount.authentication.then((value){
        print("-=AFTER-=-=-=-=--${value.idToken}");
      })}");
      googleSignInAccount.authentication.then((value){
        print("----------${value.accessToken}");
      });
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

  Future<void> getAuthorizationCode() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        GoogleSignInAuthentication authentication = await googleSignInAccount.authentication;
        String authCode = authentication.serverAuthCode ?? 'no';
        print('Authorization Code: $authCode');
      } else {
        // User canceled the sign-in
        print('User canceled sign-in');
      }
    } catch (error) {
      // Handle sign-in errors
      print('Error during sign-in: $error');
    }
  }

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
            onPressed: () async{
              try {
                await _googleSignIn.signOut();
                print('User signed out.');
              } catch (error) {
                print('Error signing out: $error');
              }
            },
            child: Text('Sign out'),
          ),
          ElevatedButton(
            onPressed: () async{
              final GoogleSignIn _googleSignIn = GoogleSignIn(
                scopes: ['email'], serverClientId:  "546137572569-6tf9m1lr24qe4pqocvneesbmpt5uj5n9.apps.googleusercontent.com"
              );

              Future<User?> signInSilently() async {
                final result = await _googleSignIn.signInSilently();
                if (result == null) {
                  print("======signInSilently===NULL=======");
                  return null;
                }else{
                  print("===NEW LOGIN===signInSilently===${_googleSignIn.currentUser!.serverAuthCode}=======");
                  print("===NEW LOGIN===signInSilently===${_googleSignIn.currentUser!.id}=======");

                }
                print("RESUL-=-===-=--=->>>>>>>>${result}");

              }
              signInSilently();
            },
            child: Text('Silent Login'),
          ),
        ],
      ),
    );
  }
}
