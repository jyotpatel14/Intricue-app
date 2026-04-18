import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'backend/authentication/authentication_repository.dart';
import 'backend/navigation/app_router.dart';
import 'blocs/recruiter/recruiter_bloc.dart';
import 'firebase_options.dart';

import 'blocs/authentication/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthenticationRepository();

    final authBloc = AuthBloc(repository: authRepository);

    final router = createAppRouter(authBloc);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => authBloc),

      ],
      child: MaterialApp.router(
        title: 'Intricue',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        routerConfig: router,
      ),
    );
  }
}
