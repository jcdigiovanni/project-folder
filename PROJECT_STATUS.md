**Last Updated:** February 11, 2026 (Phase 6 Backlog Clearance In Progress)

**Recent Work (Feb 11)**
- FactionCrusadeSystem Abstraction (REFACTOR-001): Extracted all Sororitas-specific Trials of a Living Saint logic into generic `FactionCrusadeSystem` class with registry pattern. New file `lib/models/faction_crusade_system.dart` contains `TrialDefinition`, `ProgressionKeys`, `FactionCrusadeSystem`, `loadTrials()`, and `FactionCrusadeSystemRegistry`. All 3 screens (OOB, active game, post-game) now use system properties for labels, colors, icons, event descriptions, and point calculations. Zero hardcoded faction text remains. Other factions can register their own progression systems by adding to the registry.

**Recent Work (Feb 10)**
- Trials of a Living Saint (FEA-017): Full SAINT POTENTIA / LIVING SAINT system for Adepta Sororitas. Designate CHARACTER as SAINT POTENTIA via OOB screen (D6 roll or manual trial selection). Trial info + progress bar on unit card. Saint Points +/- tracking during active games. Post-game ascension check with dialog and automatic unit replacement inheriting all data. 6 trials in external JSON, `factionGameTracking` field added to UnitGameState.

**Recent Work (Feb 9-10)**
- Sororitas Requisitions (Full Mechanics): Replaced 4 incorrect honor-system stubs with 6 correct full-mechanics requisitions — Divine Calling, Ascension to the Order, The Penitent Path, Glorious Redemption, In Suffering Enlightenment, Saintly Benedictions. Added generic faction tracking fields (factionPoints1-3, factionFlag1-2) to UnitOrGroup model with per-faction label mapping. Extracted shared widgets and utils. Separate file per faction for extensibility.
- BT/IA Agendas: Added Black Templars (4+4 base SM) and Imperial Agents (5) faction agendas — 9 new chapter/faction-specific agendas.
- SM Chapter Agendas: Added 15 chapter-specific agendas (+ base SM agendas in each) across 4 chapters — Deathwatch (4+4), Blood Angels (4+4), Dark Angels (4+4), Space Wolves (3+4). Each chapter JSON includes the 4 base Adeptus Astartes agendas.
- EC/GSC/IK/VOT/TAU Agendas: Added 22 agendas across 5 new factions — Emperor's Children (4), Genestealer Cults (5), Imperial Knights (5), Leagues of Votann (4), T'au Empire (4).
- AdMech/AM/CSM Agendas: Added 16 agendas across 3 new factions — Adeptus Mechanicus (5), Astra Militarum (5), Chaos Space Marines (6).
- Faction Agendas: Added 43 agendas across 10 factions (Drukhari, Thousand Sons, Grey Knights, Chaos Knights, Death Guard, World Eaters, Tyranids, Orks, Necrons, Space Marines) + 4 Aeldari + 4 Custodes. All data-driven JSON, auto-loaded per faction.
- CUST-FEA-001–004: Added 4 Adeptus Custodes faction agendas — Pursuit of Excellence, Judgement Delivered, Great Tithe, Unto the Dark Cells. Data-driven JSON, auto-loaded for Custodes crusades.
- BUG-020: Fixed Add/Edit Unit modals losing all form state on Android when keyboard opens/closes or text fields lose focus. Extracted modal content from inline StatefulBuilder closures into proper StatefulWidget classes with persistent state and TextEditingControllers.

**Recent Work (Feb 6)**
- ENH-015: Active Game Screen agenda section now collapsible — default collapsed with summary bar (agenda names + progress total), tap to expand, animated transitions. Frees screen space for unit management during battle.

**Recent Work (Feb 5-6)**
- BUG-019: History logging fixed — all significant events now logged (unit add/remove, supply increase, game results, requisitions); mutation pattern fixed for reliable persistence; 100-event rolling cap added to prevent unbounded growth
- History confirmed to travel with Google Drive backup/restore
- ENH-014: Landing screen crusade list multi-line layout (name/faction/points/detachment on separate lines)
- ENH-012: Settings backup/restore buttons stacked vertically for mobile readability
- ENH-013: Landing screen edge-to-edge with transparent status bar and notch-safe top padding
- Google Drive re-enabled for Android and Chrome/Web — OAuth consolidated to Crusade Tracker GCP project, SHA-1 fingerprint registered, web client ID updated. Verified working on both platforms.

**Recent Work (Feb 3)**
- ENH-009: Total Kills display in OOB unit details
- ENH-010: XP Preview section in post-game screen (per-unit breakdown before commit)
- ENH-011: Post-game layout overhaul — collapsible agenda recap, inline XP preview per unit card, per-unit agenda tally adjustments

**Recent Work (Feb 1)**
- Phase 6 Bug Clearance:
  - BUG-010: Android Google Drive auth - Added Gradle plugin, improved error handling with detailed messages
  - BUG-013/014/015: Campaign provider state sync - Clear/restore operations now properly update UI state
- Completed Phase 5 Bug Clearance:
  - BUG-001: Exit button platform-aware (Android/iOS/Desktop/Web)
  - BUG-005: Clear local data navigates to landing after clear
  - BUG-006: setCurrent persists to storage (first unit save fix)
  - BUG-007: Group create handles no-units, autofocus, inline validation
- Completed Phase 4: Enhanced Agenda System
  - 12 core Crusade agendas from JSON data file (core_agendas.json)
  - Pre-game multi-select, in-game tracking, post-game recap with VP/XP rewards
- Completed Phases 1–3: D6 roller, Battle Honours, OOA/Scars
- Requisitions core (Phases 1–3) merged and polished

**Completed Features (Updated)**
- Full Crusade game loop: roster → play → agendas → in-game tracking → post-game → XP/progression
- Enhanced agenda system with data-driven JSON agendas
- Progression foundations: D6 roller + Battle Honours/Rank-Up + OOA/Scars system
- Requisitions full core loop (Supply Increase, Fresh Recruits, Repair/Recuperate, Renowned Heroes, Legendary Veterans)
- Bug fixes for core functionality (exit, data clear, save persistence, group creation)
- Google Drive backup/restore: Android (Firebase/GMS) + Chrome/Web (OAuth 2.0) — verified working

**In Progress**
- Polish: Consistent Supply/RP dashboard visuals, confirmation dialogs

**Roadmap**
- Polish → narrative/export for beta/testable loop
- Fill Deathwatch data (last faction)