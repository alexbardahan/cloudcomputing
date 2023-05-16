import 'package:cafe_noir/providers/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../models/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart.dart';
import './order_item.dart';
import '../../providers/orders.dart';

class RestaurantOrderDetails extends StatefulWidget {
  static const routeName = 'restaurant-order-details';

  @override
  _RestaurantOrderDetailsState createState() => _RestaurantOrderDetailsState();
}

class _RestaurantOrderDetailsState extends State<RestaurantOrderDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  String tableNumber;

  Future<void> _submit(Cart cart, User user) async {
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
      idToken: idToken,
      orderType: 'restaurant',
      tableNumber: tableNumber,
      status: 'preparing',
    );
    Navigator.of(context).pop('ordered');
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final user = context.watch<User>();
    final Set<CartItem> orderItems = cart.items;
    final totalProductsPrice = cart.getTotalAmount().toStringAsFixed(2);

    // if (orderItems.isEmpty) {
    //   Navigator.of(context).pop();
    //   // in momentul in care nu avem produse in cos, iesim de pe pagina
    //   // momentan ceva eroare in consola
    // }

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          iconSize: 24,
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: GestureDetector(
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
                              'Detalii comanda',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding:
                                EdgeInsets.only(left: 20, right: 20, top: 10),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: Colors.grey[800]),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.restaurant,
                                  color: Theme.of(context).primaryColor,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[400]),
                                ),
                                labelText: 'Numarul mesei',
                                labelStyle: TextStyle(color: Colors.grey[500]),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 6,
                                ),
                                hintText: 'Introduceti numarul mesei',
                                hintStyle: TextStyle(
                                  color: Colors.white54,
                                ),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Va rugam introduceti numarul mesei!';
                                } else if (value.length > 3 ||
                                    value.contains(new RegExp(r'[a-z]')) ||
                                    value.contains(new RegExp(r'[A-Z]'))) {
                                  return 'Numarul mesei trebuie sa fie un numar intre 1 si 100.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                tableNumber = value;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 13, top: 40, right: 13),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
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
                                  (double.parse(totalProductsPrice))
                                          .toStringAsFixed(2) +
                                      " Lei",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Suma afisata se va adauga la final la totalul notei de plata.',
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
                        _submit(cart, user);
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 35),
                        padding: EdgeInsets.symmetric(vertical: 13),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Theme.of(context).accentColor),
                        child: Center(
                          child: Text(
                            'Confirma comanda',
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
      ),
    );
  }
}
