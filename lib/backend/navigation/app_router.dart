import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intricue_app/views/auth/login_screen.dart';
import 'package:intricue_app/views/home/home_screen.dart';
import 'package:intricue_app/views/recruiter/recruiter_screen.dart';

import '../../blocs/authentication/auth_bloc.dart';
import '../../blocs/recruiter/recruiter_bloc.dart';
import '../../views/auth/splash_screen.dart';
import '../recruiter/recruiter_repository.dart';
import 'route_paths.dart';
import 'route_guards.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createAppRouter(AuthBloc authBloc) {
  final recruiterRepository = RecruiterRepository();

  return GoRouter(
    initialLocation: RoutePaths.splash,

    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    redirect: (context, state) => authGuard(authBloc, state),

    routes: [
      /// PUBLIC — CORE ROUTE
      GoRoute(
        path: '/p/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;

          return BlocProvider(
            create: (_) => RecruiterBloc(repository: recruiterRepository),
            child: RecruiterScreen(id: id),
          );
        },
      ),

      /// Public
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),

      /// Private
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => RecruiterBloc(repository: recruiterRepository),
            child: const HomeScreen(),
          );
        },
      ),
    ],
  );
}
