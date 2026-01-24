import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crusade_models.dart';
import '../services/storage_service.dart';

/// Provider for all campaigns
final campaignsProvider = StateNotifierProvider<CampaignsNotifier, List<Campaign>>((ref) {
  return CampaignsNotifier();
});

/// Provider for the currently selected campaign (for viewing/editing)
final currentCampaignProvider = StateProvider<Campaign?>((ref) => null);

/// Notifier to manage all campaigns
class CampaignsNotifier extends StateNotifier<List<Campaign>> {
  CampaignsNotifier() : super([]) {
    _loadCampaigns();
  }

  void _loadCampaigns() {
    state = StorageService.loadAllCampaigns();
  }

  /// Create a new campaign
  Future<Campaign> createCampaign({
    required String name,
    String? description,
  }) async {
    final campaign = Campaign(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
    );

    await StorageService.saveCampaign(campaign);
    state = [...state, campaign];
    return campaign;
  }

  /// Update an existing campaign
  Future<void> updateCampaign(Campaign campaign) async {
    await StorageService.saveCampaign(campaign);
    state = state.map((c) => c.id == campaign.id ? campaign : c).toList();
  }

  /// Delete a campaign
  Future<void> deleteCampaign(String campaignId) async {
    await StorageService.deleteCampaign(campaignId);
    state = state.where((c) => c.id != campaignId).toList();
  }

  /// Get a campaign by ID
  Campaign? getCampaign(String id) {
    return state.where((c) => c.id == id).firstOrNull;
  }

  /// Add a crusade to a campaign
  Future<void> addCrusadeToCampaign(String campaignId, Crusade crusade) async {
    final campaign = getCampaign(campaignId);
    if (campaign == null) return;

    campaign.addCrusade(crusade);
    await updateCampaign(campaign);
  }

  /// Remove a crusade from a campaign
  Future<void> removeCrusadeFromCampaign(String campaignId, String crusadeId) async {
    final campaign = getCampaign(campaignId);
    if (campaign == null) return;

    campaign.removeCrusade(crusadeId);
    await updateCampaign(campaign);
  }

  /// Record a game result for a crusade in a campaign
  Future<void> recordGameResult({
    required String campaignId,
    required String crusadeId,
    required String result,
  }) async {
    final campaign = getCampaign(campaignId);
    if (campaign == null) return;

    final link = campaign.getCrusadeLink(crusadeId);
    if (link == null) return;

    link.recordGame(result);
    await updateCampaign(campaign);
  }

  /// Get all campaigns that include a specific crusade
  List<Campaign> getCampaignsForCrusade(String crusadeId) {
    return state.where((c) => c.hasCrusade(crusadeId)).toList();
  }

  /// End a campaign (mark as inactive)
  Future<void> endCampaign(String campaignId) async {
    final campaign = getCampaign(campaignId);
    if (campaign == null) return;

    campaign.isActive = false;
    campaign.lastModified = DateTime.now().millisecondsSinceEpoch;
    await updateCampaign(campaign);
  }

  /// Reactivate a campaign
  Future<void> reactivateCampaign(String campaignId) async {
    final campaign = getCampaign(campaignId);
    if (campaign == null) return;

    campaign.isActive = true;
    campaign.lastModified = DateTime.now().millisecondsSinceEpoch;
    await updateCampaign(campaign);
  }
}
