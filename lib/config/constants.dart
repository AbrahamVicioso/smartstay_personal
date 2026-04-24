class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'https://api.smartstay.es/api/auth';
  static const String personalBaseUrl = 'https://api.smartstay.es/api/user';
  static const String habitacionesBaseUrl = 'https://api.smartstay.es/api/reserva';
  static const String registrosBaseUrl = 'https://api.smartstay.es/api/device';

  // API Endpoints
  static const String loginEndpoint = '/Login';
  static const String registerEndpoint = '/Register';
  static const String refreshEndpoint = '/RefreshToken';
  static const String userByEmailEndpoint = '/Users/by-email';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userEmailKey = 'user_email';

  // App Info
  static const String appName = 'SmartStay Personal';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int itemsPerPage = 20;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}