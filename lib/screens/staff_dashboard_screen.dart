import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/interest_model.dart';
import '../models/project_idea_model.dart';
import '../providers/auth_provider.dart';
import '../providers/interest_provider.dart';
import '../providers/project_provider.dart';
import '../providers/staff_provider.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loaded) {
      return;
    }

    final staffId = context.read<AuthProvider>().currentUser?.staffId ?? '';
    if (staffId.isNotEmpty) {
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<StaffProvider>().loadStaffById(staffId);
        context.read<InterestProvider>().loadData(staffId: staffId);
        context.read<ProjectProvider>().loadData(staffId: staffId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final staffId = authProvider.currentUser?.staffId ?? '';

    if (staffId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Staff Dashboard')),
        body: const Center(
          child: Text('Staff login required to access the dashboard.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddActionSheet(context, staffId),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Consumer3<StaffProvider, InterestProvider, ProjectProvider>(
        builder: (context, staffProvider, interestProvider, projectProvider, _) {
          final staff = staffProvider.selectedStaff;
          final loading = staffProvider.isLoading || interestProvider.isLoading || projectProvider.isLoading;
          final hasError = staffProvider.errorMessage != null || interestProvider.errorMessage != null || projectProvider.errorMessage != null;

          if (loading && staff == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (hasError && staff == null) {
            final message = staffProvider.errorMessage ?? interestProvider.errorMessage ?? projectProvider.errorMessage ?? 'Unable to load dashboard.';
            return Center(child: Text(message));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              final profileBanner = Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        child: Text(
                          authProvider.currentUser?.name.isNotEmpty == true
                              ? authProvider.currentUser!.name.substring(0, 1).toUpperCase()
                              : 'S',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${authProvider.currentUser?.name ?? 'Staff'}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              staff?.department ?? 'Managing your research interests and project ideas',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );

              final interestsSection = _ManagementSection<InterestModel>(
                title: 'Manage Interests',
                emptyMessage: 'No interest records yet.',
                items: interestProvider.interests,
                itemBuilder: (context, item) => _InterestRecordCard(
                  item: item,
                  onEdit: () => context.pushNamed(
                    'edit-interest',
                    pathParameters: {'id': item.id},
                  ),
                  onDelete: () => _confirmDelete(context, 'Delete this interest?', () => interestProvider.deleteInterest(item.id)),
                ),
              );

              final projectsSection = _ManagementSection<ProjectIdeaModel>(
                title: 'Manage Project Ideas',
                emptyMessage: 'No project ideas yet.',
                items: projectProvider.projects,
                itemBuilder: (context, item) => _ProjectRecordCard(
                  item: item,
                  onEdit: () => _showProjectDialog(context, staffId, project: item),
                  onDelete: () => _confirmDelete(context, 'Delete this project idea?', () => projectProvider.deleteProject(item.id)),
                ),
              );

              final content = isWide
                  ? Column(
                      children: [
                        profileBanner,
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: interestsSection),
                            const SizedBox(width: 20),
                            Expanded(child: projectsSection),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        profileBanner,
                        const SizedBox(height: 20),
                        interestsSection,
                        const SizedBox(height: 20),
                        projectsSection,
                      ],
                    );

              return RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    context.read<InterestProvider>().loadData(staffId: staffId),
                    context.read<ProjectProvider>().loadData(staffId: staffId),
                    context.read<StaffProvider>().loadStaffById(staffId),
                  ]);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: content,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String message, Future<void> Function() onConfirm) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm delete'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await onConfirm();
    }
  }

  void _showAddActionSheet(BuildContext context, String staffId) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.lightbulb_outline),
                title: const Text('Add Interest'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showInterestDialog(context, staffId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_open_outlined),
                title: const Text('Add Project Idea'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  if (mounted) {
                    context.pushNamed('add-project-idea');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showInterestDialog(
    BuildContext context,
    String staffId, {
    InterestModel? interest,
  }) async {
    final titleController = TextEditingController(text: interest?.title ?? '');
    final descriptionController = TextEditingController(text: interest?.description ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(interest == null ? 'Add Interest' : 'Edit Interest'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Title is required.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Description is required.' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }

                final provider = context.read<InterestProvider>();
                final messenger = ScaffoldMessenger.of(context);
                final isAdding = interest == null;

                if (interest == null) {
                  final createdInterest = await provider.addInterest(
                    staffId: staffId,
                    title: titleController.text,
                    description: descriptionController.text,
                  );

                  if (createdInterest == null) {
                    return;
                  }
                } else {
                  final updatedInterest = await provider.updateInterest(
                    id: interest.id,
                    staffId: staffId,
                    title: titleController.text,
                    description: descriptionController.text,
                  );

                  if (updatedInterest == null) {
                    return;
                  }
                }

                await provider.loadData(staffId: staffId);

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }

                messenger.showSnackBar(
                  SnackBar(
                    content: Text(isAdding ? 'Interest added successfully.' : 'Interest updated successfully.'),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showProjectDialog(
    BuildContext context,
    String staffId, {
    ProjectIdeaModel? project,
  }) async {
    final titleController = TextEditingController(text: project?.title ?? '');
    final descriptionController = TextEditingController(text: project?.description ?? '');
    final tagsController = TextEditingController(text: project?.tags ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(project == null ? 'Add Project Idea' : 'Edit Project Idea'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Title is required.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Description is required.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: tagsController,
                  decoration: const InputDecoration(labelText: 'Tags'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Tags are required.' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }

                final provider = context.read<ProjectProvider>();
                if (project == null) {
                  await provider.addProject(
                    staffId: staffId,
                    title: titleController.text,
                    description: descriptionController.text,
                    tags: tagsController.text,
                  );
                } else {
                  await provider.updateProject(
                    id: project.id,
                    staffId: staffId,
                    title: titleController.text,
                    description: descriptionController.text,
                    tags: tagsController.text,
                  );
                }

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _ManagementSection<T> extends StatelessWidget {
  const _ManagementSection({
    required this.title,
    required this.emptyMessage,
    required this.items,
    required this.itemBuilder,
  });

  final String title;
  final String emptyMessage;
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              Text(emptyMessage)
            else
              Column(
                children: items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: itemBuilder(context, item),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _InterestRecordCard extends StatelessWidget {
  const _InterestRecordCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final InterestModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(item.description),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectRecordCard extends StatelessWidget {
  const _ProjectRecordCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final ProjectIdeaModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tags = item.tags
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(item.description),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) => Chip(label: Text(tag))).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
}
