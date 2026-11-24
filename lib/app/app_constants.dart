class AppConstants {
  AppConstants._();

  static const String appName = 'CraftyBay';
  static const String appVersion = '1.0';

  // The API is hosted on a free Render server, so the first call can be slow.
  static const Duration requestTimeout = Duration(seconds: 60);

  static const double screenPadding = 16;
}