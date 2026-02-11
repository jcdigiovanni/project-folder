import '../common.dart';

/// Progress bar showing tally progress with optional milestone markers.
///
/// Used by both the active-game and post-game screens for agenda progress.
class TallyProgressBar extends StatelessWidget {
  final int totalTallies;

  /// Optional milestone markers (e.g., [3, 6, 10]).
  /// When provided, markers and labels are drawn on the bar.
  /// When null, a simpler bar with a "Total: X" label is shown.
  final List<int>? milestones;

  /// Whether to show the "Progress" header row. Defaults to true when
  /// milestones are provided, false otherwise.
  final bool? showHeader;

  const TallyProgressBar({
    super.key,
    required this.totalTallies,
    this.milestones,
    this.showHeader,
  });

  @override
  Widget build(BuildContext context) {
    final hasMilestones = milestones != null && milestones!.isNotEmpty;
    final header = showHeader ?? hasMilestones;

    if (hasMilestones) {
      return _buildWithMilestones(header);
    }
    return _buildSimple();
  }

  Widget _buildWithMilestones(bool header) {
    final ms = milestones!;
    final maxMilestone = ms.last;
    final progress = (totalTallies / maxMilestone).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header) ...[
          Row(
            children: [
              const Icon(Icons.trending_up, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Progress',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        Stack(
          children: [
            // Background
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Progress fill
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      kAccentPink,
                      kAccentPink.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            // Milestone markers
            ...ms.map((milestone) {
              final position = milestone / maxMilestone;
              return Positioned(
                left: 0,
                right: 0,
                child: FractionallySizedBox(
                  widthFactor: position,
                  alignment: Alignment.centerLeft,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 2,
                      height: 8,
                      color: totalTallies >= milestone
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.grey.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ms.map((m) {
            final achieved = totalTallies >= m;
            return Text(
              '$m',
              style: TextStyle(
                fontSize: 10,
                color:
                    achieved ? kAccentPink : Colors.grey.shade600,
                fontWeight: achieved ? FontWeight.bold : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSimple() {
    const maxDisplay = 10;
    final progress = (totalTallies / maxDisplay).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            widthFactor: progress,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kAccentPink,
                    kAccentPink.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Total: $totalTallies',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
