import 'package:cafe_noir/constants.dart';
import 'package:cafe_noir/providers/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import 'dart:convert'; //json encode
import './cart.dart';

class Order {
  List<CartItem> cartItems;
  final DateTime dateTime;
  final String orderId;
  final String payment;
  final String address;
  final String userId;
  final String phoneNumber;
  final String chosenTime;
  final String tableNumber;
  final String orderType;
  final String estimatedTime;
  final bool paycheck;
  final String status;
  final double discount;
  final double deliveryCost;
  final int freeDeliveryLimit;
  final String reason;

  Order({
    this.cartItems,
    this.dateTime,
    this.orderId,
    this.address,
    this.userId,
    this.payment,
    this.phoneNumber,
    this.chosenTime,
    this.tableNumber,
    this.estimatedTime,
    this.paycheck,
    this.orderType,
    this.status,
    this.discount,
    this.deliveryCost,
    this.freeDeliveryLimit,
    this.reason,
  });
}

class PlacedOrders with ChangeNotifier {
  bool firstInitOrders = true;

  Future<void> addOrder({
    @required Cart cart,
    @required User user,
    @required String orderType,
    @required String idToken,
    bool checkBox,
    String payment,
    String address,
    String phoneNumber,
    String chosenTime,
    String tableNumber,
    String status,
    double discount,
    double deliveryCost,
    double amount,
  }) async {
    final userId = user.uid;

    final url = Uri.parse(
        'https://cafenoir-737f5-default-rtdb.europe-west1.firebasedatabase.app/$databaseOrders/current.json?auth=$idToken');
    final timestamp = DateTime.now();

    // uniform string representation of dates, which we can later convert back to a date,
    await http.post(
      url,
      body: json.encode({
        'dateTime': timestamp.toIso8601String(),
        'cartItems': cart.items
            .map((cartItem) => {
                  'productId': cartItem.productInfo.id,
                  'quantity': cartItem.quantity,
                  'specialInstructions': cartItem.specialInstructions
                })
            .toList(),
        'address': address,
        'phoneNumber': phoneNumber,
        'payment': payment,
        'userId': userId,
        'orderType': orderType,
        'chosenTime': chosenTime,
        'tableNumber': tableNumber,
        'status': status,
        'discount': discount,
        'name': user.displayName,
        // 'deliveryCost': deliveryCost,
        'amount': amount,
      }),
    );

    final changeUserDetailsUri = Uri.parse(
        'https://cafenoir-737f5-default-rtdb.europe-west1.firebasedatabase.app/usersDetails/$userId.json?auth=$idToken');
    final userDetails = await http.get(changeUserDetailsUri);
    final noOfOrders = json.decode(userDetails.body)['orders'];

    await http.patch(
      changeUserDetailsUri,
      body: json.encode({
        'orders': noOfOrders == null ? 1 : noOfOrders + 1,
      }),
    );

    if (checkBox != null && checkBox) {
      final urlChange = Uri.parse(
          'https://cafenoir-737f5-default-rtdb.europe-west1.firebasedatabase.app/usersDetails/$userId.json?auth=$idToken');

      if (address == null) {
        await http.patch(
          urlChange,
          body: json.encode({
            'phoneNumber': phoneNumber,
          }),
        );
      } else if (phoneNumber == null) {
        await http.patch(
          urlChange,
          body: json.encode({
            'address': address,
          }),
        );
      } else {
        await http.patch(
          urlChange,
          body: json.encode({
            'phoneNumber': phoneNumber,
            'address': address,
          }),
        );
      }
    }
  }

  Future<void> orderReceived(
      Order order, String type, BuildContext context) async {
    final String idToken =
        await Provider.of<Auth>(context, listen: false).refreshGetToken();
    final orderId = order.orderId;
    Uri url = Uri.parse(
        'https://cafenoir-737f5-default-rtdb.europe-west1.firebasedatabase.app/$databaseOrders/$type/$orderId.json?auth=$idToken');

    await http.patch(
      url,
      body: json.encode({
        'status': 'delivered',
      }),
    );
  }

  Future<void> requestPaycheck(
      {Order order, BuildContext context, User user, String payment}) async {
    final String idToken =
        await Provider.of<Auth>(context, listen: false).refreshGetToken();
    final orderId = order.orderId;
    Uri url = Uri.parse(
        'https://cafenoir-737f5-default-rtdb.europe-west1.firebasedatabase.app/$databaseOrders/current/$orderId.json?auth=$idToken');

    await http.patch(
      url,
      body: json.encode({
        'paycheck': true,
        'payment': payment,
      }),
    );
  }
}
