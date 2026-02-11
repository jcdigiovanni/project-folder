# TODO - Active Sprint Tracker
**Last Updated:** February 10, 2026 (Sprint: Phase 6 Backlog Clearance In Progress)

**Follow the guidelines in AGENTS.md exactly.**

## Current Focus: BUGS AND ENHANCEMENTS
- Read BACKLOG.md and work on all BUG, ENH, and FEA items as needed.
- When implementing "Trials of a Living Saint" in the BACKLOG - the system is an Adepta Sororitas specific Crusade feature that will build upon what we put in with the Requisitions.  Grok put in some information in Integration Points - do not assume that guidance is immutable or even applicable, use it as just guidance.  Also, bear in mind, there is only 1 Saint Potentia at a time, so this will probably introduce a lot of info that needs to be hidden unless it is on the Potentia.
  
### Current Work: Bugs and Enhancements (11 FEB)
- All sprint items complete! Ready for next sprint.

## Completed This Session / Archive
- **Feb 11**: FactionCrusadeSystem abstraction (REFACTOR-001) — Extracted Sororitas-specific progression logic into generic `FactionCrusadeSystem` class with registry pattern. Moved `TrialDefinition`/`loadTrials` to `faction_crusade_system.dart`. Renamed `isLivingSaint` → `ProgressionKeys.isAscended`. Updated OOB, active game, and post-game screens to use system properties for all labels, colors, and mechanics. Ready for other factions to register their own progression systems.
- **Feb 10**: Implemented Trials of a Living Saint (FEA-017) — Full SAINT POTENTIA / LIVING SAINT system for Adepta Sororitas. OOB screen designation (D6 roll or manual selection), trial info + progress on unit card, in-game Saint Points +/- tracking, post-game commit with ascension dialog and unit replacement. 6 trials in JSON, `factionGameTracking` added to UnitGameState.
- **Feb 9-10**: Replaced 4 incorrect Sororitas honor-system requisitions with 6 correct full-mechanics versions (FEA-001–006): Divine Calling, Ascension to the Order, The Penitent Path, Glorious Redemption, In Suffering Enlightenment, Saintly Benedictions. Added generic faction tracking fields to UnitOrGroup model. Extracted shared RequisitionOption widget and honor-system utils. Separate faction requisition file architecture.
- **Feb 9**: Added 4 Adepta Sororitas faction-specific requisitions (honor system) with inline faction header. Refactored Rearm and Resupply to generic honor-system modal. Extensible for future factions.
- **Feb 9**: Added Black Templars (4+4 base SM) and Imperial Agents (5) faction agendas — 9 new agendas across 2 factions. All factions in factions_and_detachments.json now have agenda coverage (except Chaos Daemons — no faction-specific agendas).

## Next After This Sprint
- Campaign narrative tools (battle tally/victories log, export/share OOB JSON/text, multi-campaign switcher)
- Full Deathwatch unit data fill (MFM reference – generate separately)
- Advanced: Multi-player support, scenario/agenda expansions, campaign history export