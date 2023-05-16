import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cafe_noir/constants.dart';
import 'package:cafe_noir/models/cart_item.dart';
import 'package:cafe_noir/models/product.dart';
import 'package:cafe_noir/providers/auth.dart';
import 'package:cafe_noir/providers/menuData.dart';
import 'package:cafe_noir/providers/orders.dart';
import 'package:cafe_noir/screens/profile_screen/order_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; //for dateformat

class MyOrders extends StatefulWidget {
  static const routeName = 'my-orders';

  @override
  _MyOrdersState createState() => _MyOrdersState();
}

double calculateProductsPrice(
    List<CartItem> cartItems, List<Product> menuData) {
  double total = 0;
  cartItems.forEach((element) {
    total = total +
        element.quantity *
            menuData
                .firstWhere((product) => element.productInfo.id == product.id)
                .price;
  });
  return total;
}

double calculateDiscountPercent(double discount) {
  return (discount != null) ? discount / 100 : 0;
}

double calculateDiscountValue(
    double productsPrice, double deliveryCost, double discount) {
  return (discount != null)
      ? discount / 100 * (productsPrice + deliveryCost)
      : 0;
}

double calculateDeliveryCost(String orderType, double deliveryCost) {
  if (deliveryCost == null) {
    return 0;
  } else {
    if (orderType == 'address') {
      return deliveryCost;
    } else {
      return 0;
    }
  }
}

double calculateTotal(
  List<CartItem> cartItems,
  List<Product> menuData,
  String orderType,
  double deliveryCost,
  double discount,
) {
  final productsPrice = calculateProductsPrice(cartItems, menuData);
  final deliveryCostCalculated = calculateDeliveryCost(orderType, deliveryCost);

  return (productsPrice + deliveryCostCalculated - discount);
}

