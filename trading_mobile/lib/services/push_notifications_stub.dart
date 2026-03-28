import 'package:flutter/material.dart';

/// Placeholder for Firebase Cloud Messaging integration.
/// Wire [firebase_core] + [firebase_messaging] here when you add `google-services.json` / `GoogleService-Info.plist`.
class PushNotificationsStub {
  PushNotificationsStub._();

  static const String statusLine = 'Disabled (add Firebase to enable)';

  static void showDisabledSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Push is stubbed. Add Firebase Messaging and register device tokens in the API.'),
      ),
    );
  }
}
