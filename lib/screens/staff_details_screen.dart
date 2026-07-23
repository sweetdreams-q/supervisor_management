import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/interest_model.dart';
import '../models/project_idea_model.dart';
import '../providers/interest_provider.dart';
import '../providers/project_provider.dart';
import '../providers/staff_provider.dart';
import '../routes/app_routes.dart';

class StaffDetailsScreen extends StatefulWidget {
  const StaffDetailsScreen({super.key, required this.staffId});

  final String staffId;

  @override
  State<StaffDetailsScreen> createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends State<StaffDetailsScreen> {
  bool _didLoadData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didLoadData) {
      return;
    }

    _didLoadData = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().loadStaffById(widget.staffId);
      context.read<InterestProvider>().loadData(staffId: widget.staffId);
      context.read<ProjectProvider>().loadData(staffId: widget.staffId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go(AppRoutes.browseStaff);
          },
        ),
        title: const Text('Staff Profile'),
      ),
      body: Consumer3<StaffProvider, InterestProvider, ProjectProvider>(
        builder: (context, staffProvider, interestProvider, projectProvider, _) {
          final staff = staffProvider.selectedStaff;
          final isLoading = staffProvider.isLoading || interestProvider.isLoading || projectProvider.isLoading;
          final hasError = staffProvider.errorMessage != null || interestProvider.errorMessage != null || projectProvider.errorMessage != null;

          if (isLoading && staff == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (hasError && staff == null) {
            final message = staffProvider.errorMessage ?? interestProvider.errorMessage ?? projectProvider.errorMessage ?? 'Unable to load staff profile.';

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (staff == null) {
            return const Center(child: Text('No staff profile available.'));
          }

          final interests = interestProvider.interests;
          final projects = projectProvider.projects;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              final profileHeader = Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(
                              Icons.person,
                              size: 42,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  staff.name,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  staff.department,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Biography',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        staff.bio,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                            ),
                      ),
                    ],
                  ),
                ),
              );

              final interestSection = Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Areas of Interest',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _InterestList(interests: interests),
                    ],
                  ),
                ),
              );

              final projectSection = Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Project Ideas',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _ProjectList(projects: projects),
                    ],
                  ),
                ),
              );

              final content = isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              profileHeader,
                              const SizedBox(height: 20),
                              interestSection,
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 4,
                          child: projectSection,
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        profileHeader,
                        const SizedBox(height: 20),
                        interestSection,
                        const SizedBox(height: 20),
                        projectSection,
                      ],
                    );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: content,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _InterestList extends StatelessWidget {
  const _InterestList({required this.interests});

  final List<InterestModel> interests;

  @override
  Widget build(BuildContext context) {
    if (interests.isEmpty) {
      return Text(
        'No interests listed.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: interests
          .map(
            (interest) => Chip(
              label: Text(interest.title),
            ),
          )
          .toList(),
    );
  }
}

class _ProjectList extends StatelessWidget {
  const _ProjectList({required this.projects});

  final List<ProjectIdeaModel> projects;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return Text(
        'No project ideas available.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return Column(
      children: projects
          .map(
            (project) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        project.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                            ),
                      ),
                      if (project.tags.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: project.tags
                              .split(',')
                              .map((tag) => tag.trim())
                              .where((tag) => tag.isNotEmpty)
                              .map((tag) => Chip(label: Text(tag)))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
