import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cafe_noir/models/cart_item.dart';
import 'package:cafe_noir/providers/menuData.dart';
import 'package:cafe_noir/providers/orders.dart';
// import 'package:cafe_noir/providers/settings.dart';
import 'package:cafe_noir/screens/profile_screen/my_orders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; //for dateformat

class OrderScreen extends StatefulWidget {
  final Order order;

  final Function calculateProductsPrice;
  final Function calculateDeliveryCost;
  final Function calculateDiscountPercent;
  final Function calculateDiscountValue;
  final Function calculateTotal;
  final String type;

  OrderScreen(
    this.order,
    this.calculateProductsPrice,
    this.calculateDeliveryCost,
    this.calculateDiscountPercent,
    this.calculateDiscountValue,
    this.calculateTotal,
    this.type,
  );

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Future<String> showPaycheckDialog(BuildContext context, User user) async {
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
              Text('Nota de plată'),
              Padding(
                padding: const EdgeInsets.only(top: 50, bottom: 10),
                child: Icon(
                  Icons.assignment,
                  color: Theme.of(context).primaryColor,
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
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Cum doriți să achitați nota?',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: Text(
                      'Cash',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () {
                      Provider.of<PlacedOrders>(context, listen: false)
                          .requestPaycheck(
                              user: user,
                              context: context,
                              order: widget.order,
                              payment: 'cash');
                      Navigator.of(context).pop('paycheck');
                    },
                  ),
                  TextButton(
                    child: Text(
                      'Card',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () async {
                      await Provider.of<PlacedOrders>(context, listen: false)
                          .requestPaycheck(
                              user: user,
                              context: context,
                              order: widget.order,
                              payment: 'card');
                      Navigator.of(context).pop('paycheck');
                    },
                  ),
                ],
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

  @override
  Widget build(BuildContext context) {
    final menuData = Provider.of<MenuData>(context).items;
    final user = context.watch<User>();
    // final settings = Provider.of<LoadSettings>(context, listen: false).settings;

    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Comanda ta'),
        elevation: 0,
        backgroundColor: Color.fromRGBO(128, 0, 128, 1),
        toolbarHeight: 45,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 20),
            child: Icon(
              widget.order.orderType == 'address'
                  ? Icons.delivery_dining_outlined
                  : Icons.pin_drop_outlined,
              size: 25,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Container(
        width: width,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    // color: Colors.red,
                    child: widget.order.status == "canceledR" ||
                            widget.order.status == "canceled"
                        ? Center(
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: 40, left: 50, right: 50, bottom: 40),
                              width: width / 3,
                              height: width / 3,
                              child: Lottie.asset(
                                'assets/lottie/lottie_order_canceled.json',
                                repeat: false,
                              ),
                            ),
                          )
                        : widget.order.status == 'ordered'
                            ? Center(
                                child: Container(
                                  margin: EdgeInsets.only(top: 30),
                                  width: width / 2,
                                  height: width / 2,
                                  child: Lottie.asset(
                                      'assets/lottie/lottie_ordered.json'),
                                ),
                              )
                            : widget.order.status == 'preparing'
                                ? Center(
                                    child: Container(
                                      width: width / 1.5,
                                      height: width / 1.5,
                                      child: Lottie.asset(
                                          'assets/lottie/lottie_preparing.json'),
                                    ),
                                  )
                                : widget.order.orderType == 'pickup' &&
                                        widget.order.status == 'sent'
                                    ? Center(
                                        child: Container(
                                          width: width / 2,
                                          height: width / 2,
                                          child: Lottie.asset(
                                              'assets/lottie/lottie_pickup.json'),
                                        ),
                                      )
                                    : widget.order.orderType == 'address' &&
                                            widget.order.status == 'sent'
                                        ? Lottie.asset(
                                            'assets/lottie/lottie_address.json')
                                        : Center(
                                            child: Container(
                                              margin: EdgeInsets.only(top: 30),
                                              width: width / 2,
                                              height: width / 2,
                                              child: Lottie.asset(
                                                  'assets/lottie/lottie_delivered.json'),
                                            ),
                                          ),
                  ),
                  Container(
                    // color: Colors.blue,
                    margin: EdgeInsets.only(bottom: 10),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.order.status == 'canceledR'
                                ? 'Comanda a fost anulată'
                                : widget.order.status == 'ordered'
                                    ? 'Comanda este în așteptare'
                                    : widget.order.status == 'preparing'
                                        ? 'Comanda este în preparare'
                                        : (widget.order.orderType == 'pickup' &&
                                                widget.order.status == 'sent')
                                            ? 'Comanda ta este gata de ridicare'
                                            : (widget.order.orderType ==
                                                        'address' &&
                                                    widget.order.status ==
                                                        'sent')
                                                ? 'Comanda ta este pe drum'
                                                : (widget.order.orderType ==
                                                            'restaurant' &&
                                                        widget.order.status ==
                                                            'sent')
                                                    ? 'Ospatarul vă va servi imediat'
                                                    : '',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                          ),
                          widget.order.status == 'ordered' ||
                                  widget.order.status == 'preparing' ||
                                  (widget.order.orderType == 'address' &&
                                      widget.order.status == 'sent')
                              ? AnimatedTextKit(
                                  animatedTexts: [
                                    TypewriterAnimatedText(
                                      '...',
                                      cursor: '',
                                      textStyle: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      speed: const Duration(milliseconds: 300),
                                    ),
                                  ],
                                  repeatForever: true,
                                  pause: const Duration(milliseconds: 0),
                                )
                              : Container()
                        ],
                      ),
                    ),
                  ),
                  widget.order.status == "canceledR"
                      ? Center(
                          child: Container(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              widget.order.reason,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        )
                      : Container(),
                  Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        widget.order.orderType == 'restaurant'
                            ? (widget.order.paycheck == null &&
                                    DateTime.now()
                                            .difference(widget.order.dateTime)
                                            .inHours <
                                        6)
                                //daca au trecut mai mult de 6 ore de la comanda, butonul nu va mai fi disponibil
                                ? GestureDetector(
                                    onTap: () {
                                      showPaycheckDialog(context, user).then(
                                          (value) => value == 'paycheck'
                                              ? Navigator.of(context)
                                                  .pop('paycheck')
                                              : null);
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          right: 15, top: 15, bottom: 5),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        'Cere nota',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          fontFamily: 'Quicksand',
                                        ),
                                      ),
                                    ),
                                  )
                                : widget.order.paycheck != null
                                    ? Container(
                                        margin: EdgeInsets.only(
                                          right: 15,
                                          top: 5,
                                          bottom: 20,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Text(
                                          'Nota ceruta',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            fontFamily: 'Quicksand',
                                          ),
                                        ),
                                      )
                                    : Container()
                            : Container()
                      ],
                    ),
                  ),
                  widget.order.status == "canceledR" ||
                          widget.order.status == "canceled"
                      ? Container()
                      : widget.order.estimatedTime != null &&
                              widget.order.estimatedTime != "Alege ora"
                          ? widget.order.status == "delivered"
                              ? Container()
                              : Center(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          'Oră estimativă a livrării',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 3),
                                        child: Text(
                                          DateFormat("HH:mm")
                                              .format(DateTime.parse(
                                                  widget.order.estimatedTime))
                                              .toString(),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                          : Container(),
                  widget.order.orderType == 'pickup' &&
                          (widget.order.status != 'delivered' &&
                              widget.order.status != "canceledR")
                      ? Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Oră ridicare comandă',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text(
                                  widget.order.chosenTime,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      : Container(),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 13, bottom: 13),
                    child: Text(
                      'Detalii produse',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (ctx, index) {
                      return OrderItem(widget.order.cartItems.elementAt(index));
                    },
                    itemCount: widget.order.cartItems.length,
                  ),
                  Column(
                    children: [
                      widget.order.orderType == 'address'
                          ? Container(
                              padding:
                                  EdgeInsets.only(left: 15, top: 5, right: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Preț produse',
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    '${calculateProductsPrice(widget.order.cartItems, menuData).toStringAsFixed(2)} lei',
                                    style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      widget.order.orderType == 'address'
                          ? Container(
                              padding: EdgeInsets.only(left: 15, right: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Cost livrare',
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    '${calculateDeliveryCost(widget.order.orderType, widget.order.deliveryCost).toStringAsFixed(2)} lei',
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(color: Colors.grey[500]),
                      ),
                      widget.order.discount != null
                          ? Container(
                              padding: EdgeInsets.only(left: 15, right: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total comandă',
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    (calculateProductsPrice(
                                                    widget.order.cartItems,
                                                    menuData) +
                                                calculateDeliveryCost(
                                                    widget.order.orderType,
                                                    widget.order.deliveryCost))
                                            .toStringAsFixed(2) +
                                        ' lei',
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      widget.order.discount != null
                          ? Container(
                              padding: EdgeInsets.only(left: 15, right: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Reducere aplicație",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    '-' +
                                        widget.order.discount
                                            .toStringAsFixed(2) +
                                        " lei",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 15, right: 20, top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          calculateTotal(
                                      widget.order.cartItems,
                                      menuData,
                                      widget.order.orderType,
                                      widget.order.deliveryCost,
                                      widget.order.discount)
                                  .toStringAsFixed(2) +
                              " lei",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  widget.order.orderType == 'restaurant'
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 10, left: 15),
                          child: Text(
                            'Suma afisata se va adauga la final la totalul notei de plata.',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 14),
                          ),
                        )
                      : Container(),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 30, left: 13, bottom: 0),
                    child: Text(
                      'Detalii livrare',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 13),
                    child: Text(
                      'Comanda plasata in ${DateFormat("dd/MM/yy HH:mm").format(widget.order.dateTime)}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 70),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.order.orderType == 'address'
                            ? Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.only(
                                        left: 15, top: 18, bottom: 5),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.pin_drop_outlined,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        Container(
                                          width: width - 8 - 40,
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            'Adresa: ${widget.order.address}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 15, top: 5, bottom: 10),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            'Nr. telefon: ${widget.order.phoneNumber}',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : widget.order.orderType == 'pickup'
                                ? Container(
                                    padding: EdgeInsets.only(
                                        left: 15, top: 18, bottom: 5),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.pin_drop_outlined,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            'Ora ridicare comanda: ${widget.order.chosenTime}',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    padding: EdgeInsets.only(
                                      left: 15,
                                      top: 18,
                                      bottom: 5,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.pin_drop_outlined,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            'Numar masă: ${widget.order.tableNumber}',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, top: 20, bottom: 25),
                          child: Text(
                            widget.order.orderType == 'address'
                                ? 'In cazul in care produsele nu au fost livrate in timpul estimat va rugam sa ne contactati la 0748322322.'
                                : '',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            widget.order.status == 'sent'
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(),
                      GestureDetector(
                        onTap: () {
                          Provider.of<PlacedOrders>(context, listen: false)
                              .orderReceived(widget.order, widget.type, context)
                              .then((_) => Navigator.of(context).pop());
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          padding: EdgeInsets.symmetric(vertical: 13),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Theme.of(context).accentColor,
                          ),
                          child: Center(
                            child: Text(
                              widget.order.orderType == 'pickup'
                                  ? 'Am ridicat comanda'
                                  : 'Am primit comanda',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );

    //in cazul in care produsele nu ti-au fost livrate in timpul estimat, te rugam sa ne contactezi la 07../contactezi un ospatar
  }
}

class OrderItem extends StatelessWidget {
  final CartItem cartItem;
  OrderItem(this.cartItem);

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width;
    double usableWidth = maxWidth - 2 * 5 - 30;

    return Container(
      height: 75,
      padding: EdgeInsets.only(left: 15, right: 15),
      width: double.infinity,
      child: Container(
        width: usableWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Divider(color: Colors.grey[500]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: usableWidth * 0.6,
                  child: Text(
                    '${cartItem.quantity} x ${cartItem.productInfo.title}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                cartItem.productInfo.price != cartItem.productInfo.reducedPrice
                    ? Container(
                        width: usableWidth * 0.4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              child: Text(
                                '${(cartItem.productInfo.price * cartItem.quantity).toStringAsFixed(2)} lei',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 3, right: 5),
                              child: Text(
                                '${(cartItem.productInfo.reducedPrice * cartItem.quantity).toStringAsFixed(2)} lei',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    : Container(
                        width: usableWidth * 0.4,
                        child: Text(
                          '${(cartItem.productInfo.price * cartItem.quantity).toStringAsFixed(2)} lei',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
