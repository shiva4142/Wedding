import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_dashboard_page.dart';
import '../../features/admin/admin_login_page.dart';
import '../../features/invite/invite_page.dart';
import '../../features/landing/landing_page.dart';
import '../../services/providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const LandingPage(),
      ),
      GoRoute(
        path: '/invite',
        builder: (_, state) {
          final guest = state.uri.queryParameters['guest'];
          return InvitePage(guestSlug: guest);
        },
      ),
      GoRoute(
        path: '/admin/login',
        builder: (_, __) => const AdminLoginPage(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        redirect: (context, state) {
          final token = ref.read(adminTokenProvider);
          if (token == null) return '/admin/login';
          return null;
        },
        builder: (_, __) => const AdminDashboardPage(),
      ),
    ],
  );
});
