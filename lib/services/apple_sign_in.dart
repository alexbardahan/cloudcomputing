import 'package:apple_sign_in/apple_sign_in.dart';

class AppleSignInAvailable {
  static bool availability;
  static Future<void> check() async {
    availability = await AppleSignIn.isAvailable();
  }
}
