import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/staff_browse_model.dart';
import '../providers/staff_provider.dart';
import '../routes/app_routes.dart';

class BrowseStaffScreen extends StatefulWidget {
  const BrowseStaffScreen({super.key});

  @override
  State<BrowseStaffScreen> createState() => _BrowseStaffScreenState();
}

class _BrowseStaffScreenState extends State<BrowseStaffScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().loadBrowseData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Staff'),
      ),
      body: Consumer<StaffProvider>(
        builder: (context, provider, _) {
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
                child: provider.browseStaff.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 160),
                          Center(child: Text('No staff found.')),
                        ],
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(24),
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: crossAxisCount == 1 ? 1.15 : 1.0,
                        ),
                        itemCount: provider.browseStaff.length,
                        itemBuilder: (context, index) {
                          final item = provider.browseStaff[index];
                          return _StaffCard(item: item);
                        },
                      ),
              );
            },
          );
        },
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
