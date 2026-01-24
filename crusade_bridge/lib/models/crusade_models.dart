import 'package:hive/hive.dart';

part 'crusade_models.g.dart';

@HiveType(typeId: 0)
class Crusade {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String faction;

  @HiveField(3)
  String detachment;

  @HiveField(4)
  int supplyLimit = 1000;

  @HiveField(5)
  int rp = 5;

  @HiveField(6)
  String? armyIconPath;

  @HiveField(7)
  String? factionIconAsset;

  @HiveField(8)
  List<UnitOrGroup> oob = [];

  @HiveField(9)
  List<UnitOrGroup> templates = [];

  @HiveField(10)
  int lastModified = 0; // Unix timestamp in milliseconds

  @HiveField(11)
  bool usedFirstCharacterEnhancement = false; // Tracks if Renowned Heroes was used on first character

  @HiveField(12)
  List<CrusadeEvent> history = []; // Event log for significant crusade events

  @HiveField(13)
  List<Roster> rosters = []; // Saved rosters for battles

Crusade({
  required this.id,
  required this.name,
  required this.faction,
  required this.detachment,
  required this.supplyLimit,
  required this.rp,
  this.armyIconPath,
  this.factionIconAsset,
  List<UnitOrGroup>? oob,
  List<UnitOrGroup>? templates,
  int? lastModified,
  bool? usedFirstCharacterEnhancement,
  List<CrusadeEvent>? history,
  List<Roster>? rosters,
})  : oob = oob ?? [],
      templates = templates ?? [],
      lastModified = lastModified ?? DateTime.now().millisecondsSinceEpoch,
      usedFirstCharacterEnhancement = usedFirstCharacterEnhancement ?? false,
      history = history ?? [],
      rosters = rosters ?? [];

  // Calculate total points used in OOB
  int get totalOobPoints => oob.fold<int>(0, (sum, item) => sum + item.points);

  // Calculate remaining points
  int get remainingPoints => supplyLimit - totalOobPoints;

