import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; //json encode

class UserData with ChangeNotifier {
  String address;
  String phoneNumber;

  Future<void> fetchPersonalData(String userId, String _idToken) async {
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

        notifyListeners();
      });
    }
  }

  void signOut() {
    address = null;
    phoneNumber = null;
  }
}
