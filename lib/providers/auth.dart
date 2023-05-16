import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ios
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

// android
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import 'package:http/http.dart' as http;

class Auth {
  String _idToken;

  final FirebaseAuth _firebaseAuth;

  Auth(this._firebaseAuth);

  Stream<User> get authStateChanges => _firebaseAuth.authStateChanges();

  User user;

  Future<User> signInWithApple({List<Scope> scopes = const []}) async {
    // 1. perform the sign-in request
    // print('check0');
    final result = await TheAppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);
    // print('check1');
    // 2. check the result
    switch (result.status) {
      case AuthorizationStatus.authorized:
        // print('check2');
        final appleIdCredential = result.credential;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode),
        );
        // print('credential:' + credential.toString());
        //asta ma intereseaza pe mine
        final userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        // print('userCredential:' + userCredential.toString());
        final firebaseUser = userCredential.user;
        if (scopes.contains(Scope.fullName)) {
          final fullName = appleIdCredential.fullName;
          if (fullName != null &&
              fullName.givenName != null &&
              fullName.familyName != null) {
            final displayName = '${fullName.givenName} ${fullName.familyName}';
            await firebaseUser.updateProfile(displayName: displayName);
          }
        }
        return firebaseUser;
      case AuthorizationStatus.error:
        // print('check3');
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: result.error.toString(),
        );

      case AuthorizationStatus.cancelled:
        // print('check4');
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      default:
        throw UnimplementedError();
    }
  }

  Future<void> signInWithFacebook() async {
    // IOS

    try {
      FacebookLogin facebookLogin = FacebookLogin();
      final result = await facebookLogin.logIn(['email']);
      print('check1 ' + result.status.toString());

      final token = result.accessToken.token;
      print('check2 ' + token);

      final url = Uri.parse(
          'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
      final graphResponse = await http.get(url);
      print('check3 ' + graphResponse.body);

      // final profile = json.decode(graphResponse.body);
      if (result.status == FacebookLoginStatus.loggedIn) {
        print('check4 ');
        final credential = FacebookAuthProvider.credential(token);
        user = (await _firebaseAuth.signInWithCredential(credential)).user;
      }
    } catch (error) {
      // print(error.email);
      // print(error.credential);
      // print(error.toString());
      // if (true) {
      //   final userCredential =
      //       await _firebaseAuth.signInWithCredential(error.credential);
      //   final firebaseUser = userCredential.user;
      //   print(firebaseUser);
      // }

      throw error;
    }

    // ANDROID

    // final LoginResult result = await FacebookAuth.instance.login();
    // // by default we request the email and the public profile
    // // or FacebookAuth.i.login()
    // if (result.status == LoginStatus.success) {
    //   // you are logged
    //   final AccessToken accessToken = result.accessToken;
    //   print('check1' + result.status.toString());
    //   // or FacebookAuth.i.accessToken
    //   if (accessToken != null) {
    //     // user is logged
    //     print('check2' + accessToken.token);
    //     final credential = FacebookAuthProvider.credential(accessToken.token);
    //     user = (await _firebaseAuth.signInWithCredential(credential)).user;
    //   }
    // } else {
    //   print(result.status);
    //   print(result.message);
    // }
  }

  Future<void> signInWithGoogle() async {
    try {
      GoogleSignIn _googleSignIn = GoogleSignIn();
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final GoogleAuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );
        user = (await _firebaseAuth.signInWithCredential(credential)).user;
        _idToken = await user.getIdToken();
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> signIn({
    String email,
    String password,
    // Function showError,
  }) async {
    try {
      // final UserCredential result =
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print('auth firebaseAuthException $e');
      throw e;
    } catch (e) {
      //return other types of exceptions
      print('auth other Exception $e');
      throw e;
    }
  }

  Future<void> signUp(
      {String email,
      String password,
      String name,
      BuildContext context}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = _firebaseAuth.currentUser;
      await user.updateProfile(displayName: name);

      print('am updatat numele: ' + name);
      //BUG:nu se actualizeaza instant; imediat dupa ce te inregistrezi, nu iti va aparea numele in order screen
    } on FirebaseAuthException catch (e) {
      // return FirebaseAuthExceptions;
      print('auth firebaseAuthException $e');
      throw e;
    } catch (e) {
      //return other types of exceptions
      print('auth other Exception $e');
      throw e;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String> refreshGetToken() async {
    user = FirebaseAuth.instance.currentUser;
    _idToken = await user.getIdToken();
    return _idToken;
  }

  User getUser() {
    user = _firebaseAuth.currentUser;
    return user;
  }
}
