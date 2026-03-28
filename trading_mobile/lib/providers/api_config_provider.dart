import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';

const _kApiUrlKey = 'api_base_url';

final apiBaseUrlProvider = StateProvider<String>((ref) => AppConstants.resolveBaseUrl());

Future<void> hydrateApiBaseUrl(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  final v = prefs.getString(_kApiUrlKey);
  if (v != null && v.trim().isNotEmpty) {
    ref.read(apiBaseUrlProvider.notifier).state = v.trim();
  }
}

Future<void> persistApiBaseUrl(String url) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kApiUrlKey, url.trim());
}
