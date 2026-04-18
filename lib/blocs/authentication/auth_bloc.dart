import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intricue_app/blocs/authentication/auth_event.dart';
import 'package:intricue_app/blocs/authentication/auth_state.dart';

import '../../backend/authentication/authentication_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthenticationRepository repository;

  AuthBloc({required this.repository}) : super(AuthState.initial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onAppStarted(
    AppStarted event, Emitter<AuthState> emit) async {
  final user = repository.currentUser;

  if (user != null) {
    emit(state.copyWith(
      isLoggedIn: true,
      userId: user.uid,
    ));
  } else {
    emit(state.copyWith(
      isLoggedIn: false,
      userId: null,
    ));
  }
}

  Future<void> _onLogin(
      LoginEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final user = await repository.login(
        email: event.email,
        password: event.password,
      );

      emit(state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        userId: user?.uid,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onRegister(
      RegisterEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final user = await repository.register(
        email: event.email,
        password: event.password,
      );

      emit(state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        userId: user?.uid,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLogout(
      LogoutEvent event, Emitter<AuthState> emit) async {
    await repository.logout();
    emit(AuthState.initial());
  }
}