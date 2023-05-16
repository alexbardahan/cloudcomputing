import 'package:cafe_noir/providers/auth.dart';
import 'package:cafe_noir/providers/userData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import 'about_us.dart';
import 'my_orders.dart';
import 'personal_data.dart';

import 'package:url_launcher/url_launcher.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    // final user = context.watch<User>();
    User user = Provider.of<Auth>(context, listen: false)
        .getUser(); //doar pentru afisare cred; nu poti da update

    double contentHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: contentHeight * 0.2),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                  user.displayName != null
                      ? 'Salut, ' + user.displayName + '!'
                      : 'Salut!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w600))),
          SizedBox(height: 35),
          Expanded(
            child: Container(
              width: double.infinity,
              child: Card(
                margin: EdgeInsets.all(0),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20, left: 20, bottom: 35),
                        child: Text('Contul meu',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 22)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MenuButton('Date personale', PersonalData.routeName,
                              Icons.account_circle_outlined),
                          MenuButton('Comenzile mele', MyOrders.routeName,
                              Icons.shopping_cart_outlined),
                          MenuButton('Despre noi', AboutUs.routeName,
                              Icons.people_outline),
                          MenuButton('Termeni și condiții', null,
                              Icons.library_books_outlined),

                          // MenuButton('Evaluează aplicația', null, Icons.star_outline),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 15, bottom: 50),
                        child: GestureDetector(
                          onTap: () async {
                            await context.read<Auth>().signOut();
                            setState(() {
                              Provider.of<UserData>(context, listen: false)
                                  .signOut();
                              // Navigator.of(context).pushReplacementNamed(
                              //     AuthScreen.routeName);
                              print(user);
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout,
                                color: Theme.of(context).primaryColor,
                              ),
                              Text(
                                ' Deconectare',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String text;
  final String routeName;
  final IconData iconData;

  MenuButton(this.text, this.routeName, this.iconData);

  final String _url = 'https://cafe-noir.flycricket.io/terms.html';

  void _launchURL() async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (routeName != null)
          Navigator.of(context).pushNamed(routeName);
        else {
          print('incerc');
          _launchURL();
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(color: Colors.grey[600], width: 0.2),
                bottom: BorderSide(color: Colors.grey[600], width: 0.4))),
        child: Container(
          padding: EdgeInsets.only(top: 18, left: 10, bottom: 18, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    iconData,
                    color: Theme.of(context).primaryColor,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 12),
                    child: Text(
                      text,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Theme.of(context).primaryColor,
              )
            ],
          ),
        ),
      ),
    );
  }
}
