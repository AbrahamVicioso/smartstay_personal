class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:5117';         
  static const String personalBaseUrl = 'https://localhost:7168';   // <-- HTTPS, no HTTP
  static const String habitacionesBaseUrl = 'https://localhost:7279'; // Probablemente tambien HTTPS
  static const String registrosBaseUrl = 'http://localhost:5185'; // Probablemente tambien HTTPS
  

  // API Endpoints
  static const String loginEndpoint = '/Login';
  static const String registerEndpoint = '/register';
  static const String refreshEndpoint = '/refresh';
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