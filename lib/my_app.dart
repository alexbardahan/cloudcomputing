import 'package:cafe_noir/providers/event.dart';
import 'package:cafe_noir/providers/menuData.dart';
import 'package:cafe_noir/providers/settings.dart';
import 'package:cafe_noir/providers/userData.dart';
import 'package:cafe_noir/screens/delivery_screen/choose_payment_method.dart';
import 'package:cafe_noir/screens/delivery_screen/existing_cards_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/auth_screen/auth_screen.dart';
import 'providers/advert.dart';
import 'screens/delivery_screen/address_order_details.dart';
import './providers/orders.dart';
import './providers/cart.dart';
import './providers/auth.dart';
import 'screens/profile_screen/about_us.dart';
import 'screens/profile_screen/my_orders.dart';
import 'screens/profile_screen/personal_data.dart';
import 'screens/auth_screen/forgot_password_screen.dart';
import 'screens/delivery_screen/pickup_order_details.dart';
import 'screens/delivery_screen/restaurant_order_details.dart';

import 'screens/no_internet.dart';
import 'providers/connectivity_provider.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (consumerContext, model, child) {
        if (model.isOnline != null) {
          return model.isOnline ? App() : NoInternet();
        }
        return Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Cart()),
        ChangeNotifierProvider(create: (_) => MenuData()),
        ChangeNotifierProvider(create: (_) => PlacedOrders()),
        ChangeNotifierProvider(create: (_) => UserData()),
        ChangeNotifierProvider(create: (_) => LoadSettings()),
        ChangeNotifierProvider(create: (_) => LoadAdvert()),
        ChangeNotifierProvider(create: (_) => LoadEvent()),
        Provider<Auth>(create: (_) => Auth(FirebaseAuth.instance)),
        StreamProvider(
            create: (ctx) => ctx.read<Auth>().authStateChanges,
            initialData: null),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutters Demo',
        theme: ThemeData(
          primaryColor: Color.fromRGBO(128, 0, 128, 1),
          accentColor: Color.fromRGBO(255, 192, 78, 1),
          unselectedWidgetColor: Colors.white,
          fontFamily: 'OpenSans',
        ),
        home: AuthScreen(),
        routes: {
          AddressOrderDetails.routeName: (ctx) => AddressOrderDetails(),
          RestaurantOrderDetails.routeName: (ctx) => RestaurantOrderDetails(),
          PickupOrderDetails.routeName: (ctx) => PickupOrderDetails(),
          MyOrders.routeName: (ctx) => MyOrders(),
          PersonalData.routeName: (ctx) => PersonalData(),
          ForgotPassword.routeName: (context) => ForgotPassword(),
          AboutUs.routeName: (ctx) => AboutUs(),
          ChoosePaymentMethod.routeName: (ctx) => ChoosePaymentMethod(),
          ExistingCardsPage.routeName: (ctx) => ExistingCardsPage(),
        },
      ),
    );
  }
}
