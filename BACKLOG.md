# BACKLOG.md
**Last Updated:** February 10, 2026 (Post-Sprint Cleanup)

## Tasks

## Bugs
- No remaining bugs in backlog.

## Enhancements
- No remaining enhancements in backlog.

## Features
- No remaining features in backlog.

## Deferred / Honor-System Items (RP Spend Only – No Enforcement)
- **DEF-002 (Low)**: Stub "Maintenance and Upgrades" (if rules require; similar RP-only pattern: deduct 1–2 RP, log event)

## Data Fills (Separate Generation)
- **DATA-001 (Medium)**: Full Deathwatch unit data (MFM v3.8 page 19 reference; extract points/flags like prior factions – generate externally)

## Archived/Resolved This Sprint
- **REFACTOR-002 (Medium)**: Shared code extraction — Extracted repeated patterns from large screen files into shared utilities and widgets. `GameLookups`/`CrusadeLookups` extension methods replace `.where().firstOrNull` lookups. `GameUpdateMixin` eliminates duplicate `updateKills`/`updateDestroyed`. Shared `TallyProgressBar` and `DetailRow` widgets. Consolidated duplicate `_loadBattleHonoursData()` via `loadBattleHonoursJsonData()`. Reduces screen file sizes across active game, post-game, and OOB.
- **REFACTOR-001 (Medium)**: FactionCrusadeSystem abstraction — Extracted all hardcoded Sororitas Trials of a Living Saint logic into a generic `FactionCrusadeSystem` class with configurable labels, colors, icons, and progression mechanics. New registry pattern (`FactionCrusadeSystemRegistry`) for faction lookup. Renamed `isLivingSaint` tally key → `ProgressionKeys.isAscended`, moved `TrialDefinition` and `loadTrials()` into `faction_crusade_system.dart`. Updated all 3 screens (OOB, active game, post-game) to use system properties instead of hardcoded text/colors. Ready for other factions to register their own progression systems.
- **FEA-017 (Medium)**: Trials of a Living Saint — Full SAINT POTENTIA / LIVING SAINT system for Adepta Sororitas. Designate one CHARACTER (non-Epic Hero) as SAINT POTENTIA via OOB screen (D6 roll or manual selection of 6 trials). Trial info (name, description, progress bar) displayed on unit card. Saint Points tracked via honor-system +/- control on active game screen. Post-game commit applies Saint Points to unit, checks ascension threshold, and triggers ascension dialog. On ascension: unit replaced with LIVING SAINT inheriting all Honours/Scars/XP, history event logged. Only 1 SAINT POTENTIA enforced. Trial data in external JSON (`sororitas_trials.json`). Added `factionGameTracking` (HiveField 13) to UnitGameState for per-game faction tracking.