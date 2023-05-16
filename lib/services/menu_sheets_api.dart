import 'package:cafe_noir/providers/advert.dart';
import 'package:cafe_noir/models/product.dart';
import 'package:cafe_noir/providers/event.dart';
import 'package:cafe_noir/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';

class MenuSheetsApi {
  static const _credentials = r'''
{
  "type": "service_account",
  "project_id": "cafenoir-737f5",
  "private_key_id": "7896b32d24738fa8895237d906c5a322e750d54e",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCvXhXSEkh0r+oE\nYt7DkXyMEkQv20dlbSQHpZUxB8GLtjZP6rHGEe/TS6j1wKRlomTn0ePy29L0W1Hn\nErcgzKqCbu3aUHMLPn2VsxO03AYsiR2gc/yuXoy1dlVAAJjOw5Eszxvrum8ePUKO\nsBZgwliR4WFC19U4GXg1GRZ/p/RShAQswDIb2XhRxHSNCLntkYMzM1eGWMdOQK7E\nl9iOdkeRsOPUT94VizYsVBo5oc1DKryVuxtKleh6ZSDzV86XPUBHcJ1xQEPzwbn5\nvLC6uRBTtMJQDHqJb62s717kNfoAsgDacsvb4qHIuMxNjuFEhxArfR/H8Cxk7s/w\nbhbnFVSFAgMBAAECggEAGcPgP1jF0fUNlB7lnUSpEJhXcdONAhMetcvnZ0h9MHZx\nNN0lyNTWUEw/svmefbs2CZQ+Ii6XaCTpm+JVSwme7KJ5KjfjKy3/fAjPNqWT96Oe\nmXYpFAJauId9/3UG/mvfzr5QGxptXHtCJd4rr4QmSKqdJFm7Hy6oyV5Z/p/xxtSV\n2GTwoykOE/dCE5i2MmdqA1blUSZBUYynyJ6nAJ529eFtYO/k5NGtKEj4l/0GJM87\nEb/uq8RG4lFWR3YmmJXtYlyvEwY2zCWReiZurEsU8HFdSfY9vs0RQ37VleP0zPQq\nCssmhPj5rxIC67zVnTM6SyTE0TW8H3yHpvORHd3OWQKBgQDVJ3nyE4AKXDEUVbz8\nn5icNKER+Svl7CFa2gOYnw7cVhA9oxeh6rWrqws+I6WXeK2Upq0vnYtaJlD2Yjg3\nePN5C8CfH8GZOhRwE06bn/77upMdt8Tq9sJYUMC/zsg+ggsgcsAJ+hyZ3VojiZBx\n7EilslzwKGB/c2fDUshRdopwmQKBgQDSnizx7+klZxY3WVOFjGiz+v2+4wr7lwtp\nccu9hLzVlBy5WhHvKmMOz1BtTHqWjxcSVRUFfkoPz7xi9p8NwAQ9mrHIeVq51/8R\nLyQuis3vTybLb715uwcki2sEtOqj0JFGU99csex1VlFOXqMlR2e2YD0UnjlOKwZM\nPul+R/q6zQKBgQChIomeRb2Kl20GyVXnx6Jvm52T38CevKXub1c+nid2y5zVa6Bm\n5+7USqZiIEKDQlg+Qs4za663xLV5vIBw9v9fp1HDORd6hRyEKSRIo2f31nB2i8DS\nOx5p8wnzNhfMoTRWIEkqgafzbRFCQjEu3geBM1fsuSlRz+VGFCOY6br4KQKBgQCB\nCz0Kdy3oJsMr4mUUHDVCoPO7cyyVfbQWRQzJ73wrd/YpcpAuc1ACEO98KDGr8bv3\nFX4twXTrPyJzmBtXt2BhxlhLNl9qInc7NiD7Czyl9V8Voj77SKZVs748QgTJnc6E\nwnrGNpVkRyDF3aIkAx3+VfTWnyMJS78uFBXHs55huQKBgEl060x+rTM3ZFD6u9jG\niJgzJeXr1pWJ95jKVB+HGhRvY3DjM+Bm9lAOLrH02ye11aDAkqvj619U7Yz/WfPu\n0rQTFZ25aAW5mhqhltQHXa58gYPVhAhXIM5x8J1//K09tnCdnf5AsFcX3oCABf+q\n892LLmDnVnAcPHAcAuUCjYt2\n-----END PRIVATE KEY-----\n",
  "client_email": "gsheets@cafenoir-737f5.iam.gserviceaccount.com",
  "client_id": "101607663170717962548",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gsheets%40cafenoir-737f5.iam.gserviceaccount.com"
}
  ''';
  static final _spreadsheetId = '1NI-BpOT7rDdXMZsfLUk-nwXlyRDVvpYCS_qt_TAog3c';
  static final _gsheets = GSheets(_credentials);
  static Worksheet _menuSheet;
  static Worksheet _advertSheet;
  static Worksheet _eventSheet;
  static Worksheet _settingsSheet;

