import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../models/crusade_models.dart';

/// Dice mode options for the roller
enum DiceMode {
  d6,       // Single D6 (1-6)
  d3,       // D3 (1-3, calculated as ceil(d6/2))
  twoD6,    // 2D6 with optional duplicate reroll
}

/// Result from a dice roll
class DiceResult {
  final List<int> rolls;        // Individual die results
  final int total;              // Sum of all dice
  final bool wasAutoPass;       // True if Epic Hero auto-passed
  final bool hadDuplicateReroll; // True if 2D6 had duplicate reroll

  DiceResult({
    required this.rolls,
    required this.total,
    this.wasAutoPass = false,
    this.hadDuplicateReroll = false,
  });
}

/// A reusable D6 roller widget for Crusade game mechanics.
///
/// Supports 1D6, D3, and 2D6 modes with animated rolling,
/// Epic Hero auto-skip logic, and configurable rerolls.
class D6Roller extends StatefulWidget {
  /// Title displayed at the top of the card (e.g., "OOA Test", "Trait Roll")
  final String title;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// Dice mode: d6, d3, or twoD6
  final DiceMode mode;

  /// Unit being rolled for (used for Epic Hero auto-skip)
  final UnitOrGroup? unit;

  /// Whether to allow manual rerolls
  final bool allowReroll;

  /// For 2D6 mode: automatically reroll if both dice show same value
  final bool rerollDuplicates;

  /// Callback when roll is confirmed
  final void Function(DiceResult result)? onConfirm;

  /// Callback when roll is cancelled
  final VoidCallback? onCancel;

  /// Custom message for Epic Hero auto-pass
  final String? epicHeroPassMessage;

  const D6Roller({
    required this.title,
    this.subtitle,
    this.mode = DiceMode.d6,
    this.unit,
    this.allowReroll = true,
    this.rerollDuplicates = true,
    this.onConfirm,
    this.onCancel,
    this.epicHeroPassMessage,
    super.key,
  });

  @override
  State<D6Roller> createState() => _D6RollerState();
}

class _D6RollerState extends State<D6Roller> with SingleTickerProviderStateMixin {
  final Random _random = Random();
  late AnimationController _animController;
  late Animation<double> _shakeAnimation;

