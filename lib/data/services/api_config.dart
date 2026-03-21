class ApiConfig {
  static const String baseUrl = 'https://api.example.com';
  static bool isDemoMode = true;

  static String url(String path) => '$baseUrl$path';
}
