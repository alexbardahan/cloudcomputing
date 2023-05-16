import 'package:flutter/material.dart';

class ChooseOrderType extends StatelessWidget {
  final Function _setOrderType;
  ChooseOrderType(this._setOrderType);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Theme.of(context).platform == TargetPlatform.android
            ? Container(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                height: 45 + MediaQuery.of(context).padding.top,
                width: double.infinity,
                color: Theme.of(context).primaryColor,
              )
            : Container(
                padding: EdgeInsets.only(top: 40),
                height: 92,
                width: double.infinity,
                color: Theme.of(context).primaryColor,
              ),
        SizedBox(height: 25),
        OrderTypeItem(
          setOrderType: _setOrderType,
          orderType: 'Livrare la adresa',
          text1: 'Livrare la adresa',
          text2:
              'Alege-ti produsele favorite, iar noi le\nvom livra acolo unde esti!',
          icon: Icons.delivery_dining_outlined,
        ),
        OrderTypeItem(
          setOrderType: _setOrderType,
          orderType: 'Ridicare personala',
          text1: 'Ridicare personala',
          text2:
              'Comanda mancarea ta preferata si vino\nsa o ridici din restaurant cand este gata!',
          icon: Icons.pin_drop_outlined,
        ),
        // OrderTypeItem(
        //   setOrderType: _setOrderType,
        //   orderType: 'Comanda la masa',
        //   text1: 'Comanda la masa',
        //   text2:
        //       'Economiseste timp si comanda la masa\ndirect de pe aplicatie!',
        //   icon: Icons.fastfood,
        // ),
      ],
    );
  }
}

class OrderTypeItem extends StatelessWidget {
  final Function setOrderType;
  final String orderType;
  final String text1;
  final String text2;
  final IconData icon;

  OrderTypeItem({
    this.setOrderType,
    this.orderType,
    this.text1,
    this.text2,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setOrderType(orderType);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 15, left: 12.0, right: 12.0),
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias, // nu stiu ce este
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: Colors.white,
          elevation: 0.8,
          // width: double.infinity,
          // decoration: BoxDecoration(
          //   color: Colors.white,
          //   borderRadius: BorderRadius.all(Radius.circular(10.0)),
          // boxShadow: [
          //   BoxShadow(
          //     offset: Offset(6, 7),
          //     color: Theme.of(context).primaryColor.withOpacity(0.05),
          //     blurRadius: 5.0,
          //     spreadRadius: 1.0,
          //   )
          // ],
          // ),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 30.0,
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Container(
                      height: 50.0,
                      width: 50.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          text1,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          text2,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                            fontSize: 13.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 35.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
