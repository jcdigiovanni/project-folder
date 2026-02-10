import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/crusade_models.dart';
import '../../providers/crusade_provider.dart';
import '../../utils/snackbar_utils.dart';
import '../../widgets/requisition_option.dart';
import 'requisition_utils.dart';

/// Builds the Adepta Sororitas faction-specific requisitions section.
/// Returns a list of widgets to be spread into the requisition screen's ListView.
List<Widget> buildSororitasRequisitions(BuildContext context, WidgetRef ref, Crusade crusade) {
  return [
    const SizedBox(height: 24),
    Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Sororitas Requisitions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    ),
    const SizedBox(height: 12),

    // FEA-001: Divine Calling (1 RP)
    RequisitionOption(
      title: 'Divine Calling',
      description: 'SAINT POTENTIA abandons Trial, starts new one with half Saint points (rounded up)',
      cost: 1,
      icon: Icons.auto_awesome,
      color: Colors.amber,
      enabled: crusade.rp >= 1 && _hasUnitsWithSaintPoints(crusade),
      onTap: () => _showDivineCallingModal(context, ref, crusade),
    ),
    const SizedBox(height: 12),

    // FEA-002: Ascension to the Order (2 RP)
    RequisitionOption(
      title: 'Ascension to the Order',
      description: 'Upgrade Novitiates Squad (Blooded+) to Battle Sisters, Dominion, or Retributor Squad',
      cost: 2,
      icon: Icons.upgrade,
      color: Colors.lightGreen,
      enabled: crusade.rp >= 2 && _hasEligibleNovitiates(crusade),
      onTap: () => _showAscensionModal(context, ref, crusade),
    ),
    const SizedBox(height: 12),

    // FEA-003: The Penitent Path (2 RP)
    RequisitionOption(
      title: 'The Penitent Path',
      description: 'Convert scarred squad to Repentia or Mortifiers (Devastating Blow required)',
      cost: 2,
      icon: Icons.directions_walk,
      color: Colors.deepOrange,
      enabled: crusade.rp >= 2 && _hasEligiblePenitentUnits(crusade),
      onTap: () => _showPenitentPathModal(context, ref, crusade),
    ),
    const SizedBox(height: 12),

    // FEA-004: Glorious Redemption (1 RP)
    RequisitionOption(
      title: 'Glorious Redemption',
      description: 'Upgrade Repentia Squad with 3+ Redemption points to elite squad',
      cost: 1,
      icon: Icons.military_tech,
      color: const Color(0xFFFFD700),
      enabled: crusade.rp >= 1 && _hasEligibleRedemptionUnits(crusade),
      onTap: () => _showGloriousRedemptionModal(context, ref, crusade),
    ),
    const SizedBox(height: 12),

    // FEA-005: In Suffering, Enlightenment (1 RP)
    RequisitionOption(
      title: 'In Suffering, Enlightenment',
      description: 'Auto-fail OOA test: gain 1 Battle Scar + 1 Battle Honour (once per unit)',
      cost: 1,
      icon: Icons.local_fire_department,
      color: Colors.red,
      enabled: crusade.rp >= 1 && _hasEligibleSufferingUnits(crusade),
      onTap: () => _showInSufferingModal(context, ref, crusade),
    ),
    const SizedBox(height: 12),

    // FEA-006: Saintly Benedictions (1 RP)
    RequisitionOption(
      title: 'Saintly Benedictions',
      description: 'Miracle dice auto-6 in first battle round (honor system)',
      cost: 1,
      icon: Icons.casino,
      color: Colors.lightBlue,
      enabled: crusade.rp >= 1,
      onTap: () => _showSaintlyBenedictions(context, ref, crusade),
    ),
  ];
}

// ── Eligibility checks ───────────────────────────────────────

bool _hasUnitsWithSaintPoints(Crusade crusade) {
  return flattenOobUnits(crusade).any((u) => u.factionPoints1 > 0);
}

