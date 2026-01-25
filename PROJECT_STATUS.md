# Crusade Bridge - Project Status

**Last Updated:** January 25, 2026

🎯 Current Status: Active Development – Gameplay Implementation Phase  
The app has moved from solid core/maintenance features into active battle flow development. Play Screen and agenda tracking are now underway, with post-game and XP logic next.

### Recent Session Summary (2026-01-24 to 01-25)

- **Jan 25 Morning**: Advanced agenda tracking (Phases 1–4 complete per TODO.md): ActiveGameScreen created, navigation wired, Game object/unit states initialized, placeholder agendas (tally + tiered) displayed, component tally controls + tier UI, group framing, game completion flow stubbed.
- **Jan 24 Burst**: Heavy housekeeping/QOL (11/12 tracked items crossed): conditional buttons (e.g., Play only when loaded), confirmations (exit, group delete), Warlord toggle hide, detachment-filtered enhancements in Renowned Heroes, Drive v1.1 (campaign backups), clear local also clears campaigns, icons batches (Imperium/Chaos/final), Tyranids units added, validation/sanitization.
- **Data push**: Tyranids complete; broader unit coverage + enhancements across 20+ factions.

* * *

📊 Metrics (Recent Activity)
---------------------------

- **Commits (Jan 24–25)**: ~15+ affecting crusade_bridge (data, UX, Play start, sync upgrades)
- **Files Modified (Jan 24 burst)**: 10+
- **Lines Added/Modified**: Hundreds (e.g., crusade_models.dart +44, providers +29)
- **New Features/Methods**: Campaign Manager, ActiveGameScreen route, game add/update/get, agenda init/display
- **Bug Fixes/QOL**: Async fixes, null safety, deprecation cleanup, UI conditionals/filters

* * *

✅ Completed Features
--------------------

### Core & Maintenance
- ✅ Crusade CRUD (create/load/delete/disband with confirmations)
- ✅ OOB management (add/edit/delete units/groups, hierarchical/expandable UI)
- ✅ Requisitions (Renowned Heroes live: RP spend, character-only, no Epic Heroes/duplicates, detachment-filtered enhancements)
- ✅ Google Drive Sync v1.1 (human-readable filenames, rich metadata, campaign backups included, clear local clears campaigns)
- ✅ UX Polish Batch: Conditional Play button, exit/confirmation dialogs, Warlord toggle hide, "Ungroup Only" delete option, filtered enhancements

### Data & Reference
- ✅ Adepta Sororitas complete (37 units + all 5 detachments/enhancements)
- ✅ Enhancements populated across 20+ factions (factions_and_detachments.json v3.8)
- ✅ Unit data for ~27 factions (JSON per faction + template)
- ✅ isCharacter/isEpicHero flags (Sororitas complete; propagating)
- ✅ Data validation/sanitization

### Gameplay Foundations
- ✅ Campaign Manager added
- ✅ ActiveGameScreen created + routed (/game/:gameId)
- ✅ Game object/unit states init on roster deploy
- ✅ Agenda tracking Phases 1–4: Placeholder agendas, display, component tally UI, tier selection, game completion stub

* * *

🚧 In Progress
--------------

- [ ] Agenda Tracking Phases 5–6 (post-game recap, Mark for Greatness, Commit Results, XP calc/apply)
- [ ] Tally steppers refinement (kills/survived + agenda progress indicators)
- [ ] Post-Game Screen stub (recap tallies/agendas, victor bonus)
- [ ] Roster assembly (checkbox OOB selection, points validation)
- [ ] More requisitions (Supply Limit increase, Rearm/Resupply, Fresh Recruits)
- [ ] Fill remaining isCharacter/isEpicHero flags + unit data (e.g., Orks, Necrons)

* * *

📋 Feature Status
-----------------

| Feature                  | Status     | Notes                                                                 |
|--------------------------|------------|-----------------------------------------------------------------------|
| Create/Load/Delete Crusade | ✅ Complete | With confirmations and navigation flows                              |
| Modify OOB               | ✅ Complete | Hierarchical groups, Warlord/Epic Hero handling, requisitions integrated |
| Google Drive Sync        | ✅ Complete | v1.1 with campaign backups, metadata, clear local support             |
| Requisitions (Renowned Heroes) | ✅ Complete | Detachment-filtered enhancements, RP validation                      |
| Unit Data Coverage       | 🟢 Advanced | ~27 factions; enhancements broad; flags propagating                  |
| Assemble Roster          | ⏳ Planned  | Checkbox OOB → named roster save                                      |
| Play Game / Agenda Tracking | 🟡 In Progress | ActiveGameScreen live; Phases 1–4 done (tallies, agendas display)     |
| Post-Game / XP Progression | ⏳ Planned  | Recap, Mark for Greatness, XP calc (participation/kills/marked)       |
| Maintenance Mode         | 🟡 Partial | Requisitions live; edit dialog expansion pending                      |
| Resources                | ⏳ Planned  | Links to Wahapedia/Community                                          |

* * *

🏗️ Architecture Highlights
---------------------------

- **State**: Riverpod (scoped providers for crusade, games, InGameState)
- **Storage**: Hive (Crusade, UnitOrGroup, Game models + adapters)
- **Sync**: Google Drive API v3 (app data folder, manual save/load)
- **Data**: Per-faction JSON + template; reference_service for lookup
- **UI**: Material 3 dark theme, pastel accents, collapsible groups, conditional elements

* * *

📈 Progress Tracking
--------------------

### Faction Data Completion
- **Units JSON**: ~27/30+ major factions (Tyranids recent add)
- **Enhancements**: 20+ factions/detachments populated (v3.8 points accurate)
- **Flags**: isCharacter/isEpicHero complete for Sororitas; ongoing for others

* * *

🎯 Roadmap
----------

### Phase 1: Core & Maintenance (Mostly Complete)
- [x] Crusade CRUD + Drive sync
- [x] OOB + requisitions
- [x] Data foundation (units + enhancements)

### Phase 2: Gameplay (Active)
- [x] Campaign Manager + ActiveGameScreen
- [x] Agenda init/display + tally UI (Phases 1–4)
- [ ] Post-game recap/XP/apply (Phases 5–6)
- [ ] Roster assembly
- [ ] Tally polish + agenda progress

### Phase 3: Advanced & Polish (Future)
- [ ] More requisitions
- [ ] Analytics/export
- [ ] Testing (widget/unit)
- [ ] Onboarding/hints

* * *

🐛 Known Issues / Technical Debt
--------------------------------

- Edit dialog preservation (XP/honors/scars/enhancements) – if not fixed, prioritize
- Error/loading states for Drive ops
- Automated tests (none yet)
- Remaining faction unit data/flags

* * *

📝 Notes
--------

- Goal: Sleek, approachable, low-clutter Crusade companion
- Using Flutter + Riverpod + Hive + Google Drive
- Data accuracy: Points/enhancements from Munitorum Field Manual v3.8
- Focus: Get full battle loop (pre-game → play → post-game → apply) testable soon
