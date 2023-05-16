import 'package:cafe_noir/providers/auth.dart';
import 'package:cafe_noir/services/payment-service.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_stripe_payments/services/payment-service.dart';
import 'package:awesome_card/awesome_card.dart' as card_widget;

class ExistingCardsPage extends StatefulWidget {
  static const routeName = 'existing-cards';

  @override
  ExistingCardsPageState createState() => ExistingCardsPageState();
}

class ExistingCardsPageState extends State<ExistingCardsPage> {
  List<Map<String, String>> cards = [];

  chooseExistingCard(BuildContext context, Function changePaymentMethod,
      String paymentMethodId) async {
    changePaymentMethod(paymentMethodId);
    Navigator.pop(context, 'success');
  }

  Future<void> loadPaymentMethods() async {
    final user = Provider.of<Auth>(context, listen: false).getUser();
    final String idToken =
        await Provider.of<Auth>(context, listen: false).refreshGetToken();
    cards = await StripeService.loadPaymentMethods(user, idToken);
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context).settings.arguments as Map;
    final Function changePaymentMethod = arguments['changePaymentMethod'];
    loadPaymentMethods();
    return Scaffold(
        appBar: AppBar(
          title: Text('Choose an existing card', style: TextStyle(
            fontSize: 18,
          ),),
          elevation: 0,
        backgroundColor: Color.fromRGBO(128, 0, 128, 1),
        toolbarHeight: 45,
        ),
        body: FutureBuilder(
            future: loadPaymentMethods(),
            builder: (context, projectSnap) {
              if (projectSnap.connectionState == ConnectionState.none &&
                  projectSnap.hasData == null) {
              } else if (projectSnap.connectionState ==
                  ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Colors.redAccent),
                  ),
                );
              }
              return Container(
                child: ListView.builder(
                  itemCount: cards.length,
                  itemBuilder: (BuildContext context, int index) {
                    var card = cards[index];
                    return InkWell(
                        onTap: () {
                          chooseExistingCard(context, changePaymentMethod,
                              card['paymentMethodId']);
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            top: 10,
                            left: 15,
                            right: 15, //de la astea da eroare aia
                            bottom: 10,
                          ),
                          child: card_widget.CreditCard(
                              frontBackground:
                                  card_widget.CardBackgrounds.black,
                              backBackground: card_widget.CardBackgrounds.white,
                              cardNumber: card['cardNumber'],
                              cardExpiry: card['expiryDate'],
                              cvv: '***',
                              cardHolderName: card['name']),
                        ));
                  },
                ),
              );
            }));
  }
}
