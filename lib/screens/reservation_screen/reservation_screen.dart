import 'package:cafe_noir/constants.dart';
import 'package:cafe_noir/models/reservation.dart';
import 'package:cafe_noir/providers/auth.dart';
import 'package:cafe_noir/screens/reservation_screen/reservation_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'add_reservation.dart';

class ReservationScreen extends StatefulWidget {
  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  Future<void> _showReservationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              'Rezervarea ta a fost inregistrată cu succes!',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  width: 100,
                  height: 100,
                  child: Lottie.asset(
                    'assets/lottie/lottie_succes.json',
                    repeat: false,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                        'Vă rugăm așteptați câteva minute pentru a vă confirma rezervarea.',
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: Text(
                  'Inapoi',
                  style: TextStyle(color: Colors.grey[700], fontSize: 15),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<Auth>(context, listen: false).getUser();

    return Stack(
      children: [
        SingleChildScrollView(
          child: ReservationsStream(user),
        ),
        Center(
          child: Container(
            alignment: Alignment(0, 0.95),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddReservation(),
                  ),
                ).then(
                  (value) =>
                      {if (value == 'success') _showReservationDialog(context)},
                );
              },
              child: CircleAvatar(
                maxRadius: 25,
                backgroundColor: Theme.of(context).accentColor,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 35,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ReservationsStream extends StatelessWidget {
  final User user;
  ReservationsStream(this.user);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;

    double appBarHeight = 45;
    double screenButtonsHeight = 80;
    double altceva = 50;
    double newHeight = height -
        padding.top -
        padding.bottom -
        screenButtonsHeight -
        appBarHeight -
        altceva;

    return StreamBuilder(
      stream: FirebaseDatabase.instance
          .reference()
          .child(databaseReservations)
          .onValue,
      builder: (context, snap) {
        List<Reservation> reservationsCurrent = [];
        List<Reservation> reservationsPast = [];

        if (snap.hasData && !snap.hasError) {
          final extractedData = snap.data.snapshot.value;
          if (extractedData != null) {
            if (extractedData['current'] != null) {
              extractedData['current']
                  .forEach((reservationId, reservationData) {
                if (reservationData['userId'] == user.uid) {
                  reservationsCurrent.add(Reservation(
                    phoneNumber: reservationData['phoneNumber'],
                    userId: reservationData['userId'],
                    noPersons: reservationData['noPersons'],
                    chosenDate: DateTime.parse(reservationData['chosenDate']),
                    reservationId: reservationId,
                    status: reservationData['status'],
                    cancelR: reservationData['cancelR'],
                  ));
                }
              });
              reservationsCurrent
                  .sort((r1, r2) => r1.chosenDate.compareTo(r2.chosenDate));
            }

            if (extractedData['past'] != null) {
              extractedData['past'].forEach((reservationId, reservationData) {
                if (reservationData['userId'] == user.uid) {
                  reservationsPast.add(Reservation(
                    phoneNumber: reservationData['phoneNumber'],
                    userId: reservationData['userId'],
                    noPersons: reservationData['noPersons'],
                    chosenDate: DateTime.parse(reservationData['chosenDate']),
                    reservationId: reservationId,
                    status: reservationData['status'],
                    cancelR: reservationData['cancelR'],
                  ));
                }
              });
              reservationsPast
                  .sort((r1, r2) => r1.chosenDate.compareTo(r2.chosenDate));
            }
          }

          return reservationsCurrent.isNotEmpty || reservationsPast.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    reservationsCurrent.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Title('Rezervări actuale'),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: [
                                    ...reservationsCurrent.map((element) =>
                                        ReservationItem(element, 'current'))
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Container(
                            // poate lottie?
                            // child: Title('Nu există rezervări actuale'),
                            ),
                    reservationsPast.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Title('Rezervări precedente'),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: [
                                    ...reservationsPast.map((element) =>
                                        ReservationItem(element, 'past'))
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Container(
                            // poate lottie?
                            // child: Title('Nu există rezervări precedente'),
                            ),
                    SizedBox(
                      height: 45,
                    )
                  ],
                )
              : Container(
                  // de adaugat lottie
                  // color: Colors.red,
                  height: newHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        // width: 100,
                        // height: 100,
                        child: Lottie.asset(
                          'assets/lottie/lottie_no_reservations.json',
                        ),
                      ),
                      Title(
                        'Nu ați efectuat nicio rezervare.',
                      ),
                    ],
                  ),
                );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              Center(
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(Colors.redAccent),
                ),
              ),
              // idee sa apara mai multe reservation item da fara text (animatie)
            ],
          );
        }
      },
    );
  }
}

class Title extends StatelessWidget {
  final String title;
  Title(this.title);
  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: new BoxDecoration(color: Colors.green),
      padding: EdgeInsets.only(left: 15, top: 25, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
