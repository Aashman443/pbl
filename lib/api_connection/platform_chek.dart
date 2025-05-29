import 'dart:io';

String getBaseUrl() {
  if (Platform.isAndroid) {
    return isRunningOnEmulator() ? 'http://192.0.0.2:8888/zenzo' : 'http://10.0.2.2:8888/zenzo';
  } else if (Platform.isIOS) {
    return 'http://localhost:8888/zenzo';
  } else {
    return 'http://192.0.0.2:8888/zenzo';
  }
}

bool isRunningOnEmulator() {

  return !Platform.environment.containsKey('ANDROID_STORAGE'); // crude check
}