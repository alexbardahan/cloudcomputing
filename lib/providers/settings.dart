import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cafe_noir/services/menu_sheets_api.dart';

class Settings {
  int openingHour;
  int closingHour;
  double deliveryCost;
  int minimumDeliveryPrice;
  bool discountAddress;
  double discountValueAddress;
  bool discountPickup;
  double discountValuePickup;

  String requiredMinVersion;

  String phone;
  String program1;
  String program2;
  String program3;

  bool open;

  Settings({
    this.openingHour,
    this.closingHour,
    this.deliveryCost,
    this.minimumDeliveryPrice,
    this.discountAddress,
    this.discountValueAddress,
    this.discountPickup,
    this.discountValuePickup,
    this.phone,
    this.program1,
    this.program2,
    this.program3,
    this.requiredMinVersion,
    this.open,
  });
}

class LoadSettings with ChangeNotifier {
  static Settings _settings;

  Settings get settings {
    return _settings;
  }

  static Future<void> fetchSettings() async {
    _settings = await MenuSheetsApi.getSettings();
  }
}
