import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/staff_provider.dart';
import '../routes/app_routes.dart';

class BrowseStaffScreen extends StatefulWidget {
  const BrowseStaffScreen({super.key});

  @override
  State<BrowseStaffScreen> createState() => _BrowseStaffScreenState();
}

class _BrowseStaffScreenState extends State<BrowseStaffScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().loadBrowseData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Staff'),
      ),
      body: Consumer<StaffProvider>(
        builder: (context, provider, _) {
          final filteredStaff = provider.filteredBrowseStaff;

          if (provider.isLoading && provider.browseStaff.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.browseStaff.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 1200
                  ? 3
                  : constraints.maxWidth >= 720
                      ? 2
                      : 1;

              return RefreshIndicator(
                onRefresh: provider.loadBrowseData,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                        child: _BrowseFilters(
                          searchController: _searchController,
                          provider: provider,
                        ),
                      ),
                    ),
                    if (provider.isLoading)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(24, 0, 24, 12),
                          child: LinearProgressIndicator(),
                        ),
                      ),
                    if (filteredStaff.isEmpty && !provider.isLoading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _NoResultsView(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: crossAxisCount == 1 ? 1.1 : 1.0,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _StaffCard(item: filteredStaff[index]),
                            childCount: filteredStaff.length,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _BrowseFilters extends StatelessWidget {
  const _BrowseFilters({required this.searchController, required this.provider});

  final TextEditingController searchController;
  final StaffProvider provider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 720;

    if (searchController.text != provider.browseSearchQuery) {
      searchController.value = searchController.value.copyWith(
        text: provider.browseSearchQuery,
        selection: TextSelection.collapsed(offset: provider.browseSearchQuery.length),
      );
    }

    final filters = isWide
        ? Row(
            children: [
              Expanded(child: _SearchField(controller: searchController, provider: provider)),
              const SizedBox(width: 16),
              SizedBox(
                width: 260,
                child: _InterestDropdown(provider: provider),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SearchField(controller: searchController, provider: provider),
              const SizedBox(height: 16),
              _InterestDropdown(provider: provider),
            ],
          );

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            filters,
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  searchController.clear();
                  provider.clearBrowseFilters();
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.provider});

  final TextEditingController controller;
  final StaffProvider provider;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Search staff',
        hintText: 'Name, department, or research interest',
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(),
      ),
      onChanged: provider.setBrowseSearchQuery,
    );
  }
}

class _InterestDropdown extends StatelessWidget {
  const _InterestDropdown({required this.provider});

  final StaffProvider provider;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: provider.selectedInterest,
      decoration: const InputDecoration(
        labelText: 'Interest filter',
        border: OutlineInputBorder(),
      ),
      items: provider.browseInterestOptions
          .map(
            (value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          provider.setSelectedInterest(value);
        }
      },
    );
  }
}

class _NoResultsView extends StatelessWidget {
  const _NoResultsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 72,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or interest filter.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({required this.item});

  final StaffBrowseModel item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.staffProfile.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              item.staffProfile.department,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Research interests',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.areasOfInterest.isEmpty
                  ? [
                      Chip(
                        label: Text(
                          'No interests listed',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ]
                  : item.areasOfInterest
                      .map((interest) => Chip(label: Text(interest.title)))
                      .toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.goNamed(
                  'staff-details',
                  pathParameters: {'id': item.staffProfile.id},
                ),
                child: const Text('View Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
