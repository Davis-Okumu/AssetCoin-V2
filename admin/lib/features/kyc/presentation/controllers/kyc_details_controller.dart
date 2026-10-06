import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/admin_kyc_repository.dart';

/// Loads a single KYC application by its ID.
///
/// This is a family provider because each KYC details page
/// needs to load a different application.
final kycDetailsControllerProvider =
    FutureProvider.family<AdminKycDetails, int>((ref, kycId) async {
      final repository = ref.watch(adminKycRepositoryProvider);

      return repository.getApplication(kycId);
    });
