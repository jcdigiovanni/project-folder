import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'crusade_models.dart';

/// A trial/task/mission that a unit can undertake as part of a faction's
/// Crusade progression system (e.g., Sororitas Trials of a Living Saint).
class TrialDefinition {
  final int id;
  final String name;
  final String description;
  final int requiredPoints;

  const TrialDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredPoints,
  });

  factory TrialDefinition.fromJson(Map<String, dynamic> json) {
    return TrialDefinition(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      requiredPoints: json['requiredPoints'] as int,
    );
  }
}

/// Tally map keys used by all faction progression systems.
/// Shared across factions — only one system applies per unit.
class ProgressionKeys {
  static const String trialId = 'trialId';
  static const String isAscended = 'isAscended';
}

/// Configuration for a faction-specific Crusade progression system.
///
/// Each faction can define a system where units are designated, undertake
/// trials/tasks, accumulate points during games, and optionally ascend
/// (transform) into a new unit type upon completion.
class FactionCrusadeSystem {
  /// Faction this system belongs to (must match Crusade.faction)
  final String faction;

  /// Name of the overall system (e.g., "Trials of a Living Saint")
  final String systemName;

  /// Keyword for designated units (e.g., "SAINT POTENTIA")
  final String designationKeyword;

  /// Keyword for ascended units (e.g., "LIVING SAINT")
  final String ascendedKeyword;

  /// Label for the progression points (e.g., "Saint Points")
  final String pointsLabel;

  /// Unit name after ascension (e.g., "Living Saint")
  final String ascendedUnitName;

  /// Description of ability gained on ascension (shown in dialog)
  final String? ascendedAbilityText;

  /// Icon for the progression system UI
  final IconData icon;

  /// Color theme for the progression system UI
  final Color color;

  /// Maximum number of designated units allowed at once
  final int maxConcurrent;

  /// Whether the unit must be a CHARACTER to be designated
  final bool requireCharacter;

  /// Whether Epic Heroes are excluded from designation
  final bool excludeEpicHeroes;

  /// Asset path for the trials JSON data file
  final String trialDataAsset;

  /// Button label for starting designation (e.g., "Begin Trial of a Living Saint")
  final String beginActionLabel;

  /// Button label for removing designation (e.g., "Remove SAINT POTENTIA Designation")
  final String removeActionLabel;

  /// Which factionPoints field stores progression points (1, 2, or 3)
  final int pointsFieldIndex;

  FactionCrusadeSystem({
    required this.faction,
    required this.systemName,
    required this.designationKeyword,
    required this.ascendedKeyword,
    required this.pointsLabel,
    required this.ascendedUnitName,
    this.ascendedAbilityText,
    required this.icon,
    required this.color,
    this.maxConcurrent = 1,
    this.requireCharacter = true,
    this.excludeEpicHeroes = true,
    required this.trialDataAsset,
    required this.beginActionLabel,
    required this.removeActionLabel,
    this.pointsFieldIndex = 1,
  });

  // --- Helper methods ---

  /// Check if a unit has this system's designation (trial in progress)
  bool isDesignated(UnitOrGroup unit) {
    final trialId = unit.tallies[ProgressionKeys.trialId];
    return trialId != null && trialId > 0 && !isAscended(unit);
  }

  /// Check if a unit has ascended (completed progression)
  bool isAscended(UnitOrGroup unit) =>
      unit.tallies[ProgressionKeys.isAscended] == 1;

  /// Check if any unit in the OOB already has this designation
  bool hasExistingDesignation(Crusade crusade) {
    int count = 0;
    for (final item in crusade.oob) {
      if (item.type == 'group' && item.components != null) {
        for (final comp in item.components!) {
          if (isDesignated(comp)) count++;
        }
      } else {
        if (isDesignated(item)) count++;
      }
    }
    return count >= maxConcurrent;
  }

  /// Check if a unit is eligible for designation
  bool canDesignate(UnitOrGroup unit) {
    if (requireCharacter && unit.isCharacter != true) return false;
    if (excludeEpicHeroes && unit.isEpicHero == true) return false;
    if (isDesignated(unit) || isAscended(unit)) return false;
    return true;
  }

  /// Get the progression points for a unit
  int getPoints(UnitOrGroup unit) {
    switch (pointsFieldIndex) {
      case 1: return unit.factionPoints1;
      case 2: return unit.factionPoints2;
      case 3: return unit.factionPoints3;
      default: return 0;
    }
  }

  /// Add progression points to a unit
  void addPoints(UnitOrGroup unit, int amount) {
    switch (pointsFieldIndex) {
      case 1: unit.factionPoints1 += amount;
      case 2: unit.factionPoints2 += amount;
      case 3: unit.factionPoints3 += amount;
    }
  }

  /// Format the ascension event description
  String ascensionEventDescription(String unitName, String trialName) =>
      '$unitName ascended to $ascendedUnitName after completing $trialName';

  /// Format the designation event description
  String designationEventDescription(String unitName, String trialName) =>
      '$unitName designated $designationKeyword — undertaking $trialName';

  /// Format the removal event description
  String removalEventDescription(String unitName) =>
      '$unitName removed as $designationKeyword';
}

// --- Trial data loading (cached per asset path) ---

final Map<String, List<TrialDefinition>> _trialCache = {};

/// Load trial definitions from a faction's JSON asset. Cached after first load.
Future<List<TrialDefinition>> loadTrials(String assetPath) async {
  if (_trialCache.containsKey(assetPath)) return _trialCache[assetPath]!;
  final jsonStr = await rootBundle.loadString(assetPath);
  final data = jsonDecode(jsonStr) as Map<String, dynamic>;
  final trials = (data['trials'] as List)
      .map((t) => TrialDefinition.fromJson(t as Map<String, dynamic>))
      .toList();
  _trialCache[assetPath] = trials;
  return trials;
}

// --- Faction registry ---

/// Registry of faction-specific Crusade progression systems.
/// Returns null for factions without a progression system.
class FactionCrusadeSystemRegistry {
  static FactionCrusadeSystem? forFaction(String faction) =>
      _systems[faction];

  static final Map<String, FactionCrusadeSystem> _systems = {
    'Adepta Sororitas': _sororitas,
  };
}

// --- Sororitas: Trials of a Living Saint ---

final _sororitas = FactionCrusadeSystem(
  faction: 'Adepta Sororitas',
  systemName: 'Trials of a Living Saint',
  designationKeyword: 'SAINT POTENTIA',
  ascendedKeyword: 'LIVING SAINT',
  pointsLabel: 'Saint Points',
  ascendedUnitName: 'Living Saint',
  ascendedAbilityText:
      'Living Saint Aura: While a friendly ADEPTA SORORITAS unit is within 6" '
      'of this model, each time a model in that unit would lose a wound, '
      'roll one D6: on a 5+, that wound is not lost.',
  icon: Icons.auto_awesome,
  color: Colors.amber,
  maxConcurrent: 1,
  requireCharacter: true,
  excludeEpicHeroes: true,
  trialDataAsset: 'assets/data/sororitas_trials.json',
  beginActionLabel: 'Begin Trial of a Living Saint',
  removeActionLabel: 'Remove SAINT POTENTIA Designation',
  pointsFieldIndex: 1,
);