  List<int> _currentRolls = [];
  int _displayValue = 0;
  bool _isRolling = false;
  bool _hasRolled = false;
  bool _hadDuplicateReroll = false;
  int _rerollCount = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    // Check for Epic Hero auto-pass immediately
    if (_isEpicHeroAutoPass) {
      _handleEpicHeroAutoPass();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  bool get _isEpicHeroAutoPass => widget.unit?.isEpicHero == true;

  void _handleEpicHeroAutoPass() {
    setState(() {
      _hasRolled = true;
      _currentRolls = widget.mode == DiceMode.twoD6 ? [6, 6] : [6];
      _displayValue = widget.mode == DiceMode.d3 ? 3 : (widget.mode == DiceMode.twoD6 ? 12 : 6);
    });
  }

  int get _diceCount => widget.mode == DiceMode.twoD6 ? 2 : 1;

  void _rollDice() async {
    if (_isRolling) return;

    setState(() {
      _isRolling = true;
      _hadDuplicateReroll = false;
    });

    // Animate through random values
    _animController.reset();
    _animController.forward();

    for (int i = 0; i < 8; i++) {
      await Future.delayed(const Duration(milliseconds: 60));
      if (!mounted) return;
      setState(() {
        _currentRolls = List.generate(_diceCount, (_) => _random.nextInt(6) + 1);
        _displayValue = _calculateTotal(_currentRolls);
      });
    }

    // Final roll
    List<int> finalRolls = List.generate(_diceCount, (_) => _random.nextInt(6) + 1);

    // Handle duplicate reroll for 2D6
    if (widget.mode == DiceMode.twoD6 && widget.rerollDuplicates &&
        finalRolls[0] == finalRolls[1]) {
      setState(() {
        _hadDuplicateReroll = true;
      });
      // Brief pause to show duplicates
      await Future.delayed(const Duration(milliseconds: 400));
      // Reroll
      finalRolls = List.generate(_diceCount, (_) => _random.nextInt(6) + 1);
    }

    setState(() {
      _currentRolls = finalRolls;
      _displayValue = _calculateTotal(finalRolls);
      _isRolling = false;
      _hasRolled = true;
    });
  }

  int _calculateTotal(List<int> rolls) {
    if (widget.mode == DiceMode.d3) {
      // D3 = ceil(D6/2), so 1-2=1, 3-4=2, 5-6=3
      return (rolls[0] + 1) ~/ 2;
    }
    return rolls.fold(0, (sum, val) => sum + val);
  }

  void _reroll() {
    if (!widget.allowReroll || _isRolling) return;
    _rerollCount++;
    _rollDice();
  }

  void _confirm() {
    if (!_hasRolled) return;
    widget.onConfirm?.call(DiceResult(
      rolls: _currentRolls,
      total: _displayValue,
      wasAutoPass: _isEpicHeroAutoPass,
      hadDuplicateReroll: _hadDuplicateReroll,
    ));
  }

  String get _diceLabel {
    switch (widget.mode) {
      case DiceMode.d6:
        return 'D6';
      case DiceMode.d3:
        return 'D3';
      case DiceMode.twoD6:
        return '2D6';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              widget.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 8),

            // Unit info if provided
            if (widget.unit != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.unit!.isEpicHero == true)
                      Icon(Icons.auto_awesome, size: 16, color: Colors.amber[700]),
                    const SizedBox(width: 6),
                    Text(
                      widget.unit!.customName ?? widget.unit!.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Epic Hero auto-pass message
            if (_isEpicHeroAutoPass) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      widget.epicHeroPassMessage ?? 'Epic Hero - Automatic Pass',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Dice display
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                final shake = sin(_shakeAnimation.value * pi * 4) *
                    (1 - _shakeAnimation.value) * 8;
                return Transform.translate(
                  offset: Offset(shake, 0),
                  child: child,
                );
              },
              child: _buildDiceDisplay(colorScheme),
            ),

            const SizedBox(height: 8),

            // Dice mode label
            Text(
              _diceLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            // Duplicate reroll indicator
            if (_hadDuplicateReroll)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Duplicates rerolled!',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Action buttons
            if (!_isEpicHeroAutoPass) ...[
              if (!_hasRolled) ...[
                // Initial roll button
                FilledButton.icon(
                  onPressed: _isRolling ? null : _rollDice,
                  icon: _isRolling
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.casino),
                  label: Text(_isRolling ? 'Rolling...' : 'Roll $_diceLabel'),
                ),
              ] else ...[
                // Post-roll buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.allowReroll)
                      OutlinedButton.icon(
                        onPressed: _isRolling ? null : _reroll,
                        icon: const Icon(Icons.refresh),
                        label: Text('Reroll${_rerollCount > 0 ? ' ($_rerollCount)' : ''}'),
                      ),
                    if (widget.allowReroll) const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _confirm,
                      icon: const Icon(Icons.check),
                      label: const Text('Confirm'),
                    ),
                  ],
                ),
              ],
            ] else ...[
              // Epic Hero confirm only
              FilledButton.icon(
                onPressed: _confirm,
                icon: const Icon(Icons.check),
                label: const Text('Continue'),
              ),
            ],

            // Cancel option
            if (widget.onCancel != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDiceDisplay(ColorScheme colorScheme) {
    if (widget.mode == DiceMode.twoD6) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSingleDie(_currentRolls.isNotEmpty ? _currentRolls[0] : 0, colorScheme),
          const SizedBox(width: 16),
          Text(
            '+',
            style: TextStyle(
              fontSize: 32,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          _buildSingleDie(_currentRolls.length > 1 ? _currentRolls[1] : 0, colorScheme),
          const SizedBox(width: 16),
          Text(
            '=',
            style: TextStyle(
              fontSize: 32,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          _buildTotalDisplay(colorScheme),
        ],
      );
    }

    // Single die display (D6 or D3)
    return Column(
      children: [
        _buildSingleDie(_currentRolls.isNotEmpty ? _currentRolls[0] : 0, colorScheme),
        if (widget.mode == DiceMode.d3 && _hasRolled) ...[
          const SizedBox(height: 8),
          Text(
            '(${_currentRolls.isNotEmpty ? _currentRolls[0] : 0} ÷ 2 rounded up)',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Result: $_displayValue',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSingleDie(int value, ColorScheme colorScheme) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: _hasRolled ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hasRolled ? colorScheme.primary : colorScheme.outline,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: value > 0
            ? _buildDieFace(value, colorScheme)
            : Icon(
                Icons.casino,
                size: 32,
                color: colorScheme.onSurfaceVariant,
              ),
      ),
    );
  }

  Widget _buildDieFace(int value, ColorScheme colorScheme) {
    // Simple numeric display for now - could be enhanced with pip patterns
    return Text(
      '$value',
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildTotalDisplay(ColorScheme colorScheme) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$_displayValue',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

/// A modal bottom sheet wrapper for the D6 roller
Future<DiceResult?> showD6RollerModal({
  required BuildContext context,
  required String title,
  String? subtitle,
  DiceMode mode = DiceMode.d6,
  UnitOrGroup? unit,
  bool allowReroll = true,
  bool rerollDuplicates = true,
  String? epicHeroPassMessage,
}) {
  return showModalBottomSheet<DiceResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      margin: const EdgeInsets.all(16),
      child: D6Roller(
        title: title,
        subtitle: subtitle,
        mode: mode,
        unit: unit,
        allowReroll: allowReroll,
        rerollDuplicates: rerollDuplicates,
        epicHeroPassMessage: epicHeroPassMessage,
        onConfirm: (result) => Navigator.of(context).pop(result),
        onCancel: () => Navigator.of(context).pop(),
      ),
    ),
  );
}
