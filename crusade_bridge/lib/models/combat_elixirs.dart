import 'dart:convert';

// ── Stash Limits ──────────────────────────────────────────────────────────────

class StashLimits {
  static const int maxCommon = 6;
  static const int maxRare = 4;
  static const int maxExoticTotal = 2;
  static const int maxElixirPerType = 3;
}

// ── Exotic Ingredients ────────────────────────────────────────────────────────

class ExoticIngredient {
  static const String concentrateOfTormentedSouls = 'concentrate_of_tormented_souls';
  static const String dilutionOfFalseHope = 'dilution_of_false_hope';
  static const String distillateOfHatred = 'distillate_of_hatred';
  static const String essenceOfFear = 'essence_of_fear';
  static const String extractOfXenoMatter = 'extract_of_xeno_matter';
  static const String infusionOfTraitorsBlood = 'infusion_of_traitors_blood';

  static const List<String> allTypes = [
    concentrateOfTormentedSouls,
    dilutionOfFalseHope,
    distillateOfHatred,
    essenceOfFear,
    extractOfXenoMatter,
    infusionOfTraitorsBlood,
  ];

  static const Map<String, String> labels = {
    concentrateOfTormentedSouls: 'Concentrate of Tormented Souls',
    dilutionOfFalseHope: 'Dilution of False Hope',
    distillateOfHatred: 'Distillate of Hatred',
    essenceOfFear: 'Essence of Fear',
    extractOfXenoMatter: 'Extract of Xeno-matter',
    infusionOfTraitorsBlood: 'Infusion of Traitor\'s Blood',
  };

  static const Map<String, String> descriptions = {
    concentrateOfTormentedSouls: 'Sickly-sour ectoplasmic soup syphoned from those who bear corruption in their hearts.',
    dilutionOfFalseHope: 'A clear liquid adulterated with the sickly essence of those sworn to a false god.',
    distillateOfHatred: 'Purest fury sieved from the ground and pulped corpses of the righteous.',
    essenceOfFear: 'Stolen and refined from the last breath of a craven victim.',
    extractOfXenoMatter: 'Ichor, viscera or psychic spore extracted from an alien foe.',
    infusionOfTraitorsBlood: 'Crimson fluid extracted from the veins of those who have broken an oath of loyalty.',
  };
}

// ── Army Elixirs ──────────────────────────────────────────────────────────────

class ArmyElixir {
  static const String anfrakSilk = 'anfrak_silk';
  static const String xylocil = 'xylocil';
  static const String shivversplit = 'shivversplit';
  static const String heliotrophos = 'heliotrophos';
  static const String skorflense = 'skorflense';
  static const String quail = 'quail';

  static const List<String> allTypes = [
    anfrakSilk, xylocil, shivversplit, heliotrophos, skorflense, quail,
  ];

  static const Map<String, String> labels = {
    anfrakSilk: 'Anfrak Silk',
    xylocil: 'Xylocil',
    shivversplit: 'Shivversplit',
    heliotrophos: 'Heliotrophos',
    skorflense: 'Skorflense',
    quail: 'Quail',
  };

  static const Map<String, String> effects = {
    anfrakSilk: 'Add 2" to the Move characteristic of EMPEROR\'S CHILDREN units.',
    xylocil: 'Add 1 to the Strength characteristic of melee weapons equipped by EMPEROR\'S CHILDREN models.',
    shivversplit: 'Add 1 to the Toughness characteristic of EMPEROR\'S CHILDREN units.',
    heliotrophos: 'Add 1 to the Attacks characteristic of melee weapons equipped by EMPEROR\'S CHILDREN models.',
    skorflense: 'Improve the Ballistic Skill and Weapon Skill characteristics of weapons equipped by EMPEROR\'S CHILDREN models by 1.',
    quail: 'Improve the Leadership and Objective Control characteristics of EMPEROR\'S CHILDREN units by 1.',
  };
}

// ── Personal Elixirs ──────────────────────────────────────────────────────────

class PersonalElixir {
  static const String alacrine = 'alacrine';
  static const String cerebresec = 'cerebresec';
  static const String thrynicine = 'thrynicine';
  static const String salviqineTears = 'salviqine_tears';
  static const String sanctusVi = 'sanctus_vi';
  static const String excelsorX = 'excelsor_x';

  static const List<String> allTypes = [
    alacrine, cerebresec, thrynicine, salviqineTears, sanctusVi, excelsorX,
  ];

  static const Map<String, String> labels = {
    alacrine: 'Alacrine',
    cerebresec: 'Cerebresec',
    thrynicine: 'Thrynicine',
    salviqineTears: 'Salviqine Tears',
    sanctusVi: 'Sanctus Vi',
    excelsorX: 'Excelsor X',
  };

