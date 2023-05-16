import 'package:flutter/material.dart';

class Reservation {
  final int noPersons;
  final DateTime chosenDate;
  final String reservationId;
  final String phoneNumber;
  final String specialInstructions;
  final String userId;
  final String status;
  final String cancelR; // canceled by restaurant (true / null)

  const Reservation({
    @required this.noPersons,
    @required this.chosenDate,
    @required this.phoneNumber,
    @required this.userId,
    @required this.reservationId,
    @required this.status,
    this.cancelR,
    this.specialInstructions,
  });
}
