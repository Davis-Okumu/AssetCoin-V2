import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/dashboard.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/activity_card.dart';
import '../widgets/admin_activity_card.dart';
import '../widgets/asset_activity_chart.dart';
import '../widgets/asset_type_chart.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/kyc_summary_chart.dart';
import '../widgets/overview_grid.dart';
import '../widgets/recent_transactions_card.dart';
import '../widgets/registration_chart.dart';
import '../widgets/review_summary_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);
    return state.when(
      loading: () => const _DashboardLoading(),
      error: (error, stackTrace) => _DashboardError(
        message: error.toString(),
        onRetry: () {
          ref.read(dashboardControllerProvider.notifier).refreshDashboard();
        },
      ),
      data: (dashboard) => RefreshIndicator(
        onRefresh: () {
          return ref
              .read(dashboardControllerProvider.notifier)
              .refreshDashboard();
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardHeader(
                        onRefresh: () {
                          ref
                              .read(dashboardControllerProvider.notifier)
                              .refreshDashboard();
                        },
                      ),
                      const SizedBox(height: 24),
                      OverviewGrid(overview: dashboard.overview),
                      const SizedBox(height: 18),
                      _ChartsSection(
                        dashboard: dashboard,
                        width: constraints.maxWidth,
                      ),
                      const SizedBox(height: 18),
                      _OperationalSection(
                        dashboard: dashboard,
                        width: constraints.maxWidth,
                      ),
                      const SizedBox(height: 18),
                      RecentTransactionsCard(
                        transactions: dashboard.recentTransactions,
                      ),
                    ],
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

class _ChartsSection extends StatelessWidget {
  const _ChartsSection({required this.dashboard, required this.width});
  final Dashboard dashboard;
  final double width;
  @override
  Widget build(BuildContext context) {
    if (width >= 1200) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: AssetActivityChart(data: dashboard.assetActivity),
          ),
          const SizedBox(width: 18),
          Expanded(child: KycSummaryChart(data: dashboard.kycSummary)),
          const SizedBox(width: 18),
          Expanded(child: AssetTypeChart(data: dashboard.assetTypes)),
        ],
      );
    }
    if (width >= 700) {
      return Column(
        children: [
          AssetActivityChart(data: dashboard.assetActivity),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: KycSummaryChart(data: dashboard.kycSummary)),
              const SizedBox(width: 18),
              Expanded(child: AssetTypeChart(data: dashboard.assetTypes)),
            ],
          ),
        ],
      );
    }
    return Column(
      children: [
        AssetActivityChart(data: dashboard.assetActivity),
        const SizedBox(height: 18),
        KycSummaryChart(data: dashboard.kycSummary),
        const SizedBox(height: 18),
        AssetTypeChart(data: dashboard.assetTypes),
      ],
    );
  }
}

class _OperationalSection extends StatelessWidget {
  const _OperationalSection({required this.dashboard, required this.width});
  final Dashboard dashboard;
  final double width;
  @override
  Widget build(BuildContext context) {
    if (width >= 1200) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ReviewSummaryCard(overview: dashboard.overview)),
          const SizedBox(width: 18),
          Expanded(
            flex: 2,
            child: ActivityCard(
              assets: dashboard.recentAssetActivity,
              kyc: dashboard.recentKycActivity,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: AdminActivityCard(activities: dashboard.adminActivity),
          ),
        ],
      );
    }
    return Column(
      children: [
        ReviewSummaryCard(overview: dashboard.overview),
        const SizedBox(height: 18),
        ActivityCard(
          assets: dashboard.recentAssetActivity,
          kyc: dashboard.recentKycActivity,
        ),
        const SizedBox(height: 18),
        AdminActivityCard(activities: dashboard.adminActivity),
        const SizedBox(height: 18),
        RegistrationChart(data: dashboard.userRegistrationActivity),
      ],
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: Color(0xFFDC2626),
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to load dashboard',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message.replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
