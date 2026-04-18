abstract class RoutePaths {
  // 🔓 Public
  static const splash = '/';
  static const login = '/login';

  // 🔥 CORE FEATURE
  static const recruiter = '/p/:id';

  // 🔐 Internal (you only)
  static const home = '/home';

  // (future)
  static const dashboard = '/dashboard';
}

class RouteAccess {
  /// 🔓 Public routes (no login required)
  static const public = {
    RoutePaths.splash,
    RoutePaths.login,
  };

  /// 🔓 Special public dynamic routes
  static const publicDynamicPrefixes = [
    '/p/', // recruiter pages
  ];

  /// 🔐 Requires login
  static const authenticated = {
    RoutePaths.home,
    RoutePaths.dashboard,
  };
}
