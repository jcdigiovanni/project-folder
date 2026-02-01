import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crusade_models.dart';
import '../providers/crusade_provider.dart';
import '../services/storage_service.dart';
import '../services/reference_data_service.dart';
import '../utils/snackbar_utils.dart';

class RequisitionScreen extends ConsumerWidget {
  const RequisitionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCrusade = ref.watch(currentCrusadeNotifierProvider);

    if (currentCrusade == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Requisitions')),
        body: const Center(child: Text('No Crusade loaded. Create one first.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Requisitions'),
      ),
      body: Column(
        children: [
          // RP & Supply Summary Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 2,
                ),
              ),
            ),
            child: Column(
              children: [
                // Top row: RP and Supply Limit
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Available RP',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${currentCrusade.rp}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFF59D),
                              ),
                            ),
                            const Text(
                              ' / 10 RP',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Supply Used',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          '${currentCrusade.totalOobPoints} / ${currentCrusade.supplyLimit} pts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: currentCrusade.totalOobPoints > currentCrusade.supplyLimit
                                ? Colors.red
                                : const Color(0xFFFFB6C1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Supply progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: currentCrusade.supplyLimit > 0
                        ? (currentCrusade.totalOobPoints / currentCrusade.supplyLimit).clamp(0.0, 1.0)
                        : 0.0,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade800,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      currentCrusade.totalOobPoints > currentCrusade.supplyLimit
                          ? Colors.red
                          : const Color(0xFFFFB6C1),
                    ),
                  ),
                ),
                if (currentCrusade.totalOobPoints > currentCrusade.supplyLimit)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.red, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Over supply limit by ${currentCrusade.totalOobPoints - currentCrusade.supplyLimit} pts',
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Requisition Options List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _RequisitionOption(
                  title: 'Increase Supply Limit',
                  description: 'Add 200 points to your army\'s supply limit',
                  cost: 1,
                  icon: Icons.arrow_upward,
                  color: Colors.blue,
                  enabled: currentCrusade.rp >= 1,
                  onTap: () => _increaseSupplyLimit(context, ref, currentCrusade),
                ),
                const SizedBox(height: 12),
                _RequisitionOption(
                  title: 'Fresh Recruits',
                  description: 'Add models to an existing unit (1 RP + 1 per Battle Honour)',
                  cost: 1,
                  costSuffix: '+',
                  icon: Icons.person_add,
                  color: Colors.green,
                  enabled: currentCrusade.rp >= 1,
                  onTap: () => _showFreshRecruitsModal(context, ref, currentCrusade),
                ),
                const SizedBox(height: 12),
                _RequisitionOption(
                  title: 'Battle Honours',
                  description: 'Grant a Battle Honour to one of your units',
                  cost: 1,
                  icon: Icons.military_tech,
                  color: Colors.amber,
                  enabled: false, // Coming soon
                  onTap: () {
                    SnackBarUtils.showMessage(context, 'Coming soon');
                  },
                ),
                const SizedBox(height: 12),
                _RequisitionOption(
                  title: 'Rearm and Resupply',
                  description: 'Swap wargear before a battle (requires wargear data)',
                  cost: 1,
                  icon: Icons.build,
                  color: Colors.purple,
                  enabled: false, // Requires wargear data layer
                  onTap: () {
                    SnackBarUtils.showMessage(context, 'Coming soon - requires wargear data');
                  },
                ),
                const SizedBox(height: 12),
                _RequisitionOption(
                  title: 'Repair and Recuperate',
                  description: 'Remove a Battle Scar from a unit (cost = scar count)',
                  cost: 1,
                  costSuffix: '-5',
                  icon: Icons.healing,
                  color: Colors.teal,
                  enabled: currentCrusade.rp >= 1 && _hasUnitsWithScars(currentCrusade),
                  onTap: () => _showRepairAndRecuperateModal(context, ref, currentCrusade),
                ),
                const SizedBox(height: 12),
                _RequisitionOption(
                  title: 'Renowned Heroes',
                  description: 'Grant an Enhancement to a Character (1-3 RP)',
                  cost: 1,
                  costSuffix: '-3',
                  icon: Icons.star,
                  color: Colors.orange,
                  enabled: currentCrusade.rp >= 1 && _hasEligibleCharacters(currentCrusade),
                  onTap: () => _showRenownedHeroesModal(context, ref, currentCrusade),
                ),
                const SizedBox(height: 12),
                _RequisitionOption(
                  title: 'Legendary Veterans',
                  description: 'Allow a unit to exceed 30 XP and 3 Honours cap',
                  cost: 3,
                  icon: Icons.auto_awesome,
                  color: Colors.deepPurple,
                  enabled: currentCrusade.rp >= 3,
                  onTap: () => _showLegendaryVeteransModal(context, ref, currentCrusade),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _increaseSupplyLimit(BuildContext context, WidgetRef ref, Crusade crusade) {
    if (crusade.rp < 1) {
      SnackBarUtils.showError(context, 'Not enough RP');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Increase Supply Limit?'),
        content: Text(
          'Spend 1 RP to increase your supply limit from ${crusade.supplyLimit} to ${crusade.supplyLimit + 200} points?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final updatedCrusade = Crusade(
                id: crusade.id,
                name: crusade.name,
                faction: crusade.faction,
                detachment: crusade.detachment,
                supplyLimit: crusade.supplyLimit + 200,
                rp: crusade.rp - 1,
                armyIconPath: crusade.armyIconPath,
                factionIconAsset: crusade.factionIconAsset,
                oob: crusade.oob,
                templates: crusade.templates,
                lastModified: DateTime.now().millisecondsSinceEpoch,
                usedFirstCharacterEnhancement: crusade.usedFirstCharacterEnhancement,
                history: crusade.history,
                rosters: crusade.rosters,
                games: crusade.games,
              );

              ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(updatedCrusade);
              StorageService.saveCrusade(updatedCrusade);

              Navigator.pop(context);
              SnackBarUtils.showSuccess(
                context,
                'Supply limit increased to ${updatedCrusade.supplyLimit} pts!',
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showFreshRecruitsModal(BuildContext context, WidgetRef ref, Crusade crusade) async {
    // Load unit data for the faction
    await ReferenceDataService.getUnits(crusade.faction);

    // Gather all units (from OOB and from groups)
    final List<_EligibleUnit> eligibleUnits = [];

    for (final item in crusade.oob) {
      if (item.type == 'group' && item.components != null) {
        // Check units inside groups
        for (final unit in item.components!) {
          final eligibility = _checkUnitEligibility(crusade.faction, unit);
          if (eligibility != null) {
            eligibleUnits.add(eligibility);
          }
        }
      } else if (item.type == 'unit') {
        final eligibility = _checkUnitEligibility(crusade.faction, item);
        if (eligibility != null) {
          eligibleUnits.add(eligibility);
        }
      }
    }

    if (!context.mounted) return;

    if (eligibleUnits.isEmpty) {
      SnackBarUtils.showMessage(context, 'No units eligible for Fresh Recruits (all at max size or single-model units)');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fresh Recruits',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Select a unit to add models',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Unit list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: eligibleUnits.length,
                itemBuilder: (context, index) {
                  final eligible = eligibleUnits[index];
                  final rpCost = 1 + eligible.unit.honours.length;
                  final canAfford = crusade.rp >= rpCost;
                  final pointsDiff = eligible.newPoints - eligible.unit.points;
                  final wouldExceedSupply = (crusade.totalOobPoints + pointsDiff) > crusade.supplyLimit;

                  return ListTile(
                    enabled: canAfford && !wouldExceedSupply,
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.group_add, color: Colors.green),
                    ),
                    title: Text(eligible.unit.customName ?? eligible.unit.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${eligible.unit.modelsCurrent} → ${eligible.newModels} models (+$pointsDiff pts)',
                          style: TextStyle(
                            color: wouldExceedSupply ? Colors.red : Colors.grey,
                          ),
                        ),
                        if (eligible.unit.honours.isNotEmpty)
                          Text(
                            '${eligible.unit.honours.length} Battle Honour${eligible.unit.honours.length > 1 ? 's' : ''}',
                            style: const TextStyle(color: Colors.amber, fontSize: 12),
                          ),
                        if (wouldExceedSupply)
                          const Text(
                            'Would exceed Supply Limit',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: canAfford
                            ? const Color(0xFFFFF59D).withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: canAfford ? const Color(0xFFFFF59D) : Colors.grey,
                        ),
                      ),
                      child: Text(
                        '$rpCost RP',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: canAfford ? const Color(0xFFFFF59D) : Colors.grey,
                        ),
                      ),
                    ),
                    onTap: canAfford && !wouldExceedSupply
                        ? () => _confirmFreshRecruits(context, ref, crusade, eligible, rpCost)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _EligibleUnit? _checkUnitEligibility(String faction, UnitOrGroup unit) {
    // Get unit data from reference
    final unitData = ReferenceDataService.getUnitDataSync(faction, unit.name);
    if (unitData.isEmpty) return null;

    final sizeOptions = (unitData['sizeOptions'] as List<dynamic>?)?.cast<int>() ?? [];
    final pointsOptions = (unitData['pointsOptions'] as List<dynamic>?)?.cast<int>() ?? [];

    if (sizeOptions.length <= 1) return null; // Single size only
    if (sizeOptions.length != pointsOptions.length) return null; // Data mismatch

    // Find current size index
    final currentSizeIndex = sizeOptions.indexOf(unit.modelsCurrent);
    if (currentSizeIndex == -1) {
      // Current size not in options, find the closest smaller one
      int closestIndex = 0;
      for (int i = 0; i < sizeOptions.length; i++) {
        if (sizeOptions[i] <= unit.modelsCurrent) {
          closestIndex = i;
        }
      }
      if (closestIndex >= sizeOptions.length - 1) return null; // Already at max
    } else if (currentSizeIndex >= sizeOptions.length - 1) {
      return null; // Already at max size
    }

    // Get next size option
    final nextIndex = (currentSizeIndex == -1 ? 0 : currentSizeIndex) + 1;
    if (nextIndex >= sizeOptions.length) return null;

    return _EligibleUnit(
      unit: unit,
      newModels: sizeOptions[nextIndex],
      newPoints: pointsOptions[nextIndex],
      sizeOptions: sizeOptions,
      pointsOptions: pointsOptions,
    );
  }

  void _confirmFreshRecruits(
    BuildContext context,
    WidgetRef ref,
    Crusade crusade,
    _EligibleUnit eligible,
    int rpCost,
  ) {
    final pointsDiff = eligible.newPoints - eligible.unit.points;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Fresh Recruits'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unit: ${eligible.unit.customName ?? eligible.unit.name}'),
            const SizedBox(height: 8),
            Text('Models: ${eligible.unit.modelsCurrent} → ${eligible.newModels}'),
            Text('Points: ${eligible.unit.points} → ${eligible.newPoints} (+$pointsDiff)'),
            const SizedBox(height: 8),
            Text(
              'Cost: $rpCost RP',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFF59D),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Capture old values before updating
              final oldModels = eligible.unit.modelsCurrent;

              // Update the unit
              eligible.unit.modelsCurrent = eligible.newModels;
              eligible.unit.modelsMax = eligible.newModels;
              eligible.unit.points = eligible.newPoints;

              // Update crusade RP
              crusade.rp -= rpCost;
              crusade.lastModified = DateTime.now().millisecondsSinceEpoch;

              // Add history event
              crusade.addEvent(CrusadeEvent.create(
                type: CrusadeEventType.requisition,
                description: 'Fresh Recruits: ${eligible.unit.customName ?? eligible.unit.name} expanded to ${eligible.newModels} models',
                unitId: eligible.unit.id,
                unitName: eligible.unit.customName ?? eligible.unit.name,
                metadata: {
                  'requisition': 'fresh_recruits',
                  'rpCost': rpCost,
                  'oldModels': oldModels,
                  'newModels': eligible.newModels,
                  'pointsDiff': pointsDiff,
                },
              ));

              // Save
              ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(crusade);
              StorageService.saveCrusade(crusade);

              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context); // Close modal

              SnackBarUtils.showSuccess(
                context,
                '${eligible.unit.customName ?? eligible.unit.name} now has ${eligible.newModels} models!',
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // ============ REPAIR AND RECUPERATE ============

  bool _hasUnitsWithScars(Crusade crusade) {
    for (final item in crusade.oob) {
      if (item.type == 'group' && item.components != null) {
        for (final unit in item.components!) {
          if (unit.scars.isNotEmpty) return true;
        }
      } else if (item.scars.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  void _showRepairAndRecuperateModal(BuildContext context, WidgetRef ref, Crusade crusade) {
    // Gather all units with scars
    final List<UnitOrGroup> unitsWithScars = [];

    for (final item in crusade.oob) {
      if (item.type == 'group' && item.components != null) {
        for (final unit in item.components!) {
          if (unit.scars.isNotEmpty) {
            unitsWithScars.add(unit);
          }
        }
      } else if (item.scars.isNotEmpty) {
        unitsWithScars.add(item);
      }
    }

    if (unitsWithScars.isEmpty) {
      SnackBarUtils.showMessage(context, 'No units have Battle Scars to remove');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repair and Recuperate',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Select a unit to remove a Battle Scar',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Unit list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: unitsWithScars.length,
                itemBuilder: (context, index) {
                  final unit = unitsWithScars[index];
                  final rpCost = unit.scars.length; // Cost = number of scars
                  final canAfford = crusade.rp >= rpCost;

                  return ListTile(
                    enabled: canAfford,
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.healing, color: Colors.teal),
                    ),
                    title: Text(unit.customName ?? unit.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${unit.scars.length} Battle Scar${unit.scars.length > 1 ? 's' : ''}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        ...unit.scars.map((scar) => Text(
                          '• $scar',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        )),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: canAfford
                            ? const Color(0xFFFFF59D).withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: canAfford ? const Color(0xFFFFF59D) : Colors.grey,
                        ),
                      ),
                      child: Text(
                        '$rpCost RP',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: canAfford ? const Color(0xFFFFF59D) : Colors.grey,
                        ),
                      ),
                    ),
                    onTap: canAfford
                        ? () => _selectScarToRemove(context, ref, crusade, unit, rpCost)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectScarToRemove(
    BuildContext context,
    WidgetRef ref,
    Crusade crusade,
    UnitOrGroup unit,
    int rpCost,
  ) {
    // If only one scar, go directly to confirmation
    if (unit.scars.length == 1) {
      _confirmRepairAndRecuperate(context, ref, crusade, unit, unit.scars.first, rpCost);
      return;
    }

    // Show scar selection dialog
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Scar to Remove'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: unit.scars.map((scar) => ListTile(
            leading: const Icon(Icons.remove_circle, color: Colors.red),
            title: Text(scar),
            onTap: () {
              Navigator.pop(dialogContext);
              _confirmRepairAndRecuperate(context, ref, crusade, unit, scar, rpCost);
            },
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _confirmRepairAndRecuperate(
    BuildContext context,
    WidgetRef ref,
    Crusade crusade,
    UnitOrGroup unit,
    String scar,
    int rpCost,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Repair and Recuperate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unit: ${unit.customName ?? unit.name}'),
            const SizedBox(height: 8),
            Text('Remove: $scar'),
            const SizedBox(height: 8),
            Text(
              'Cost: $rpCost RP',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFF59D),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Remove the scar
              unit.scars.remove(scar);

              // Update crusade RP
              crusade.rp -= rpCost;
              crusade.lastModified = DateTime.now().millisecondsSinceEpoch;

              // Add history event
              crusade.addEvent(CrusadeEvent.create(
                type: CrusadeEventType.requisition,
                description: 'Repair and Recuperate: Removed "$scar" from ${unit.customName ?? unit.name}',
                unitId: unit.id,
                unitName: unit.customName ?? unit.name,
                metadata: {
                  'requisition': 'repair_and_recuperate',
                  'rpCost': rpCost,
                  'removedScar': scar,
                },
              ));

              // Save
              ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(crusade);
              StorageService.saveCrusade(crusade);

              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context); // Close modal

              SnackBarUtils.showSuccess(
                context,
                'Battle Scar removed from ${unit.customName ?? unit.name}!',
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // ============ RENOWNED HEROES ============

  bool _hasEligibleCharacters(Crusade crusade) {
    for (final item in crusade.oob) {
      if (item.type == 'group' && item.components != null) {
        for (final unit in item.components!) {
          if (_isEligibleForEnhancement(unit)) return true;
        }
      } else if (_isEligibleForEnhancement(item)) {
        return true;
      }
    }
    return false;
  }

  bool _isEligibleForEnhancement(UnitOrGroup unit) {
    // Must be a Character
    if (unit.isCharacter != true) return false;
    // Cannot be an Epic Hero
    if (unit.isEpicHero == true) return false;
    // Cannot already have an enhancement
    if (unit.enhancements.isNotEmpty) return false;
    // Cannot have Disgraced or Mark of Shame scars
    if (unit.scars.any((scar) =>
        scar.toLowerCase().contains('disgraced') ||
        scar.toLowerCase().contains('mark of shame'))) {
      return false;
    }
    return true;
  }

  void _showRenownedHeroesModal(BuildContext context, WidgetRef ref, Crusade crusade) {
    // Gather eligible characters
    final List<UnitOrGroup> eligibleCharacters = [];

    for (final item in crusade.oob) {
      if (item.type == 'group' && item.components != null) {
        for (final unit in item.components!) {
          if (_isEligibleForEnhancement(unit)) {
            eligibleCharacters.add(unit);
          }
        }
      } else if (_isEligibleForEnhancement(item)) {
        eligibleCharacters.add(item);
      }
    }

    if (eligibleCharacters.isEmpty) {
      SnackBarUtils.showMessage(
        context,
        'No eligible characters! Must be CHARACTER, not Epic Hero, no existing enhancement, and no Disgraced/Mark of Shame scars.',
      );
      return;
    }

    // Calculate RP cost based on how many characters already have enhancements
    int charactersWithEnhancements = 0;
    for (final item in crusade.oob) {
      if (item.type == 'group' && item.components != null) {
        for (final unit in item.components!) {
          if (unit.isCharacter == true && unit.enhancements.isNotEmpty) {
            charactersWithEnhancements++;
          }
        }
      } else if (item.isCharacter == true && item.enhancements.isNotEmpty) {
        charactersWithEnhancements++;
      }
    }

    // Cost: 1 RP for first, 2 RP for second, 3 RP for third+
    final rpCost = (charactersWithEnhancements + 1).clamp(1, 3);
    final canAfford = crusade.rp >= rpCost;

    if (!canAfford) {
      SnackBarUtils.showError(context, 'Not enough RP ($rpCost RP required)');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Renowned Heroes',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select a Character to grant an Enhancement ($rpCost RP)',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Character list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: eligibleCharacters.length,
                itemBuilder: (context, index) {
                  final unit = eligibleCharacters[index];

                  return ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.star, color: Colors.orange),
                    ),
                    title: Text(unit.customName ?? unit.name),
                    subtitle: Text(
                      '${unit.rank} • ${unit.xp} XP',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF59D).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFF59D)),
                      ),
                      child: Text(
                        '$rpCost RP',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFF59D),
                        ),
                      ),
                    ),
                    onTap: () => _selectEnhancement(context, ref, crusade, unit, rpCost),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectEnhancement(
    BuildContext context,
    WidgetRef ref,
    Crusade crusade,
    UnitOrGroup unit,
    int rpCost,
  ) {
    // Get enhancements for the current detachment
    final enhancements = ReferenceDataService.getEnhancements(crusade.faction, crusade.detachment);

    if (enhancements.isEmpty) {
      SnackBarUtils.showMessage(context, 'No enhancements available for ${crusade.detachment}');
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Enhancement'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: enhancements.length,
            itemBuilder: (context, index) {
              final enhancement = enhancements[index];
              final name = enhancement['name'] as String? ?? 'Unknown';
              final points = enhancement['points'] as int? ?? 0;

              return ListTile(
                title: Text(name),
                subtitle: Text('$points pts'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _confirmRenownedHeroes(context, ref, crusade, unit, name, points, rpCost);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _confirmRenownedHeroes(
    BuildContext context,
    WidgetRef ref,
    Crusade crusade,
    UnitOrGroup unit,
    String enhancementName,
    int enhancementPoints,
    int rpCost,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Renowned Heroes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unit: ${unit.customName ?? unit.name}'),
            const SizedBox(height: 8),
            Text('Enhancement: $enhancementName (+$enhancementPoints pts)'),
            const SizedBox(height: 8),
            Text(
              'Cost: $rpCost RP',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFF59D),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add enhancement to unit
              unit.enhancements.add(enhancementName);
              unit.points += enhancementPoints;

              // Update crusade RP
              crusade.rp -= rpCost;
              crusade.lastModified = DateTime.now().millisecondsSinceEpoch;

              // Add history event
              crusade.addEvent(CrusadeEvent.create(
                type: CrusadeEventType.enhancement,
                description: 'Renowned Heroes: ${unit.customName ?? unit.name} gained $enhancementName',
                unitId: unit.id,
                unitName: unit.customName ?? unit.name,
                metadata: {
                  'requisition': 'renowned_heroes',
                  'rpCost': rpCost,
                  'enhancement': enhancementName,
                  'enhancementPoints': enhancementPoints,
                },
              ));

              // Save
              ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(crusade);
              StorageService.saveCrusade(crusade);

              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context); // Close modal

              SnackBarUtils.showSuccess(
                context,
                '${unit.customName ?? unit.name} gained $enhancementName!',
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // ============ LEGENDARY VETERANS ============

  void _showLegendaryVeteransModal(BuildContext context, WidgetRef ref, Crusade crusade) {
    // Gather eligible units (non-Characters that could benefit from exceeding caps)
    // For now, show all non-Epic Hero units that aren't already legendary
    final List<UnitOrGroup> eligibleUnits = [];

    for (final item in crusade.oob) {
      if (item.type == 'group' && item.components != null) {
        for (final unit in item.components!) {
          if (unit.isEpicHero != true && unit.isCharacter != true) {
            eligibleUnits.add(unit);
          }
        }
      } else if (item.isEpicHero != true && item.isCharacter != true) {
        eligibleUnits.add(item);
      }
    }

    if (eligibleUnits.isEmpty) {
      SnackBarUtils.showMessage(context, 'No eligible units for Legendary Veterans');
      return;
    }

    const rpCost = 3;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Legendary Veterans',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Allow a unit to exceed 30 XP and 3 Honours',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Unit list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: eligibleUnits.length,
                itemBuilder: (context, index) {
                  final unit = eligibleUnits[index];
                  final canAfford = crusade.rp >= rpCost;

                  return ListTile(
                    enabled: canAfford,
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.deepPurple),
                    ),
                    title: Text(unit.customName ?? unit.name),
                    subtitle: Text(
                      '${unit.rank} • ${unit.xp} XP • ${unit.honours.length} Honours',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: canAfford
                            ? const Color(0xFFFFF59D).withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: canAfford ? const Color(0xFFFFF59D) : Colors.grey,
                        ),
                      ),
                      child: Text(
                        '$rpCost RP',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: canAfford ? const Color(0xFFFFF59D) : Colors.grey,
                        ),
                      ),
                    ),
                    onTap: canAfford
                        ? () => _confirmLegendaryVeterans(context, ref, crusade, unit, rpCost)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLegendaryVeterans(
    BuildContext context,
    WidgetRef ref,
    Crusade crusade,
    UnitOrGroup unit,
    int rpCost,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Legendary Veterans'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unit: ${unit.customName ?? unit.name}'),
            const SizedBox(height: 8),
            const Text('This unit can now exceed:'),
            const Text('• 30 XP cap'),
            const Text('• 3 Battle Honours limit'),
            const SizedBox(height: 8),
            Text(
              'Cost: $rpCost RP',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFF59D),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Note: We would need to add a flag to track legendary status
              // For now, just record the event and deduct RP

              // Update crusade RP
              crusade.rp -= rpCost;
              crusade.lastModified = DateTime.now().millisecondsSinceEpoch;

              // Add history event
              crusade.addEvent(CrusadeEvent.create(
                type: CrusadeEventType.requisition,
                description: 'Legendary Veterans: ${unit.customName ?? unit.name} can now exceed XP and Honours caps',
                unitId: unit.id,
                unitName: unit.customName ?? unit.name,
                metadata: {
                  'requisition': 'legendary_veterans',
                  'rpCost': rpCost,
                },
              ));

              // Save
              ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(crusade);
              StorageService.saveCrusade(crusade);

              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context); // Close modal

              SnackBarUtils.showSuccess(
                context,
                '${unit.customName ?? unit.name} is now a Legendary Veteran!',
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

/// Helper class for tracking eligible units for Fresh Recruits
class _EligibleUnit {
  final UnitOrGroup unit;
  final int newModels;
  final int newPoints;
  final List<int> sizeOptions;
  final List<int> pointsOptions;

  _EligibleUnit({
    required this.unit,
    required this.newModels,
    required this.newPoints,
    required this.sizeOptions,
    required this.pointsOptions,
  });
}

class _RequisitionOption extends StatelessWidget {
  final String title;
  final String description;
  final int cost;
  final String? costSuffix; // e.g., '+' for variable costs like "1+"
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _RequisitionOption({
    required this.title,
    required this.description,
    required this.cost,
    this.costSuffix,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 16),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Cost badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF59D).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFF59D)),
                  ),
                  child: Text(
                    '$cost${costSuffix ?? ''} RP',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFF59D),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