bool _hasEligibleNovitiates(Crusade crusade) {
  return flattenOobUnits(crusade).any((u) =>
      u.name.toLowerCase().contains('novitiates') && u.xp >= 6);
}

bool _hasEligiblePenitentUnits(Crusade crusade) {
  final units = flattenOobUnits(crusade);
  // Path A: Battle Sisters/Dominion/Retributor with scars
  final pathA = units.any((u) =>
      _isPenitentPathAEligible(u));
  // Path B: Repentia with scars
  final pathB = units.any((u) =>
      u.name.toLowerCase().contains('repentia') && u.scars.isNotEmpty);
  return pathA || pathB;
}

bool _isPenitentPathAEligible(UnitOrGroup u) {
  final name = u.name.toLowerCase();
  return (name.contains('battle sisters squad') ||
      name.contains('dominion squad') ||
      name.contains('retributor squad')) &&
      u.scars.isNotEmpty;
}

bool _hasEligibleRedemptionUnits(Crusade crusade) {
  return flattenOobUnits(crusade).any((u) =>
      u.name.toLowerCase().contains('repentia') && u.factionPoints3 >= 3);
}

bool _hasEligibleSufferingUnits(Crusade crusade) {
  return flattenOobUnits(crusade).any((u) => !u.factionFlag1);
}

// ── FEA-001: Divine Calling ──────────────────────────────────

