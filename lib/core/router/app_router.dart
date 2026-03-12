import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/hello/presentation/pages/hello_world_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../di/injection_container.dart';

const _publicRoutes = {'/login', '/hello'};

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = sl<AuthBloc>().state is AuthAuthenticated;
      final isPublic = _publicRoutes.contains(state.matchedLocation);

      if (!isAuthenticated && !isPublic) return '/login';
      if (isAuthenticated && state.matchedLocation == '/login') return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/hello',
        builder: (context, state) => const HelloWorldPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
    ],
  );
}
