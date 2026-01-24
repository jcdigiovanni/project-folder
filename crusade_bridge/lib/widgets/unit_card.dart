import 'package:flutter/material.dart';

import '../models/crusade_models.dart';

class UnitCard extends StatelessWidget {
  final UnitOrGroup unitOrGroup;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UnitCard({
    required this.unitOrGroup,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Row(
        children: [
          if (unitOrGroup.isWarlord == true) const Icon(Icons.star, color: Colors.yellow, size: 20),
          if (unitOrGroup.isEpicHero == true) const Icon(Icons.warning, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(unitOrGroup.customName ?? unitOrGroup.name)),
          Text('${unitOrGroup.points} pts'),
        ],
      ),
      subtitle: Text('${unitOrGroup.modelsCurrent}/${unitOrGroup.modelsMax} models'),
      children: [
        if (unitOrGroup.components != null)
          ...unitOrGroup.components!.map((comp) => ListTile(
                title: Text(comp.name),
                subtitle: Text('${comp.points} pts - ${comp.modelsCurrent}/${comp.modelsMax}'),
              )),
        ListTile(
          title: const Text('Edit'),
          onTap: onEdit,
        ),
        ListTile(
          title: const Text('Delete', style: TextStyle(color: Colors.red)),
          onTap: onDelete,
        ),
      ],
    );
  }
}