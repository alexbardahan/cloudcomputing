import 'package:cafe_noir/services/menu_sheets_api.dart';
import 'package:flutter/material.dart';

class Event {
  String title;
  String header;
  String description;
  String photo;

  Event({
    this.title,
    this.header,
    this.description,
    this.photo,
  });
}

class LoadEvent with ChangeNotifier {
  static Event _event;

  Event get event {
    return _event;
  }

  static Future<void> fetchEvent() async {
    _event = await MenuSheetsApi.getEvent();
  }
}
