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
- **FEA-001–006 (Medium)**: Replaced 4 incorrect Sororitas honor-system requisitions with 6 correct full-mechanics versions: Divine Calling (1 RP, Saint point management), Ascension to the Order (2 RP, Novitiates→Orders Militant upgrade), The Penitent Path (2 RP, squad conversion + Dealers of Death bonus), Glorious Redemption (1 RP, Repentia→elite upgrade + bonus Battle Trait), In Suffering Enlightenment (1 RP, auto-fail OOA + scar/honour/Saint/Martyr), Saintly Benedictions (1 RP, Miracle dice auto-6). Added generic faction tracking fields (factionPoints1-3, factionFlag1-2) to UnitOrGroup model. Extracted RequisitionOption widget and honor-system utils to shared files. Separate faction requisition file architecture for extensibility.
- **FEA-013–016 (Medium)**: Added 4 Adepta Sororitas faction-specific requisitions (honor system) — Saintly Blessing, Divine Intervention, Martyr's Strength, Ecclesiarchy Support. Inline section with faction header, only shown for Sororitas crusades. Also refactored Rearm and Resupply to use generic honor-system modal. DEF-001 resolved.
- **BT-FEA-001–004 (Medium)**: Added 4 Black Templars agendas (+ 4 base SM) — Fulfil Your Vows, Reconsecration, First-Hand Experience, Recovering Sacred Wargear.
- **IA-FEA-001–005 (Medium)**: Added 5 Imperial Agents agendas — Aggressive Negotiation, Strategic Excruciation, Execution Order, Clandestine Infiltration, Long Vigil.
- **DW-FEA-001–004 (Medium)**: Added 4 Deathwatch agendas (+ 4 base SM) — A Deadly Prize, Furor Tactics, Malleus Tactics, Purgatus Tactics.
- **BA-FEA-001–004 (Medium)**: Added 4 Blood Angels agendas (+ 4 base SM) — For Baal and the Angel!, Search for the Cure, Against the Darkness, Liberators from Tyranny.
- **DA-FEA-001–004 (Medium)**: Added 4 Dark Angels agendas (+ 4 base SM) — Interrogate the Mysterious Figure, Encircle the Foe, The Deathwing Cometh, Mental Interrogation.
- **SW-FEA-001–003 (Medium)**: Added 3 Space Wolves agendas (+ 4 base SM) — Show Them How We Fight, Savage Fury, Howls of Vengeance.
- **BUG-020 (High)**: Fixed Add/Edit Unit modals losing all form state on Android when keyboard opens/closes or text fields lose focus. Root cause: form variables in showModalBottomSheet builder closure reinitialized on MediaQuery rebuilds. Fix: extracted into StatefulWidget classes with persistent State objects and TextEditingControllers.
- **ENH-015 (High)**: Made Agenda Section Collapsible on Active Game Screen — default collapsed with summary bar showing agenda names + total progress, tap to expand for full agenda cards with tracking controls. Animated chevron and crossfade transitions. Frees up screen space for unit management during battle.