  static Future init() async {
    try {
      final spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
      _menuSheet = await _getWorkSheet(spreadsheet: spreadsheet, title: 'Menu');
      _advertSheet =
          await _getWorkSheet(spreadsheet: spreadsheet, title: 'Reclama');
      _eventSheet =
          await _getWorkSheet(spreadsheet: spreadsheet, title: 'Eveniment');
      _settingsSheet =
          await _getWorkSheet(spreadsheet: spreadsheet, title: 'Setari');
    } catch (e) {
      print('e o problema: $e');
    }
  }

  static Future<Worksheet> _getWorkSheet({
    Spreadsheet spreadsheet,
    @required String title,
  }) async {
    return spreadsheet.worksheetByTitle(title);
    // return await spreadsheet.worksheetByTitle(title)!;
  }

  static Future<List<Product>> getProducts() async {
    final menuData = await _menuSheet.values.map.allRows();
    return menuData
        .map((e) => Product(
              id: e['id'],
              title: e['title'],
              description: e['description'],
              price: double.parse(e['price']),
              reducedPrice: double.parse(e['reducedPrice']),
              category: e['category'],
              subCategory: e['subcategory'],
              grossWeight: e['grossWeight'],
              allergens: e['allergens'],
              nutVal: e['nutVal'],
              imageSmall: e['imageSmall'],
              imageBig: e['imageBig'],
              bigElement: e['bigElement'],
              video: e['video'],
              status: e['status'],
              delivery: e['delivery'],
              best: e['best'],
            ))
        .toList();
  }

  static Future<Advert> getAdvert() async {
    final advertData = await _advertSheet.values.row(2);

    return Advert(
      title: advertData[0],
      header: advertData[1],
      description: advertData[2],
      photo: advertData[3],
    );
  }

  static Future<Event> getEvent() async {
    final eventData = await _eventSheet.values.row(2);

    return Event(
      title: eventData[0],
      header: eventData[1],
      description: eventData[2],
      photo: eventData[3],
    );
  }

  static Future<Settings> getSettings() async {
    final settingsData1 = await _settingsSheet.values.row(2);
    final settingsData2 = await _settingsSheet.values.row(5);
    final settingsData3 = await _settingsSheet.values.row(6);
    final settingsData4 = await _settingsSheet.values.row(9);
    final settingsData5 = await _settingsSheet.values.row(15);

    return Settings(
      openingHour: int.parse(settingsData1[0]),
      closingHour: int.parse(settingsData1[1]),
      open: settingsData1[4] == "deschis" ? true : false,
      deliveryCost: double.parse(settingsData1[2]),
      minimumDeliveryPrice: int.parse(settingsData1[3]),
      discountAddress: settingsData2[0] == 'da' ? true : false,
      discountValueAddress:
          settingsData2[0] == 'da' ? double.parse(settingsData2[1]) : 0,
      discountPickup: settingsData3[0] == 'da' ? true : false,
      discountValuePickup:
          settingsData3[0] == 'da' ? double.parse(settingsData3[1]) : 0,
      phone: settingsData4[0],
      program1: settingsData4[1],
      program2: settingsData4[2],
      program3: settingsData4[3],
      requiredMinVersion: settingsData5[0],
    );
  }
}
