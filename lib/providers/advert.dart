import 'package:cafe_noir/services/menu_sheets_api.dart';
import 'package:flutter/material.dart';

class Advert {
  String title;
  String header;
  String description;
  String photo;

  Advert({
    this.title,
    this.header,
    this.description,
    this.photo,
  });
}

class LoadAdvert with ChangeNotifier {
  static Advert _advert;

  Advert get advert {
    return _advert;
  }

  static Future<void> fetchAdvert() async {
    _advert = await MenuSheetsApi.getAdvert();
  }
}
