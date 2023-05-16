import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPassword extends StatefulWidget {
  static String routeName = 'forgot-password';

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String _email;
  String _error;

  Future _passwordReset() async {
    try {
      _formKey.currentState.save();
      await _auth.sendPasswordResetEmail(email: _email);
      print(_email);
    } catch (e) {
      print(e);
      print('EROARE!');
      return e;
    }
    return null;
  }

  void _showError(String error) {
    setState(() {
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Introduceți adresa de email',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  icon: Icon(
                    Icons.mail,
                    color: Colors.white,
                  ),
                  errorStyle: TextStyle(color: Colors.white),
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(color: Colors.white),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                onSaved: (value) {
                  _email = value;
                },
              ),
              _error != null
                  ? Container(
                      margin: EdgeInsets.only(top: 10, bottom: 25),
                      child: Center(
                          child: Text(
                        _error,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      )),
                    )
                  : Container(),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  _passwordReset().then((value) {
                    if (value != null) {
                      _showError(value.toString().substring(
                          value.toString().indexOf(']') + 2,
                          value.toString().length));
                      // print(value);
                    } else {
                      Navigator.of(context).pop('succes');
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  child: Text(
                    'Trimite e-mail',
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ),
              ),
              TextButton(
                child: Text(
                  'Înapoi',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
