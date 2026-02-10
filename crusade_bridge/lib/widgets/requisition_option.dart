import 'package:flutter/material.dart';

/// Reusable requisition card widget used by the main requisition screen
/// and faction-specific requisition files.
class RequisitionOption extends StatelessWidget {
  final String title;
  final String description;
  final int cost;
  final String? costSuffix; // e.g., '+' for variable costs like "1+"
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const RequisitionOption({
    super.key,
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
