# TODO - Active Sprint Tracker
**Last Updated:** February 24, 2026 (Sprint: Victor Bonuses)

**Follow the guidelines in AGENTS.md exactly.**

## Current Focus: BUGS AND ENHANCEMENTS
- Read BACKLOG.md and work on all BUG, ENH, and FEA items as needed.
- When implementing "Trials of a Living Saint" in the BACKLOG - the system is an Adepta Sororitas specific Crusade feature that will build upon what we put in with the Requisitions.  Grok put in some information in Integration Points - do not assume that guidance is immutable or even applicable, use it as just guidance.  Also, bear in mind, there is only 1 Saint Potentia at a time, so this will probably introduce a lot of info that needs to be hidden unless it is on the Potentia.
  
### Current Work: Victor Bonuses (24 FEB)
- All Victor Bonus items complete! Ready for next sprint.

## Completed This Session / Archive
- **Feb 24**: Victor Bonuses (FEA-019) — Post-game bonus selection for victorious players. 7 bonus types with extensible `VictorBonusType` class. Deferred token architecture via `pendingFreeRequisitions`. Mark for Greatness multi-select. Free requisition/honour/enhancement redemption on OOB and requisition screens. Fixed token propagation in 6 immutable Crusade constructors.
- **Feb 11**: Post-Game Navigation Guard — Confirmation dialog on all exit paths (bottom nav, back button, Android back) when results uncommitted. `isCommitted` (HiveField 17) on Game model. Play screen detects uncommitted games and prompts return. Prevents accidental XP/tally loss and OOA bypass.
- **Feb 11**: Battlefield Survivors XP Fix — Added `maxXp: 3` cap to core.json. Tier 2 was awarding 4 XP instead of correct 3 XP.
- **Feb 11**: Battle Honours as Currency — Replaced `pendingRankUp` boolean with `availableBattleHonours` integer counter (HiveField 28). Multiple rank-ups per game supported via `rankIndex()`. Added `floatingBattleHonours` (HiveField 15) to Crusade. Fixed `pendingRankUp` missing from JSON serialization (backup/restore bug).
- **Feb 11**: Agenda Multi-Select Fix — Fixed unit selection dialog for multi-unit agendas. New `StatefulBuilder` multi-select toggle, deferred state updates, full unit name display with count.
- **Feb 11**: Shared code extraction (REFACTOR-002) — Extracted repeated code into shared utilities/widgets: `GameLookups`/`CrusadeLookups` extensions, `GameUpdateMixin`, `TallyProgressBar`, `DetailRow`. Consolidated duplicate `_loadBattleHonoursData()` via shared loader. Reduces duplication across active game, post-game, and OOB screens.
- **Feb 11**: FactionCrusadeSystem abstraction (REFACTOR-001) — Extracted Sororitas-specific progression logic into generic `FactionCrusadeSystem` class with registry pattern. Moved `TrialDefinition`/`loadTrials` to `faction_crusade_system.dart`. Renamed `isLivingSaint` → `ProgressionKeys.isAscended`. Updated OOB, active game, and post-game screens to use system properties for all labels, colors, and mechanics. Ready for other factions to register their own progression systems.

## Next After This Sprint
- Campaign narrative tools (battle tally/victories log, export/share OOB JSON/text, multi-campaign switcher)
- Full Deathwatch unit data fill (MFM reference – generate separately)
- Advanced: Multi-player support, scenario/agenda expansions, campaign history export