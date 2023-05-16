import 'package:apple_sign_in/apple_sign_in.dart' as apple;
import 'package:cafe_noir/screens/auth_screen/verify_email.dart';
import 'package:cafe_noir/services/apple_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:the_apple_sign_in/scope.dart' as the_apple;
import 'dart:io' show Platform;

import '../../providers/auth.dart';
import 'forgot_password_screen.dart';

enum AuthMode { Signup, Login }

class AuthCard extends StatefulWidget {
  final Function _switchIsLoading;
  final Function _functionShowError;
  const AuthCard(this._switchIsLoading, this._functionShowError);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
    'name': '',
  };
  final _passwordController = TextEditingController();
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }

    _formKey.currentState.save();
    widget._switchIsLoading();

    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).signIn(
          email: _authData['email'],
          password: _authData['password'],
        );
      } else {
        // Sign user up
        await context.read<Auth>().signUp(
              email: _authData['email'],
              password: _authData['password'],
              name: _authData['name'],
              context: context,
            );
        // Log Analytics
        await analytics.logSignUp(signUpMethod: 'email');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VerifyEmail()),
        );
      }
    } on FirebaseAuthException catch (error) {
      print('auth_screen FirebaseAuthException $error');
      //will catch only FirebaseAuthExceptions errors
      var errorMessage = 'Autentificare nereusita';
      if (error.toString().contains('email-already-in-use')) {
        errorMessage = 'Aceasta adresa de email este deja utilizata.';
      } else if (error.toString().contains('user-not-found')) {
        errorMessage = 'Aceasta adresa de email nu este inregistrata.';
      } else if (error.toString().contains('wrong-password')) {
        errorMessage = 'Adresa de email sau parola nu sunt corecte.';
      } else if (error.toString().contains('badly formatted')) {
        errorMessage = 'Aceasta adresa de email nu a fost formatata corect.';
      } else if (error.toString().contains('invalid-email')) {
        errorMessage = 'Aceasta adresa de email este invalida.';
      }
      widget._functionShowError(errorMessage);
    } catch (error) {
      //will catch any other error
      print('auth_screen otherErrors $error');
      // const errorMessage =
      //     'Nu ati fost autentificat. Va rugam incercati mai tarziu.';
      // widget._functionShowError(errorMessage);
    }

    widget._switchIsLoading();
  }

  Future<void> _submitApple() async {
    widget._switchIsLoading();
    try {
      await Provider.of<Auth>(context, listen: false).signInWithApple(
          scopes: [the_apple.Scope.email, the_apple.Scope.fullName]);
      await analytics.logSignUp(signUpMethod: 'apple');
    } catch (error) {
      print(error);
    }
    widget._switchIsLoading();
  }

  Future<void> _submitFacebook() async {
    widget._switchIsLoading();
    try {
      await Provider.of<Auth>(context, listen: false).signInWithFacebook();
      await analytics.logSignUp(signUpMethod: 'facebook');
    } catch (error) {
      print(error);
      widget._functionShowError(error.toString());
    }
    widget._switchIsLoading();
  }

  Future<void> _submitGoogle() async {
    widget._switchIsLoading();
    try {
      await Provider.of<Auth>(context, listen: false).signInWithGoogle();
      await analytics.logSignUp(signUpMethod: 'google');
    } catch (error) {
      print(error);
      widget._functionShowError(error.toString());
    }
    widget._switchIsLoading();
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  Future<void> _showForgotPasswordEmailSent(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: const Text(
              'Mail-ul de resetare a parolei a fost trimis!',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  width: 200,
                  height: 200,
                  child: Lottie.asset(
                    'assets/lottie/lottie_sent_email.json',
                    repeat: false,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: const Text(
                      '',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: Text('Inapoi',
                    style: TextStyle(color: Colors.grey[700], fontSize: 15)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    return Center(
      child: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // apple
                        (AppleSignInAvailable.availability && Platform.isIOS)
                            ? Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Colors.grey[300], width: 0.7),
                                ),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 10),
                                height: 50,
                                child: apple.AppleSignInButton(
                                  style: apple.ButtonStyle.white,
                                  type: apple.ButtonType.continueButton,
                                  onPressed: _submitApple,
                                ),
                              )
                            : Container(),
                        // facebook
                        GestureDetector(
                          onTap: _submitFacebook,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors.grey[300], width: 0.7),
                            ),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  FontAwesomeIcons.facebookF,
                                  color: Color.fromRGBO(24, 119, 242, 1),
                                  size: 25,
                                ),
                                const Text(
                                  '  Continuă cu Facebook',
                                  style: TextStyle(
                                    color: Color.fromRGBO(24, 119, 242, 1),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        // google
                        GestureDetector(
                          onTap: _submitGoogle,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors.grey[300], width: 0.7),
                            ),
                            margin: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Image(
                                  image: AssetImage(
                                      'assets/icons/google-logo.png'),
                                ),
                                Text(
                                  'Continuă cu Google   ',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              width: (queryData.size.width - 100) / 2,
                              child: Divider(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              "   sau   ",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                            Container(
                              width: (queryData.size.width - 100) / 2,
                              child: Divider(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 25),
                        // logare cu mail
                        if (_authMode == AuthMode.Signup)
                          TextFormField(
                            style: TextStyle(color: Colors.black),
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[400],
                                ),
                              ),
                              labelText: 'Nume și prenume',
                              labelStyle: TextStyle(color: Colors.black),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 6),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              hintText: 'Introduceți numele și prenumele',
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Nume invalid!';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _authData['name'] = value;
                            },
                          ),
                        SizedBox(height: 15),
                        TextFormField(
                          style: TextStyle(color: Colors.black),
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          autocorrect: false,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[400]),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[400])),
                            labelText: 'Adresă de e-mail',
                            labelStyle: TextStyle(color: Colors.black),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 6),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6)),
                            hintText: 'Introduceți o adresă de email',
                          ),
                          validator: (value) {
                            if (value.isEmpty || !value.contains('@')) {
                              return 'E-mail invalid!';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _authData['email'] = value;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          style: TextStyle(color: Colors.black),
                          autocorrect: false,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[400]),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[400])),
                            labelText: 'Parolă',
                            labelStyle: TextStyle(color: Colors.black),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 6),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6)),
                            hintText: 'Introduceti o parolă',
                          ),
                          obscureText: true,
                          controller: _passwordController,
                          validator: (value) {
                            if (value.isEmpty || value.length < 5) {
                              return 'Parola este prea scurtă!';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _authData['password'] = value;
                          },
                        ),
                      ],
                    ),
                    if (_authMode == AuthMode.Login)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                      context, ForgotPassword.routeName)
                                  .then((value) {
                                if (value == 'succes') {
                                  _showForgotPasswordEmailSent(context);
                                }
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, right: 10),
                              child: Text(
                                'Ați uitat parola?',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).primaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(
                      height: 25,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).primaryColor)),
                      child: Container(
                        height: 48,
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Center(
                          child: Text(
                            _authMode == AuthMode.Login
                                ? 'Autentificare'
                                : 'Înregistrare',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      onPressed: _submit,
                    ),
                    SizedBox(height: 3),
                    TextButton(
                      child: Container(
                        child: Text(
                          _authMode == AuthMode.Login
                              ? 'Creează cont nou'
                              : 'Autentificare',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      onPressed: _switchAuthMode,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
