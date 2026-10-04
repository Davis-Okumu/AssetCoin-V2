
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/token_storage.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/auth_api_service.dart';

// TOKEN STORAGE PROVIDER
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

// API SERVICE PROVIDER
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final service = AuthApiService();

  ref.onDispose(service.dispose);

  return service;
});

// AUTHENTICATION REPOSITORY PROVIDER
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiService: ref.watch(authApiServiceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});