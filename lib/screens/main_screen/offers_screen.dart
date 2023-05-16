import 'package:cafe_noir/providers/advert.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

class OffersScreen extends StatelessWidget {
  final Advert advert;
  OffersScreen(this.advert);

  // Future<void> initFunction() async {
  //   final customerId = 'cus_KeJRHklCSLJ2jx';
  //   final customerId2 = 'cus_KZw5OOb5Vl9tFC';
  //   final url = Uri.parse(
  //       'https://us-central1-cafenoir-737f5.cloudfunctions.net/returnCustomerEmail?customerId=$customerId2');
  //   final http.Response response = await http.post(url);
  //   String email = response.body;
  //   print('email ul returnat este ' + email + ' da');
  // }

  // firebase deploy --only functions:createPaymentIntent

  // @override
  // void initState() {
  //   initFunction();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(''),
        elevation: 0,
        backgroundColor: Color.fromRGBO(128, 0, 128, 1),
        toolbarHeight: 45,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Column(
          children: [
            Container(
              height: 250,
              width: double.infinity,
              child: Image.network(
                advert.photo,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Text(
                          advert.title,
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: 20, right: 20, top: 0, bottom: 10),
                        child: Text(
                          advert.header,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[600]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 10),
                        child: Text(
                          advert.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
