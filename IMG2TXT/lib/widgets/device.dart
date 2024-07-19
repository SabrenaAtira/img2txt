import "dart:io";
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

Future<String> getDeviceId() async {
  try {
    if (!kIsWeb) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        // ignore: avoid_print
        print("Android Device ID: ${androidInfo.model}");
        return androidInfo.model; // Unique identifier on Android
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        // ignore: avoid_print
        print("iOS Device ID: ${iosInfo.utsname.machine}");
        return iosInfo.utsname.machine; // Unique identifier on iOS
      }
    }
  } catch (e) {
    // ignore: avoid_print
    print("Error getting device ID: $e");
  }
  return "unknown"; // Fallback if not Android or iOS or if there's an error
}
