import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user.dart';

class RememberUserPref {
  static Future<void> saveUserInfo(User userInfo) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userJson = jsonEncode(userInfo.toJson());
      await preferences.setString('currentUser', userJson);
      print('User info saved successfully');
    } catch (e) {
      print('Error saving user info: $e');
    }
  }

  static Future<User?> readUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('currentUser');

    if (userJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userJson);
      return User.fromJson(userMap); // Make sure this matches the expected data structure
    } else {
      return null;
    }
  }

  static Future<void> removeUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
  }
}
