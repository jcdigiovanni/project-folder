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
                    color: color.withOpacity(0.2),
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
                    color: const Color(0xFFFFF59D).withOpacity(0.2),
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
