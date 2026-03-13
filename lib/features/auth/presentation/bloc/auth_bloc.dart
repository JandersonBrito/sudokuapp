import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/auth/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final TokenStorage tokenStorage;

  AuthBloc({
    required this.authRepository,
    required this.tokenStorage,
  }) : super(AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoggedIn>(_onLoggedIn);
    on<AuthLoggedOut>(_onLoggedOut);
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    if (tokenStorage.hasToken) {
      // Token exists — consider session valid (backend will reject if expired)
      emit(AuthAuthenticated(
        user: User(
          id: '',
          email: '',
          accessToken: tokenStorage.getAccessToken()!,
          refreshToken: tokenStorage.getRefreshToken() ?? '',
        ),
      ));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  void _onLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(user: event.user));
  }

  Future<void> _onLoggedOut(AuthLoggedOut event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }
}
