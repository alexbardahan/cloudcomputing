import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cafe_noir/screens/profile_screen/account_screen.dart';
import 'package:provider/provider.dart';
import 'main_screen/home_screen.dart';
import 'delivery_screen/delivery_screen.dart';
import 'reservation_screen/reservation_screen.dart';
import 'package:upgrader/upgrader.dart';

class MyRomanianMessages extends UpgraderMessages {
  // Override the message function to provide custom language localization.
  @override
  String message(UpgraderMessage messageKey) {
    switch (messageKey) {
      case UpgraderMessage.body:
        return 'O nouă versiune a aplicatiei {{appName}} este disponibilă!';
      case UpgraderMessage.buttonTitleIgnore:
        return 'Ignoră';
      case UpgraderMessage.buttonTitleLater:
        return 'Mai târziu';
      case UpgraderMessage.buttonTitleUpdate:
        return 'Actualizează';
      case UpgraderMessage.prompt:
        return 'Pentru a beneficia de ultimele caracteristici te rugăm să faci update!';
      case UpgraderMessage.title:
        return 'Actualizeaza aplicatia?';
    }
    // Messages that are not provided above can still use the default values.
    return super.message(messageKey);
  }
}

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  List<Map<String, Object>> _pages;
  int _selectedPageIndex = 0;

  final FirebaseAnalytics analytics = FirebaseAnalytics();

  Future<void> initAnalytics(User user) async {
    print('log set user id');
    await analytics.setUserId(user.uid);
  }

  @override
  void initState() {
    _pages = [
      {'page': HomeScreen(_selectPage), 'title': 'CafeNoir'},
      {'page': DeliveryScreen(_selectPage), 'title': 'Order'},
      {'page': ReservationScreen(), 'title': 'Reservation'},
      {'page': AccountScreen(), 'title': 'Profile'}
    ];

    final user = Provider.of<User>(context, listen: false);
    initAnalytics(user);

    super.initState();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  // String dropdownValue = 'Livrare la adresa';

  @override
  Widget build(BuildContext context) {
    // User user = Provider.of<Auth>(context, listen: false).getUser();
    // double height = MediaQuery.of(context).size.width * 0.8;
    // final settings = Provider.of<LoadSettings>(context, listen: false).settings;
    // print(AppleSignInAvailable.availability);
    print('am intrat in tabs screen si fac scaffold');

    BottomNavigationBar bottomBar = BottomNavigationBar(
      currentIndex: _selectedPageIndex,
      type: BottomNavigationBarType.fixed,
      //without it, backgroundColor property doesn't work

      //var1
      // backgroundColor: Theme.of(context).primaryColor,
      // unselectedItemColor: Colors.white,
      // selectedItemColor: Theme.of(context).accentColor,
      // iconSize: 30,

      //var2
      backgroundColor: Colors.white,
      unselectedItemColor: Colors.grey,
      selectedItemColor: Theme.of(context).primaryColor,
      iconSize: 24,

      selectedIconTheme: IconThemeData(size: 30),
      onTap: _selectPage,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Order',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.schedule),
          label: 'Reservation',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Profile',
        ),
      ],
    );

    return Scaffold(
      appBar: (_pages[_selectedPageIndex]['title'] == 'Profile' ||
              _pages[_selectedPageIndex]['title'] == 'Order')
          ? null
          : AppBar(
              toolbarHeight: 45,
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 0,
              title: Text(
                _pages[_selectedPageIndex]['title'],
                style: TextStyle(color: Colors.white),
              ),
            ),
      body: _pages[_selectedPageIndex]['page'],
      bottomNavigationBar: bottomBar,
    );
  }
}
