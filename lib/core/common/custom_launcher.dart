import 'package:flutter/material.dart';
import 'package:minilauncher/core/common/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openWebPage({
  required BuildContext context,
  required String url,
  required String errorMessage,
}) async {
  final Uri uri = Uri.parse(url);
  final bool launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);

  if (!launched) {
    if (context.mounted) {
      CustomSnackBar.show(
        context,
        message: errorMessage,
        textAlign: TextAlign.center,
      );
    }
  }
}

Future<void> sendFeedback(BuildContext context) async {
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'Growblic@gmail.com',
    query: 'subject=Feedback for PivotOS: Minimalist launcher App&body=Hi Team,%0A%0AI would like to share the following feedback:%0A%0A',
  );
  try {
    await launchUrl(emailLaunchUri);
  } catch (e) {
    if(!context.mounted) return;
    CustomSnackBar.show(
        context,
        message: "An error occurred while launching the email.",
        textAlign: TextAlign.center,
      );
  }
}
