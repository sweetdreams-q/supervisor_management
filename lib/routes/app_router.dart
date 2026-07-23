import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/browse_staff_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/staff_dashboard_screen.dart';
import '../screens/staff_details_screen.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (BuildContext context, GoRouterState state) =>
          const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.browseStaff,
      name: 'browse-staff',
      builder: (BuildContext context, GoRouterState state) =>
          const BrowseStaffScreen(),
    ),
    GoRoute(
      path: AppRoutes.staffDetails,
      name: 'staff-details',
      builder: (BuildContext context, GoRouterState state) {
        final staffId = state.pathParameters['id'] ?? '';
        return StaffDetailsScreen(staffId: staffId);
      },
    ),
    GoRoute(
      path: AppRoutes.staffDashboard,
      name: 'staff-dashboard',
      builder: (BuildContext context, GoRouterState state) =>
          const StaffDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (BuildContext context, GoRouterState state) =>
          const LoginScreen(),
    ),
  ],
  errorBuilder: (BuildContext context, GoRouterState state) =>
      const NotFoundScreen(),
);
