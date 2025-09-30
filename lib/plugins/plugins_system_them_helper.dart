import 'dart:developer';

import 'package:device_apps/device_apps.dart';

// class ThemeSystemHelper {
//   static Future<void> openSystemThemeSettings() async {
//     const intent = "android.settings.DISPLAY_SETTINGS";
//     try {
//       await DeviceApps.openAppIntent(
//         action: intent,
//       );
//     } catch (e) {
//       log('Unexpected error: settings: $e');
//       throw Exception('Error settings: $e');
//     }
//   }
// }