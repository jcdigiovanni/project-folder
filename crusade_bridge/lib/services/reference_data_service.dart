import 'dart:convert';
import 'package:flutter/services.dart';

/// Service for loading and accessing faction and unit reference data.
///
/// Data is stored in JSON files:
/// - assets/data/factions_and_detachments.json - All factions with their detachments
/// - assets/data/units/{faction_name}.json - Unit data per faction (loaded on-demand)
///
/// This structure allows for:
/// - Faster initial load (only factions/detachments)
/// - Lower memory usage (units loaded as needed)
/// - Easier maintenance (smaller, focused files)
class ReferenceDataService {
  // Cache for faction/detachment data (loaded once at startup)
  static Map<String, dynamic>? _factionsData;

  // Cache for loaded unit data (lazy-loaded per faction)
  static final Map<String, List<dynamic>> _unitsCache = {};

  /// Initialize the service by loading faction data
  static Future<void> init() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/factions_and_detachments.json');
      _factionsData = jsonDecode(jsonString) as Map<String, dynamic>;
      print('Loaded ${_factionsData?['factions']?.length ?? 0} factions');
    } catch (e) {
      print('Error loading factions data: $e');
      _factionsData = {'factions': {}};
    }
  }

  /// Get list of all available factions
  static List<String> getFactions() {
    final factions = _factionsData?['factions'] as Map<String, dynamic>?;
    return factions?.keys.toList() ?? [];
  }

  /// Get list of detachments for a specific faction
  static List<String> getDetachments(String faction) {
    final factions = _factionsData?['factions'] as Map<String, dynamic>?;
    final factionData = factions?[faction] as Map<String, dynamic>?;
    final detachmentsData = factionData?['detachments'];

    // Handle both old array format and new object format for backwards compatibility
    if (detachmentsData is List) {
      return detachmentsData.cast<String>();
    } else if (detachmentsData is Map<String, dynamic>) {
      return detachmentsData.keys.toList();
    }

    return [];
  }

  /// Get list of enhancements for a specific faction's detachment
  static List<Map<String, dynamic>> getEnhancements(String faction, String detachment) {
    final factions = _factionsData?['factions'] as Map<String, dynamic>?;
    final factionData = factions?[faction] as Map<String, dynamic>?;
    final detachmentsData = factionData?['detachments'] as Map<String, dynamic>?;
    final detachmentData = detachmentsData?[detachment] as Map<String, dynamic>?;
    final enhancements = detachmentData?['enhancements'] as List<dynamic>?;

    if (enhancements == null) return [];

    return enhancements.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Get faction icon asset path
  static String? getFactionIcon(String faction) {
    final factions = _factionsData?['factions'] as Map<String, dynamic>?;
    final factionData = factions?[faction] as Map<String, dynamic>?;
    return factionData?['icon'] as String?;
  }

  /// Get units for a specific faction (lazy-loaded and cached)
  static Future<List<dynamic>> getUnits(String faction) async {
    // Return cached data if available
    if (_unitsCache.containsKey(faction)) {
      return _unitsCache[faction]!;
    }

    // Load unit data for this faction
    try {
      // Convert faction name to file-safe format
      final fileName = _factionToFileName(faction);
      final jsonString = await rootBundle.loadString('assets/data/units/$fileName.json');
      final unitData = jsonDecode(jsonString) as Map<String, dynamic>;
      final units = unitData['units'] as List<dynamic>? ?? [];

      // Cache the result
      _unitsCache[faction] = units;
      print('Loaded ${units.length} units for $faction');

      return units;
    } catch (e) {
      print('Error loading units for $faction: $e');
      // Return empty list if file doesn't exist yet
      _unitsCache[faction] = [];
      return [];
    }
  }

  /// Get units for a specific faction synchronously from cache
  /// Returns empty list if not yet loaded. Call getUnits() first to load.
  static List<dynamic> getUnitsSync(String faction) {
    return _unitsCache[faction] ?? [];
  }

  /// Get detailed data for a specific unit within a faction
  static Future<Map<String, dynamic>> getUnitData(String faction, String unitName) async {
    final units = await getUnits(faction);

    for (final unit in units) {
      final unitMap = unit as Map<String, dynamic>;
      if (unitMap['name'] == unitName) {
        return unitMap;
      }
    }

    return {};
  }

  /// Get detailed data for a specific unit within a faction synchronously from cache
  /// Returns empty map if not yet loaded. Call getUnits() first to load.
  static Map<String, dynamic> getUnitDataSync(String faction, String unitName) {
    final units = _unitsCache[faction] ?? [];

    for (final unit in units) {
      final unitMap = unit as Map<String, dynamic>;
      if (unitMap['name'] == unitName) {
        return unitMap;
      }
    }

    return {};
  }

  /// Convert faction name to file-safe name
  /// Examples:
  /// - "Adepta Sororitas" -> "adepta_sororitas"
  /// - "T'au Empire" -> "tau_empire"
  /// - "Chaos Space Marines" -> "chaos_space_marines"
  static String _factionToFileName(String faction) {
    return faction
        .toLowerCase()
        .replaceAll("'", '')
        .replaceAll(' ', '_');
  }

  /// Clear cached unit data (useful for development/testing)
  static void clearCache() {
    _unitsCache.clear();
  }
}
