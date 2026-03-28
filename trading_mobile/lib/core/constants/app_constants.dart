/// API base URL. Override with `--dart-define=API_BASE_URL=https://api.example.com`
class AppConstants {
  AppConstants._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  /// Android emulator → host machine (override API_BASE_URL if needed)
  static const String androidEmulatorHost = '10.0.2.2';

  static String resolveBaseUrl() {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;
    return apiBaseUrl;
  }
}
