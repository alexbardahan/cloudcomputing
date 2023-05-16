import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NoInternet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 30),
                width: 300,
                height: 300,
                child: Lottie.asset('assets/lottie/lottie_no_internet.json'),
              ),
              Text(
                "No Internet Connection",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: Center(
                  child: Text(
                    "You are not connected to the internet. Make sure Wi-Fi is on and Airplane Mode is Off.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