  // Calculate total Crusade Points across all units
  int get totalCrusadePoints => oob.fold<int>(0, (sum, item) => sum + item.totalCrusadePoints);

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'faction': faction,
      'detachment': detachment,
      'supplyLimit': supplyLimit,
      'rp': rp,
      'armyIconPath': armyIconPath,
      'factionIconAsset': factionIconAsset,
      'oob': oob.map((e) => e.toJson()).toList(),
      'templates': templates.map((e) => e.toJson()).toList(),
      'lastModified': lastModified,
      'usedFirstCharacterEnhancement': usedFirstCharacterEnhancement,
      'history': history.map((e) => e.toJson()).toList(),
      'rosters': rosters.map((e) => e.toJson()).toList(),
    };
  }

  factory Crusade.fromJson(Map<String, dynamic> json) {
    return Crusade(
      id: json['id'] as String,
      name: json['name'] as String,
      faction: json['faction'] as String,
      detachment: json['detachment'] as String,
      supplyLimit: json['supplyLimit'] as int,
      rp: json['rp'] as int,
      armyIconPath: json['armyIconPath'] as String?,
      factionIconAsset: json['factionIconAsset'] as String?,
      oob: (json['oob'] as List<dynamic>?)
          ?.map((e) => UnitOrGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      templates: (json['templates'] as List<dynamic>?)
          ?.map((e) => UnitOrGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastModified: json['lastModified'] as int?,
      usedFirstCharacterEnhancement: json['usedFirstCharacterEnhancement'] as bool?,
      history: (json['history'] as List<dynamic>?)
          ?.map((e) => CrusadeEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      rosters: (json['rosters'] as List<dynamic>?)
          ?.map((e) => Roster.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Add an event to the crusade history
  void addEvent(CrusadeEvent event) {
    history.add(event);
  }

  /// Get events filtered by unit ID
  List<CrusadeEvent> getEventsForUnit(String unitId) {
    return history.where((e) => e.unitId == unitId).toList();
  }

  /// Get events filtered by type
  List<CrusadeEvent> getEventsByType(String type) {
    return history.where((e) => e.type == type).toList();
  }
}

@HiveType(typeId: 1)
class UnitOrGroup {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // 'unit' or 'group'

  @HiveField(2)
  String name;

  @HiveField(3)
  String? customName;

  @HiveField(4)
  int points;

  @HiveField(5)
  List<UnitOrGroup>? components;

  @HiveField(6)
  int modelsCurrent;

  @HiveField(7)
  int modelsMax;

  @HiveField(8)
  int xp = 0;

  @HiveField(9)
  List<String> honours = [];

  @HiveField(10)
  List<String> scars = [];

  @HiveField(11)
  int crusadePoints = 0;

  @HiveField(12)
  Map<String, int> tallies = {'played': 0, 'survived': 0, 'destroyed': 0};

  @HiveField(13)
  String? notes;

  @HiveField(14)
  String? statsText;

  @HiveField(15)
  bool? isWarlord;

  @HiveField(16)
  bool? isEpicHero;

  @HiveField(17)
  List<String> enhancements = [];

  @HiveField(18)
  bool? isCharacter;

  UnitOrGroup({
    required this.id,
    required this.type,
    required this.name,
    required this.points,
    this.customName,
    this.components,
    this.modelsCurrent = 1,
    this.modelsMax = 1,
    this.notes,
    this.statsText,
    this.isWarlord,
    this.isEpicHero,
    this.isCharacter,
    int? xp,
    List<String>? honours,
    List<String>? scars,
    List<String>? enhancements,
    int? crusadePoints,
    Map<String, int>? tallies,
  })  : xp = xp ?? 0,
        honours = honours ?? [],
        scars = scars ?? [],
        enhancements = enhancements ?? [],
        crusadePoints = crusadePoints ?? 0,
        tallies = tallies ?? {'played': 0, 'survived': 0, 'destroyed': 0};

  // Calculate rank based on XP (Epic Heroes don't gain XP)
  String get rank {
    if (isEpicHero == true) return 'Epic Hero';
    if (xp <= 5) return 'Battle-ready';
    if (xp <= 15) return 'Blooded';
    if (xp <= 30) return 'Battle-hardened';
    if (xp <= 50) return 'Heroic';
    return 'Legendary';
  }

  // Calculate total Crusade Points for this unit or group
  int get totalCrusadePoints {
    if (type == 'group' && components != null) {
      return components!.fold<int>(0, (sum, unit) => sum + unit.crusadePoints);
    }
    return crusadePoints;
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'customName': customName,
      'points': points,
      'components': components?.map((e) => e.toJson()).toList(),
      'modelsCurrent': modelsCurrent,
      'modelsMax': modelsMax,
      'xp': xp,
      'honours': honours,
      'scars': scars,
      'enhancements': enhancements,
      'crusadePoints': crusadePoints,
      'tallies': tallies,
      'notes': notes,
      'statsText': statsText,
      'isWarlord': isWarlord,
      'isEpicHero': isEpicHero,
      'isCharacter': isCharacter,
    };
  }

  factory UnitOrGroup.fromJson(Map<String, dynamic> json) {
    return UnitOrGroup(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      points: json['points'] as int,
      customName: json['customName'] as String?,
      components: (json['components'] as List<dynamic>?)
          ?.map((e) => UnitOrGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      modelsCurrent: json['modelsCurrent'] as int? ?? 1,
      modelsMax: json['modelsMax'] as int? ?? 1,
      notes: json['notes'] as String?,
      statsText: json['statsText'] as String?,
      isWarlord: json['isWarlord'] as bool?,
      isEpicHero: json['isEpicHero'] as bool?,
      isCharacter: json['isCharacter'] as bool?,
      xp: json['xp'] as int?,
      honours: (json['honours'] as List<dynamic>?)?.cast<String>(),
      scars: (json['scars'] as List<dynamic>?)?.cast<String>(),
      enhancements: (json['enhancements'] as List<dynamic>?)?.cast<String>(),
      crusadePoints: json['crusadePoints'] as int?,
      tallies: (json['tallies'] as Map<String, dynamic>?)?.cast<String, int>(),
    );
  }
}

/// Represents a detachment enhancement that can be purchased for character units
/// via the Renowned Heroes requisition.
class Enhancement {
  final String name;
  final int points;

  Enhancement({
    required this.name,
    required this.points,
  });

  factory Enhancement.fromJson(Map<String, dynamic> json) {
    return Enhancement(
      name: json['name'] as String,
      points: json['points'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'points': points,
    };
  }
}

/// Event types for crusade history logging
class CrusadeEventType {
  static const String unitAdded = 'unit_added';
  static const String unitRemoved = 'unit_removed';
  static const String requisition = 'requisition';
  static const String battle = 'battle';
  static const String xpGain = 'xp_gain';
  static const String rankUp = 'rank_up';
  static const String honour = 'honour';
  static const String scar = 'scar';
  static const String outOfAction = 'out_of_action';
  static const String enhancement = 'enhancement';
  static const String crusadeCreated = 'crusade_created';
}

/// Represents a significant event in a crusade's history
/// Used for tracking battles, requisitions, unit progression, etc.
@HiveType(typeId: 2)
class CrusadeEvent {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int timestamp; // Unix timestamp in milliseconds

  @HiveField(2)
  final String type; // Use CrusadeEventType constants

  @HiveField(3)
  final String description; // Human-readable summary

  @HiveField(4)
  final String? unitId; // Reference to affected unit (if applicable)

  @HiveField(5)
  final String? unitName; // Snapshot of unit name at time of event

  @HiveField(6)
  final Map<String, dynamic>? metadata; // Flexible data (RP spent, XP amount, etc.)

  CrusadeEvent({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.description,
    this.unitId,
    this.unitName,
    this.metadata,
  });

  /// Factory constructor for creating events with auto-generated ID and timestamp
  factory CrusadeEvent.create({
    required String type,
    required String description,
    String? unitId,
    String? unitName,
    Map<String, dynamic>? metadata,
  }) {
    return CrusadeEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now().millisecondsSinceEpoch,
      type: type,
      description: description,
      unitId: unitId,
      unitName: unitName,
      metadata: metadata,
    );
  }

  factory CrusadeEvent.fromJson(Map<String, dynamic> json) {
    return CrusadeEvent(
      id: json['id'] as String,
      timestamp: json['timestamp'] as int,
      type: json['type'] as String,
      description: json['description'] as String,
      unitId: json['unitId'] as String?,
      unitName: json['unitName'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'type': type,
      'description': description,
      'unitId': unitId,
      'unitName': unitName,
      'metadata': metadata,
    };
  }

  /// Get formatted date string for display
  String get formattedDate {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get formatted time string for display
  String get formattedTime {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Represents a roster assembled from the Order of Battle for a specific game
/// Rosters are ephemeral and transitory - used for organizing forces before battles
@HiveType(typeId: 3)
class Roster {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> unitIds; // References to UnitOrGroup IDs in the OOB

  @HiveField(3)
  int createdAt; // Unix timestamp

  @HiveField(4)
  int lastModified; // Unix timestamp

  // Game metrics (optional tracking)
  @HiveField(5)
  int timesDeployed;

  @HiveField(6)
  int wins;

  @HiveField(7)
  int losses;

  @HiveField(8)
  int draws;

  Roster({
    required this.id,
    required this.name,
    List<String>? unitIds,
    int? createdAt,
    int? lastModified,
    this.timesDeployed = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
  })  : unitIds = unitIds ?? [],
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        lastModified = lastModified ?? DateTime.now().millisecondsSinceEpoch;

  /// Calculate total points for this roster based on the OOB
  int calculateTotalPoints(List<UnitOrGroup> oob) {
    int total = 0;
    for (final unitId in unitIds) {
      final unit = oob.where((u) => u.id == unitId).firstOrNull;
      if (unit != null) {
        total += unit.points;
      }
    }
    return total;
  }

  /// Get the units in this roster from the OOB
  List<UnitOrGroup> getUnits(List<UnitOrGroup> oob) {
    final units = <UnitOrGroup>[];
    for (final unitId in unitIds) {
      final unit = oob.where((u) => u.id == unitId).firstOrNull;
      if (unit != null) {
        units.add(unit);
      }
    }
    return units;
  }

  /// Check if a unit is in this roster
  bool containsUnit(String unitId) {
    return unitIds.contains(unitId);
  }

  /// Add a unit to this roster
  void addUnit(String unitId) {
    if (!unitIds.contains(unitId)) {
      unitIds.add(unitId);
      lastModified = DateTime.now().millisecondsSinceEpoch;
    }
  }

  /// Remove a unit from this roster
  void removeUnit(String unitId) {
    unitIds.remove(unitId);
    lastModified = DateTime.now().millisecondsSinceEpoch;
  }

  /// Record a game result
  void recordGame({required String result}) {
    timesDeployed++;
    lastModified = DateTime.now().millisecondsSinceEpoch;
    switch (result.toLowerCase()) {
      case 'win':
        wins++;
        break;
      case 'loss':
        losses++;
        break;
      case 'draw':
        draws++;
        break;
    }
  }

  /// Get win rate as a percentage string
  String get winRate {
    if (timesDeployed == 0) return 'N/A';
    final rate = (wins / timesDeployed * 100).toStringAsFixed(0);
    return '$rate%';
  }

  /// Get formatted record string
  String get record {
    if (timesDeployed == 0) return 'No games played';
    return '$wins-$losses-$draws (W-L-D)';
  }

  factory Roster.fromJson(Map<String, dynamic> json) {
    return Roster(
      id: json['id'] as String,
      name: json['name'] as String,
      unitIds: (json['unitIds'] as List<dynamic>?)?.cast<String>(),
      createdAt: json['createdAt'] as int?,
      lastModified: json['lastModified'] as int?,
      timesDeployed: json['timesDeployed'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unitIds': unitIds,
      'createdAt': createdAt,
      'lastModified': lastModified,
      'timesDeployed': timesDeployed,
      'wins': wins,
      'losses': losses,
      'draws': draws,
    };
  }
}