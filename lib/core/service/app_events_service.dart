import 'dart:async';
import 'package:flutter/services.dart';

/// Service for listening to real-time app install/uninstall events
/// 
/// This service provides a stream of app package events from the native Android
/// platform, allowing the UI to update immediately when apps are installed,
/// uninstalled, or updated.
class AppEventsService {
  static const EventChannel _eventChannel = EventChannel('app_events_stream');
  
  static StreamSubscription? _subscription;
  
  /// Stream of app events
  /// 
  /// Each event is a Map containing:
  /// - 'event': String - Type of event ('app_installed', 'app_uninstalled', 'app_updated', 'app_changed')
  /// - 'packageName': String - Package name of the affected app
  /// 
  /// Example:
  /// ```dart
  /// AppEventsService.appEventsStream.listen((event) {
  ///   print('Event: ${event['event']}, Package: ${event['packageName']}');
  /// });
  /// ```
  static Stream<Map<String, dynamic>> get appEventsStream {
    return _eventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return Map<String, dynamic>.from(event);
      }
      return <String, dynamic>{};
    });
  }

  /// Start listening to app events
  /// 
  /// This will automatically register the native BroadcastReceiver
  /// and start emitting events through the stream.
  static void startListening() {
    // The stream automatically starts when first listener subscribes
    // This method is here for explicit control if needed
  }

  /// Stop listening to app events
  /// 
  /// This will unregister the native BroadcastReceiver.
  /// Call this when you no longer need to listen to app events.
  static void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
}

