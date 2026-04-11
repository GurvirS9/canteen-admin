class AppConstants {
  AppConstants._();

  static const String appName = 'Canteen Manager';

  // ─── API Configuration ──────────────────────────────────────────
  // Production backend on Railway
  static const String baseUrl = 'https://kanteen-queue-production.up.railway.app/api';

  /// Socket.IO URL — same host as API but without /api path
  static String get socketUrl {
    if (baseUrl.endsWith('/api')) {
      return baseUrl.substring(0, baseUrl.length - 4);
    }
    return baseUrl;
  }

  /// Root URL for resolving uploaded image paths like /uploads/xyz.jpg
  /// e.g. https://kanteen-queue-production.up.railway.app
  static String get imageBaseUrl => socketUrl;

  // ─── Endpoints ────────────────────────────────────────────────
  static const String menuEndpoint = '/menu';
  static const String slotsEndpoint = '/slots';
  static const String slotsCheckEndpoint = '/slots/check';
  static const String ordersEndpoint = '/orders';
  static const String activeOrdersEndpoint = '/orders/active';
  static const String summaryEndpoint = '/summary';
  static const String authLoginEndpoint = '/auth/login';
  static const String authLogoutEndpoint = '/auth/logout';
  static String orderStatusEndpoint(String id) => '/orders/$id/status';
  static String orderEndpoint(String id) => '/orders/$id';
  static String menuItemEndpoint(String id) => '/menu/$id';
  static String menuItemImageEndpoint(String id) => '/menu/$id/image';
  static String slotEndpoint(String id) => '/slots/$id';
  static String slotStatusEndpoint(String id) => '/slots/$id/status';

  // Shops
  static const String shopsEndpoint = '/shops';
  static String shopEndpoint(String id) => '/shops/$id';
  static String shopStatusEndpoint(String id) => '/shops/$id/status';

  // Users
  static String userFcmEndpoint(String id) => '/users/$id/fcm-token';

  // Analytics / Prediction
  static const String analyticsEndpoint = '/analytics';
  static const String predictionEndpoint = '/prediction';



  // ─── Auth ─────────────────────────────────────────────────────
  /// Dev bypass key accepted by the backend's auth middleware.
  /// Used as fallback when Firebase token is unavailable.
  /// ⚠️ Development/testing only — do NOT ship in production without gating.
  static const String devAuthKey = 'swagger-local-dev-2024';

  // ─── Timing ───────────────────────────────────────────────────
  static const int apiTimeout = 30; // seconds

  /// Build full URL from an endpoint path
  static String url(String path) => '$baseUrl$path';

  // ─── Menu ─────────────────────────────────────────────────────
  static const List<String> menuCategories = [
    'Main Course',
    'Snacks',
    'Beverages',
    'Desserts',
    'Combos',
    'Breakfast',
  ];
}