class _MyOrdersState extends State<MyOrders> {
  Future<String> showPaycheckDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      // barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: FractionalOffset.topRight,
                    child: Icon(
                      Icons.clear,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              Text('Multumim!'),
              Padding(
                padding: const EdgeInsets.only(top: 50, bottom: 10),
                child: Icon(
                  Icons.done_rounded,
                  color: Colors.green,
                  size: 80,
                ),
              )
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    child: Text(
                      'Nota de plata va sosi imediat!',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<Auth>(context, listen: false).getUser();
    final menuData = Provider.of<MenuData>(context).items;

    return Scaffold(
      floatingActionButton: IconButton(
        iconSize: 24,
        color: Colors.white,
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 110),
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
                  // color: Color.fromRGBO(51, 0, 51, 1),
                  color: Colors.white,
                  child: Container(
                    // margin: EdgeInsets.only(top: 5),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20, left: 20, bottom: 25),
                            child: Text(
                              'Comenzile mele',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          StreamBuilderOrders(
                            user: user,
                            menuData: menuData,
                            showPaycheckDialog: showPaycheckDialog,
                          ),
                          SizedBox(
                            height: 30,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class StreamBuilderOrders extends StatelessWidget {
  const StreamBuilderOrders({
    Key key,
    @required this.user,
    @required this.menuData,
    @required this.showPaycheckDialog,
  }) : super(key: key);

  final User user;
  final List<Product> menuData;
  final Function showPaycheckDialog;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance
          .reference()
          .child(databaseOrders)
          .child('current')
          .orderByChild('userId')
          .equalTo(user.uid)
          .onValue,
      builder: (context, snap) {
        if (snap.hasData && !snap.hasError) {
          return StreamBuilder(
              stream: FirebaseDatabase.instance
                  .reference()
                  .child(databaseOrders)
                  .child('past')
                  .orderByChild('userId')
                  .equalTo(user.uid)
                  .onValue,
              builder: (context2, snap2) {
                if (snap2.hasData && !snap2.hasError) {
                  final List<Order> loadedOrders = [];
                  final extractedData = snap.data.snapshot.value;

                  final List<Order> loadedOrders2 = [];
                  final extractedData2 = snap2.data.snapshot.value;

                  if (extractedData == null && extractedData2 == null) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              margin: EdgeInsets.only(top: 80, bottom: 30),
                              width: MediaQuery.of(context).size.width * 0.9,
                              // height: MediaQuery.of(context).size.width * 0.9,
                              child: Lottie.asset(
                                  'assets/lottie/lottie_no_orders.json'),
                            ),
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                'Nu ați efectuat nicio comandă până acum.',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    if (extractedData != null) {
                      print('curente ' + extractedData.length.toString());
                      extractedData.forEach((orderId, orderData) {
                        loadedOrders.add(
                          Order(
                            orderId: orderId,
                            userId: user.uid,
                            payment: orderData['payment'],
                            orderType: orderData['orderType'],
                            chosenTime: orderData['chosenTime'],
                            tableNumber: orderData['tableNumber'],
                            address: orderData['address'],
                            estimatedTime: orderData['estimatedTime'],
                            phoneNumber: orderData['phoneNumber'],
                            paycheck: orderData['paycheck'],
                            cartItems: (orderData['cartItems'] as List<dynamic>)
                                .map((item) => CartItem(
                                    productInfo: menuData.singleWhere(
                                        (element) =>
                                            element.id == item['productId']),
                                    quantity: item['quantity'],
                                    specialInstructions:
                                        item['specialInstructions']))
                                .toList(),
                            dateTime: DateTime.parse(orderData['dateTime']),
                            status: orderData['status'],
                            discount: orderData['discount'],
                            deliveryCost: orderData['deliveryCost'],
                            reason: orderData['reason'],
                          ),
                        );
                        loadedOrders
                            .sort((a, b) => b.dateTime.compareTo(a.dateTime));
                      });
                    }

                    if (extractedData2 != null) {
                      print('past ' + extractedData2.length.toString());
                      extractedData2.forEach((orderId, orderData) {
                        print(orderId);
                        loadedOrders2.add(
                          Order(
                            orderId: orderId,
                            userId: user.uid,
                            payment: orderData['payment'],
                            orderType: orderData['orderType'],
                            chosenTime: orderData['chosenTime'],
                            tableNumber: orderData['tableNumber'],
                            address: orderData['address'],
                            estimatedTime: orderData['estimatedTime'],
                            phoneNumber: orderData['phoneNumber'],
                            paycheck: orderData['paycheck'],
                            cartItems: (orderData['cartItems'] as List<dynamic>)
                                .map((item) => CartItem(
                                    productInfo: menuData.singleWhere(
                                        (element) =>
                                            element.id == item['productId']),
                                    quantity: item['quantity'],
                                    specialInstructions:
                                        item['specialInstructions']))
                                .toList(),
                            dateTime: DateTime.parse(orderData['dateTime']),
                            status: orderData['status'],
                            discount: orderData['discount'],
                            deliveryCost: orderData['deliveryCost'],
                            reason: orderData['reason'],
                          ),
                        );
                        loadedOrders2
                            .sort((a, b) => b.dateTime.compareTo(a.dateTime));
                      });
                    }

                    return Column(
                      children: [
                        if (loadedOrders.isNotEmpty)
                          ...loadedOrders.map(
                            (elem) => OrderItem(
                                elem, menuData, showPaycheckDialog, "current"),
                          ),
                        if (loadedOrders2.isNotEmpty)
                          ...loadedOrders2.map(
                            (elem) => OrderItem(
                                elem, menuData, showPaycheckDialog, "past"),
                          ),
                      ],
                    );
                  }
                } else {
                  return Container();
                }
              });
        } else {
          return Container();
        }
      },
    );
  }
}

class OrderItem extends StatelessWidget {
  final Order elem;
  final List<Product> menuData;
  final Function showPaycheckDialog;
  final String type;

  OrderItem(this.elem, this.menuData, this.showPaycheckDialog, this.type);

  @override
  Widget build(BuildContext context) {
    List<CartItem> productsShown = [];
    // final settings = Provider.of<LoadSettings>(context, listen: false).settings;

    for (int i = 0; i < elem.cartItems.length && i < 2; i++)
      productsShown.add(elem.cartItems[i]);

    if (elem.discount == null) {
      print('discount null');
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderScreen(
              elem,
              calculateProductsPrice,
              calculateDeliveryCost,
              calculateDiscountPercent,
              calculateDiscountValue,
              calculateTotal,
              type,
            ),
          ),
        ).then((value) =>
            value == 'paycheck' ? showPaycheckDialog(context) : null);
      },
      child: Container(
        width: double.infinity,
        height: 120,
        margin: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          // color: Color.fromRGBO(231, 231, 243, 1),
          // color: type == 'current' ? Colors.white : Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 100,
                child: elem.status == "canceledR" || elem.status == "canceled"
                    ? Container(
                        width: 60,
                        height: 60,
                        child: Lottie.asset(
                            'assets/lottie/lottie_order_canceled.json',
                            repeat: false),
                      )
                    : elem.status == 'ordered'
                        ? Container(
                            width: 60,
                            height: 60,
                            child: Lottie.asset(
                                'assets/lottie/lottie_ordered.json',
                                repeat: false),
                          )
                        : elem.status == 'preparing'
                            ? Lottie.asset(
                                'assets/lottie/lottie_preparing.json',
                                repeat: true)
                            : (elem.orderType == 'pickup' &&
                                    elem.status == 'sent')
                                ? Lottie.asset(
                                    'assets/lottie/lottie_pickup.json',
                                    repeat: false)
                                : (elem.orderType == 'address' &&
                                        elem.status == 'sent')
                                    ? Lottie.asset(
                                        'assets/lottie/lottie_address.json')
                                    : (elem.orderType == 'restaurant' &&
                                            elem.status == 'sent')
                                        ? Lottie.asset(
                                            'assets/lottie/lottie_restaurant.json',
                                            repeat: false)
                                        : Container(
                                            width: 85,
                                            height: 85,
                                            child: Lottie.asset(
                                              'assets/lottie/lottie_delivered.json',
                                              repeat: false,
                                            ),
                                          ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 10, top: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: elem.status == 'canceled' ||
                                            elem.status == "canceledR"
                                        ? Text(
                                            'Anulată',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                        : elem.status == 'ordered' ||
                                                elem.status == 'preparing'
                                            ? Row(
                                                children: [
                                                  Text(
                                                    elem.status == 'preparing'
                                                        ? 'În preparare'
                                                        : 'În așteptare',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  AnimatedTextKit(
                                                    animatedTexts: [
                                                      TypewriterAnimatedText(
                                                        '...',
                                                        cursor: '',
                                                        textStyle:
                                                            const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        speed: const Duration(
                                                          milliseconds: 300,
                                                        ),
                                                      ),
                                                    ],
                                                    repeatForever: true,
                                                    pause: const Duration(
                                                        milliseconds: 0),
                                                  ),
                                                ],
                                              )
                                            : (elem.status == 'sent' &&
                                                    elem.orderType == 'address')
                                                ? Row(
                                                    children: [
                                                      Text(
                                                        'Comanda ta este pe drum',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      AnimatedTextKit(
                                                        animatedTexts: [
                                                          TypewriterAnimatedText(
                                                            '...',
                                                            cursor: '',
                                                            textStyle:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            speed:
                                                                const Duration(
                                                              milliseconds: 150,
                                                            ),
                                                          ),
                                                        ],
                                                        repeatForever: true,
                                                        pause: const Duration(
                                                          milliseconds: 0,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : (elem.status == 'sent' &&
                                                        elem.orderType ==
                                                            'pickup')
                                                    ? Text(
                                                        'Gata de ridicare',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      )
                                                    : (elem.status == 'sent' &&
                                                            elem.orderType ==
                                                                'restaurant')
                                                        ? Text(
                                                            'Ospătarul vă va servi imediat',
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          )
                                                        : Text(
                                                            elem.orderType ==
                                                                    'address'
                                                                ? 'Livrată'
                                                                : 'Ridicată',
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(right: 15),
                                    child: Icon(
                                      elem.orderType == 'address'
                                          ? Icons.delivery_dining_outlined
                                          : Icons.pin_drop_outlined,
                                      size: 20,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                ],
                              ),

                              ...productsShown.map(
                                (e) => Text(
                                  e.quantity.toString() +
                                      'x ' +
                                      e.productInfo.title,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                              // Text(elem.orderType),
                              Expanded(
                                child: Container(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                          bottom: 5,
                                          right: 10,
                                        ),
                                        child: Text(
                                          DateFormat("dd MMMM HH:mm")
                                              .format(elem.dateTime),
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                          bottom: 5,
                                          right: 10,
                                        ),
                                        child: Text(
                                          '${calculateTotal(elem.cartItems, menuData, elem.orderType, elem.deliveryCost, elem.discount).toStringAsFixed(2)} lei',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
