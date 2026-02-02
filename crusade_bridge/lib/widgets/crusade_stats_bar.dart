import 'package:flutter/material.dart';

import '../models/crusade_models.dart';

/// Reusable stats bar widget for displaying Crusade Supply/CP/RP info
/// Use this widget consistently across dashboard, OOB, and other screens
class CrusadeStatsBar extends StatelessWidget {
  final Crusade crusade;
  final bool showProgress;
  final bool compact;

  const CrusadeStatsBar({
    super.key,
    required this.crusade,
    this.showProgress = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isOverLimit = crusade.remainingPoints < 0;
    final supplyProgress = (crusade.totalOobPoints / crusade.supplyLimit).clamp(0.0, 1.0);
    final rpProgress = (crusade.rp / 10).clamp(0.0, 1.0);

    if (compact) {
      return _buildCompact(context, isOverLimit);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: isOverLimit ? Colors.red : Theme.of(context).dividerColor,
            width: isOverLimit ? 2 : 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Supply section with progress
          Expanded(
            flex: 3,
            child: _StatColumn(
              label: 'Supply',
              value: '${crusade.totalOobPoints}/${crusade.supplyLimit}',
              valueColor: isOverLimit ? Colors.red : Colors.white,
              progress: showProgress ? supplyProgress : null,
              progressColor: isOverLimit ? Colors.red : const Color(0xFFFFB6C1),
              warning: isOverLimit ? 'Over limit!' : null,
            ),
          ),
          const SizedBox(width: 12),
          // Remaining points
          Expanded(
            flex: 2,
            child: _StatColumn(
              label: 'Remaining',
              value: '${crusade.remainingPoints}',
              valueColor: isOverLimit
                  ? Colors.red
                  : crusade.remainingPoints < 100
                      ? Colors.orange
                      : const Color(0xFFFFB6C1),
            ),
          ),
          const SizedBox(width: 12),
          // CP section
          Expanded(
            flex: 2,
            child: _StatColumn(
              label: 'Total CP',
              value: '${crusade.totalCrusadePoints}',
              valueColor: const Color(0xFF90CAF9),
            ),
          ),
          const SizedBox(width: 12),
          // RP section with progress to cap
          Expanded(
            flex: 2,
            child: _StatColumn(
              label: 'RP',
              value: '${crusade.rp}/10',
              valueColor: crusade.rp >= 10
                  ? Colors.green
                  : const Color(0xFFFFF59D),
              progress: showProgress ? rpProgress : null,
              progressColor: crusade.rp >= 10 ? Colors.green : const Color(0xFFFFF59D),
              warning: crusade.rp >= 10 ? 'At cap' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompact(BuildContext context, bool isOverLimit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOverLimit ? Colors.red : Colors.transparent,
          width: isOverLimit ? 2 : 0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CompactStat(
            icon: Icons.inventory_2,
            value: '${crusade.totalOobPoints}/${crusade.supplyLimit}',
            color: isOverLimit ? Colors.red : const Color(0xFFFFB6C1),
            tooltip: 'Supply Used / Limit',
          ),
          _CompactStat(
            icon: Icons.military_tech,
            value: '${crusade.totalCrusadePoints} CP',
            color: const Color(0xFF90CAF9),
            tooltip: 'Total Crusade Points',
          ),
          _CompactStat(
            icon: Icons.stars,
            value: '${crusade.rp} RP',
            color: crusade.rp >= 10 ? Colors.green : const Color(0xFFFFF59D),
            tooltip: 'Requisition Points (max 10)',
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final double? progress;
  final Color? progressColor;
  final String? warning;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.valueColor,
    this.progress,
    this.progressColor,
    this.warning,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        if (progress != null) ...[
          const SizedBox(height: 4),
          SizedBox(
            height: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress!,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor ?? valueColor),
              ),
            ),
          ),
        ],
        if (warning != null) ...[
          const SizedBox(height: 2),
          Text(
            warning!,
            style: TextStyle(
              fontSize: 9,
              color: valueColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _CompactStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final String tooltip;

  const _CompactStat({
    required this.icon,
    required this.value,
    required this.color,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