  static const Map<String, String> effects = {
    alacrine: 'The bearer\'s unit has the Fights First ability.',
    cerebresec: 'Once per battle round, when you target the bearer\'s unit with a Stratagem, reduce the CP cost by 1.',
    thrynicine: 'Each time the bearer makes an attack, a successful Wound roll inflicts 1 mortal wound on the target (2 if the bearer has lost wounds).',
    salviqineTears: 'Each enemy unit within 12" of the bearer that is below Starting Strength must take a Battle-shock test, subtracting 1 if Below Half-strength.',
    sanctusVi: 'The bearer has a 2+ invulnerable save.',
    excelsorX: 'In your Shooting phase, after the bearer\'s unit has shot (if not in Engagement Range), it can make a Normal move of up to 6".',
  };
}

// ── Recipes ───────────────────────────────────────────────────────────────────

/// A single ingredient slot in a recipe. The player must provide ONE of the
/// options. Options can be generic types ('common', 'rare', 'exotic') or
/// specific exotic ingredient keys.
class RecipeSlot {
  final List<String> options;

  const RecipeSlot(this.options);

  /// Whether this slot can be satisfied by a generic common ingredient.
  bool get acceptsCommon => options.contains('common');
  bool get acceptsRare => options.contains('rare');
  bool get acceptsExotic => options.contains('exotic');

  /// Specific exotic ingredients accepted (not generic 'exotic').
  List<String> get specificExotics =>
      options.where((o) => o != 'common' && o != 'rare' && o != 'exotic').toList();
}

/// Recipe for crafting one dose of an elixir.
class ElixirRecipe {
  final String elixirKey;
  final bool isPersonal;
  final List<RecipeSlot> slots;

  const ElixirRecipe({
    required this.elixirKey,
    required this.isPersonal,
    required this.slots,
  });

  String get label => isPersonal
      ? PersonalElixir.labels[elixirKey]!
      : ArmyElixir.labels[elixirKey]!;
}

/// All elixir recipes. Approximate recipes based on Codex — slot options
/// represent "ingredient OR specific exotic" alternatives from the rules.
/// These can be refined when exact icon mapping is confirmed.
class ElixirRecipes {
  static const List<ElixirRecipe> all = [
    // Army Elixirs
    ElixirRecipe(elixirKey: ArmyElixir.anfrakSilk, isPersonal: false, slots: [
      RecipeSlot(['common']),
      RecipeSlot(['rare', ExoticIngredient.extractOfXenoMatter]),
    ]),
    ElixirRecipe(elixirKey: ArmyElixir.xylocil, isPersonal: false, slots: [
      RecipeSlot(['common']),
      RecipeSlot(['rare', ExoticIngredient.extractOfXenoMatter]),
    ]),
    ElixirRecipe(elixirKey: ArmyElixir.shivversplit, isPersonal: false, slots: [
      RecipeSlot(['common']),
      RecipeSlot(['rare', ExoticIngredient.essenceOfFear]),
    ]),
    ElixirRecipe(elixirKey: ArmyElixir.heliotrophos, isPersonal: false, slots: [
      RecipeSlot(['common']),
      RecipeSlot(['exotic']),
    ]),
    ElixirRecipe(elixirKey: ArmyElixir.skorflense, isPersonal: false, slots: [
      RecipeSlot(['rare', ExoticIngredient.extractOfXenoMatter]),
    ]),
    ElixirRecipe(elixirKey: ArmyElixir.quail, isPersonal: false, slots: [
      RecipeSlot(['rare']),
      RecipeSlot(['exotic']),
    ]),
    // Personal Elixirs
    ElixirRecipe(elixirKey: PersonalElixir.alacrine, isPersonal: true, slots: [
      RecipeSlot(['rare', 'common']),
      RecipeSlot([ExoticIngredient.extractOfXenoMatter]),
    ]),
    ElixirRecipe(elixirKey: PersonalElixir.cerebresec, isPersonal: true, slots: [
      RecipeSlot(['exotic']),
      RecipeSlot([ExoticIngredient.concentrateOfTormentedSouls]),
    ]),
    ElixirRecipe(elixirKey: PersonalElixir.thrynicine, isPersonal: true, slots: [
      RecipeSlot(['rare', ExoticIngredient.distillateOfHatred]),
      RecipeSlot(['rare', ExoticIngredient.dilutionOfFalseHope]),
    ]),
    ElixirRecipe(elixirKey: PersonalElixir.salviqineTears, isPersonal: true, slots: [
      RecipeSlot(['exotic']),
      RecipeSlot(['rare', ExoticIngredient.essenceOfFear]),
    ]),
    ElixirRecipe(elixirKey: PersonalElixir.sanctusVi, isPersonal: true, slots: [
      RecipeSlot(['exotic']),
      RecipeSlot(['rare', ExoticIngredient.concentrateOfTormentedSouls]),
      RecipeSlot([ExoticIngredient.infusionOfTraitorsBlood]),
    ]),
    ElixirRecipe(elixirKey: PersonalElixir.excelsorX, isPersonal: true, slots: [
      RecipeSlot(['rare', ExoticIngredient.dilutionOfFalseHope]),
      RecipeSlot(['common']),
    ]),
  ];

