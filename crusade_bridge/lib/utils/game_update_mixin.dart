import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crusade_models.dart';
import '../providers/crusade_provider.dart';
import 'game_state_utils.dart';

/// Mixin providing shared game-state update methods for screens that
/// track kills, destroyed status, and other per-unit game data.
///
/// Used by both [ActiveGameScreen] and [PostGameScreen].
mixin GameUpdateMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Update the kill count for a unit and persist.
  void updateKills(Game game, String unitId, int newKills) {
    final unitState = game.findUnitState(unitId);
    if (unitState != null) {
      setState(() {
        unitState.kills = newKills;
      });
      ref.read(currentCrusadeNotifierProvider.notifier).updateGame(game);
    }
  }

  /// Update the destroyed flag for a unit and persist.
  void updateDestroyed(Game game, String unitId, bool wasDestroyed) {
    final unitState = game.findUnitState(unitId);
    if (unitState != null) {
      setState(() {
        unitState.wasDestroyed = wasDestroyed;
      });
      ref.read(currentCrusadeNotifierProvider.notifier).updateGame(game);
    }
  }
}
