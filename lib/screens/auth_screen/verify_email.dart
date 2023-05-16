import 'dart:async';
import 'package:cafe_noir/providers/auth.dart';
import 'package:cafe_noir/screens/tabs_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class VerifyEmail extends StatefulWidget {
  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  final auth = FirebaseAuth.instance;
  User user;
  Timer timer;

  @override
  void initState() {
    user = auth.currentUser;

    print(user.providerData[0].providerId);

    if (user.providerData[0].providerId.contains('facebook') ||
        user.providerData[0].providerId.contains('google') ||
        user.providerData[0].providerId.contains('apple')) {
    } else {
      if (!user.emailVerified) user.sendEmailVerification();
      timer = Timer.periodic(Duration(seconds: 5), (timer) {
        checkEmailVerified();
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    if (timer != null) timer.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    user = auth.currentUser;
    await user.reload();
    if (user.emailVerified) {
      timer.cancel();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    print('verific daca are sau nu mail-ul verificat');

    double height = MediaQuery.of(context).size.width * 0.8;
    String providerId = user.providerData[0].providerId;

    if (providerId.contains('facebook') ||
        providerId.contains('google') ||
        providerId.contains('apple')) {
      return TabsScreen();
    } else if (!user.emailVerified) {
      return Scaffold(
        body: SafeArea(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: height,
                      height: height,
                      child: Lottie.asset(
                          'assets/lottie/lottie_email_verification.json'),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 30),
                      child: Center(
                        child: Text(
                          'Un e-mail a fost trimis la adresa ${user.email}. Vă rugăm accesați link-ul pentru a confirma contul!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromRGBO(128, 0, 128, 1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          textStyle: const TextStyle(fontSize: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          user.sendEmailVerification();
                        },
                        child: const Text('Retrimite e-mail'),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          textStyle: const TextStyle(fontSize: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Provider.of<Auth>(context, listen: false).signOut();
                        },
                        child: const Text('Înapoi'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return TabsScreen();
    }
  }
}
