import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minilauncher/core/service/usage_notification_service.dart';

/// Handles showing usage limit dialogs when notifications are tapped
class UsageDialogHandler {
  static const MethodChannel _channel = MethodChannel('usage_dialog_channel');
  static BuildContext? _context;
  
  /// Initialize the dialog handler with app context
  static void initialize(BuildContext context) {
    _context = context;
    
    // Listen for dialog requests from native code
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'showUsageDialog') {
        final appName = call.arguments['appName'] as String;
        final minutes = call.arguments['minutes'] as int;
        
        if (_context != null && _context!.mounted) {
          UsageNotificationService.showUsageLimitDialog(
            _context!,
            appName,
            minutes,
          );
        }
      }
    });
  }
  
  /// Update context (call this when navigating)
  static void updateContext(BuildContext context) {
    _context = context;
  }
  
  /// Clear context when disposing
  static void dispose() {
    _context = null;
  }
}