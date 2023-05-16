import 'dart:convert';

import 'package:cafe_noir/providers/auth.dart';
import 'package:cafe_noir/providers/orders.dart';
import 'package:cafe_noir/providers/settings.dart';
import 'package:cafe_noir/screens/delivery_screen/choose_payment_method.dart';
import 'package:cafe_noir/services/payment-service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../../models/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart.dart';
import './order_item.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_analytics/firebase_analytics.dart';

class AddressOrderDetails extends StatefulWidget {
  static const routeName = 'address-order-details';

  @override
  _AddressOrderDetailsState createState() => _AddressOrderDetailsState();
}

class _AddressOrderDetailsState extends State<AddressOrderDetails> {
  String address;
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
          if (key == 'address') {
            address = value;
          }
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
      // floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: FutureBuilder(
        builder: (context, projectSnap) {
          if (projectSnap.connectionState == ConnectionState.none &&
              projectSnap.hasData == null) {
            print('am intrat in connection state no! Error!');
          } else if (projectSnap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(Colors.redAccent),
              ),
            );
          }

          return AddressOrderDetailsBody(
              phoneNumber: phoneNumber, address: address, user: user);
        },
        future: _getPhoneNumber(),
      ),
    );
  }
}

class AddressOrderDetailsBody extends StatefulWidget {
  String phoneNumber;
  String address;
  final User user;

  AddressOrderDetailsBody({
    this.phoneNumber,
    this.address,
    this.user,
  });

  @override
  _AddressOrderDetailsBodyState createState() =>
      _AddressOrderDetailsBodyState();
}

class _AddressOrderDetailsBodyState extends State<AddressOrderDetailsBody> {
  bool choosePayment;
  bool checkBox = false;
  final GlobalKey<FormState> _formKey = GlobalKey();

  String paymentType; //cash sau card
  String paymentMethodId; //detaliile cardului

  FirebaseAnalytics analytics = FirebaseAnalytics();

  changePhoneNumber(String newNumber) {
    setState(() {
      widget.phoneNumber = newNumber;
    });
  }

  changeAddress(String newAddress) {
    setState(() {
      widget.address = newAddress;
    });
  }

  void changePaymentType(String paymentType) {
    setState(() {
      this.paymentType = paymentType;
      choosePayment = true;
    });
  }

  void changePaymentMethod(String paymentMethodId) {
    setState(() {
      this.paymentMethodId = paymentMethodId;
      choosePayment = true;
    });
  }

