import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tokenization_controller.dart';

final tokenizationOfferingControllerProvider =
    AsyncNotifierProvider<TokenizationOfferingController, void>(
      TokenizationOfferingController.new,
    );

class TokenizationOfferingController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> activate(int offeringId) async {
    await _execute(
      () => ref.read(tokenizationApiProvider).activateOffering(offeringId),
    );
  }

  Future<void> pause(int offeringId, {String? reason}) async {
    await _execute(
      () => ref
          .read(tokenizationApiProvider)
          .pauseOffering(offeringId, reason: reason),
    );
  }

  Future<void> suspend(int offeringId, {String? reason}) async {
    await _execute(
      () => ref
          .read(tokenizationApiProvider)
          .suspendOffering(offeringId, reason: reason),
    );
  }

  Future<void> resume(int offeringId) async {
    await _execute(
      () => ref.read(tokenizationApiProvider).resumeOffering(offeringId),
    );
  }

  Future<void> _execute(Future<dynamic> Function() action) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await action();
    });
  }
}
