import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthUnauthenticated()) {
    on<AuthLoggedIn>(_onLoggedIn);
    on<AuthLoggedOut>(_onLoggedOut);
  }

  void _onLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(user: event.user));
  }

  void _onLoggedOut(AuthLoggedOut event, Emitter<AuthState> emit) {
    emit(AuthUnauthenticated());
  }
}
