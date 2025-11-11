import 'package:flutter/material.dart';
import 'package:minilauncher/core/service/screen_control_service.dart';

/// Mixin for handling double tap to turn off screen functionality
/// Includes debouncing and device admin checks
mixin DoubleTapHandlerMixin<T extends StatefulWidget> on State<T> {
  DateTime? _lastDoubleTapTime;
  bool _isProcessing = false;
  static const Duration _debounceDelay = Duration(milliseconds: 1000);

  Future<void> handleDoubleTap() async {
    // Debounce to prevent multiple rapid calls
    final now = DateTime.now();
    
    // Check if already processing
    if (_isProcessing) {
      return; // Already processing, ignore
    }
    
    // Check if too soon after last double-tap
    if (_lastDoubleTapTime != null &&
        now.difference(_lastDoubleTapTime!) < _debounceDelay) {
      return; // Too soon after last double-tap, ignore
    }
    
    // Set flags immediately to prevent multiple calls
    _lastDoubleTapTime = now;
    _isProcessing = true;

    try {
      // Prefer device admin if available; otherwise suggest accessibility fallback
      final isAdmin = await ScreenControlService.isDeviceAdminEnabled();
      if (!isAdmin) {
        await ScreenControlService.requestDeviceAdmin();
        await ScreenControlService.openAccessibilitySettings();
        return;
      }
      
      final ok = await ScreenControlService.turnOffScreen();
      if (!ok) {
        // Prompt user to enable the Accessibility Service fallback
        await ScreenControlService.openAccessibilitySettings();
      }
    } catch (e) {
      // Silently handle errors - screen control may not be available on all devices
    } finally {
      // Reset processing flag after a longer delay to ensure screen stays off
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      });
    }
  }
}

