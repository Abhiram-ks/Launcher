import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/constant/usage_constants.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/themes/app_colors.dart';

class UsageNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize notification service
  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      UsageConstants.notificationChannelId,
      UsageConstants.notificationChannelName,
      description: UsageConstants.notificationChannelDescription,
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Show usage limit dialog
  static void showUsageLimitDialog(
    BuildContext context,
    String appName,
    int minutes,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _UsageLimitDialog(
        appName: appName,
        minutes: minutes,
      ),
    );
  }

  /// Show notification (when app is in background)
  static Future<void> showNotification(
    String appName,
    int minutes,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      UsageConstants.notificationChannelId,
      UsageConstants.notificationChannelName,
      channelDescription: UsageConstants.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      appName.hashCode, // Unique ID per app
      'Screen Time Alert',
      'You\'ve used $appName for $minutes minutes',
      details,
    );
  }
}

class _UsageLimitDialog extends StatelessWidget {
  final String appName;
  final int minutes;

  const _UsageLimitDialog({
    required this.appName,
    required this.minutes,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppTextStyleNotifier.instance,
      builder: (context, _, __) {
        return AlertDialog(
          backgroundColor: AppPalette.blackColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: AppTextStyleNotifier.instance.textColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppPalette.orengeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.clock_fill,
                  color: AppPalette.orengeColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Screen Time Alert',
                  style: GoogleFonts.getFont(
                    AppTextStyleNotifier.instance.fontFamily,
                    textStyle: TextStyle(
                      color: AppTextStyleNotifier.instance.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You\'ve used',
                style: GoogleFonts.getFont(
                  AppTextStyleNotifier.instance.fontFamily,
                  textStyle: TextStyle(
                    color: AppTextStyleNotifier.instance.textColor.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppPalette.orengeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppPalette.orengeColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      appName,
                      style: GoogleFonts.getFont(
                        AppTextStyleNotifier.instance.fontFamily,
                        textStyle: const TextStyle(
                          color: AppPalette.orengeColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'for $minutes minutes',
                  style: GoogleFonts.getFont(
                    AppTextStyleNotifier.instance.fontFamily,
                    textStyle: TextStyle(
                      color: AppTextStyleNotifier.instance.textColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.orengeColor,
                  foregroundColor: AppPalette.whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'OK',
                  style: GoogleFonts.getFont(
                    AppTextStyleNotifier.instance.fontFamily,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

