# TODO - Active Sprint Tracker
**Last Updated:** February 10, 2026 (Sprint: Phase 6 Backlog Clearance In Progress)

**Follow the guidelines in AGENTS.md exactly.**

## Current Focus: BUGS AND ENHANCEMENTS
- Read BACKLOG.md and work on all BUG, ENH, and FEA items as needed.
- When implementing "Trials of a Living Saint" in the BACKLOG - the system is an Adepta Sororitas specific Crusade feature that will build upon what we put in with the Requisitions.  Grok put in some information in Integration Points - do not assume that guidance is immutable or even applicable, use it as just guidance.  Also, bear in mind, there is only 1 Saint Potentia at a time, so this will probably introduce a lot of info that needs to be hidden unless it is on the Potentia.
  
### Current Work: Bugs and Enhancements (11 FEB)
- All sprint items complete! Ready for next sprint.

## Completed This Session / Archive
- **Feb 11**: Shared code extraction (REFACTOR-002) — Extracted repeated code into shared utilities/widgets: `GameLookups`/`CrusadeLookups` extensions, `GameUpdateMixin`, `TallyProgressBar`, `DetailRow`. Consolidated duplicate `_loadBattleHonoursData()` via shared loader. Reduces duplication across active game, post-game, and OOB screens.
- **Feb 11**: FactionCrusadeSystem abstraction (REFACTOR-001) — Extracted Sororitas-specific progression logic into generic `FactionCrusadeSystem` class with registry pattern. Moved `TrialDefinition`/`loadTrials` to `faction_crusade_system.dart`. Renamed `isLivingSaint` → `ProgressionKeys.isAscended`. Updated OOB, active game, and post-game screens to use system properties for all labels, colors, and mechanics. Ready for other factions to register their own progression systems.

## Next After This Sprint
- Campaign narrative tools (battle tally/victories log, export/share OOB JSON/text, multi-campaign switcher)
- Full Deathwatch unit data fill (MFM reference – generate separately)
- Advanced: Multi-player support, scenario/agenda expansions, campaign history export