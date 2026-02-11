import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/crusade_models.dart';

/// Extension methods for common Game lookups.
extension GameLookups on Game {
  /// Find a UnitGameState by unit ID.
  UnitGameState? findUnitState(String unitId) =>
      unitStates.where((u) => u.unitId == unitId).firstOrNull;

  /// Find a GameAgenda by agenda ID.
  GameAgenda? findAgenda(String agendaId) =>
      agendas.where((a) => a.id == agendaId).firstOrNull;
}

/// Extension methods for common Crusade lookups.
extension CrusadeLookups on Crusade {
  /// Find a Game by game ID.
  Game? findGame(String gameId) =>
      games.where((g) => g.id == gameId).firstOrNull;
}

/// Load and parse the battle_honours.json asset.
/// Returns the parsed data map, or null on failure.
Future<Map<String, dynamic>?> loadBattleHonoursJsonData(
    BuildContext context) async {
  try {
    final jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/data/battle_honours.json');
    return Map<String, dynamic>.from(
      (const JsonDecoder().convert(jsonString)) as Map,
    );
  } catch (e) {
    return null;
  }
}
