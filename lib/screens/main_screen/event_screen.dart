import 'package:cafe_noir/providers/event.dart';
import 'package:flutter/material.dart';

class EventScreen extends StatelessWidget {
  final Event event;
  EventScreen(this.event);

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
                event.photo,
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
                          event.title,
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
                          event.header,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[600]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 10),
                        child: Text(
                          event.description,
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
