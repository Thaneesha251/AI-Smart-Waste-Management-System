class AppConstants {
  static const String appName = 'SwachhAI';

  // Use 10.0.2.2 for Android Emulator to access localhost
  static const String apiBaseUrl =
      'http://10.0.2.2:8000'; // Base url changed to root per api requirements: /login, /register, /complaints/create, etc.

  // Explicit Mock Fallback Switch (if true, will fallback to mocks if API fails)
  static const bool useMockFallback = true;

  // Storage Keys
  static const String tokenKey = 'access_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String usernameKey = 'username';
}
