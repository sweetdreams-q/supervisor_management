import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/project_provider.dart';

class AddProjectIdeaScreen extends StatefulWidget {
  const AddProjectIdeaScreen({super.key});

  @override
  State<AddProjectIdeaScreen> createState() => _AddProjectIdeaScreenState();
}

class _AddProjectIdeaScreenState extends State<AddProjectIdeaScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final staffId = authProvider.currentUser?.staffId ?? '';
    if (staffId.isEmpty) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final provider = context.read<ProjectProvider>();
    final createdProject = await provider.addProject(
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

    if (createdProject == null) {
      return;
    }

    await provider.loadData(staffId: staffId);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project idea added successfully.')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authProvider = context.watch<AuthProvider>();
    final staffId = authProvider.currentUser?.staffId ?? '';
    final isLoading = context.watch<ProjectProvider>().isLoading;

    if (staffId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Project Idea')),
        body: const Center(child: Text('Staff login required.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Project Idea'),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'New Project Idea',
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
                        onPressed: (_isSaving || isLoading) ? null : _submit,
                        child: (_isSaving || isLoading)
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save'),
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
