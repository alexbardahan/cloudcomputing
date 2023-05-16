import 'dart:convert';

import 'package:cafe_noir/constants.dart';
import 'package:cafe_noir/providers/auth.dart';
import 'package:cafe_noir/screens/reservation_screen/format_DateTime.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../providers/userData.dart';

class AddReservation extends StatefulWidget {
  @override
  _AddReservationState createState() => _AddReservationState();
}

class _AddReservationState extends State<AddReservation> {
  bool hasLoaded = false;
  String phoneNumber;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User>();

    Future<String> _getPhoneNumber() async {
      if (!hasLoaded) {
        String idToken =
            await Provider.of<Auth>(context, listen: false).refreshGetToken();

        await Provider.of<UserData>(context, listen: false)
            .fetchPersonalData(user.uid, idToken.toString());
        hasLoaded = true;
      }
      phoneNumber = Provider.of<UserData>(context, listen: false).phoneNumber;
      print('am modificat in userdata');

      return phoneNumber;
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromRGBO(128, 0, 128, 1),
        toolbarHeight: 45,
      ),
      body: FutureBuilder(
        builder: (context, projectSnap) {
          if (projectSnap.connectionState == ConnectionState.none &&
              projectSnap.hasData == null) {
            //print('project snapshot data is: ${projectSnap.data}');
            print('am intrat in connection state no! Error!');
          } else if (projectSnap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(Colors.redAccent),
              ),
            );
          }
          return AddReservationBody(
            user,
            phoneNumber,
          );
        },
        future: _getPhoneNumber(),
      ),
    );
  }
}

class AddReservationBody extends StatefulWidget {
  final User user;
  String phoneNumber;

  AddReservationBody(
    this.user,
    this.phoneNumber,
  );
  @override
  _AddReservationBodyState createState() => _AddReservationBodyState();
}

class _AddReservationBodyState extends State<AddReservationBody> {
  Future<void> addReservation(
    User user,
    int noPersons,
    DateTime chosenDate,
    String phoneNumber,
    String specialInstructions,
    bool checkBox,
    String idToken,
  ) async {
    final url = Uri.parse(
        'https://cafenoir-737f5-default-rtdb.europe-west1.firebasedatabase.app/$databaseReservations/current.json?auth=$idToken');
    final timestamp = DateTime.now();

    await http.post(
      url,
      body: json.encode({
        'dateTime': timestamp
            .toIso8601String(), //nu stiu sigur la ce mi-ar folosi aici, dar il las asa momentan
        'noPersons': noPersons,
        'chosenDate': chosenDate.toIso8601String(),
        'phoneNumber': phoneNumber,
        'specialInstructions': specialInstructions,
        'userId': user.uid,
        'name': user.displayName,
        'status': 'pending',
      }),
    );

    print(phoneNumber + ' inainte de patch');
    final userId = user.uid;
    if (checkBox != null && checkBox) {
      print(phoneNumber + ' efectiv in patch');
      final url = Uri.parse(
          'https://cafenoir-737f5-default-rtdb.europe-west1.firebasedatabase.app/usersDetails/$userId.json?auth=$idToken');
      await http.patch(
        url,
        body: json.encode({
          'phoneNumber': phoneNumber,
        }),
      );
    }
  }

  changePhoneNumber(String newNumber) {
    setState(() {
      widget.phoneNumber = newNumber;
    });
  }

  var noPersons = 1;
  DateTime chosenDate;
  String specialInstructions;

  bool checkBox = false;

  void _increasePersons() {
    setState(() {
      noPersons++;
    });
  }

