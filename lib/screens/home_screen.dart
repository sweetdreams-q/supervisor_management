import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisor Management'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;

            final welcomeSection = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Explore staff profiles, review interests, and manage project ideas from one place.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                ),
              ],
            );

            final actionButtons = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.browseStaff),
                  icon: const Icon(Icons.search),
                  label: const Text('Browse Staff'),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.login),
                  icon: const Icon(Icons.login),
                  label: const Text('Staff Login'),
                ),
              ],
            );

            final content = isWide
                ? Row(
                    children: [
                      Expanded(child: welcomeSection),
                      const SizedBox(width: 48),
                      SizedBox(width: 320, child: actionButtons),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      welcomeSection,
                      const SizedBox(height: 32),
                      actionButtons,
                    ],
                  );

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerLow,
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: content,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