  static ElixirRecipe? forElixir(String key) {
    for (final r in all) {
      if (r.elixirKey == key) return r;
    }
    return null;
  }
}

// ── Combat Elixirs Stash ──────────────────────────────────────────────────────

/// Persistent stash tracking ingredients, crafted elixirs, and previous-battle
/// usage for the Emperor's Children Combat Elixirs system.
class CombatElixirsStash {
  int commonIngredients;
  int rareIngredients;
  Map<String, int> exoticIngredients; // key → count
  Map<String, int> armyElixirs;       // key → dose count
  Map<String, int> personalElixirs;   // key → dose count
  List<String> previousBattleElixirs; // keys used last battle

  CombatElixirsStash({
    this.commonIngredients = 0,
    this.rareIngredients = 0,
    Map<String, int>? exoticIngredients,
    Map<String, int>? armyElixirs,
    Map<String, int>? personalElixirs,
    List<String>? previousBattleElixirs,
  })  : exoticIngredients = exoticIngredients ?? {},
        armyElixirs = armyElixirs ?? {},
        personalElixirs = personalElixirs ?? {},
        previousBattleElixirs = previousBattleElixirs ?? [];

  factory CombatElixirsStash.empty() => CombatElixirsStash();

  // ── Limits ──

  int get totalExotic => exoticIngredients.values.fold(0, (a, b) => a + b);

  bool get isCommonFull => commonIngredients >= StashLimits.maxCommon;
  bool get isRareFull => rareIngredients >= StashLimits.maxRare;
  bool get isExoticFull => totalExotic >= StashLimits.maxExoticTotal;

  int addCommon(int amount) {
    final space = StashLimits.maxCommon - commonIngredients;
    final added = amount.clamp(0, space);
    commonIngredients += added;
    return added;
  }

  int addRare(int amount) {
    final space = StashLimits.maxRare - rareIngredients;
    final added = amount.clamp(0, space);
    rareIngredients += added;
    return added;
  }

  int addExotic(String type, int amount) {
    final space = StashLimits.maxExoticTotal - totalExotic;
    final added = amount.clamp(0, space);
    if (added > 0) {
      exoticIngredients[type] = (exoticIngredients[type] ?? 0) + added;
    }
    return added;
  }

  /// Get dose count for an elixir (army or personal).
  int getElixirDoses(String key) =>
      armyElixirs[key] ?? personalElixirs[key] ?? 0;

  /// Add a dose of a crafted elixir. Returns true if added (within limit).
  bool addElixirDose(String key, {required bool isPersonal}) {
    final map = isPersonal ? personalElixirs : armyElixirs;
    final current = map[key] ?? 0;
    if (current >= StashLimits.maxElixirPerType) return false;
    map[key] = current + 1;
    return true;
  }

  /// Remove a dose (e.g., when equipping). Returns true if removed.
  bool removeElixirDose(String key) {
    if (armyElixirs.containsKey(key) && armyElixirs[key]! > 0) {
      armyElixirs[key] = armyElixirs[key]! - 1;
      if (armyElixirs[key] == 0) armyElixirs.remove(key);
      return true;
    }
    if (personalElixirs.containsKey(key) && personalElixirs[key]! > 0) {
      personalElixirs[key] = personalElixirs[key]! - 1;
      if (personalElixirs[key] == 0) personalElixirs.remove(key);
      return true;
    }
    return false;
  }

