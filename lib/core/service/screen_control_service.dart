import 'package:flutter/services.dart';

class ScreenControlService {
  static const MethodChannel _channel = MethodChannel('screen_control_service');

  /// Turn off the screen (lock screen)
  static Future<bool> turnOffScreen() async {
    try {
      final result = await _channel.invokeMethod<bool>('turnOffScreen');
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception("Failed to turn off screen: '${e.message}'.");
    }
  }

  /// Turn on the screen (wake up screen)
  static Future<bool> turnOnScreen() async {
    try {
      final result = await _channel.invokeMethod<bool>('turnOnScreen');
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception("Failed to turn on screen: '${e.message}'.");
    }
  }

  /// Check if screen is currently on
  static Future<bool> isScreenOn() async {
    try {
      final result = await _channel.invokeMethod<bool>('isScreenOn');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isDeviceAdminEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isDeviceAdminEnabled');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestDeviceAdmin() async {
    try {
      await _channel.invokeMethod<void>('requestDeviceAdmin');
    } catch (_) {}
  }

  static Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod<void>('openAccessibilitySettings');
    } catch (_) {}
  }
}

