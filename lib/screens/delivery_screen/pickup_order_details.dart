import 'dart:convert';

import 'package:cafe_noir/providers/auth.dart';
import 'package:cafe_noir/providers/settings.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart.dart';
import '../../providers/userData.dart';
import './order_item.dart';
import '../../providers/orders.dart';

import 'package:http/http.dart' as http;

class PickupOrderDetails extends StatefulWidget {
  static const routeName = 'pickup-order-details';

  @override
  _PickupOrderDetailsState createState() => _PickupOrderDetailsState();
}

class _PickupOrderDetailsState extends State<PickupOrderDetails> {
  String phoneNumber;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User>();

    Future<String> _getPhoneNumber() async {
      String _idToken =
          await Provider.of<Auth>(context, listen: false).refreshGetToken();
      var userId = user.uid;
      final url = Uri.parse(
          'https://cafenoir-737f5-default-rtdb.europe-west1.firebasedatabase.app/usersDetails/$userId.json?auth=$_idToken');
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData != null) {
        extractedData.forEach((key, value) {
          if (key == 'phoneNumber') {
            phoneNumber = value;
          }
        });
      }

      return phoneNumber;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          iconSize: 24,
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        toolbarHeight: 45,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: FutureBuilder(
        builder: (context, projectSnap) {
          if (projectSnap.connectionState == ConnectionState.none &&
              projectSnap.hasData == null) {
            //print('project snapshot data is: ${projectSnap.data}');
            print('am intrat in connection state no! Error!');
          } else if (projectSnap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(Colors.redAccent),
              ),
            );
          }
          return PickupOrderDetailsBody(phoneNumber, user);
        },
        future: _getPhoneNumber(),
      ),
    );
  }
}

class PickupOrderDetailsBody extends StatefulWidget {
  String phoneNumber;
  final User user;

  PickupOrderDetailsBody(this.phoneNumber, this.user);

  @override
  _PickupOrderDetailsBodyState createState() => _PickupOrderDetailsBodyState();
}

