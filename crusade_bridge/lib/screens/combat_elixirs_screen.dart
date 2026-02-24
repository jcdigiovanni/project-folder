import '../common.dart';
import '../models/combat_elixirs.dart';

/// Full-screen stash management for Emperor's Children Combat Elixirs.
/// Shows ingredients, crafted elixirs, crafting, and previous-battle info.
class CombatElixirsScreen extends ConsumerStatefulWidget {
  const CombatElixirsScreen({super.key});

  @override
  ConsumerState<CombatElixirsScreen> createState() => _CombatElixirsScreenState();
}

class _CombatElixirsScreenState extends ConsumerState<CombatElixirsScreen> {
  late CombatElixirsStash _stash;

  @override
  void initState() {
    super.initState();
    final crusade = ref.read(currentCrusadeNotifierProvider);
    _stash = crusade?.combatElixirsStash ?? CombatElixirsStash.empty();
  }

  void _saveStash() {
    final crusade = ref.read(currentCrusadeNotifierProvider);
    if (crusade == null) return;
    crusade.combatElixirsStash = _stash;
    crusade.lastModified = DateTime.now().millisecondsSinceEpoch;
    ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(crusade);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Combat Elixirs Stash'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'About Combat Elixirs',
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildIngredientsSection(),
          const SizedBox(height: 24),
          _buildCraftingSection(),
          const SizedBox(height: 24),
          _buildElixirsSection('Army Elixirs', ArmyElixir.allTypes, ArmyElixir.labels, ArmyElixir.effects, false),
          const SizedBox(height: 24),
          _buildElixirsSection('Personal Elixirs', PersonalElixir.allTypes, PersonalElixir.labels, PersonalElixir.effects, true),
          if (_stash.previousBattleElixirs.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildPreviousBattleSection(),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Ingredients Section ──

  Widget _buildIngredientsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.science, color: Colors.purple.shade300),
                const SizedBox(width: 8),
                const Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildIngredientRow(
              'Common',
              Icons.circle,
              Colors.green.shade400,
              _stash.commonIngredients,
              StashLimits.maxCommon,
              (delta) {
                setState(() {
                  if (delta > 0) {
                    _stash.addCommon(delta);
                  } else {
                    _stash.commonIngredients = (_stash.commonIngredients + delta).clamp(0, StashLimits.maxCommon);
                  }
                });
                _saveStash();
              },
            ),
            const SizedBox(height: 8),
            _buildIngredientRow(
              'Rare',
              Icons.diamond,
              Colors.blue.shade400,
              _stash.rareIngredients,
              StashLimits.maxRare,
              (delta) {
                setState(() {
                  if (delta > 0) {
                    _stash.addRare(delta);
                  } else {
                    _stash.rareIngredients = (_stash.rareIngredients + delta).clamp(0, StashLimits.maxRare);
                  }
                });
                _saveStash();
              },
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.amber.shade400, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Exotic (${_stash.totalExotic}/${StashLimits.maxExoticTotal})',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.amber.shade300),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...ExoticIngredient.allTypes.map((type) {
              final count = _stash.exoticIngredients[type] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _buildExoticRow(type, count),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientRow(String label, IconData icon, Color color, int count, int max, void Function(int) onDelta) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 20),
          onPressed: count > 0 ? () => onDelta(-1) : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        SizedBox(
          width: 50,
          child: Text('$count / $max', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 20),
          onPressed: count < max ? () => onDelta(1) : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  Widget _buildExoticRow(String type, int count) {
    final label = ExoticIngredient.labels[type]!;
    return Row(
      children: [
        const SizedBox(width: 28),
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade300)),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 18),
          onPressed: count > 0 ? () {
            setState(() {
              _stash.exoticIngredients[type] = count - 1;
              if (_stash.exoticIngredients[type] == 0) _stash.exoticIngredients.remove(type);
            });
            _saveStash();
          } : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        ),
        SizedBox(
          width: 24,
          child: Text('$count', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 18),
          onPressed: !_stash.isExoticFull ? () {
            setState(() { _stash.addExotic(type, 1); });
            _saveStash();
          } : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        ),
      ],
    );
  }

  // ── Crafting Section ──

  Widget _buildCraftingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build_circle, color: Colors.orange.shade300),
                const SizedBox(width: 8),
                const Text('Craft Elixirs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Combine ingredients to craft elixir doses.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 12),
            ...ElixirRecipes.all.map((recipe) => _buildRecipeRow(recipe)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeRow(ElixirRecipe recipe) {
    final canCraft = _stash.canCraft(recipe) != null;
    final currentDoses = recipe.isPersonal
        ? (_stash.personalElixirs[recipe.elixirKey] ?? 0)
        : (_stash.armyElixirs[recipe.elixirKey] ?? 0);
    final atMax = currentDoses >= StashLimits.maxElixirPerType;
    final enabled = canCraft && !atMax;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: enabled ? Colors.white : Colors.grey.shade600,
                  ),
                ),
                Text(
                  _recipeDescription(recipe),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          if (atMax)
            Chip(
              label: const Text('MAX', style: TextStyle(fontSize: 10)),
              backgroundColor: Colors.grey.shade800,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )
          else
            TextButton.icon(
              icon: const Icon(Icons.science, size: 16),
              label: const Text('Craft'),
              onPressed: enabled ? () {
                setState(() { _stash.craft(recipe); });
                _saveStash();
                SnackBarUtils.showSuccess(context, '${recipe.label} crafted!');
              } : null,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
              ),
            ),
        ],
      ),
    );
  }

  String _recipeDescription(ElixirRecipe recipe) {
    final parts = <String>[];
    for (final slot in recipe.slots) {
      final options = slot.options.map((o) {
        if (o == 'common') return 'Common';
        if (o == 'rare') return 'Rare';
        if (o == 'exotic') return 'Exotic';
        return ExoticIngredient.labels[o] ?? o;
      }).join(' or ');
      parts.add(options);
    }
    return parts.join(' + ');
  }

  // ── Elixirs Section ──

  Widget _buildElixirsSection(String title, List<String> allTypes, Map<String, String> labels, Map<String, String> effects, bool isPersonal) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPersonal ? Icons.person : Icons.groups,
                  color: isPersonal ? Colors.cyan.shade300 : Colors.purple.shade300,
                ),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ...allTypes.map((key) {
              final doses = isPersonal
                  ? (_stash.personalElixirs[key] ?? 0)
                  : (_stash.armyElixirs[key] ?? 0);
              final wasUsedLast = _stash.wasUsedLastBattle(key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildElixirTile(key, labels[key]!, effects[key]!, doses, wasUsedLast),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildElixirTile(String key, String label, String effect, int doses, bool wasUsedLast) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: doses > 0 ? Colors.purple.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: doses > 0 ? Border.all(color: Colors.purple.withValues(alpha: 0.4)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: doses > 0 ? Colors.white : Colors.grey.shade500,
                )),
              ),
              if (wasUsedLast)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                  ),
                  child: const Text('Used Last Battle', style: TextStyle(fontSize: 10, color: Colors.red)),
                ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: doses > 0 ? Colors.purple.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$doses doses',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: doses > 0 ? Colors.purple.shade200 : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(effect, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  // ── Previous Battle Section ──

  Widget _buildPreviousBattleSection() {
    return Card(
      color: Colors.red.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.block, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                const Text('Previous Battle Elixirs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() { _stash.previousBattleElixirs.clear(); });
                    _saveStash();
                  },
                  child: const Text('Clear', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'These elixirs cannot be equipped in your next battle.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _stash.previousBattleElixirs.map((key) {
                final label = ArmyElixir.labels[key] ?? PersonalElixir.labels[key] ?? key;
                return Chip(
                  label: Text(label, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.red.withValues(alpha: 0.2),
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.4)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Info Dialog ──

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Combat Elixirs'),
        content: const SingleChildScrollView(
          child: Text(
            'Emperor\'s Children collect ingredients after battles to craft Combat Elixirs.\n\n'
            'Ingredients:\n'
            '• Common — rolled for after every battle (D6+2 if won: 4+ = 1, 6+ = D3)\n'
            '• Rare — rolled for after every battle (D6+1 if won: 6+ = 1)\n'
            '• Exotic — earned from agendas, requisitions, or battle honours\n\n'
            'Elixirs:\n'
            '• Army Elixirs affect your whole army for one battle\n'
            '• Personal Elixirs affect one CHARACTER for one battle\n'
            '• You cannot use the same elixir in consecutive battles\n'
            '• If no elixirs are equipped, all EC units are Battle-shocked in Round 1\n\n'
            'Equip elixirs before each battle from the Play screen.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
