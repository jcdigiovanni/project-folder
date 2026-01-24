import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crusade_models.dart';
import '../providers/crusade_provider.dart';
import '../services/storage_service.dart';
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
          // RP Summary Banner
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available RP',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${currentCrusade.rp} RP',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFF59D),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Supply Limit',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${currentCrusade.supplyLimit} pts',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFB6C1),
                      ),
                    ),
                  ],
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
                  description: 'Add a new unit to your Order of Battle',
                  cost: 1,
                  icon: Icons.person_add,
                  color: Colors.green,
                  enabled: false, // Coming soon
                  onTap: () {
                    SnackBarUtils.showMessage(context, 'Coming soon');
                  },
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
                  description: 'Restore lost models to a unit',
                  cost: 1,
                  icon: Icons.healing,
                  color: Colors.purple,
                  enabled: false, // Coming soon
                  onTap: () {
                    SnackBarUtils.showMessage(context, 'Coming soon');
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
}

class _RequisitionOption extends StatelessWidget {
  final String title;
  final String description;
  final int cost;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _RequisitionOption({
    required this.title,
    required this.description,
    required this.cost,
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
                    '$cost RP',
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
