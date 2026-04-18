class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final String? error;
  final String? userId;

  AuthState({
    required this.isLoading,
    required this.isLoggedIn,
    this.error,
    this.userId,
  });

  factory AuthState.initial() {
    return AuthState(
      isLoading: false,
      isLoggedIn: false,
      error: null,
      userId: null,
    );
  }

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    String? error,
    String? userId,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      error: error,
      userId: userId ?? this.userId,
    );
  }
}