import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:stripe_payment/stripe_payment.dart';

class StripeTransactionResponse {
  String message;
  bool success;
  StripeTransactionResponse({this.message, this.success});
}

class StripeService {
  static String apiBase = 'https://api.stripe.com//v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';

  static init() {
    StripePayment.setOptions(StripeOptions(
        publishableKey:
            "pk_live_51Jk7LoGCWeH6sBHbRuJR4p16OxEJ9uMOy9ttrZIKavD9I6Z9k1cOLslchol3v7whKjXGgMormHVV6lf6Ifp1uwN200BkhzCYkr",
        merchantId: "Test",
        androidPayMode: 'test'));
  }

  static Future<String> addNewCard(
      User user, String idToken, BuildContext context) async {
    try {
      PaymentMethod paymentMethod =
          await StripePayment.paymentRequestWithCardForm(
        CardFormPaymentRequest(),
      );
      if (paymentMethod != null) {
        print('check1');
        ProgressDialog dialog = new ProgressDialog(context);
        dialog.style(message: 'Please wait...');
        await dialog.show();
        var url = Uri.parse(
            'https://cafenoir-737f5-default-rtdb.europe-west1.firebasedatabase.app/usersDetails/${user.uid}.json?auth=$idToken');
        http.Response response = await http.get(url);
        print('check2');
        String cid = json.decode(response.body)['stripe_cid'];
        print(cid);
        if (cid == null) {
          String email;
          if (user.email == null) {
            email = user.uid + '@fastapp.ro';
          } else {
            email = user.email;
          }
          url = Uri.parse(
              'https://us-central1-cafenoir-737f5.cloudfunctions.net/createNewCustomer?paymentMethodId=${paymentMethod.id}&email=$email');
          response = await http.post(url);
          print('check3' + response.body);
          if (response.body != 'error') {
            url = Uri.parse(
                'https://cafenoir-737f5-default-rtdb.europe-west1.firebasedatabase.app/usersDetails/${user.uid}.json?auth=$idToken');
            await http.patch(url,
                body: json.encode({
                  'stripe_cid': response.body,
                }));
          }
          print('check4');
        } else {
          url = Uri.parse(
              'https://us-central1-cafenoir-737f5.cloudfunctions.net/addPaymentMethod?paymentMethod=${paymentMethod.id}&customerId=$cid');
          response = await http.post(url);
          print('check5' + response.body);
        }
        dialog.hide();
      }
      // print(json.encode(paymentMethod));
      return paymentMethod.id;
    } catch (err) {
      return null;
    }
  }

  static Future<List<Map<String, String>>> loadPaymentMethods(
      User user, String idToken) async {
    var url = Uri.parse(
        'https://cafenoir-737f5-default-rtdb.europe-west1.firebasedatabase.app/usersDetails/${user.uid}.json?auth=$idToken');
    http.Response response = await http.get(url);
    String cid = json.decode(response.body)['stripe_cid'];
    List<Map<String, String>> cards = [];
    if (cid != null) {
      url = Uri.parse(
          'https://us-central1-cafenoir-737f5.cloudfunctions.net/loadPaymentMethods?customerId=$cid');
      response = await http.post(url);

      final extractedData = json.decode(response.body);
      if (extractedData != null) {
        extractedData['data'].forEach((dynamic paymentMethod) {
          final card = paymentMethod['card'];
          final cardNumber = '**** **** **** ${card['last4']}';
          String expMonth = card['exp_month'].toString();
          if (int.parse(expMonth) < 10) {
            expMonth = '0' + expMonth;
          }
          card['exp_year'] = card['exp_year'].toString().substring(2, 4);
          final expiryDate = '$expMonth/${card['exp_year']}';
          cards.add(
            {
              'paymentMethodId': paymentMethod['id'],
              'cardNumber': cardNumber,
              'expiryDate': expiryDate,
              'name': paymentMethod['billing_details']['name'],
            },
          );
        });
        return cards;
      } else {
        return null;
      }
    } else {
      return cards;
    }
  }

  static Future<StripeTransactionResponse> payWithCard(
      {String amount,
      String currency,
      String paymentMethodId,
      String userId,
      String idToken}) async {
    var url = Uri.parse(
        'https://cafenoir-737f5-default-rtdb.europe-west1.firebasedatabase.app/usersDetails/$userId.json?auth=$idToken');
    http.Response responseFirebase = await http.get(url);
    String customerId = json.decode(responseFirebase.body)['stripe_cid'];
    var paymentIntent =
        await StripeService.createPaymentIntent(amount, currency, customerId);
    print(paymentIntent.toString());
    var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
        clientSecret: paymentIntent['client_secret'],
        paymentMethodId: paymentMethodId));
    if (response.status == 'succeeded') {
      return new StripeTransactionResponse(
          message: 'Transaction successful', success: true);
    } else {
      return new StripeTransactionResponse(
          message: 'Transaction failed', success: false);
    }
  }

  static Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency, String customerId) async {
    try {
      final url = Uri.parse(
          'https://us-central1-cafenoir-737f5.cloudfunctions.net/createPaymentIntent?amount=$amount&currency=RON&customerId=$customerId');
      final http.Response response = await http.post(url);
      return jsonDecode(response.body);
    } catch (err) {
      print('err charing user: ${err.toString()}');
    }
    return null;
  }
}
