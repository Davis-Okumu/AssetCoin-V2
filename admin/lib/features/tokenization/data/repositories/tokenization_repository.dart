import '../datasources/admin_tokenization_api.dart';
import '../models/token_offering_model.dart';
import '../models/tokenization_assignment_model.dart';
import '../models/tokenization_overview_model.dart';
import '../models/tokenization_proposal_model.dart';

class TokenizationRepository {
  TokenizationRepository(this._api);

  final AdminTokenizationApi _api;

  // ============================================================
  // OVERVIEW
  // ============================================================

  Future<TokenizationOverviewModel> getOverview() async {
    final json = await _api.getOverview();

    return TokenizationOverviewModel.fromJson(json);
  }

  // ============================================================
  // PROPOSALS
  // ============================================================

  Future<List<TokenizationProposalModel>> getProposals({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.getProposals(
      status: status,
      page: page,
      limit: limit,
    );

    return response
        .whereType<Map<String, dynamic>>()
        .map(TokenizationProposalModel.fromJson)
        .toList();
  }

  Future<TokenizationProposalModel> getProposal(int id) async {
    final json = await _api.getProposal(id);

    return TokenizationProposalModel.fromJson(json);
  }

  // ============================================================
  // ASSIGNMENTS
  // ============================================================

  Future<List<TokenizationAssignmentModel>> getAssignments({
    int? assignedTo,
    int? proposalId,
    String? status,
    bool mine = false,
  }) async {
    final response = await _api.getAssignments(
      assignedTo: assignedTo,
      proposalId: proposalId,
      status: status,
      mine: mine,
    );

    return response
        .whereType<Map<String, dynamic>>()
        .map(TokenizationAssignmentModel.fromJson)
        .toList();
  }

  Future<List<TokenizationOfficerModel>> getAssignmentOfficers() async {
    final response = await _api.getAssignmentOfficers();

    return response
        .whereType<Map<String, dynamic>>()
        .map(TokenizationOfficerModel.fromJson)
        .toList();
  }

  // ============================================================
  // OFFERINGS
  // ============================================================

  Future<List<TokenOfferingModel>> getOfferings({String? status}) async {
    final response = await _api.getOfferings(status: status);

    return response
        .whereType<Map<String, dynamic>>()
        .map(TokenOfferingModel.fromJson)
        .toList();
  }

  Future<TokenOfferingModel> getOffering(int id) async {
    final json = await _api.getOffering(id);

    return TokenOfferingModel.fromJson(json);
  }

  Future<TokenOfferingModel> resumeOffering(int offeringId) async {
    final data = await _api.resumeOffering(offeringId);

    return TokenOfferingModel.fromJson(data);
  }
}
