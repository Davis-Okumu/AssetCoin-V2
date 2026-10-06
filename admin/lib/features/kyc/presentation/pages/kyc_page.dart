import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../controllers/kyc_controller.dart';
import '../widgets/kyc_filter_bar.dart';
import '../widgets/kyc_stats_cards.dart';
import '../widgets/kyc_table.dart';

class KycPage extends ConsumerStatefulWidget {
  const KycPage({super.key});

  @override
  ConsumerState<KycPage> createState() => _KycPageState();
}

class _KycPageState extends ConsumerState<KycPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kycState = ref.watch(kycControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: kycState.when(
          loading: () => const AppLoading(),
          error: (error, stackTrace) => AppErrorState(
            message: error.toString(),
            onRetry: () {
              ref.read(kycControllerProvider.notifier).refresh();
            },
          ),
          data: (data) => _buildContent(context, data),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, KycControllerState data) {
    return RefreshIndicator(
      onRefresh: () {
        return ref.read(kycControllerProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),

            // Reusable KYC-specific stats widget.
            KycStatsCards(stats: data.stats),

            const SizedBox(height: 24),

            // Hybrid filter section:
            // KycFilterBar handles the KYC-specific controls,
            // while the existing core AppSearchField remains
            // available throughout the dashboard.
            _buildFilters(context, data),

            const SizedBox(height: 24),

            // Reusable KYC-specific table widget.
            _buildApplicationsTable(context, data),

            const SizedBox(height: 20),

            _buildPagination(context, data),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KYC Verification',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Review and verify customer-submitted KYC applications.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: () {
            ref.read(kycControllerProvider.notifier).refresh();
          },
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, KycControllerState data) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 800;

            if (isCompact) {
              return _buildCompactFilters(context, data);
            }

            return _buildWideFilters(context, data);
          },
        ),
      ),
    );
  }

  Widget _buildWideFilters(BuildContext context, KycControllerState data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: AppSearchField(
            controller: _searchController,
            hintText: 'Search applicant, email or ID...',
            onChanged: (value) {
              ref
                  .read(kycControllerProvider.notifier)
                  .searchApplications(value);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: KycFilterBar(
            status: data.status,
            assignedTo: data.assignedTo,
            onStatusChanged: (value) {
              ref.read(kycControllerProvider.notifier).filterByStatus(value);
            },
            onAssignedToChanged: (value) {
              ref
                  .read(kycControllerProvider.notifier)
                  .filterByAssignedTo(value);
            },
            onClear: _clearFilters,
            showAssignmentFilter: false,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactFilters(BuildContext context, KycControllerState data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSearchField(
          controller: _searchController,
          hintText: 'Search applicant, email or ID...',
          onChanged: (value) {
            ref.read(kycControllerProvider.notifier).searchApplications(value);
          },
        ),
        const SizedBox(height: 16),
        KycFilterBar(
          status: data.status,
          assignedTo: data.assignedTo,
          onStatusChanged: (value) {
            ref.read(kycControllerProvider.notifier).filterByStatus(value);
          },
          onAssignedToChanged: (value) {
            ref.read(kycControllerProvider.notifier).filterByAssignedTo(value);
          },
          onClear: _clearFilters,
          showAssignmentFilter: false,
        ),
      ],
    );
  }

  Widget _buildApplicationsTable(
    BuildContext context,
    KycControllerState data,
  ) {
    if (data.applications.isEmpty) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 52,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No KYC applications found',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  'Customer-submitted KYC applications will appear here.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'KYC Applications',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${data.pagination.total} applications',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: KycTable(
              applications: data.applications,
              onApplicationTap: (application) {
                context.push('/kyc/${application.id}');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context, KycControllerState data) {
    final pagination = data.pagination;

    if (pagination.totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          tooltip: 'Previous page',
          onPressed: pagination.page > 1
              ? () {
                  ref
                      .read(kycControllerProvider.notifier)
                      .loadPage(pagination.page - 1);
                }
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        const SizedBox(width: 8),
        Text(
          'Page ${pagination.page} of ${pagination.totalPages}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Next page',
          onPressed: pagination.page < pagination.totalPages
              ? () {
                  ref
                      .read(kycControllerProvider.notifier)
                      .loadPage(pagination.page + 1);
                }
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  void _clearFilters() {
    _searchController.clear();

    ref.read(kycControllerProvider.notifier).clearFilters();
  }
}