  void _decreasePersons() {
    setState(() {
      noPersons--;
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey();

  Future<void> _submit(User user) async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();

    if (chosenDate == null || chosenDate.toString() == 'Alegeti data') {
      setState(() {
        errorChosenDate = true;
      });
      return;
    } else {
      setState(() {
        errorChosenDate = false;
      });
    }

    final String idToken =
        await Provider.of<Auth>(context, listen: false).refreshGetToken();

    addReservation(user, noPersons, chosenDate, widget.phoneNumber,
        specialInstructions, checkBox, idToken);
    Navigator.of(context).pop('success');
  }

  bool errorChosenDate = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Title('Rezervare nouă'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 25),
                    child: Text(
                      'Numar persoane',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, right: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: IconButton(
                                icon: noPersons > 1
                                    ? Icon(
                                        Icons.remove_circle_rounded,
                                        color: Theme.of(context).accentColor,
                                        size: 30,
                                      )
                                    : Icon(
                                        Icons.remove_circle_rounded,
                                        color: Colors.grey[300],
                                        size: 30,
                                      ),
                                onPressed:
                                    noPersons > 1 ? _decreasePersons : null,
                              ),
                            ),
                            Text(
                              noPersons.toString(),
                              style: TextStyle(
                                color: Colors.grey[850],
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: IconButton(
                                icon: Icon(
                                  Icons.add_circle_rounded,
                                  color: Theme.of(context).accentColor,
                                  size: 30,
                                ),
                                onPressed: _increasePersons,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 5, left: 25),
                    child: Text(
                      'Data rezervarii',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 25, top: 5),
                    child: TextButton(
                      onPressed: () {
                        DateTime today = DateTime.now();
                        DateTime twoWeeksFromNow =
                            DateTime.now().add(Duration(days: 14));
                        DatePicker.showDateTimePicker(context,
                            showTitleActions: true,
                            minTime: DateTime(
                              today.year,
                              today.month,
                              today.day,
                              today.hour,
                              today.minute,
                            ),
                            maxTime: DateTime(
                                twoWeeksFromNow.year,
                                twoWeeksFromNow.month,
                                twoWeeksFromNow.day,
                                twoWeeksFromNow.hour,
                                twoWeeksFromNow.minute), onConfirm: (date) {
                          setState(() {
                            chosenDate = date;
                            errorChosenDate = false;
                          });
                        }, currentTime: DateTime.now(), locale: LocaleType.en);
                      },
                      child: Text(
                        chosenDate == null
                            ? 'Alegeti data'
                            : formatDateTime(chosenDate),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              errorChosenDate
                  ? Container(
                      padding: EdgeInsets.only(left: 25),
                      child: Text(
                        'Vă rugam alegeți data rezervării!',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    )
                  : Container(),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(left: 25, right: 25, top: 10),
                      child: TextFormField(
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: Colors.grey[600]),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.phone_enabled,
                            color: Theme.of(context).primaryColor,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[400]),
                          ),
                          labelText: 'Telefon',
                          labelStyle: TextStyle(color: Colors.grey[500]),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                          hintText: 'Numar de telefon',
                          hintStyle: TextStyle(color: Colors.white54),
                        ),
                        initialValue: widget.phoneNumber,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Va rugam introduceti un numar de telefon!';
                          }
                          if (value.length < 10 ||
                              value.length > 13 ||
                              value.contains(new RegExp(r'[a-z]')) ||
                              value.contains(new RegExp(r'[A-Z]'))) {
                            return 'Va rugam introduceti un numar de telefon valid!';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          // Provider.of<UserData>(context, listen: false)
                          //     .phoneNumber = value;
                        },
                        onSaved: (value) {
                          changePhoneNumber(value);
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 25, top: 10, bottom: 5),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(right: 8),
                            child: SizedBox(
                              height: 18,
                              width: 18,
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  unselectedWidgetColor: Colors.grey[500],
                                ),
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  activeColor: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  value: checkBox,
                                  onChanged: (bool value) {
                                    setState(() {
                                      checkBox = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          Text(
                            'Retine numarul pentru rezervarile viitoare',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 100,
                      margin: EdgeInsets.only(left: 50, right: 50, top: 30),
                      child: TextFormField(
                        textInputAction: TextInputAction.done,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          labelText: 'Instructiuni speciale',
                          alignLabelWithHint: true,
                          labelStyle: TextStyle(color: Colors.grey),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onChanged: (value) {
                          specialInstructions = value;
                        },
                        onSaved: (value) {
                          specialInstructions = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  _submit(widget.user);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 50, horizontal: 100),
                  padding: EdgeInsets.symmetric(vertical: 13),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Theme.of(context).accentColor,
                  ),
                  child: Center(
                    child: Text(
                      'Rezerva',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Title extends StatelessWidget {
  final String title;
  Title(this.title);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 21,
        ),
      ),
    );
  }
}
