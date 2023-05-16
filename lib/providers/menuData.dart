import 'package:cafe_noir/models/product.dart';
import 'package:cafe_noir/services/menu_sheets_api.dart';
import 'package:flutter/material.dart';

class MenuData with ChangeNotifier {
  static List<Product> _items;

  List<Product> get items {
    return _items;
  }

  static Future<void> fetchMenuData() async {
    _items = await MenuSheetsApi.getProducts();
  }
}
