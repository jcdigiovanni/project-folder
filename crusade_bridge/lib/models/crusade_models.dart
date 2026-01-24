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

Crusade({
  required this.id,
  required this.name,
  required this.faction,
  required this.detachment,
  required this.supplyLimit,  // ← Make required
  required this.rp,           // ← Make required
  this.armyIconPath,
  this.factionIconAsset,
  List<UnitOrGroup>? oob,
  List<UnitOrGroup>? templates,
  int? lastModified,
})  : oob = oob ?? [],
      templates = templates ?? [],
      lastModified = lastModified ?? DateTime.now().millisecondsSinceEpoch;

  // Calculate total points used in OOB
  int get totalOobPoints => oob.fold<int>(0, (sum, item) => sum + item.points);

  // Calculate remaining points
  int get remainingPoints => supplyLimit - totalOobPoints;

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
    );
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
    int? xp,
    List<String>? honours,
    List<String>? scars,
    int? crusadePoints,
    Map<String, int>? tallies,
  })  : xp = xp ?? 0,
        honours = honours ?? [],
        scars = scars ?? [],
        crusadePoints = crusadePoints ?? 0,
        tallies = tallies ?? {'played': 0, 'survived': 0, 'destroyed': 0};

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
      'crusadePoints': crusadePoints,
      'tallies': tallies,
      'notes': notes,
      'statsText': statsText,
      'isWarlord': isWarlord,
      'isEpicHero': isEpicHero,
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
      xp: json['xp'] as int?,
      honours: (json['honours'] as List<dynamic>?)?.cast<String>(),
      scars: (json['scars'] as List<dynamic>?)?.cast<String>(),
      crusadePoints: json['crusadePoints'] as int?,
      tallies: (json['tallies'] as Map<String, dynamic>?)?.cast<String, int>(),
    );
  }
}