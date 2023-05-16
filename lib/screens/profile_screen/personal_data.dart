import 'dart:convert';

import 'package:cafe_noir/providers/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:lottie/lottie.dart';

class PersonalData extends StatefulWidget {
  static const routeName = 'personal-data';

  @override
  _PersonalDataState createState() => _PersonalDataState();
}

class _PersonalDataState extends State<PersonalData> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var hasChanged = false;

  String address;
  String phoneNumber;
  User user;

  Future<void> _changeData() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    if (hasChanged) {
      FocusManager.instance.primaryFocus?.unfocus();
      user = Provider.of<Auth>(context, listen: false).getUser();
      final userId = user.uid;
      final String idToken =
          await Provider.of<Auth>(context, listen: false).refreshGetToken();
      final url = Uri.parse(
          'https://cafenoir-737f5-default-rtdb.europe-west1.firebasedatabase.app/usersDetails/$userId.json?auth=$idToken');
      await http.patch(
        url,
        body: json.encode({
          'address': address,
          'phoneNumber': phoneNumber,
        }),
      );
      hasChanged = false;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> getData() async {
      var userId = Provider.of<Auth>(context, listen: false).getUser().uid;
      String _idToken =
          await Provider.of<Auth>(context, listen: false).refreshGetToken();

      // await Provider.of<UserData>(context, listen: false)
      //     .fetchPersonalData(user.uid, idToken.toString());
      // address = Provider.of<UserData>(context, listen: false).address;
      // phoneNumber = Provider.of<UserData>(context, listen: false).phoneNumber;

      final url = Uri.parse(
          'https://cafenoir-737f5-default-rtdb.europe-west1.firebasedatabase.app/usersDetails/$userId.json?auth=$_idToken');
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData != null) {
        extractedData.forEach((key, value) {
          if (key == 'address') {
            address = value;
          }
          if (key == 'phoneNumber') {
            phoneNumber = value;
          }
        });
      }
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        floatingActionButton: IconButton(
          iconSize: 24,
          color: Colors.white,
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 12.0),
                  child: Container(
                    width: 120,
                    height: 120,
                    child: Lottie.asset('assets/lottie/lottie_loading.json'),
                  ),
                );
              default:
                if (snapshot.hasError)
                  return Text('Error: ${snapshot.error}');
                else
                  return Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(128, 0, 128, 1),
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
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 30,
                                            left: 25,
                                            bottom: 25,
                                          ),
                                          child: Text(
                                            'Date personale',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 22,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: 25,
                                          ),
                                          child: Text(
                                            'Adresa',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            top: 10,
                                          ),
                                          child: TextFormField(
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                            keyboardType:
                                                TextInputType.streetAddress,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  new EdgeInsets.symmetric(
                                                vertical: 12.0,
                                                horizontal: 10.0,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 1.0,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                              labelStyle: TextStyle(
                                                color: Colors.red,
                                              ),
                                              hintText: 'Introduceti adresa',
                                              hintStyle: TextStyle(
                                                  color: Colors.grey[500]),
                                            ),
                                            initialValue:
                                                address == null ? "" : address,
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Va rugam introduceti adresa!';
                                              }
                                              return null;
                                            },
                                            onSaved: (value) {
                                              if (value != address) {
                                                address = value;
                                                hasChanged = true;
                                              }
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: 25,
                                            top: 20,
                                          ),
                                          child: Text(
                                            'Numar de telefon',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            top: 10,
                                          ),
                                          child: TextFormField(
                                            keyboardType: TextInputType.phone,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  new EdgeInsets.symmetric(
                                                vertical: 12.0,
                                                horizontal: 10.0,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                  // color: Colors.white,
                                                  color: Colors.black,
                                                  width: 1.0,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                              labelStyle: TextStyle(
                                                color: Colors.red,
                                              ),
                                              hintText:
                                                  'Introduceti nr. de telefon',
                                              hintStyle: TextStyle(
                                                  color: Colors.grey[500]),
                                            ),
                                            initialValue: phoneNumber == null
                                                ? ""
                                                : phoneNumber,
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Va rugam introduceti nr. de telefon!';
                                              }
                                              if (value.length < 10 ||
                                                  value.length > 13 ||
                                                  value.contains(
                                                      new RegExp(r'[a-z]')) ||
                                                  value.contains(
                                                      new RegExp(r'[A-Z]'))) {
                                                return 'Va rugam introduceti un numar de telefon valid!';
                                              }
                                              return null;
                                            },
                                            onSaved: (value) {
                                              if (value != phoneNumber) {
                                                phoneNumber = value;
                                                hasChanged = true;
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SaveButton(_changeData),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
            }
          },
        ),
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  final Function changeData;
  SaveButton(this.changeData);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 40),
      child: Center(
        child: GestureDetector(
          onTap: () {
            changeData();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 13,
              horizontal: 30,
            ),
            margin: EdgeInsets.only(top: 40),
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
              borderRadius: BorderRadius.circular(35),
            ),
            child: Text(
              'Salveaza',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
