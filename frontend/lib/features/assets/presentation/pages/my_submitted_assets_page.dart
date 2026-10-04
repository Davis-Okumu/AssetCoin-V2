
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/colors.dart';
import '../providers/asset_providers.dart';
import '../widgets/submission_status_card.dart';

class MySubmittedAssetsPage extends ConsumerWidget {
  const MySubmittedAssetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsState = ref.watch(myAssetSubmissionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        title: const Text(
          'My Submissions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          // Refresh submissions.
          IconButton(
            onPressed: () {
              ref.invalidate(myAssetSubmissionsProvider);
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh submissions',
          ),

          // Return to the main Assets page.
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                context.go(RouteNames.assets);
              },
              icon: const Icon(
                Icons.check_circle_outline_rounded,
                size: 18,
              ),
              label: const Text(
                'Done',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: submissionsState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
        error: (error, stackTrace) => _buildError(ref),
        data: (submissions) {
          if (submissions.isEmpty) {
            return _buildEmptyState(context, ref);
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(myAssetSubmissionsProvider);
              await ref.read(myAssetSubmissionsProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
              children: [
                _buildHeader(submissions.length),

                const SizedBox(height: 20),

                ...submissions.map(
                  (submission) => SubmissionStatusCard(
                    submission: submission,
                    onTap: () {
                      context.push(
                        '/my-submissions/${submission.id}',
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================
  // PAGE HEADER
  // =========================

  Widget _buildHeader(int submissionCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            Color(0xFFB51F32),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR ASSET PORTFOLIO',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            '$submissionCount ${submissionCount == 1 ? 'Submission' : 'Submissions'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Track your submitted assets and follow their review progress.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // EMPTY STATE
  // =========================

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
  ) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(myAssetSubmissionsProvider);
        await ref.read(myAssetSubmissionsProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(25),
        children: [
          const SizedBox(height: 100),

          Icon(
            Icons.inventory_2_outlined,
            size: 75,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 20),

          const Text(
            'No Submitted Assets Yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Assets you submit for verification will appear here. '
            'You can track their review progress from this page.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 25),

          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                context.go(RouteNames.assets);
              },
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to Assets'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // ERROR STATE
  // =========================

  Widget _buildError(WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 50,
              color: AppColors.primary,
            ),

            const SizedBox(height: 15),

            const Text(
              'Unable to Load Submissions',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 9),

            Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(myAssetSubmissionsProvider);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}