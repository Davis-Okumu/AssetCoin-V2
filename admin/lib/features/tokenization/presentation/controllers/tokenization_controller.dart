import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/admin_tokenization_api.dart';
import '../../data/models/token_offering_model.dart';
import '../../data/models/tokenization_assignment_model.dart';
import '../../data/models/tokenization_overview_model.dart';
import '../../data/models/tokenization_proposal_model.dart';
import '../../data/repositories/tokenization_repository.dart';

final tokenizationApiProvider = Provider<AdminTokenizationApi>((ref) {
  return AdminTokenizationApi(ApiClient());
});

final tokenizationRepositoryProvider = Provider<TokenizationRepository>((ref) {
  return TokenizationRepository(ref.watch(tokenizationApiProvider));
});

final tokenizationControllerProvider =
    AsyncNotifierProvider<TokenizationController, TokenizationPageState>(
      TokenizationController.new,
    );

class TokenizationPageState {
  const TokenizationPageState({
    this.overview,
    this.proposals = const [],
    this.assignments = const [],
    this.offerings = const [],
  });

  final TokenizationOverviewModel? overview;

  final List<TokenizationProposalModel> proposals;

  final List<TokenizationAssignmentModel> assignments;

  final List<TokenOfferingModel> offerings;

  TokenizationPageState copyWith({
    TokenizationOverviewModel? overview,
    List<TokenizationProposalModel>? proposals,
    List<TokenizationAssignmentModel>? assignments,
    List<TokenOfferingModel>? offerings,
  }) {
    return TokenizationPageState(
      overview: overview ?? this.overview,
      proposals: proposals ?? this.proposals,
      assignments: assignments ?? this.assignments,
      offerings: offerings ?? this.offerings,
    );
  }
}

class TokenizationController extends AsyncNotifier<TokenizationPageState> {
  late final TokenizationRepository _repository;

  @override
  Future<TokenizationPageState> build() async {
    _repository = ref.watch(tokenizationRepositoryProvider);

    return _load();
  }

  Future<TokenizationPageState> _load() async {
    final results = await Future.wait([
      _repository.getOverview(),
      _repository.getProposals(),
      _repository.getAssignments(),
      _repository.getOfferings(),
    ]);

    return TokenizationPageState(
      overview: results[0] as TokenizationOverviewModel,
      proposals: results[1] as List<TokenizationProposalModel>,
      assignments: results[2] as List<TokenizationAssignmentModel>,
      offerings: results[3] as List<TokenOfferingModel>,
    );
  }

  Future<void> load() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(_load);
  }

  Future<void> refresh() async {
    await load();
  }
}
