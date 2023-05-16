import 'dart:async';
import 'dart:io';

import 'package:cafe_noir/providers/advert.dart';
import 'package:cafe_noir/providers/event.dart';
import 'package:cafe_noir/providers/menuData.dart';
import 'package:cafe_noir/providers/settings.dart';
import 'package:cafe_noir/screens/auth_screen/verify_email.dart';
import 'package:cafe_noir/screens/tabs_screen.dart';
import 'package:cafe_noir/services/apple_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

import 'auth_card.dart';

import '../../services/menu_sheets_api.dart';
import '../../services/payment-service.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:lottie/lottie.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  RemoteNotification notification = message.notification;
  AndroidNotification android = message.notification?.android;
  final data = message.data;
  print('am ajuns aici in _firebaseMessagingBackgroundHandler');
  // if (!Platform.isAndroid) {
  // la inceput cand implementam se trimiteau notificari automat fara sa ma folosesc eu de local notifications
  // dar spre final de implementare nu a mai mers, idk de ce
  flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    data['title'],
    data['body'],
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channel.description,
        icon: android?.smallIcon,
        color: Color.fromRGBO(128, 0, 128, 1),
        priority: Priority.high,
      ),
      iOS: IOSNotificationDetails(),
    ),
  );
  // }
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initAplicatie() async {
  await AppleSignInAvailable.check();
  StripeService.init();

  // background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Firebase local notification plugin
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);

  //Firebase messaging (pentru ios)
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
}

Future<void> initGSheets() async {
  print('init starting');
  await MenuSheetsApi.init(); //metoda in user_sheets_api.dart
  print('init done');

  print('fetch menu');
  await MenuData.fetchMenuData(); //metoda pt a incarca meniul
  print('fetch menu done');

  print('fetch advert');
  await LoadAdvert.fetchAdvert(); //metoda pt a incarca reclama
  print('fetch advert done');

  print('fetch settings');
  await LoadSettings.fetchSettings(); //metoda pt a incarca setari
  print('fetch settings done');

  print('fetch event');
  await LoadEvent.fetchEvent(); //metoda pt a incarca evenimente
  print('fetch event done');
}

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var isLoading = false;

  void switchIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  Future<void> _showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('A apărut o eroare!'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User>(); //echivalent cu Provider.of<User>

    return Scaffold(
      body: FutureBuilder(
        future: initAplicatie(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 12.0),
                child: Container(
                  width: 120,
                  height: 120,
                  child: Lottie.asset('assets/lottie/lottie_loading.json'),
                ),
              );
            default:
              if (snapshot.hasError)
                return Text('Error: ${snapshot.error}');
              else {
                return isLoading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: Container(
                                width: 120,
                                height: 120,
                                child: Lottie.asset(
                                    'assets/lottie/lottie_loading.json'),
                              ),
                            ),
                          ),
                        ],
                      )
                    : user != null
                        ? Center(
                            child: FutureBuilder(
                              future: initGSheets(),
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    print('init g sheets');
                                    return Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        child: Lottie.asset(
                                            'assets/lottie/lottie_loading.json'),
                                      ),
                                    );
                                  default:
                                    if (snapshot.hasError)
                                      return Text('Error: ${snapshot.error}');
                                    else {
                                      print('am terminat g sheets');
                                      final settings =
                                          Provider.of<LoadSettings>(
                                        context,
                                        listen: false,
                                      ).settings;
                                      return UpgradeAlert(
                                        debugLogging: false,
                                        dialogStyle: Platform.isIOS
                                            ? UpgradeDialogStyle.cupertino
                                            : UpgradeDialogStyle.material,
                                        messages: MyRomanianMessages(),
                                        minAppVersion:
                                            settings.requiredMinVersion,
                                        canDismissDialog: false,
                                        showIgnore: false,
                                        showLater: false,
                                        showReleaseNotes: false,
                                        child: VerifyEmail(),
                                      );
                                    }
                                }
                              },
                            ),
                          )
                        : AuthCard(switchIsLoading, _showErrorDialog);
              }
          }
        },
      ),
    );
  }
}