void _showDivineCallingModal(BuildContext context, WidgetRef ref, Crusade crusade) {
  final eligible = flattenOobUnits(crusade)
      .where((u) => u.factionPoints1 > 0)
      .toList();

  if (eligible.isEmpty) {
    SnackBarUtils.showMessage(context, 'No units with Saint points to abandon a Trial');
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
          _buildModalHeader(
            'Divine Calling',
            'Select SAINT POTENTIA model to abandon Trial (1 RP)',
            context,
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: eligible.length,
              itemBuilder: (context, index) {
                final unit = eligible[index];
                final halfPoints = (unit.factionPoints1 / 2).ceil();
                return ListTile(
                  leading: _buildUnitIcon(Icons.auto_awesome, Colors.amber),
                  title: Text(unit.customName ?? unit.name),
                  subtitle: Text(
                    'Saint Points: ${unit.factionPoints1} → $halfPoints (new Trial)',
                    style: const TextStyle(color: Colors.amber),
                  ),
                  trailing: _buildRpBadge(1),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDivineCalling(context, ref, crusade, unit);
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _confirmDivineCalling(BuildContext context, WidgetRef ref, Crusade crusade, UnitOrGroup unit) {
  final oldPoints = unit.factionPoints1;
  final newPoints = (oldPoints / 2).ceil();
  final unitName = unit.customName ?? unit.name;

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Divine Calling'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Unit: $unitName'),
          const SizedBox(height: 8),
          const Text('Abandon current Trial and start a new one.'),
          const SizedBox(height: 4),
          Text('Current Saint Points: $oldPoints'),
          Text('New Trial starts with: $newPoints Saint Points (half, rounded up)'),
          const SizedBox(height: 8),
          const Text(
            'Cost: 1 RP',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFF59D)),
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
            unit.factionPoints1 = newPoints;

            crusade.rp -= 1;
            crusade.lastModified = DateTime.now().millisecondsSinceEpoch;
            ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(crusade);
            ref.read(currentCrusadeNotifierProvider.notifier).addEvent(CrusadeEvent.create(
              type: CrusadeEventType.requisition,
              description: 'Divine Calling: $unitName abandoned Trial ($oldPoints → $newPoints Saint Points)',
              unitId: unit.id,
              unitName: unitName,
              metadata: {
                'requisition': 'divine_calling',
                'rpCost': 1,
                'oldSaintPoints': oldPoints,
                'newSaintPoints': newPoints,
              },
            ));

            Navigator.pop(dialogContext);
            SnackBarUtils.showSuccess(context, 'Divine Calling: $unitName starts new Trial with $newPoints Saint Points');
          },
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}

// ── FEA-002: Ascension to the Order ──────────────────────────

const _ascensionTargets = ['Battle Sisters Squad', 'Dominion Squad', 'Retributor Squad'];

void _showAscensionModal(BuildContext context, WidgetRef ref, Crusade crusade) {
  final eligible = flattenOobUnits(crusade)
      .where((u) => u.name.toLowerCase().contains('novitiates') && u.xp >= 6)
      .toList();

  if (eligible.isEmpty) {
    SnackBarUtils.showMessage(context, 'No eligible Sisters Novitiates Squad (must be Blooded rank or higher)');
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
          _buildModalHeader(
            'Ascension to the Order',
            'Select Novitiates Squad to upgrade (2 RP)',
            context,
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: eligible.length,
              itemBuilder: (context, index) {
                final unit = eligible[index];
                return ListTile(
                  leading: _buildUnitIcon(Icons.upgrade, Colors.lightGreen),
                  title: Text(unit.customName ?? unit.name),
                  subtitle: Text(
                    '${unit.rank} • ${unit.xp} XP → ${unit.xp + 5} XP after upgrade',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: _buildRpBadge(2),
                  onTap: () {
                    Navigator.pop(context);
                    _selectAscensionTarget(context, ref, crusade, unit);
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _selectAscensionTarget(BuildContext context, WidgetRef ref, Crusade crusade, UnitOrGroup unit) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Select New Squad Type'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _ascensionTargets.map((target) => ListTile(
          leading: const Icon(Icons.shield, color: Colors.lightGreen),
          title: Text(target),
          onTap: () {
            Navigator.pop(dialogContext);
            _confirmAscension(context, ref, crusade, unit, target);
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

void _confirmAscension(BuildContext context, WidgetRef ref, Crusade crusade, UnitOrGroup unit, String newSquadType) {
  final unitName = unit.customName ?? unit.name;

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Confirm Ascension to the Order'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Unit: $unitName'),
          Text('Upgrade to: $newSquadType'),
          const SizedBox(height: 8),
          Text('XP: ${unit.xp} → ${unit.xp + 5} (+5 XP)'),
          if (unit.honours.isNotEmpty) Text('Honours transferred: ${unit.honours.length}'),
          if (unit.scars.isNotEmpty) Text('Scars transferred: ${unit.scars.length}'),
          const SizedBox(height: 8),
          const Text(
            'Cost: 2 RP',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFF59D)),
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
            final newUnit = UnitOrGroup(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              type: 'unit',
              name: newSquadType,
              customName: unit.customName,
              points: unit.points,
              modelsCurrent: unit.modelsCurrent,
              modelsMax: unit.modelsMax,
              xp: unit.xp + 5,
              honours: List<String>.from(unit.honours),
              scars: List<String>.from(unit.scars),
              crusadePoints: unit.crusadePoints,
              tallies: Map<String, int>.from(unit.tallies),
              battleTraits: List<String>.from(unit.battleTraits),
              weaponEnhancements: List<String>.from(unit.weaponEnhancements),
              crusadeRelic: unit.crusadeRelic,
              pendingRankUp: unit.pendingRankUp,
              isCharacter: unit.isCharacter,
              isWarlord: unit.isWarlord,
              isEpicHero: unit.isEpicHero,
              enhancements: List<String>.from(unit.enhancements),
              notes: unit.notes,
            );

            ref.read(currentCrusadeNotifierProvider.notifier).replaceUnit(unit.id, newUnit);

            crusade.rp -= 2;
            crusade.lastModified = DateTime.now().millisecondsSinceEpoch;
            ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(crusade);
            ref.read(currentCrusadeNotifierProvider.notifier).addEvent(CrusadeEvent.create(
              type: CrusadeEventType.requisition,
              description: 'Ascension to the Order: $unitName upgraded to $newSquadType (+5 XP)',
              unitId: newUnit.id,
              unitName: unitName,
              metadata: {
                'requisition': 'ascension_to_the_order',
                'rpCost': 2,
                'oldUnitName': unit.name,
                'newUnitName': newSquadType,
                'xpGained': 5,
              },
            ));

            Navigator.pop(dialogContext);
            SnackBarUtils.showSuccess(context, '$unitName ascended to $newSquadType!');
          },
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}

// ── FEA-003: The Penitent Path ───────────────────────────────

void _showPenitentPathModal(BuildContext context, WidgetRef ref, Crusade crusade) {
  final units = flattenOobUnits(crusade);

  // Build eligible units with their upgrade path
  final List<_PenitentCandidate> candidates = [];

  for (final u in units) {
    if (_isPenitentPathAEligible(u)) {
      candidates.add(_PenitentCandidate(unit: u, upgradeTo: 'Repentia Squad'));
    }
    if (u.name.toLowerCase().contains('repentia') && u.scars.isNotEmpty) {
      candidates.add(_PenitentCandidate(unit: u, upgradeTo: 'Mortifiers'));
    }
  }

  if (candidates.isEmpty) {
    SnackBarUtils.showMessage(context, 'No eligible units (must have suffered Devastating Blow / have Battle Scars)');
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
          _buildModalHeader(
            'The Penitent Path',
            'Select squad with Devastating Blow to convert (2 RP)',
            context,
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: candidates.length,
              itemBuilder: (context, index) {
                final candidate = candidates[index];
                final unit = candidate.unit;
                return ListTile(
                  leading: _buildUnitIcon(Icons.directions_walk, Colors.deepOrange),
                  title: Text(unit.customName ?? unit.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('→ ${candidate.upgradeTo}',
                        style: const TextStyle(color: Colors.deepOrange)),
                      Text('${unit.scars.length} scar${unit.scars.length > 1 ? 's' : ''} • Gains 2XP Dealers of Death bonus',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                  trailing: _buildRpBadge(2),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmPenitentPath(context, ref, crusade, unit, candidate.upgradeTo);
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _confirmPenitentPath(BuildContext context, WidgetRef ref, Crusade crusade, UnitOrGroup unit, String newSquadType) {
  final unitName = unit.customName ?? unit.name;

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Confirm The Penitent Path'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Unit: $unitName'),
          Text('Convert to: $newSquadType'),
          const SizedBox(height: 8),
          const Text('Transfers all Honours, Scars, and XP'),
          const Text('Gains 2XP from Dealers of Death (instead of 1)',
            style: TextStyle(color: Colors.deepOrange)),
          const SizedBox(height: 8),
          const Text(
            'Cost: 2 RP',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFF59D)),
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
            final newUnit = UnitOrGroup(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              type: 'unit',
              name: newSquadType,
              customName: unit.customName,
              points: unit.points,
              modelsCurrent: unit.modelsCurrent,
              modelsMax: unit.modelsMax,
              xp: unit.xp,
              honours: List<String>.from(unit.honours),
              scars: List<String>.from(unit.scars),
              crusadePoints: unit.crusadePoints,
              tallies: Map<String, int>.from(unit.tallies),
              battleTraits: List<String>.from(unit.battleTraits),
              weaponEnhancements: List<String>.from(unit.weaponEnhancements),
              crusadeRelic: unit.crusadeRelic,
              pendingRankUp: unit.pendingRankUp,
              isCharacter: unit.isCharacter,
              isWarlord: unit.isWarlord,
              isEpicHero: unit.isEpicHero,
              enhancements: List<String>.from(unit.enhancements),
              notes: unit.notes,
              factionFlag2: true, // Dealers of Death bonus
            );

            ref.read(currentCrusadeNotifierProvider.notifier).replaceUnit(unit.id, newUnit);

            crusade.rp -= 2;
            crusade.lastModified = DateTime.now().millisecondsSinceEpoch;
            ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(crusade);
            ref.read(currentCrusadeNotifierProvider.notifier).addEvent(CrusadeEvent.create(
              type: CrusadeEventType.requisition,
              description: 'The Penitent Path: $unitName converted to $newSquadType (Dealers of Death 2XP)',
              unitId: newUnit.id,
              unitName: unitName,
              metadata: {
                'requisition': 'the_penitent_path',
                'rpCost': 2,
                'oldUnitName': unit.name,
                'newUnitName': newSquadType,
                'dealersOfDeathBonus': true,
              },
            ));

            Navigator.pop(dialogContext);
            SnackBarUtils.showSuccess(context, '$unitName converted to $newSquadType!');
          },
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}

// ── FEA-004: Glorious Redemption ─────────────────────────────

const _redemptionTargets = ['Seraphim Squad', 'Zephyrim Squad', 'Celestian Sacresants', 'Paragon Warsuits'];

void _showGloriousRedemptionModal(BuildContext context, WidgetRef ref, Crusade crusade) {
  final eligible = flattenOobUnits(crusade)
      .where((u) => u.name.toLowerCase().contains('repentia') && u.factionPoints3 >= 3)
      .toList();

  if (eligible.isEmpty) {
    SnackBarUtils.showMessage(context, 'No Repentia Squad with 3+ Redemption points');
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
          _buildModalHeader(
            'Glorious Redemption',
            'Select Repentia Squad with 3+ Redemption points (1 RP)',
            context,
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: eligible.length,
              itemBuilder: (context, index) {
                final unit = eligible[index];
                return ListTile(
                  leading: _buildUnitIcon(Icons.military_tech, const Color(0xFFFFD700)),
                  title: Text(unit.customName ?? unit.name),
                  subtitle: Text(
                    'Redemption Points: ${unit.factionPoints3} • ${unit.rank}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: _buildRpBadge(1),
                  onTap: () {
                    Navigator.pop(context);
                    _selectRedemptionTarget(context, ref, crusade, unit);
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _selectRedemptionTarget(BuildContext context, WidgetRef ref, Crusade crusade, UnitOrGroup unit) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Select New Squad Type'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _redemptionTargets.map((target) => ListTile(
          leading: const Icon(Icons.military_tech, color: Color(0xFFFFD700)),
          title: Text(target),
          onTap: () {
            Navigator.pop(dialogContext);
            _enterBattleTrait(context, ref, crusade, unit, target);
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

void _enterBattleTrait(BuildContext context, WidgetRef ref, Crusade crusade, UnitOrGroup unit, String newSquadType) {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Bonus Battle Trait'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('This unit gains 1 extra Battle Trait (does not count toward the maximum).'),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Battle Trait name',
              hintText: 'Enter the Battle Trait',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            autofocus: true,
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
            final trait = controller.text.trim();
            if (trait.isEmpty) {
              SnackBarUtils.showError(dialogContext, 'Please enter a Battle Trait name');
              return;
            }
            Navigator.pop(dialogContext);
            _confirmGloriousRedemption(context, ref, crusade, unit, newSquadType, trait);
          },
          child: const Text('Continue'),
        ),
      ],
    ),
  );
}

void _confirmGloriousRedemption(
  BuildContext context, WidgetRef ref, Crusade crusade,
  UnitOrGroup unit, String newSquadType, String bonusTrait,
) {
  final unitName = unit.customName ?? unit.name;

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Confirm Glorious Redemption'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Unit: $unitName'),
          Text('Upgrade to: $newSquadType'),
          const SizedBox(height: 8),
          const Text('Transfers all Honours and Scars'),
          Text('Bonus Battle Trait: $bonusTrait'),
          const Text('Note: Legendary Veterans costs only 1 RP for this unit',
            style: TextStyle(color: Color(0xFFFFD700), fontSize: 12)),
          const SizedBox(height: 8),
          const Text(
            'Cost: 1 RP',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFF59D)),
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
            final newTraits = List<String>.from(unit.battleTraits)..add(bonusTrait);

            final newUnit = UnitOrGroup(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              type: 'unit',
              name: newSquadType,
              customName: unit.customName,
              points: unit.points,
              modelsCurrent: unit.modelsCurrent,
              modelsMax: unit.modelsMax,
              xp: unit.xp,
              honours: List<String>.from(unit.honours),
              scars: List<String>.from(unit.scars),
              crusadePoints: unit.crusadePoints,
              tallies: Map<String, int>.from(unit.tallies),
              battleTraits: newTraits,
              weaponEnhancements: List<String>.from(unit.weaponEnhancements),
              crusadeRelic: unit.crusadeRelic,
              pendingRankUp: unit.pendingRankUp,
              isCharacter: unit.isCharacter,
              isWarlord: unit.isWarlord,
              isEpicHero: unit.isEpicHero,
              enhancements: List<String>.from(unit.enhancements),
              notes: unit.notes,
            );

            ref.read(currentCrusadeNotifierProvider.notifier).replaceUnit(unit.id, newUnit);

            crusade.rp -= 1;
            crusade.lastModified = DateTime.now().millisecondsSinceEpoch;
            ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(crusade);
            ref.read(currentCrusadeNotifierProvider.notifier).addEvent(CrusadeEvent.create(
              type: CrusadeEventType.requisition,
              description: 'Glorious Redemption: $unitName upgraded to $newSquadType with bonus trait "$bonusTrait"',
              unitId: newUnit.id,
              unitName: unitName,
              metadata: {
                'requisition': 'glorious_redemption',
                'rpCost': 1,
                'oldUnitName': unit.name,
                'newUnitName': newSquadType,
                'bonusBattleTrait': bonusTrait,
                'legendaryVeteransDiscount': true,
              },
            ));

            Navigator.pop(dialogContext);
            SnackBarUtils.showSuccess(context, '$unitName redeemed as $newSquadType!');
          },
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}

// ── FEA-005: In Suffering, Enlightenment ─────────────────────

void _showInSufferingModal(BuildContext context, WidgetRef ref, Crusade crusade) {
  final eligible = flattenOobUnits(crusade)
      .where((u) => !u.factionFlag1)
      .toList();

  if (eligible.isEmpty) {
    SnackBarUtils.showMessage(context, 'All units have already used In Suffering, Enlightenment');
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
          _buildModalHeader(
            'In Suffering, Enlightenment',
            'Select unit to auto-fail OOA test (1 RP, once per unit)',
            context,
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: eligible.length,
              itemBuilder: (context, index) {
                final unit = eligible[index];
                return ListTile(
                  leading: _buildUnitIcon(Icons.local_fire_department, Colors.red),
                  title: Text(unit.customName ?? unit.name),
                  subtitle: Text(
                    '${unit.rank} • ${unit.xp} XP',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: _buildRpBadge(1),
                  onTap: () {
                    Navigator.pop(context);
                    _showInSufferingForm(context, ref, crusade, unit);
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showInSufferingForm(BuildContext context, WidgetRef ref, Crusade crusade, UnitOrGroup unit) {
  final scarController = TextEditingController();
  final honourController = TextEditingController();
  bool isSaintPotentia = false;

  showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: const Text('In Suffering, Enlightenment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Unit: ${unit.customName ?? unit.name}'),
              const SizedBox(height: 4),
              const Text('OOA test auto-failed. Unit gains:',
                style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              TextField(
                controller: scarController,
                decoration: const InputDecoration(
                  labelText: 'Battle Scar gained',
                  hintText: 'Enter Battle Scar name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: honourController,
                decoration: const InputDecoration(
                  labelText: 'Battle Honour gained',
                  hintText: 'Enter Battle Honour name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('SAINT POTENTIA unit'),
                subtitle: const Text('+3 Saint Points, +1 Martyr Point',
                  style: TextStyle(fontSize: 12)),
                value: isSaintPotentia,
                onChanged: (v) => setState(() => isSaintPotentia = v ?? false),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cost: 1 RP',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFF59D)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final scar = scarController.text.trim();
              final honour = honourController.text.trim();
              if (scar.isEmpty || honour.isEmpty) {
                SnackBarUtils.showError(dialogContext, 'Please enter both a Battle Scar and Battle Honour');
                return;
              }

              unit.scars.add(scar);
              unit.honours.add(honour);
              // Scar -1 CP, Honour +1 CP = net 0
              unit.factionFlag1 = true; // Mark as used
              if (isSaintPotentia) {
                unit.factionPoints1 += 3;
                unit.factionPoints2 += 1;
              }

              crusade.rp -= 1;
              crusade.lastModified = DateTime.now().millisecondsSinceEpoch;
              ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(crusade);

              final unitName = unit.customName ?? unit.name;
              var desc = 'In Suffering, Enlightenment: $unitName gained scar "$scar" and honour "$honour"';
              if (isSaintPotentia) desc += ' (+3 Saint, +1 Martyr)';

              ref.read(currentCrusadeNotifierProvider.notifier).addEvent(CrusadeEvent.create(
                type: CrusadeEventType.requisition,
                description: desc,
                unitId: unit.id,
                unitName: unitName,
                metadata: {
                  'requisition': 'in_suffering_enlightenment',
                  'rpCost': 1,
                  'battleScar': scar,
                  'battleHonour': honour,
                  'isSaintPotentia': isSaintPotentia,
                },
              ));

              Navigator.pop(dialogContext);
              SnackBarUtils.showSuccess(context, '$unitName: gained "$scar" and "$honour"');
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    ),
  );
}

// ── FEA-006: Saintly Benedictions ────────────────────────────

void _showSaintlyBenedictions(BuildContext context, WidgetRef ref, Crusade crusade) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Saintly Benedictions'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spend 1 RP before a battle.'),
          SizedBox(height: 8),
          Text('During the first battle round, each Miracle dice you gain at the start of each player\'s turn is automatically a 6.'),
          SizedBox(height: 8),
          Text('Track this on the tabletop.',
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          SizedBox(height: 8),
          Text(
            'Cost: 1 RP',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFF59D)),
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
            final event = CrusadeEvent.create(
              type: CrusadeEventType.requisition,
              description: 'Saintly Benedictions: Miracle dice auto-6 for first battle round',
              metadata: {
                'requisition': 'saintly_benedictions',
                'rpCost': 1,
              },
            );

            final updatedCrusade = Crusade(
              id: crusade.id,
              name: crusade.name,
              faction: crusade.faction,
              detachment: crusade.detachment,
              supplyLimit: crusade.supplyLimit,
              rp: crusade.rp - 1,
              armyIconPath: crusade.armyIconPath,
              factionIconAsset: crusade.factionIconAsset,
              oob: crusade.oob,
              templates: crusade.templates,
              lastModified: DateTime.now().millisecondsSinceEpoch,
              usedFirstCharacterEnhancement: crusade.usedFirstCharacterEnhancement,
              history: [...crusade.history, event],
              rosters: crusade.rosters,
              games: crusade.games,
            );

            ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(updatedCrusade);

            Navigator.pop(dialogContext);
            SnackBarUtils.showSuccess(context, 'Saintly Benedictions activated! (-1 RP)');
          },
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}

// ── Shared UI helpers ────────────────────────────────────────

Widget _buildModalHeader(String title, String subtitle, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Close',
        ),
      ],
    ),
  );
}

Widget _buildUnitIcon(IconData icon, Color color) {
  return Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(icon, color: color),
  );
}

Widget _buildRpBadge(int cost) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF59D).withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFFFF59D)),
    ),
    child: Text(
      '$cost RP',
      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFF59D)),
    ),
  );
}

// ── Helper classes ───────────────────────────────────────────

class _PenitentCandidate {
  final UnitOrGroup unit;
  final String upgradeTo;
  _PenitentCandidate({required this.unit, required this.upgradeTo});
}
