# TODO - Active Sprint Tracker
**Last Updated:** February 24, 2026 (Sprint: EC Combat Elixirs)

**Follow the guidelines in AGENTS.md exactly.**

## Current Focus: BUGS AND ENHANCEMENTS
- Read BACKLOG.md and work on all BUG, ENH, and FEA items as needed.
- Implement the Emperor's Children specific Crusade Agendas; the implementation method should mirror the Adepta Sororitas agendas already implemented.

### Current Work: EC Combat Elixirs (25 FEB)
- All Combat Elixirs items complete! Ready for next sprint.
- EC-specific Crusade agendas in BACKLOG.md still need implementation (Draught of Despair, Adorn the Canvas Eclectic, Symphony of Pain and Hate, Feeding the Addiction).
- [x] Data-driven refactor: Extracted hardcoded elixir data into `ec_combat_elixirs.json` (matches sororitas_trials.json pattern).

## Completed This Session / Archive
- **Feb 24**: EC Combat Elixirs — Full inventory/crafting/equipping system for Emperor's Children. Data model (`combat_elixirs.dart`): `CombatElixirsStash` with 3 ingredient types (Common/Rare/Exotic), 6 Army + 6 Personal Elixirs, recipe crafting system, stash limits. `factionDataJson` (HiveField 17) on Crusade for generic faction-specific data storage. `equippedElixirsJson` (HiveField 19) on Game for per-battle elixir snapshot. Stash management screen with ingredient counts, crafting, and previous-battle tracking. OOB integration: stash button for EC crusades + free Anfrak Silk on first unit added. Pre-battle equipping on Play screen: army elixir multi-select + personal elixir per-CHARACTER assignment with consecutive-use blocking. Active Game equipped elixirs collapsible reference bar. Post-game D6 ingredient rolls (Common D6+2/Rare D6+1 if won). Propagated `factionDataJson` to all 10 Crusade immutable constructors.
- **Feb 24**: Victor Bonuses (FEA-019) — Post-game bonus selection for victorious players. 7 bonus types with extensible `VictorBonusType` class. Deferred token architecture via `pendingFreeRequisitions`. Mark for Greatness multi-select. Free requisition/honour/enhancement redemption on OOB and requisition screens. Fixed token propagation in 6 immutable Crusade constructors.
