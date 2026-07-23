import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/interest_model.dart';
import '../providers/auth_provider.dart';
import '../providers/interest_provider.dart';
import '../routes/app_routes.dart';

class EditInterestScreen extends StatefulWidget {
  const EditInterestScreen({super.key, required this.interestId});

  final String interestId;

  @override
  State<EditInterestScreen> createState() => _EditInterestScreenState();
}

class _EditInterestScreenState extends State<EditInterestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _didInitialize = false;
  bool _isSaving = false;
  InterestModel? _selectedInterest;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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

    final interestProvider = context.read<InterestProvider>();
    _selectedInterest = _findInterest(interestProvider.interests);

    if (_selectedInterest != null) {
      _titleController.text = _selectedInterest!.title;
      _descriptionController.text = _selectedInterest!.description;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await interestProvider.loadData(staffId: staffId);
      final reloadedInterest = _findInterest(interestProvider.interests);
      if (!mounted) {
        return;
      }

      setState(() {
        _selectedInterest = reloadedInterest;
        if (reloadedInterest != null) {
          _titleController.text = reloadedInterest.title;
          _descriptionController.text = reloadedInterest.description;
        }
      });
    });
  }

  InterestModel? _findInterest(List<InterestModel> interests) {
    for (final interest in interests) {
      if (interest.id == widget.interestId) {
        return interest;
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
    if (staffId.isEmpty || _selectedInterest == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final provider = context.read<InterestProvider>();
    final updatedInterest = await provider.updateInterest(
      id: _selectedInterest!.id,
      staffId: staffId,
      title: _titleController.text,
      description: _descriptionController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (updatedInterest == null) {
      return;
    }

    await provider.loadData(staffId: staffId);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Interest updated successfully.')),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authProvider = context.watch<AuthProvider>();
    final staffId = authProvider.currentUser?.staffId ?? '';
    final provider = context.watch<InterestProvider>();
    final loading = provider.isLoading && _selectedInterest == null;
    final hasError = provider.errorMessage != null && _selectedInterest == null;

    if (staffId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Interest')),
        body: const Center(child: Text('Staff login required.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Interest'),
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
                        ? Center(child: Text(provider.errorMessage ?? 'Unable to load interest.'))
                        : _selectedInterest == null
                            ? const Center(child: Text('Interest not found.'))
                            : Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Update Interest',
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
