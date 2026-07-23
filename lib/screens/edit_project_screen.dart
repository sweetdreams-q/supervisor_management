import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/project_idea_model.dart';
import '../providers/auth_provider.dart';
import '../providers/project_provider.dart';

class EditProjectScreen extends StatefulWidget {
  const EditProjectScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  bool _didInitialize = false;
  bool _isSaving = false;
  ProjectIdeaModel? _selectedProject;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didInitialize) {
      return;
    }

    _didInitialize = true;
    final authProvider = context.read<AuthProvider>();
    final staffId = authProvider.currentUser?.staffId ?? '';
    if (staffId.isEmpty) {
      return;
    }

    final projectProvider = context.read<ProjectProvider>();
    _selectedProject = _findProject(projectProvider.projects);

    if (_selectedProject != null) {
      _titleController.text = _selectedProject!.title;
      _descriptionController.text = _selectedProject!.description;
      _tagsController.text = _selectedProject!.tags;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await projectProvider.loadData(staffId: staffId);
      final reloadedProject = _findProject(projectProvider.projects);
      if (!mounted) {
        return;
      }

      setState(() {
        _selectedProject = reloadedProject;
        if (reloadedProject != null) {
          _titleController.text = reloadedProject.title;
          _descriptionController.text = reloadedProject.description;
          _tagsController.text = reloadedProject.tags;
        }
      });
    });
  }

  ProjectIdeaModel? _findProject(List<ProjectIdeaModel> projects) {
    for (final project in projects) {
      if (project.id == widget.projectId) {
        return project;
      }
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final staffId = authProvider.currentUser?.staffId ?? '';
    if (staffId.isEmpty || _selectedProject == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final provider = context.read<ProjectProvider>();
    final updatedProject = await provider.updateProject(
      id: _selectedProject!.id,
      staffId: staffId,
      title: _titleController.text,
      description: _descriptionController.text,
      tags: _tagsController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (updatedProject == null) {
      return;
    }

    await provider.loadData(staffId: staffId);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project idea updated successfully.')),
    );

    context.goNamed('staff-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authProvider = context.watch<AuthProvider>();
    final staffId = authProvider.currentUser?.staffId ?? '';
    final provider = context.watch<ProjectProvider>();
    final loading = provider.isLoading && _selectedProject == null;
    final hasError = provider.errorMessage != null && _selectedProject == null;

    if (staffId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Project Idea')),
        body: const Center(child: Text('Staff login required.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Project Idea'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 0,
              color: colorScheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : hasError
                        ? Center(child: Text(provider.errorMessage ?? 'Unable to load project.'))
                        : _selectedProject == null
                            ? const Center(child: Text('Project not found.'))
                            : Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Update Project Idea',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 24),
                                    TextFormField(
                                      controller: _titleController,
                                      decoration: const InputDecoration(
                                        labelText: 'Title',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Title is required.';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _descriptionController,
                                      decoration: const InputDecoration(
                                        labelText: 'Description',
                                        border: OutlineInputBorder(),
                                      ),
                                      maxLines: 4,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Description is required.';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _tagsController,
                                      decoration: const InputDecoration(
                                        labelText: 'Tags',
                                        border: OutlineInputBorder(),
                                        hintText: 'Comma-separated tags',
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Tags are required.';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    FilledButton(
                                      onPressed: _isSaving ? null : _submit,
                                      child: _isSaving
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Text('Update'),
                                    ),
                                  ],
                                ),
                              ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
