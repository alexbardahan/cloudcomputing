import 'package:cafe_noir/providers/auth.dart';
import 'package:cafe_noir/screens/delivery_screen/existing_cards_page.dart';
import 'package:cafe_noir/services/payment-service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChoosePaymentMethod extends StatelessWidget {
  static const routeName = 'choose-payment-method';

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context).settings.arguments as Map;
    // final PaymentMethod paymentMethod = arguments['paymentMethod'];
    final Function changePaymentMethod = arguments['changePaymentMethod'];
    final Function changePaymentType = arguments['changePaymentType'];
    final User user = arguments['user'];

    onItemPress(BuildContext context, int index) async {
      switch (index) {
        case 0:
          final String idToken =
              await Provider.of<Auth>(context, listen: false).refreshGetToken();

          final String response =
              await StripeService.addNewCard(user, idToken, context);
          print(response);
          if (response != null) {
            changePaymentMethod(response);
            changePaymentType('card');
            Navigator.of(context).pop();
          }
          break;
        case 1:
          var response = await Navigator.of(context)
              .pushNamed(ExistingCardsPage.routeName, arguments: {
            'changePaymentMethod': changePaymentMethod,
          });
          if (response == 'success') {
            changePaymentType('card');
            Navigator.of(context).pop();
          } else {}

          break;
        case 2:
          changePaymentType('cash');
          Navigator.of(context).pop();
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alege metoda de plata',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        elevation: 0,
        backgroundColor: Color.fromRGBO(128, 0, 128, 1),
        toolbarHeight: 45,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView.separated(
          itemCount: 3,
          itemBuilder: (context, index) {
            Icon icon;
            Text text;

            switch (index) {
              case 0:
                icon = Icon(Icons.add_circle,
                    color: Theme.of(context).primaryColor);
                text = Text('Adauga un card');
                break;
              case 1:
                icon = Icon(Icons.credit_card,
                    color: Theme.of(context).primaryColor);
                text = Text('Plateste cu un card existent');
                break;
              case 2:
                icon = Icon(Icons.money, color: Theme.of(context).primaryColor);
                text = Text('Plateste cu cash');
                break;
            }

            return InkWell(
              onTap: () {
                onItemPress(context, index);
              },
              child: ListTile(
                title: text,
                leading: icon,
              ),
            );
          },
          separatorBuilder: (context, index) =>
              Divider(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