  void __showSnackbar(
      Cart cart,
      User user,
      bool checkBox,
      String amount,
      double amountDouble,
      bool discount,
      int minimumDeliveryPrice,
      double discountValue,
      double deliveryCost,
      double totalProductsReduction) {
    final snackBar = SnackBar(
      content: const Text('Transaction failed.'),
      action: SnackBarAction(
        label: 'Try again',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          _submit(
              cart,
              user,
              checkBox,
              amount,
              amountDouble,
              discount,
              minimumDeliveryPrice,
              discountValue,
              deliveryCost,
              totalProductsReduction);
        },
      ),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _minimumPriceDialog(
      BuildContext context,
      int minimumDeliveryPrice,
      Cart cart,
      double totalProductsReduction) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text('Comanda minimă este de $minimumDeliveryPrice lei',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 19,
                )),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  width: 120,
                  height: 120,
                  child: Lottie.asset(
                    'assets/lottie/add_more_to_cart.json',
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Adăugați produse în valoare de ${(minimumDeliveryPrice - cart.getTotalAmount()).toStringAsFixed(2)} lei pentru a vă finaliza comanda.',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
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
                child: Text(
                  'Inapoi la produse',
                  style: TextStyle(color: Colors.grey[700], fontSize: 15),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }

  Future<void> _submit(
    Cart cart,
    User user,
    bool checkBox,
    String amount,
    double amountDouble,
    bool discount,
    int minimumDeliveryPrice,
    double discountValue,
    double deliveryCost,
    double totalProductsReduction,
  ) async {
    if ((cart.getTotalAmount()) < minimumDeliveryPrice) {
      _minimumPriceDialog(
              context, minimumDeliveryPrice, cart, totalProductsReduction)
          .then((value) => Navigator.of(context).pop());
      return;
    }
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }

    if (choosePayment == null || choosePayment == false) {
      setState(() {
        choosePayment = false;
      });
      return;
    }

    _formKey.currentState.save();

    if (cart.itemCount != 0) {
      // se poate efectua comanda

      ProgressDialog dialog = new ProgressDialog(context);
      dialog.style(message: 'Please wait...');
      await dialog.show();
      final String idToken =
          await Provider.of<Auth>(context, listen: false).refreshGetToken();

      if (paymentType == 'card') {
        final response = await StripeService.payWithCard(
          amount: amount,
          currency: 'RON',
          userId: user.uid,
          idToken: idToken,
          paymentMethodId: paymentMethodId,
        );
        if (response.success == false) {
          dialog.hide();
          __showSnackbar(
            cart,
            user,
            checkBox,
            amount,
            amountDouble,
            discount,
            minimumDeliveryPrice,
            discountValue,
            deliveryCost,
            totalProductsReduction,
          );
          return;
        }
        print('trebuie sa platesti: ' + amount);
      }

      await Provider.of<PlacedOrders>(context, listen: false).addOrder(
        cart: cart,
        user: user,
        address: widget.address,
        phoneNumber: widget.phoneNumber,
        checkBox: checkBox,
        idToken: idToken,
        payment: paymentType,
        orderType: 'address',
        status: 'ordered',
        discount: discount ? totalProductsReduction : null,
        deliveryCost: deliveryCost,
        amount: amountDouble,
      );

      await analytics.logEvent(
        name: 'custom_purchase',
        parameters: <String, dynamic>{
          'value': amountDouble,
          'currency': 'RON',
          'type': 'address',
          'payment': paymentType == 'card' ? 'card' : 'cash',
          'noOfProducts': cart.numberOfProducts,
          'noOfItems': cart.itemCount,
        },
      );
      print('log custom_purchase ' + amountDouble.toString());

      await dialog.hide();
      Navigator.of(context).pop('ordered');
    } else {
      ProgressDialog dialog = new ProgressDialog(context);
      dialog.style(message: 'Nu se pot efectua comenzi cu coșul gol...');
      await dialog.show();
      await dialog.hide();
      Navigator.of(context).pop();
      return;
    }
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
        'type': 'address',
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
    final String totalProductsPrice = cart.getTotalAmount().toStringAsFixed(2);
    final String totalProductsReduction =
        cart.getReduction().toStringAsFixed(2);
    final settings = Provider.of<LoadSettings>(context, listen: false).settings;

    final String deliveryCost = settings.deliveryCost.toStringAsFixed(2);

    return Container(
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
                        padding: EdgeInsets.only(left: 13, top: 20, bottom: 5),
                        child: Text(
                          'Detalii livrare',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                        child: TextFormField(
                          style: TextStyle(color: Colors.grey[800]),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.location_on,
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
                            labelText: 'Adresa',
                            labelStyle: TextStyle(color: Colors.grey[500]),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 6,
                            ),
                            hintText: 'Introduceti adresa',
                            hintStyle: TextStyle(color: Colors.white54),
                          ),
                          initialValue: widget.address,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Va rugam introduceti adresa!';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            // Provider.of<UserData>(context, listen: false)
                            //     .address = value;
                          },
                          onSaved: (value) {
                            changeAddress(value);
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 20, right: 20, top: 10),
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
                                  color: Theme.of(context).primaryColor),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[400]),
                            ),
                            labelText: 'Telefon',
                            labelStyle: TextStyle(color: Colors.grey[500]),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 6,
                            ),
                            hintText: 'Numar de telefon',
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
                            // Provider.of<UserData>(context, listen: false)
                            //     .phoneNumber = value;
                          },
                          onSaved: (value) {
                            changePhoneNumber(value);
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 35, top: 15, bottom: 5),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(right: 8),
                              child: SizedBox(
                                height: 18,
                                width: 18,
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                      unselectedWidgetColor: Colors.grey[600]),
                                  child: Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Theme.of(context).primaryColor,
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
                                'Reține pentru comenzile viitoare',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w300,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 13, top: 20, bottom: 5),
                        child: Text(
                          'Metoda de plată',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                              ChoosePaymentMethod.routeName,
                              arguments: {
                                // 'paymentMethod': paymentMethod,
                                'changePaymentMethod': changePaymentMethod,
                                'changePaymentType': changePaymentType,
                                'user': widget.user,
                              });
                        },
                        child: Container(
                            margin: EdgeInsets.only(left: 13, right: 13),
                            padding: EdgeInsets.only(right: 10, left: 10),
                            width: double.infinity,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey[200],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      margin: EdgeInsets.only(
                                        right: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50.0)),
                                        color: Colors.white,
                                      ),
                                      child: Icon(
                                        Icons.payment_outlined,
                                        size: 28,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Plătește cu',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        paymentType == null
                                            ? Text(
                                                'Alege metoda de plată',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            : paymentType == 'card'
                                                ? Text(
                                                    'Card',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  )
                                                : Text(
                                                    'Cash',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                      ],
                                    )
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ],
                            )),
                      ),
                      choosePayment == false
                          ? Padding(
                              padding: const EdgeInsets.only(left: 13),
                              child: Text(
                                'Vă rugăm alegeți metoda de plată!',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 13),
                              ),
                            )
                          : Container(),
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
                  padding: EdgeInsets.only(left: 13, top: 10, right: 13),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Preț produse",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              totalProductsPrice + " Lei",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Cost livrare",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              deliveryCost + " Lei",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                      ),
                      settings.discountAddress
                          ? Container(
                              padding:
                                  const EdgeInsets.only(bottom: 5, top: 10),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    // color: Theme.of(context).primaryColor,
                                    // color: Theme.of(context).accentColor,
                                    color: Colors.grey[500],
                                    width: 1,
                                  ),
                                ),
                              ),
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
                                    (double.parse(deliveryCost) +
                                                double.parse(
                                                    totalProductsPrice))
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
                      settings.discountAddress
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
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              ((double.parse(deliveryCost) +
                                          double.parse(totalProductsPrice) -
                                          double.parse(totalProductsReduction)))
                                      .toStringAsFixed(2) +
                                  " lei",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          ],
                        ),
                      ),
                      (cart.getTotalAmount()) < settings.minimumDeliveryPrice
                          ? Text(
                              'Comanda minimă este de ${settings.minimumDeliveryPrice.toStringAsFixed(2)} de lei. Adăugați produse în valoare de ${(settings.minimumDeliveryPrice - cart.getTotalAmount()).toStringAsFixed(2)} lei pentru a finaliza comanda.',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                              ),
                            )
                          : Container(),
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
              Container(),
              Center(
                child: GestureDetector(
                  onTap: () {
                    final String amount = (double.parse(totalProductsPrice) -
                            double.parse(totalProductsReduction))
                        .toStringAsFixed(2)
                        .replaceFirst('.', '');
                    final double amountDouble =
                        double.parse(totalProductsPrice) -
                            double.parse(totalProductsReduction);

                    _submit(
                      cart,
                      widget.user,
                      checkBox,
                      amount,
                      amountDouble,
                      settings.discountAddress,
                      settings.minimumDeliveryPrice,
                      settings.discountValueAddress,
                      double.parse(deliveryCost),
                      double.parse(totalProductsReduction),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 35),
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
    );
  }
}