class _PickupOrderDetailsBodyState extends State<PickupOrderDetailsBody> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  FirebaseAnalytics analytics = FirebaseAnalytics();

  Future<void> _submit(
    Cart cart,
    User user,
    bool checkBox,
    String chosenTime,
    bool discount,
    double discountValue,
    String totalProductsReduction,
    double amountDouble,
  ) async {
    // print(chosenTime);
    if (chosenTime == null) {
      setState(() {
        _showErrorHour = true;
      });
      return;
    }
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    final String idToken =
        await Provider.of<Auth>(context, listen: false).refreshGetToken();

    await Provider.of<PlacedOrders>(context, listen: false).addOrder(
      cart: cart,
      user: user,
      phoneNumber: widget.phoneNumber,
      checkBox: checkBox,
      idToken: idToken,
      orderType: 'pickup',
      chosenTime: chosenTime,
      status: 'ordered',
      discount: discount ? double.parse(totalProductsReduction) : null,
      amount: amountDouble,
    );

    await analytics.logEvent(
      name: 'custom_purchase',
      parameters: <String, dynamic>{
        'value': amountDouble,
        'currency': 'RON',
        'type': 'pickup',
        'payment': 'cash/card',
        'noOfProducts': cart.numberOfProducts,
        'noOfItems': cart.itemCount,
      },
    );
    print('log custom_purchase ' + amountDouble.toString());

    Navigator.of(context).pop('ordered');
  }

  bool checkBox = false;
  String chosenTime;
  bool _showErrorHour = false;

  changePhoneNumber(String newNumber) {
    setState(() {
      widget.phoneNumber = newNumber;
    });
  }

  void _changeChosenTime(String newTime) {
    setState(() {
      chosenTime = newTime;
    });
  }

  void _changeShowErrorHour() {
    setState(() {
      _showErrorHour = false;
    });
  }

  Future<void> initAnalytics(Cart cart) async {
    final double amountDouble = cart.getTotalAmount() - cart.getReduction();

    var items = {};
    cart.items.forEach((element) {
      items[element.productInfo.id] = element.quantity;
    });
    print(items);

    await analytics.logEvent(
      name: 'begin_checkout',
      parameters: <String, dynamic>{
        'value': amountDouble,
        'currency': 'RON',
        'type': 'pickup',
      },
    );

    print('log begin checkout: ' + amountDouble.toString());
  }

  @override
  void initState() {
    super.initState();
    final cart = Provider.of<Cart>(context, listen: false);
    initAnalytics(cart);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final Set<CartItem> orderItems = cart.items;
    final totalProductsPrice = cart.getTotalAmount().toStringAsFixed(2);
    final settings = Provider.of<LoadSettings>(context, listen: false).settings;
    List<String> hoursList = [];
    final String totalProductsReduction =
        cart.getReduction().toStringAsFixed(2);

    final int closingHour =
        Provider.of<LoadSettings>(context, listen: false).settings.closingHour;
    DateTime lastPickUp = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, closingHour, 0, 0, 0, 0);
    DateTime iterator = DateTime.now().add(Duration(minutes: 30));
    while (iterator.isBefore(lastPickUp)) {
      if (iterator.minute % 15 == 0) {
        hoursList.add(
            '${iterator.hour}:${iterator.minute == 0 ? '0' + iterator.minute.toString() : iterator.minute}');
      }
      iterator = iterator.add(const Duration(minutes: 1));
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        //when you tap out of form, the keyboard disapear
      },
      child: Container(
        width: double.infinity,
        child: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    child: Center(
                      child: Text(
                        'Comanda ta',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(0),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (ctx, index) {
                      return OrderItem(orderItems.elementAt(index));
                    },
                    itemCount: cart.numberOfProducts,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding:
                              EdgeInsets.only(left: 13, top: 20, bottom: 5),
                          child: Text(
                            'Detalii ridicare',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 15, top: 15),
                          child: Text(
                            'Ora la care doriți să ridicați comanda:',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w300,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 15, top: 5, bottom: 5),
                          child: _showErrorHour
                              ? hoursList.isNotEmpty
                                  ? Text(
                                      'Vă rugăm alegeți ora la care ridicați comanda!',
                                      style: TextStyle(
                                          color: Colors.redAccent[700],
                                          fontSize: 12),
                                    )
                                  : Text(
                                      'Nu se mai pot prelua comenzi deoarece este aproape ora închiderii!',
                                      style: TextStyle(
                                        color: Colors.redAccent[700],
                                      ),
                                    )
                              : Container(),
                        ),
                        hoursList.isNotEmpty
                            ? SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  height: 50,
                                  child: Row(
                                    children: [
                                      ...hoursList
                                          .map((e) => HourItem(
                                              e,
                                              chosenTime,
                                              _changeChosenTime,
                                              _changeShowErrorHour))
                                          .toList()
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: HourItem(
                                  'Nu se mai pot prelua comenzi!',
                                  '',
                                  _changeChosenTime,
                                  _changeShowErrorHour,
                                ),
                              ),
                        Container(
                          padding:
                              EdgeInsets.only(left: 10, right: 20, top: 15),
                          child: TextFormField(
                            keyboardType: TextInputType.phone,
                            style: TextStyle(color: Colors.grey[600]),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.phone_enabled,
                                color: Theme.of(context).primaryColor,
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey[400]),
                              ),
                              labelText: 'Telefon',
                              labelStyle: TextStyle(color: Colors.grey[500]),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 6),
                              hintText: 'Număr de telefon',
                              hintStyle: TextStyle(color: Colors.white54),
                            ),
                            initialValue: widget.phoneNumber,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Va rugam introduceti numarul de telefon!';
                              }
                              if (value.length < 10 ||
                                  value.length > 13 ||
                                  value.contains(new RegExp(r'[a-z]')) ||
                                  value.contains(new RegExp(r'[A-Z]'))) {
                                return 'Va rugam introduceti un numar de telefon valid!';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              Provider.of<UserData>(context, listen: false)
                                  .phoneNumber = value;
                            },
                            onSaved: (value) {
                              changePhoneNumber(value);
                            },
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 15, top: 8, bottom: 5),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(right: 8),
                                child: SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                        unselectedWidgetColor:
                                            Colors.grey[500]),
                                    child: Checkbox(
                                      checkColor: Colors.white,
                                      activeColor:
                                          Theme.of(context).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      value: checkBox,
                                      onChanged: (bool value) {
                                        setState(() {
                                          checkBox = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    checkBox = !checkBox;
                                  });
                                },
                                child: Text(
                                  'Reține numărul pentru comenzile viitoare',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 13, top: 20, bottom: 5),
                    child: Text(
                      'Sumar comandă',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 13, right: 13),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        settings.discountPickup
                            ? Container(
                                padding:
                                    const EdgeInsets.only(bottom: 5, top: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total comandă",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      double.parse(totalProductsPrice)
                                              .toStringAsFixed(2) +
                                          " Lei",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 15,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Container(),
                        settings.discountPickup
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Reducere aplicație ",
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '-' + totalProductsReduction + " lei",
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 15,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Container(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18),
                              ),
                              Text(
                                  (double.parse(totalProductsPrice) -
                                              double.parse(
                                                  totalProductsReduction))
                                          .toStringAsFixed(2) +
                                      " Lei",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Suma afișată va fi plătită numerar sau cu cardul atunci când ridicați comanda din restaurant.',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 80)
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      _submit(
                        cart,
                        widget.user,
                        checkBox,
                        chosenTime,
                        settings.discountPickup,
                        settings.discountValuePickup,
                        totalProductsReduction,
                        double.parse(totalProductsPrice) -
                            double.parse(totalProductsReduction),
                      );
                    },
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 35),
                      padding: EdgeInsets.symmetric(vertical: 13),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Theme.of(context).accentColor,
                      ),
                      child: Center(
                        child: Text(
                          'Confirmă comanda',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class HourItem extends StatelessWidget {
  final String hour;
  final Function _changeChosenTime;
  final Function _changeShowErrorHour;
  final String chosenTime;
  HourItem(this.hour, this.chosenTime, this._changeChosenTime,
      this._changeShowErrorHour);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (hour == 'Nu se mai pot prelua comenzi!') {
          _changeShowErrorHour();
          return;
        }
        _changeChosenTime(hour);
        _changeShowErrorHour();
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color:
            chosenTime == hour ? Theme.of(context).primaryColor : Colors.white,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Text(
            hour,
            style: chosenTime == hour
                ? TextStyle(fontWeight: FontWeight.w700, color: Colors.white)
                : TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
          ),
        ),
      ),
    );
  }
}
