
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/notification_preference.dart';
import '../../domain/notification_repository.dart';

final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    apiClient: ref.watch(apiClientProvider),
  );
});

final notificationPreferencesProvider =
    FutureProvider<List<NotificationPreference>>((ref) {
  return ref
      .watch(notificationRepositoryProvider)
      .getNotificationPreferences();
});
