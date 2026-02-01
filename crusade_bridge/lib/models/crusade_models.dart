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

  @HiveField(14)
  List<Game> games = []; // Games played

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
  List<Game>? games,
})  : oob = oob ?? [],
      templates = templates ?? [],
      lastModified = lastModified ?? DateTime.now().millisecondsSinceEpoch,
      usedFirstCharacterEnhancement = usedFirstCharacterEnhancement ?? false,
      history = history ?? [],
      rosters = rosters ?? [],
      games = games ?? [];

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
      'games': games.map((e) => e.toJson()).toList(),
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
      games: (json['games'] as List<dynamic>?)
          ?.map((e) => Game.fromJson(e as Map<String, dynamic>))
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

  @HiveField(19)
  bool pendingRankUp; // True when unit has ranked up and needs attention (e.g., select Battle Honour)

  @HiveField(20)
  List<String> battleTraits = []; // Battle Traits from D6 table roll or manual selection

  @HiveField(21)
  List<String> weaponEnhancements = []; // Weapon Enhancements from 2D6 table roll

  @HiveField(22)
  String? crusadeRelic; // Crusade Relic (Characters only, limit 1)

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
    bool? pendingRankUp,
    List<String>? battleTraits,
    List<String>? weaponEnhancements,
    this.crusadeRelic,
  })  : xp = xp ?? 0,
        honours = honours ?? [],
        scars = scars ?? [],
        enhancements = enhancements ?? [],
        crusadePoints = crusadePoints ?? 0,
        tallies = tallies ?? {'played': 0, 'survived': 0, 'destroyed': 0},
        pendingRankUp = pendingRankUp ?? false,
        battleTraits = battleTraits ?? [],
        weaponEnhancements = weaponEnhancements ?? [];

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
      'battleTraits': battleTraits,
      'weaponEnhancements': weaponEnhancements,
      'crusadeRelic': crusadeRelic,
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
      battleTraits: (json['battleTraits'] as List<dynamic>?)?.cast<String>(),
      weaponEnhancements: (json['weaponEnhancements'] as List<dynamic>?)?.cast<String>(),
      crusadeRelic: json['crusadeRelic'] as String?,
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

  /// Calculate total Crusade Points for this roster based on the OOB
  int calculateTotalCrusadePoints(List<UnitOrGroup> oob) {
    int total = 0;
    for (final unitId in unitIds) {
      final unit = oob.where((u) => u.id == unitId).firstOrNull;
      if (unit != null) {
        total += unit.totalCrusadePoints;
      }
    }
    return total;
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

/// Tracks a crusade force's performance within a campaign
@HiveType(typeId: 8)
class CrusadeCampaignLink {
  @HiveField(0)
  final String crusadeId;

  @HiveField(1)
  String crusadeName; // Snapshot of name when linked

  @HiveField(2)
  String faction; // Snapshot of faction

  @HiveField(3)
  int gamesPlayed;

  @HiveField(4)
  int wins;

  @HiveField(5)
  int losses;

  @HiveField(6)
  int draws;

  @HiveField(7)
  int joinedAt; // When this crusade joined the campaign

  CrusadeCampaignLink({
    required this.crusadeId,
    required this.crusadeName,
    required this.faction,
    this.gamesPlayed = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    int? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now().millisecondsSinceEpoch;

  /// Record a game result for this crusade in the campaign
  void recordGame(String result) {
    gamesPlayed++;
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
    if (gamesPlayed == 0) return 'N/A';
    final rate = (wins / gamesPlayed * 100).toStringAsFixed(0);
    return '$rate%';
  }

  factory CrusadeCampaignLink.fromJson(Map<String, dynamic> json) {
    return CrusadeCampaignLink(
      crusadeId: json['crusadeId'] as String,
      crusadeName: json['crusadeName'] as String,
      faction: json['faction'] as String,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
      joinedAt: json['joinedAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crusadeId': crusadeId,
      'crusadeName': crusadeName,
      'faction': faction,
      'gamesPlayed': gamesPlayed,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'joinedAt': joinedAt,
    };
  }
}

/// Represents a campaign - a standalone container for tracking narrative campaigns
/// Multiple crusade forces can participate in a single campaign
@HiveType(typeId: 4)
class Campaign {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  int createdAt;

  @HiveField(4)
  int lastModified;

  @HiveField(5)
  List<CrusadeCampaignLink> crusadeLinks; // Participating crusade forces with stats

  @HiveField(6)
  bool isActive; // Is the campaign still running?

  Campaign({
    required this.id,
    required this.name,
    this.description,
    int? createdAt,
    int? lastModified,
    List<CrusadeCampaignLink>? crusadeLinks,
    this.isActive = true,
  })  : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        lastModified = lastModified ?? DateTime.now().millisecondsSinceEpoch,
        crusadeLinks = crusadeLinks ?? [];

  /// Add a crusade force to this campaign
  void addCrusade(Crusade crusade) {
    if (!crusadeLinks.any((link) => link.crusadeId == crusade.id)) {
      crusadeLinks.add(CrusadeCampaignLink(
        crusadeId: crusade.id,
        crusadeName: crusade.name,
        faction: crusade.faction,
      ));
      lastModified = DateTime.now().millisecondsSinceEpoch;
    }
  }

  /// Remove a crusade force from this campaign
  void removeCrusade(String crusadeId) {
    crusadeLinks.removeWhere((link) => link.crusadeId == crusadeId);
    lastModified = DateTime.now().millisecondsSinceEpoch;
  }

  /// Get link for a specific crusade
  CrusadeCampaignLink? getCrusadeLink(String crusadeId) {
    return crusadeLinks.where((l) => l.crusadeId == crusadeId).firstOrNull;
  }

  /// Check if a crusade is part of this campaign
  bool hasCrusade(String crusadeId) {
    return crusadeLinks.any((link) => link.crusadeId == crusadeId);
  }

  /// Get total games played in this campaign
  int get totalGames => crusadeLinks.fold(0, (sum, l) => sum + l.gamesPlayed);

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: json['createdAt'] as int?,
      lastModified: json['lastModified'] as int?,
      crusadeLinks: (json['crusadeLinks'] as List<dynamic>?)
          ?.map((e) => CrusadeCampaignLink.fromJson(e as Map<String, dynamic>))
          .toList(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt,
      'lastModified': lastModified,
      'crusadeLinks': crusadeLinks.map((e) => e.toJson()).toList(),
      'isActive': isActive,
    };
  }
}

/// Agenda types
class AgendaType {
  static const String objective = 'objective'; // Binary or tiered completion
  static const String tally = 'tally'; // Count tallies per unit
}

/// Represents an agenda selected for a game
@HiveType(typeId: 5)
class GameAgenda {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type; // AgendaType.objective or AgendaType.tally

  @HiveField(3)
  String? description;

  // For objective agendas
  @HiveField(4)
  bool completed; // Did we complete the objective?

  @HiveField(5)
  int tier; // For tiered objectives: 0 = not achieved, 1 = basic, 2 = enhanced, etc.

  @HiveField(6)
  int maxTier; // Maximum tier available (1 for binary, 2-3 for tiered)

  // For tally agendas - tracks tallies per unit
  @HiveField(7)
  Map<String, int> unitTallies; // unitId -> tally count

  // For agendas that require unit selection
  @HiveField(8)
  int? maxUnits; // Max units that can attempt this agenda (null = all units)

  @HiveField(9)
  List<String> assignedUnitIds; // Units assigned to attempt this agenda

  GameAgenda({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.completed = false,
    this.tier = 0,
    this.maxTier = 1,
    Map<String, int>? unitTallies,
    this.maxUnits,
    List<String>? assignedUnitIds,
  })  : unitTallies = unitTallies ?? {},
        assignedUnitIds = assignedUnitIds ?? [];

  /// Add a tally for a unit (for tally-type agendas)
  void addTally(String unitId, {int count = 1}) {
    unitTallies[unitId] = (unitTallies[unitId] ?? 0) + count;
  }

  /// Get total tallies across all units
  int get totalTallies => unitTallies.values.fold(0, (sum, t) => sum + t);

  factory GameAgenda.fromJson(Map<String, dynamic> json) {
    return GameAgenda(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      completed: json['completed'] as bool? ?? false,
      tier: json['tier'] as int? ?? 0,
      maxTier: json['maxTier'] as int? ?? 1,
      unitTallies: (json['unitTallies'] as Map<String, dynamic>?)?.cast<String, int>(),
      maxUnits: json['maxUnits'] as int?,
      assignedUnitIds: (json['assignedUnitIds'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'completed': completed,
      'tier': tier,
      'maxTier': maxTier,
      'unitTallies': unitTallies,
      'maxUnits': maxUnits,
      'assignedUnitIds': assignedUnitIds,
    };
  }

  /// Check if a unit is assigned to this agenda
  bool isUnitAssigned(String unitId) {
    // If no maxUnits limit, all units can participate (for tally agendas)
    if (maxUnits == null) return true;
    return assignedUnitIds.contains(unitId);
  }

  /// Check if more units can be assigned
  bool get canAssignMoreUnits {
    if (maxUnits == null) return true;
    return assignedUnitIds.length < maxUnits!;
  }
}

/// Represents the state of a unit during/after a game
/// Tracks kills, whether destroyed, and agenda-specific tallies
@HiveType(typeId: 6)
class UnitGameState {
  @HiveField(0)
  final String unitId;

  @HiveField(1)
  String unitName; // Snapshot of name at game time

  @HiveField(2)
  int kills; // Enemy units/models destroyed by this unit

  @HiveField(3)
  bool wasDestroyed; // Was this unit destroyed during the game?

  @HiveField(4)
  bool markedForGreatness; // Was this unit marked for greatness?

  @HiveField(5)
  String? notes; // Optional notes for this unit's performance

  @HiveField(6)
  String? groupId; // ID of the group this unit belongs to (null if standalone)

  @HiveField(7)
  String? groupName; // Name of the group this unit belongs to

  UnitGameState({
    required this.unitId,
    required this.unitName,
    this.kills = 0,
    this.wasDestroyed = false,
    this.markedForGreatness = false,
    this.notes,
    this.groupId,
    this.groupName,
  });

  factory UnitGameState.fromJson(Map<String, dynamic> json) {
    return UnitGameState(
      unitId: json['unitId'] as String,
      unitName: json['unitName'] as String,
      kills: json['kills'] as int? ?? 0,
      wasDestroyed: json['wasDestroyed'] as bool? ?? false,
      markedForGreatness: json['markedForGreatness'] as bool? ?? false,
      notes: json['notes'] as String?,
      groupId: json['groupId'] as String?,
      groupName: json['groupName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unitId': unitId,
      'unitName': unitName,
      'kills': kills,
      'wasDestroyed': wasDestroyed,
      'markedForGreatness': markedForGreatness,
      'notes': notes,
      'groupId': groupId,
      'groupName': groupName,
    };
  }
}

/// Battle size definitions
class BattleSizeType {
  static const String combatPatrol = 'combat_patrol';
  static const String incursion = 'incursion';
  static const String strikeForce = 'strike_force';
  static const String onslaught = 'onslaught';
  static const String apocalypse = 'apocalypse';

  static int getPointsLimit(String type) {
    switch (type) {
      case combatPatrol:
        return 500;
      case incursion:
        return 1000;
      case strikeForce:
        return 2000;
      case onslaught:
        return 3000;
      case apocalypse:
        return 3000; // 3000+ (no upper limit)
      default:
        return 2000;
    }
  }

  static String getDisplayName(String type) {
    switch (type) {
      case combatPatrol:
        return 'Combat Patrol';
      case incursion:
        return 'Incursion';
      case strikeForce:
        return 'Strike Force';
      case onslaught:
        return 'Onslaught';
      case apocalypse:
        return 'Apocalypse';
      default:
        return 'Unknown';
    }
  }
}

/// Game result types
class GameResult {
  static const String inProgress = 'in_progress';
  static const String win = 'win';
  static const String loss = 'loss';
  static const String draw = 'draw';
}

/// Represents a single game/battle session
@HiveType(typeId: 7)
class Game {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? campaignId; // Optional - reference to Campaign

  @HiveField(3)
  String rosterId; // Reference to the Roster used

  @HiveField(4)
  String battleSize; // BattleSizeType constant

  @HiveField(5)
  int rosterPoints; // Snapshot of roster points at game start

  @HiveField(6)
  int rosterCrusadePoints; // Snapshot of roster CP at game start

  @HiveField(7)
  int createdAt; // Unix timestamp - when game started

  @HiveField(8)
  int? completedAt; // Unix timestamp - when game ended (null if in progress)

  @HiveField(9)
  String result; // GameResult constant

  @HiveField(10)
  List<GameAgenda> agendas; // 2 agendas for the game

  @HiveField(11)
  List<UnitGameState> unitStates; // State of each unit in the game

  @HiveField(12)
  String? opponentName; // Optional opponent name

  @HiveField(13)
  String? opponentFaction; // Optional opponent faction

  @HiveField(14)
  String? notes; // Optional game notes

  @HiveField(15)
  int? playerScore; // Optional VP score

  @HiveField(16)
  int? opponentScore; // Optional opponent VP score

  Game({
    required this.id,
    required this.name,
    required this.rosterId,
    required this.battleSize,
    required this.rosterPoints,
    this.rosterCrusadePoints = 0,
    this.campaignId,
    int? createdAt,
    this.completedAt,
    this.result = GameResult.inProgress,
    List<GameAgenda>? agendas,
    List<UnitGameState>? unitStates,
    this.opponentName,
    this.opponentFaction,
    this.notes,
    this.playerScore,
    this.opponentScore,
  })  : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        agendas = agendas ?? [],
        unitStates = unitStates ?? [];

  /// Check if game is still in progress
  bool get isInProgress => result == GameResult.inProgress;

  /// Check if game is completed
  bool get isCompleted => !isInProgress;

  /// Get unit state by ID
  UnitGameState? getUnitState(String unitId) {
    return unitStates.where((u) => u.unitId == unitId).firstOrNull;
  }

  /// Initialize unit states from a roster's units
  void initializeUnitStates(List<UnitOrGroup> units) {
    unitStates.clear();
    for (final unit in units) {
      // For groups, add state for each component unit with group info
      if (unit.type == 'group' && unit.components != null) {
        final groupName = unit.customName ?? unit.name;
        for (final component in unit.components!) {
          unitStates.add(UnitGameState(
            unitId: component.id,
            unitName: component.customName ?? component.name,
            groupId: unit.id,
            groupName: groupName,
          ));
        }
      } else {
        unitStates.add(UnitGameState(
          unitId: unit.id,
          unitName: unit.customName ?? unit.name,
        ));
      }
    }
  }

  /// Calculate total kills across all units
  int get totalKills => unitStates.fold(0, (sum, u) => sum + u.kills);

  /// Count units destroyed
  int get unitsDestroyed => unitStates.where((u) => u.wasDestroyed).length;

  /// Count units that survived
  int get unitsSurvived => unitStates.where((u) => !u.wasDestroyed).length;

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      name: json['name'] as String,
      rosterId: json['rosterId'] as String,
      battleSize: json['battleSize'] as String,
      rosterPoints: json['rosterPoints'] as int,
      rosterCrusadePoints: json['rosterCrusadePoints'] as int? ?? 0,
      campaignId: json['campaignId'] as String?,
      createdAt: json['createdAt'] as int?,
      completedAt: json['completedAt'] as int?,
      result: json['result'] as String? ?? GameResult.inProgress,
      agendas: (json['agendas'] as List<dynamic>?)
          ?.map((e) => GameAgenda.fromJson(e as Map<String, dynamic>))
          .toList(),
      unitStates: (json['unitStates'] as List<dynamic>?)
          ?.map((e) => UnitGameState.fromJson(e as Map<String, dynamic>))
          .toList(),
      opponentName: json['opponentName'] as String?,
      opponentFaction: json['opponentFaction'] as String?,
      notes: json['notes'] as String?,
      playerScore: json['playerScore'] as int?,
      opponentScore: json['opponentScore'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rosterId': rosterId,
      'battleSize': battleSize,
      'rosterPoints': rosterPoints,
      'rosterCrusadePoints': rosterCrusadePoints,
      'campaignId': campaignId,
      'createdAt': createdAt,
      'completedAt': completedAt,
      'result': result,
      'agendas': agendas.map((e) => e.toJson()).toList(),
      'unitStates': unitStates.map((e) => e.toJson()).toList(),
      'opponentName': opponentName,
      'opponentFaction': opponentFaction,
      'notes': notes,
      'playerScore': playerScore,
      'opponentScore': opponentScore,
    };
  }
}