  /// Check whether a recipe can be crafted with current ingredients.
  /// Returns a list of ingredient choices (one per slot) if craftable, null otherwise.
  /// Each choice is the key of the ingredient to consume from that slot.
  List<String>? canCraft(ElixirRecipe recipe) {
    // Track available resources for simulation
    int availCommon = commonIngredients;
    int availRare = rareIngredients;
    final availExotic = Map<String, int>.from(exoticIngredients);
    int availGenericExotic = totalExotic;

    final choices = <String>[];

    for (final slot in recipe.slots) {
      bool filled = false;

      // Try specific exotics first (they're most constrained)
      for (final exotic in slot.specificExotics) {
        if ((availExotic[exotic] ?? 0) > 0) {
          availExotic[exotic] = availExotic[exotic]! - 1;
          availGenericExotic -= 1;
          choices.add(exotic);
          filled = true;
          break;
        }
      }
      if (filled) continue;

      // Try generic exotic
      if (slot.acceptsExotic && availGenericExotic > 0) {
        // Find any exotic with stock
        for (final e in availExotic.entries) {
          if (e.value > 0) {
            availExotic[e.key] = e.value - 1;
            availGenericExotic -= 1;
            choices.add(e.key);
            filled = true;
            break;
          }
        }
        if (filled) continue;
      }

      // Try rare
      if (slot.acceptsRare && availRare > 0) {
        availRare -= 1;
        choices.add('rare');
        filled = true;
      }
      if (filled) continue;

      // Try common
      if (slot.acceptsCommon && availCommon > 0) {
        availCommon -= 1;
        choices.add('common');
        filled = true;
      }
      if (filled) continue;

      // Can't fill this slot
      return null;
    }

    return choices;
  }

  /// Craft an elixir: deduct ingredients and add one dose.
  /// Returns true if successful.
  bool craft(ElixirRecipe recipe) {
    final key = recipe.elixirKey;
    final map = recipe.isPersonal ? personalElixirs : armyElixirs;
    if ((map[key] ?? 0) >= StashLimits.maxElixirPerType) return false;

    final choices = canCraft(recipe);
    if (choices == null) return false;

    // Deduct ingredients
    for (final choice in choices) {
      if (choice == 'common') {
        commonIngredients -= 1;
      } else if (choice == 'rare') {
        rareIngredients -= 1;
      } else {
        // Specific exotic
        exoticIngredients[choice] = (exoticIngredients[choice] ?? 1) - 1;
        if (exoticIngredients[choice] == 0) exoticIngredients.remove(choice);
      }
    }

    map[key] = (map[key] ?? 0) + 1;
    return true;
  }

  /// Whether an elixir was used in the previous battle (consecutive-use block).
  bool wasUsedLastBattle(String key) => previousBattleElixirs.contains(key);

  /// Total elixir doses in stash (army + personal).
  int get totalElixirDoses {
    int total = 0;
    for (final v in armyElixirs.values) total += v;
    for (final v in personalElixirs.values) total += v;
    return total;
  }

  // ── JSON ──

  Map<String, dynamic> toJson() => {
    'commonIngredients': commonIngredients,
    'rareIngredients': rareIngredients,
    'exoticIngredients': exoticIngredients,
    'armyElixirs': armyElixirs,
    'personalElixirs': personalElixirs,
    'previousBattleElixirs': previousBattleElixirs,
  };

  factory CombatElixirsStash.fromJson(Map<String, dynamic> json) {
    return CombatElixirsStash(
      commonIngredients: json['commonIngredients'] as int? ?? 0,
      rareIngredients: json['rareIngredients'] as int? ?? 0,
      exoticIngredients: (json['exoticIngredients'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as int)) ?? {},
      armyElixirs: (json['armyElixirs'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as int)) ?? {},
      personalElixirs: (json['personalElixirs'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as int)) ?? {},
      previousBattleElixirs: (json['previousBattleElixirs'] as List<dynamic>?)
          ?.map((e) => e as String).toList() ?? [],
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory CombatElixirsStash.fromJsonString(String jsonStr) =>
      CombatElixirsStash.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
}

// ── Equipped Elixirs (per-game snapshot) ──────────────────────────────────────

/// Snapshot of which elixirs were equipped for a specific battle.
class EquippedElixirs {
  final List<String> armyElixirs;                // army elixir keys
  final Map<String, String> personalElixirs;     // unitId → personal elixir key

  const EquippedElixirs({
    this.armyElixirs = const [],
    this.personalElixirs = const {},
  });

  int get totalCount => armyElixirs.length + personalElixirs.length;

  /// Crusade Points cost: +1 per 2 elixirs (rounding up).
  int get crusadePointsCost => (totalCount / 2).ceil();

  /// All elixir keys (for previousBattleElixirs tracking).
  List<String> get allKeys => [...armyElixirs, ...personalElixirs.values];

  bool get isEmpty => armyElixirs.isEmpty && personalElixirs.isEmpty;

  Map<String, dynamic> toJson() => {
    'army': armyElixirs,
    'personal': personalElixirs,
  };

  factory EquippedElixirs.fromJson(Map<String, dynamic> json) {
    return EquippedElixirs(
      armyElixirs: (json['army'] as List<dynamic>?)
          ?.map((e) => e as String).toList() ?? [],
      personalElixirs: (json['personal'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as String)) ?? {},
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory EquippedElixirs.fromJsonString(String jsonStr) =>
      EquippedElixirs.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
}
