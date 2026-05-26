import 'package:go_router/go_router.dart';

import '../../backend/navigation/route_paths.dart';
import '../../blocs/authentication/auth_bloc.dart';

String? authGuard(AuthBloc authBloc, GoRouterState state) {
  final isLoggedIn = authBloc.state.isLoggedIn;
  final location = state.matchedLocation;

  /// 🔓 Allow dynamic public routes (VERY IMPORTANT)
  if (RouteAccess.publicDynamicPrefixes
      .any((prefix) => location.startsWith(prefix))) {
    return null;
  }

  /// 🔓 Allow splash ALWAYS
  if (location == RoutePaths.splash) return null;

  /// 🔐 Not logged in -> send to login
  if (!isLoggedIn) {
    return RoutePaths.login;
  }

  /// Prevent going back to login once authenticated
  if (location == RoutePaths.login) {
    return RoutePaths.home;
  }

  return null;
}