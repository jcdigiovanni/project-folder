import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/crusade_models.dart';
import '../../providers/crusade_provider.dart';
import '../../utils/snackbar_utils.dart';

/// Generic honor-system requisition flow: unit picker → confirm → deduct RP → log event.
/// Reusable across factions for simple "pick unit, spend RP" requisitions.
void showHonorSystemRequisitionModal({
  required BuildContext context,
  required WidgetRef ref,
  required Crusade crusade,
  required String title,
  required String subtitle,
  required String confirmTitle,
  required String Function(String unitDisplayName) confirmMessage,
  required String Function(String unitDisplayName) successMessage,
  required String Function(String unitDisplayName) eventDescription,
  required String requisitionKey,
  required int rpCost,
  required IconData icon,
  required Color color,
}) {
  final List<UnitOrGroup> allUnits = [];
  for (final item in crusade.oob) {
    if (item.type == 'group' && item.components != null) {
      allUnits.addAll(item.components!);
    } else {
      allUnits.add(item);
    }
  }

  if (allUnits.isEmpty) {
    SnackBarUtils.showMessage(context, 'No units in Order of Battle');
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
          Padding(
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
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: allUnits.length,
              itemBuilder: (context, index) {
                final unit = allUnits[index];
                return ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  title: Text(unit.customName ?? unit.name),
                  subtitle: Text(unit.name),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF59D).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFF59D)),
                    ),
                    child: Text(
                      '$rpCost RP',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFF59D)),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    confirmHonorSystemRequisition(
                      context: context,
                      ref: ref,
                      crusade: crusade,
                      unit: unit,
                      confirmTitle: confirmTitle,
                      confirmMessage: confirmMessage(unit.customName ?? unit.name),
                      successMessage: successMessage(unit.customName ?? unit.name),
                      eventDescription: eventDescription(unit.customName ?? unit.name),
                      requisitionKey: requisitionKey,
                      rpCost: rpCost,
                    );
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

/// Confirmation dialog for honor-system requisitions: deduct RP, log CrusadeEvent, save.
void confirmHonorSystemRequisition({
  required BuildContext context,
  required WidgetRef ref,
  required Crusade crusade,
  required UnitOrGroup unit,
  required String confirmTitle,
  required String confirmMessage,
  required String successMessage,
  required String eventDescription,
  required String requisitionKey,
  required int rpCost,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(confirmTitle),
      content: Text(confirmMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final event = CrusadeEvent.create(
              type: CrusadeEventType.requisition,
              description: eventDescription,
              metadata: {
                'requisition': requisitionKey,
                'rpCost': rpCost,
                'unitName': unit.name,
                'unitCustomName': unit.customName,
              },
            );

            final updatedCrusade = Crusade(
              id: crusade.id,
              name: crusade.name,
              faction: crusade.faction,
              detachment: crusade.detachment,
              supplyLimit: crusade.supplyLimit,
              rp: crusade.rp - rpCost,
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

            Navigator.pop(context);
            SnackBarUtils.showSuccess(context, successMessage);
          },
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}

/// Helper to flatten all units from OOB (including group components).
List<UnitOrGroup> flattenOobUnits(Crusade crusade) {
  final List<UnitOrGroup> allUnits = [];
  for (final item in crusade.oob) {
    if (item.type == 'group' && item.components != null) {
      allUnits.addAll(item.components!);
    } else {
      allUnits.add(item);
    }
  }
  return allUnits;
}
