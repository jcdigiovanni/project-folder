import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

// ── Key Constants ────────────────────────────────────────────────────────────
// Minimal string constants for elixir keys referenced directly in Dart code.
// These match the keys in ec_combat_elixirs.json for backward compatibility.

class ElixirKeys {
  static const String anfrakSilk = 'anfrak_silk';
}

// ── JSON-Loaded Data Models ──────────────────────────────────────────────────

/// Definition of an exotic ingredient, loaded from JSON.
class IngredientDef {
  final String key;
  final String label;
  final String description;

  const IngredientDef({
    required this.key,
    required this.label,
    required this.description,
  });

  factory IngredientDef.fromJson(Map<String, dynamic> json) => IngredientDef(
    key: json['key'] as String,
    label: json['label'] as String,
    description: json['description'] as String,
  );
}

/// Definition of an elixir (army or personal), loaded from JSON.
class ElixirDef {
  final String key;
  final String label;
  final String effect;
  final bool isPersonal;

  const ElixirDef({
    required this.key,
    required this.label,
    required this.effect,
    required this.isPersonal,
  });

  factory ElixirDef.fromJson(Map<String, dynamic> json) => ElixirDef(
    key: json['key'] as String,
    label: json['label'] as String,
    effect: json['effect'] as String,
    isPersonal: json['isPersonal'] as bool,
  );
}

/// Stash capacity limits, loaded from JSON.
class ElixirLimits {
  final int maxCommon;
  final int maxRare;
  final int maxExoticTotal;
  final int maxElixirPerType;

  const ElixirLimits({
    required this.maxCommon,
    required this.maxRare,
    required this.maxExoticTotal,
    required this.maxElixirPerType,
  });

  factory ElixirLimits.fromJson(Map<String, dynamic> json) => ElixirLimits(
    maxCommon: json['maxCommon'] as int,
    maxRare: json['maxRare'] as int,
    maxExoticTotal: json['maxExoticTotal'] as int,
    maxElixirPerType: json['maxElixirPerType'] as int,
  );
}

// ── Recipes ──────────────────────────────────────────────────────────────────

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

  ElixirRecipe({
    required this.elixirKey,
    required this.isPersonal,
    required this.slots,
  });
}

// ── Elixir System Data (top-level container) ─────────────────────────────────

/// Complete elixir system data loaded from JSON. Provides all lookups that
/// screens need for ingredient names, elixir labels/effects, and recipes.
class ElixirSystemData {
  final ElixirLimits limits;
  final List<IngredientDef> exoticIngredients;
  final List<ElixirDef> elixirs;
  final List<ElixirRecipe> recipes;

  ElixirSystemData({
    required this.limits,
    required this.exoticIngredients,
    required this.elixirs,
    required this.recipes,
  });

  // ── Convenience lookups (built lazily) ──

  late final Map<String, IngredientDef> _ingredientsByKey = {
    for (final i in exoticIngredients) i.key: i,
  };
  late final Map<String, ElixirDef> _elixirsByKey = {
    for (final e in elixirs) e.key: e,
  };

  List<String> get exoticKeys => exoticIngredients.map((i) => i.key).toList();
  List<ElixirDef> get armyElixirs => elixirs.where((e) => !e.isPersonal).toList();
  List<ElixirDef> get personalElixirs => elixirs.where((e) => e.isPersonal).toList();

  String? ingredientLabel(String key) => _ingredientsByKey[key]?.label;
  String? ingredientDescription(String key) => _ingredientsByKey[key]?.description;
  String? elixirLabel(String key) => _elixirsByKey[key]?.label;
  String? elixirEffect(String key) => _elixirsByKey[key]?.effect;
  bool isPersonalElixir(String key) => _elixirsByKey[key]?.isPersonal ?? false;

  ElixirRecipe? recipeForElixir(String key) {
    for (final r in recipes) {
      if (r.elixirKey == key) return r;
    }
    return null;
  }

  factory ElixirSystemData.fromJson(Map<String, dynamic> json) {
    final limits = ElixirLimits.fromJson(json['limits'] as Map<String, dynamic>);
    final ingredients = (json['exoticIngredients'] as List)
        .map((e) => IngredientDef.fromJson(e as Map<String, dynamic>))
        .toList();
    final elixirDefs = (json['elixirs'] as List)
        .map((e) => ElixirDef.fromJson(e as Map<String, dynamic>))
        .toList();

    // Build elixir lookup for isPersonal resolution in recipes
    final elixirMap = {for (final e in elixirDefs) e.key: e};

    final recipes = (json['recipes'] as List).map((r) {
      final rMap = r as Map<String, dynamic>;
      final elixirKey = rMap['elixirKey'] as String;
      final slots = (rMap['slots'] as List)
          .map((s) => RecipeSlot((s as List).cast<String>()))
          .toList();
      return ElixirRecipe(
        elixirKey: elixirKey,
        isPersonal: elixirMap[elixirKey]?.isPersonal ?? false,
        slots: slots,
      );
    }).toList();

    return ElixirSystemData(
      limits: limits,
      exoticIngredients: ingredients,
      elixirs: elixirDefs,
      recipes: recipes,
    );
  }
}

// ── Loader ────────────────────────────────────────────────────────────────────

ElixirSystemData? _elixirDataCache;

/// Load elixir system data from JSON asset. Cached after first load.
Future<ElixirSystemData> loadElixirData() async {
  if (_elixirDataCache != null) return _elixirDataCache!;
  final jsonStr = await rootBundle.loadString('assets/data/ec_combat_elixirs.json');
  final data = jsonDecode(jsonStr) as Map<String, dynamic>;
  _elixirDataCache = ElixirSystemData.fromJson(data);
  return _elixirDataCache!;
}

// ── Combat Elixirs Stash ────────────────────────────────────────────────────

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

  bool isCommonFull(ElixirLimits limits) => commonIngredients >= limits.maxCommon;
  bool isRareFull(ElixirLimits limits) => rareIngredients >= limits.maxRare;
  bool isExoticFull(ElixirLimits limits) => totalExotic >= limits.maxExoticTotal;

  int addCommon(int amount, ElixirLimits limits) {
    final space = limits.maxCommon - commonIngredients;
    final added = amount.clamp(0, space);
    commonIngredients += added;
    return added;
  }

  int addRare(int amount, ElixirLimits limits) {
    final space = limits.maxRare - rareIngredients;
    final added = amount.clamp(0, space);
    rareIngredients += added;
    return added;
  }

  int addExotic(String type, int amount, ElixirLimits limits) {
    final space = limits.maxExoticTotal - totalExotic;
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
  bool addElixirDose(String key, {required bool isPersonal, required ElixirLimits limits}) {
    final map = isPersonal ? personalElixirs : armyElixirs;
    final current = map[key] ?? 0;
    if (current >= limits.maxElixirPerType) return false;
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
  bool craft(ElixirRecipe recipe, ElixirLimits limits) {
    final key = recipe.elixirKey;
    final map = recipe.isPersonal ? personalElixirs : armyElixirs;
    if ((map[key] ?? 0) >= limits.maxElixirPerType) return false;

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

// ── Equipped Elixirs (per-game snapshot) ────────────────────────────────────

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
