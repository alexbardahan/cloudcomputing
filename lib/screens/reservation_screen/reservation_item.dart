import 'dart:convert';

import 'package:cafe_noir/constants.dart';
import 'package:cafe_noir/models/reservation.dart';
import 'package:cafe_noir/providers/auth.dart';
import 'package:cafe_noir/screens/reservation_screen/format_DateTime.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ReservationItem extends StatelessWidget {
  final Reservation reservation;
  final String category;
  ReservationItem(this.reservation, this.category);

  Future<void> _cancelReservation(BuildContext context) async {
    // final user = FirebaseAuth.instance.currentUser;
    final reservationId = reservation.reservationId;

    final String idToken =
        await Provider.of<Auth>(context, listen: false).refreshGetToken();
    var url = Uri.parse(
        'https://cafenoir-737f5-default-rtdb.europe-west1.firebasedatabase.app/$databaseReservations/current/$reservationId.json?auth=$idToken');

    await http.patch(
      url,
      body: json.encode({
        'status': 'canceled',
      }),
    );

    Navigator.of(context).pop();
  }

  Future<void> _showCancelReservationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: FractionalOffset.topRight,
                    child: Icon(
                      Icons.clear,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Anuleaza rezervarea',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 200,
                  height: 200,
                  child: Lottie.asset(
                    'assets/lottie/lottie_cancel.json',
                    repeat: false,
                    //ocupa cam prea mult spatiu
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Esti sigur ca vrei sa anulezi rezervarea?',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: Text(
                      'Nu',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(
                      'Da',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () {
                      _cancelReservation(context);
                    },
                  ),
                ],
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
    double maxWidth = MediaQuery.of(context).size.width;

    double containerHeight = 115;
    double containerMargin = 10;

    double contentMargin = 2 * containerMargin;
    double contentWidth = maxWidth - 2 * containerMargin - 2 * contentMargin;

    bool isCurrentAndCanceled() {
      return category == 'past' ||
          (category == 'current' && reservation.status == 'canceled');
    }

    double iconStatusPercentage = 0.24;
    double actionButtonPercentage = 0.1;
    double infoPercentage = 1 -
        iconStatusPercentage -
        (isCurrentAndCanceled() ? 0 : actionButtonPercentage);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: containerMargin, vertical: 5),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias, // nu stiu ce este
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.white,
        elevation: 0.8,
        child: Container(
          height: containerHeight,
          width: maxWidth - 2 * containerMargin,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: contentWidth * iconStatusPercentage,
                child: IconStatus(
                  reservation.status,
                  category,
                ),
              ),
              Container(
                width: contentWidth * infoPercentage,
                padding: EdgeInsets.only(left: 15),
                // color: Colors.red,
                child: ReservationInfo(
                  reservation.noPersons,
                  reservation.chosenDate,
                  reservation.status,
                  reservation.cancelR,
                  contentWidth * 0.8,
                ),
              ),
              isCurrentAndCanceled()
                  ? Container()
                  : Container(
                      height: containerHeight,
                      width: contentWidth * actionButtonPercentage,
                      child: GestureDetector(
                        onTap: () {
                          _showCancelReservationDialog(context);
                        },
                        child: Icon(
                          Icons.cancel,
                          color: Colors.grey,
                          size: contentWidth * 0.1,
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

class IconStatus extends StatelessWidget {
  final String reservationStatus;
  final String reservationCategory;
  IconStatus(this.reservationStatus, this.reservationCategory);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        reservationStatus == 'approved' || reservationStatus == 'canceled'
            ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: reservationCategory == 'current'
                      ? reservationStatus == 'approved'
                          ? Colors.green
                          : Colors.red
                      : Colors.grey,
                ),
                padding: const EdgeInsets.all(5),
                child: Icon(
                  reservationStatus == 'approved'
                      ? Icons.check_rounded
                      : Icons.close_rounded,
                  size: 28,
                  color: Colors.white,
                ),
              )
            : reservationStatus == 'pending'
                ? Container(
                    width: 28,
                    height: 28,
                    margin: EdgeInsets.only(bottom: 5),
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : Container(),
        Container(
          margin: EdgeInsets.only(top: 5),
          child: Text(
            reservationStatus == 'pending'
                ? 'Așteptare...'
                : reservationStatus == 'approved'
                    ? 'Aprobată'
                    : 'Anulată',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class ReservationInfo extends StatelessWidget {
  final int reservationNoPersons;
  final DateTime reservationChosenDate;
  final String reservationStatus;
  final String reservationCancelR;
  final double canceledByRestaurantWidth;

  ReservationInfo(
      this.reservationNoPersons,
      this.reservationChosenDate,
      this.reservationStatus,
      this.reservationCancelR,
      this.canceledByRestaurantWidth);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rezervare ${reservationNoPersons.toString()} persoane',
          style: TextStyle(
            fontSize: 17,
            color: Colors.black,
          ),
        ),
        Container(
          child: Text(
            formatDateTime(reservationChosenDate),
            style: TextStyle(
              fontSize: 14.5,
              color: Colors.grey[600],
            ),
          ),
        ),
        reservationStatus == 'canceled' && reservationCancelR == 'true'
            ? Container(
                width: canceledByRestaurantWidth,
                padding: EdgeInsets.only(top: 3),
                child: Text(
                  'Ne pare rău, dar rezervarea dvs. nu a fost acceptata deoarece nu mai sunt locuri disponibile.',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
