import '../../backend/navigation/route_paths.dart';
import '../../blocs/authentication/auth_bloc.dart';
import 'package:go_router/go_router.dart';

String? authGuard(AuthBloc authBloc, GoRouterState state) {
  final isLoggedIn = authBloc.state.isLoggedIn;
  final authState = authBloc.state;
  final location = state.matchedLocation;

  /// 🔓 Allow dynamic public routes (VERY IMPORTANT)
  if (RouteAccess.publicDynamicPrefixes
      .any((prefix) => location.startsWith(prefix))) {
    return null;
  }

   /// 🔓 Allow splash ALWAYS
  if (location == '/') return null;

  /// 🔐 Not logged in
  if (!isLoggedIn) {
    return '/login';
  }

  /// Prevent going back to login
  if (location == '/login') {
    return '/home';
  }

  return null;
}