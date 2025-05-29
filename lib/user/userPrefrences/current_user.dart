import 'package:get/get.dart';
import 'package:zenzo/user/model/user.dart';
import 'package:zenzo/user/userPrefrences/user_prefrences.dart';

class CurrentUser extends GetxController {
  // Rx object to hold the current user data
  Rx<User?> _currentUser = Rx<User?>(null);

  // Getter to access the current user
  User? get user => _currentUser.value;

  // Fetch user info from SharedPreferences asynchronously
  Future<void> getUserInfo() async {
    try {
      // Attempt to read user data from shared preferences
      User? userFromPrefs = await RememberUserPref.readUserInfo();

      // If found, update the current user value
      if (userFromPrefs != null) {
        _currentUser.value = userFromPrefs;
      } else {
        _currentUser.value = null; // If no user found, set to null
      }
    } catch (e) {
      // Handle any potential errors (for example, errors in reading from SharedPreferences)
      print('Error fetching user info: $e');
      _currentUser.value = null; // Set to null in case of error
    }
  }

  // Remove the current user (log out action)
  void removeUser() {
    _currentUser.value = null;
  }
}
