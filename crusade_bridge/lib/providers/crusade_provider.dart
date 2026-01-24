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

  void addUnitOrGroup(UnitOrGroup newItem) {
    if (state == null) return;

    // Create a new Crusade instance with updated OOB
    state = Crusade(
      id: state!.id,
      name: state!.name,
      faction: state!.faction,
      detachment: state!.detachment,
      supplyLimit: state!.supplyLimit,
      rp: state!.rp,
      armyIconPath: state!.armyIconPath,
      factionIconAsset: state!.factionIconAsset,
      oob: [...state!.oob, newItem],
      templates: state!.templates,
      lastModified: DateTime.now().millisecondsSinceEpoch,
    );

    // Persist the updated Crusade
    StorageService.saveCrusade(state!);
  }

  void removeUnitOrGroup(int index) {
    if (state == null) return;

    final updatedOob = List<UnitOrGroup>.from(state!.oob)..removeAt(index);

    state = Crusade(
      id: state!.id,
      name: state!.name,
      faction: state!.faction,
      detachment: state!.detachment,
      supplyLimit: state!.supplyLimit,
      rp: state!.rp,
      armyIconPath: state!.armyIconPath,
      factionIconAsset: state!.factionIconAsset,
      oob: updatedOob,
      templates: state!.templates,
      lastModified: DateTime.now().millisecondsSinceEpoch,
    );

    // Persist the updated Crusade
    StorageService.saveCrusade(state!);
  }

  void addGroupFromUnits(UnitOrGroup group, List<String> unitIdsToRemove) {
    if (state == null) return;

    // Remove the units that are now in the group from the main OOB
    final updatedOob = state!.oob.where((item) => !unitIdsToRemove.contains(item.id)).toList();

    // Add the new group
    updatedOob.add(group);

    state = Crusade(
      id: state!.id,
      name: state!.name,
      faction: state!.faction,
      detachment: state!.detachment,
      supplyLimit: state!.supplyLimit,
      rp: state!.rp,
      armyIconPath: state!.armyIconPath,
      factionIconAsset: state!.factionIconAsset,
      oob: updatedOob,
      templates: state!.templates,
      lastModified: DateTime.now().millisecondsSinceEpoch,
    );

    // Persist the updated Crusade
    StorageService.saveCrusade(state!);
  }

  void updateUnitOrGroup(int index, UnitOrGroup updatedItem) {
    if (state == null) return;

    final updatedOob = List<UnitOrGroup>.from(state!.oob);
    updatedOob[index] = updatedItem;

    state = Crusade(
      id: state!.id,
      name: state!.name,
      faction: state!.faction,
      detachment: state!.detachment,
      supplyLimit: state!.supplyLimit,
      rp: state!.rp,
      armyIconPath: state!.armyIconPath,
      factionIconAsset: state!.factionIconAsset,
      oob: updatedOob,
      templates: state!.templates,
      lastModified: DateTime.now().millisecondsSinceEpoch,
    );

    // Persist the updated Crusade
    StorageService.saveCrusade(state!);
  }

  // Add more methods later (set warlord, etc.)
}

final currentCrusadeNotifierProvider = StateNotifierProvider<CurrentCrusadeNotifier, Crusade?>(
  (ref) => CurrentCrusadeNotifier(),
);