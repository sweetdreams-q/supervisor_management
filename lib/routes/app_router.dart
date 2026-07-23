import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/browse_staff_screen.dart';
import '../screens/add_project_idea_screen.dart';
import '../screens/edit_interest_screen.dart';
import '../screens/edit_project_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/signup_screen.dart';
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
      path: AppRoutes.editInterest,
      name: 'edit-interest',
      builder: (BuildContext context, GoRouterState state) {
        final interestId = state.pathParameters['id'] ?? '';
        return EditInterestScreen(interestId: interestId);
      },
    ),
    GoRoute(
      path: AppRoutes.addProjectIdea,
      name: 'add-project-idea',
      builder: (BuildContext context, GoRouterState state) =>
          const AddProjectIdeaScreen(),
    ),
    GoRoute(
      path: AppRoutes.editProject,
      name: 'edit-project',
      builder: (BuildContext context, GoRouterState state) {
        final projectId = state.pathParameters['id'] ?? '';
        return EditProjectScreen(projectId: projectId);
      },
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (BuildContext context, GoRouterState state) =>
          const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (BuildContext context, GoRouterState state) =>
          const SignupScreen(),
    ),
  ],
  errorBuilder: (BuildContext context, GoRouterState state) =>
      const NotFoundScreen(),
);
