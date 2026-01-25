import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crusade_models.dart';
import '../services/storage_service.dart';

// Provider for the current active Crusade (read-only watch)
final currentCrusadeProvider = StateProvider<Crusade?>((ref) {
  // Load the first saved Crusade on app start (or null)
  final all = StorageService.loadAllCrusades();
  return all.isNotEmpty ? all.first : null;
});

// Notifier to update current Crusade (mutable state)
class CurrentCrusadeNotifier extends StateNotifier<Crusade?> {
  CurrentCrusadeNotifier() : super(null);

  void setCurrent(Crusade crusade) {
    state = crusade;
  }

  void clearCurrent() {
    state = null;
  }

  Future<void> deleteCrusade(String crusadeId) async {
    await StorageService.deleteCrusade(crusadeId);
    // If the deleted crusade is the current one, clear it
    if (state?.id == crusadeId) {
      state = null;
    }
  }

  /// Helper to create a new Crusade with updated fields while preserving all existing data
  Crusade _copyWith({
    List<UnitOrGroup>? oob,
    List<UnitOrGroup>? templates,
    int? rp,
    bool? usedFirstCharacterEnhancement,
    List<CrusadeEvent>? history,
    List<Roster>? rosters,
    List<Game>? games,
  }) {
    return Crusade(
      id: state!.id,
      name: state!.name,
      faction: state!.faction,
      detachment: state!.detachment,
      supplyLimit: state!.supplyLimit,
      rp: rp ?? state!.rp,
      armyIconPath: state!.armyIconPath,
      factionIconAsset: state!.factionIconAsset,
      oob: oob ?? state!.oob,
      templates: templates ?? state!.templates,
      lastModified: DateTime.now().millisecondsSinceEpoch,
      usedFirstCharacterEnhancement: usedFirstCharacterEnhancement ?? state!.usedFirstCharacterEnhancement,
      history: history ?? state!.history,
      rosters: rosters ?? state!.rosters,
      games: games ?? state!.games,
    );
  }

  void addUnitOrGroup(UnitOrGroup newItem) {
    if (state == null) return;

    state = _copyWith(oob: [...state!.oob, newItem]);

    // Persist the updated Crusade
    StorageService.saveCrusade(state!);
  }

  void removeUnitOrGroup(int index) {
    if (state == null) return;

    final updatedOob = List<UnitOrGroup>.from(state!.oob)..removeAt(index);

    state = _copyWith(oob: updatedOob);

    // Persist the updated Crusade
    StorageService.saveCrusade(state!);
  }

  void addGroupFromUnits(UnitOrGroup group, List<String> unitIdsToRemove) {
    if (state == null) return;

    // Remove the units that are now in the group from the main OOB
    final updatedOob = state!.oob.where((item) => !unitIdsToRemove.contains(item.id)).toList();

    // Add the new group
    updatedOob.add(group);

    state = _copyWith(oob: updatedOob);

    // Persist the updated Crusade
    StorageService.saveCrusade(state!);
  }

  void updateUnitOrGroup(int index, UnitOrGroup updatedItem) {
    if (state == null) return;

    final updatedOob = List<UnitOrGroup>.from(state!.oob);
    updatedOob[index] = updatedItem;

    state = _copyWith(oob: updatedOob);

    // Persist the updated Crusade
    StorageService.saveCrusade(state!);
  }

  /// Update a unit by ID (searches through OOB)
  void updateUnitById(String unitId, UnitOrGroup updatedUnit) {
    if (state == null) return;

    final index = state!.oob.indexWhere((u) => u.id == unitId);
    if (index != -1) {
      updateUnitOrGroup(index, updatedUnit);
    }
  }

  /// Update RP amount
  void updateRp(int newRp) {
    if (state == null) return;

    state = _copyWith(rp: newRp);
    StorageService.saveCrusade(state!);
  }

  /// Add event to history
  void addEvent(CrusadeEvent event) {
    if (state == null) return;

    state = _copyWith(history: [...state!.history, event]);
    StorageService.saveCrusade(state!);
  }

  /// Mark first character enhancement as used
  void setFirstCharacterEnhancementUsed() {
    if (state == null) return;

    state = _copyWith(usedFirstCharacterEnhancement: true);
    StorageService.saveCrusade(state!);
  }

  // ========== Roster Management ==========

  /// Add a new roster to the crusade
  void addRoster(Roster roster) {
    if (state == null) return;

    state = _copyWith(rosters: [...state!.rosters, roster]);
    StorageService.saveCrusade(state!);
  }

  /// Update an existing roster
  void updateRoster(Roster updatedRoster) {
    if (state == null) return;

    final updatedRosters = state!.rosters.map((r) {
      return r.id == updatedRoster.id ? updatedRoster : r;
    }).toList();

    state = _copyWith(rosters: updatedRosters);
    StorageService.saveCrusade(state!);
  }

  /// Delete a roster by ID
  void deleteRoster(String rosterId) {
    if (state == null) return;

    final updatedRosters = state!.rosters.where((r) => r.id != rosterId).toList();
    state = _copyWith(rosters: updatedRosters);
    StorageService.saveCrusade(state!);
  }

  /// Get a roster by ID
  Roster? getRoster(String rosterId) {
    return state?.rosters.where((r) => r.id == rosterId).firstOrNull;
  }

  // ========== Game Management ==========

  /// Add a new game to the crusade
  void addGame(Game game) {
    if (state == null) return;

    state = _copyWith(games: [...state!.games, game]);
    StorageService.saveCrusade(state!);
  }

  /// Update an existing game
  void updateGame(Game updatedGame) {
    if (state == null) return;

    final updatedGames = state!.games.map((g) {
      return g.id == updatedGame.id ? updatedGame : g;
    }).toList();

    state = _copyWith(games: updatedGames);
    StorageService.saveCrusade(state!);
  }

  /// Get a game by ID
  Game? getGame(String gameId) {
    return state?.games.where((g) => g.id == gameId).firstOrNull;
  }
}

final currentCrusadeNotifierProvider = StateNotifierProvider<CurrentCrusadeNotifier, Crusade?>(
  (ref) => CurrentCrusadeNotifier(),
);