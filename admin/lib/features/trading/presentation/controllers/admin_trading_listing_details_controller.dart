import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_trading_listing_model.dart';
import 'admin_trading_overview_controller.dart';

final adminTradingListingDetailsControllerProvider =
    AsyncNotifierProvider.family<
      AdminTradingListingDetailsController,
      AdminTradingListingModel,
      int
    >(AdminTradingListingDetailsController.new);

class AdminTradingListingDetailsController
    extends AsyncNotifier<AdminTradingListingModel> {
  AdminTradingListingDetailsController(this.listingId);

  final int listingId;

  @override
  Future<AdminTradingListingModel> build() async {
    final repository = ref.read(adminTradingRepositoryProvider);

    return repository.getListing(listingId);
  }

  Future<void> getDetails() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(adminTradingRepositoryProvider);

      return repository.getListing(listingId);
    });
  }

  Future<void> refresh() async {
    await getDetails();
  }

  Future<void> suspend({String? reason}) async {
    final repository = ref.read(adminTradingRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return repository.suspendListing(listingId, reason: reason);
    });
  }

  Future<void> reactivate({String? reason}) async {
    final repository = ref.read(adminTradingRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return repository.reactivateListing(listingId, reason: reason);
    });
  }
}
