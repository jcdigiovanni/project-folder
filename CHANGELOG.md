# Changelog

All notable changes to the Crusade Bridge project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Adepta Sororitas Requisitions (Full Mechanics)** — Replaced 4 honor-system stubs with 6 correct full-mechanics requisitions: Divine Calling (1 RP, Saint point management — abandon Trial, gain half points rounded up), Ascension to the Order (2 RP, upgrade Novitiates Squad to Battle Sisters/Dominion/Retributor with +5 XP transfer), The Penitent Path (2 RP, convert scarred squad to Repentia/Mortifiers with Dealers of Death 2XP bonus), Glorious Redemption (1 RP, upgrade Repentia with 3+ Redemption points to elite squad with bonus Battle Trait), In Suffering Enlightenment (1 RP, auto-fail OOA test for Battle Scar + Honour, once per unit, SAINT POTENTIA bonus), Saintly Benedictions (1 RP, Miracle dice auto-6 first round). Generic faction tracking fields (factionPoints1-3, factionFlag1-2) on UnitOrGroup model with per-faction label mapping. Separate faction requisition file architecture. Shared RequisitionOption widget and honor-system utils extracted for reuse.
- **Black Templars Agendas** — 4 chapter-specific agendas + 4 base Space Marine agendas: Fulfil Your Vows, Reconsecration, First-Hand Experience, Recovering Sacred Wargear.
- **Imperial Agents Agendas** — 5 faction-specific agendas: Aggressive Negotiation, Strategic Excruciation, Execution Order, Clandestine Infiltration, Long Vigil.
- **Deathwatch Agendas** — 4 chapter-specific agendas + 4 base Space Marine agendas: A Deadly Prize, Furor Tactics, Malleus Tactics, Purgatus Tactics.
- **Blood Angels Agendas** — 4 chapter-specific agendas + 4 base Space Marine agendas: For Baal and the Angel!, Search for the Cure, Against the Darkness, Liberators from Tyranny.
- **Dark Angels Agendas** — 4 chapter-specific agendas + 4 base Space Marine agendas: Interrogate the Mysterious Figure, Encircle the Foe, The Deathwing Cometh, Mental Interrogation.
- **Space Wolves Agendas** — 3 chapter-specific agendas + 4 base Space Marine agendas: Show Them How We Fight, Savage Fury, Howls of Vengeance.
- **Emperor's Children Agendas** — 4 faction-specific agendas: Excess of Indulgence, Flawless Performance, Perfect the Art, Captive Audience.
- **Genestealer Cults Agendas** — 5 faction-specific agendas: Genestealer's Kiss, Silence Detractor, Telepathic Domination, Prepared for the Ordeal, Topple the False Temple.
- **Imperial Knights Agendas** — 5 faction-specific agendas: Sally Forth, Break Their Will, Petitioned for Aid, Honour Must Be Satisfied, Death Before Dishonour.
- **Leagues of Votann Agendas** — 4 faction-specific agendas: Prospecting, Yield Prophecy, Exhaustive Pursuit, Debt to Be Paid.
- **T'au Empire Agendas** — 4 faction-specific agendas: Coordinated Strike, Decisive Strike, For the Greater Good, Targeted Elimination.
- **Adeptus Mechanicus Agendas** — 5 faction-specific agendas (AdMech-FEA-001 to 005): Cold Logic (Imperative ranged destroy tally), Tech Scavengers (Vehicle target + Archeotech), Omnissiah's Will (Command phase activation), Break the Seals (CHARACTER objective task + D6), Claim Legendary Archeotech (marker control).
- **Astra Militarum Agendas** — 5 faction-specific agendas (AM-FEA-006 to 010): Advance For the Emperor! (deployment zone push), Propaganda Targets (Extermination Targets), Inspired Command (Officer Order tally), Hold the Line (deployment defense), Arming the Assault (objective securing).
- **Chaos Space Marines Agendas** — 6 faction-specific agendas (CSM-FEA-001 to 006): Claim and Despoil (warband prizes + Warfleet Glory), Blasphemous Ritual (Dark Pact tally + Dark God Glory), Path to Glory (Champion conditions + Personal Glory), plus 3 Glory Agendas (Warlord's Glory, Glory of the Gods, Glory of Conquest).
- **Faction Agendas (10 factions, 43 agendas)** — Drukhari (5), Thousand Sons (4), Grey Knights (5), Chaos Knights (4), Death Guard (4), World Eaters (4), Tyranids (4), Orks (4), Necrons (4), Space Marines (4). All data-driven JSON, auto-loaded per faction crusade. Covers tally and objective types with XP caps, unit limits, and faction-specific mechanics.
- **Aeldari Agendas** — 4 faction-specific Crusade agendas (AEL-FEA-001 to AEL-FEA-004): Fulcrum of Fate (Thread of Fate success for 3XP), Eldritch Supremacy (Psychic kill tally tiered XP), Few in Number (survival/destroy for selected units), Evasive Warfare (encircled corners tiered XP).
- **Adeptus Custodes Agendas** — 4 faction-specific Crusade agendas (CUST-FEA-001 to CUST-FEA-004): Pursuit of Excellence (lowest XP unit conditions check, up to 4XP), Judgement Delivered (table wipe 2XP per unit), Great Tithe (Psyker destroy tracking with Anathema Psykana bonus), Unto the Dark Cells (No Man's Land objective control, up to 3 units for 2XP each).
- **Tyrannic War Agendas** — 11 thematic Crusade agendas (FEA-001 to FEA-011): Battlefield Survivors, Swarm the Planet, Headhunters, Monstrous Targets, Eradicate the Swarm, Critical Objectives, Drive Home the Blade, Cleanse Infestation, Forward Observers, Recover Mission Archives, Malefic Hunter. Supports XP/CP rewards, unit selection limits, tally/objective types.
- **Enhanced Agenda System** — Agenda infrastructure supporting JSON data (assets/data/core_agendas.json), pre-game multi-select with tally/objective type indicators, in-game progress tracking (AgendaProgressCard with type icons, TierProgressIndicator for objectives, TallyProgressBar with milestone markers), post-game recap with completion status badges, VP/XP rewards display, summary totals banner, full persistence via Game model.
- **Out of Action (OOA) & Battle Scars system** — Post-game integration, per-unit/batch resolution, 1D6 roll with auto-pass (Epic/Fort/Swarm), prompt on 1 for Devastating Blow or Scar, scar table roll (D6), effect application, scar tracking in model, Repair requisition link, dedicated UI step, visual indicators on unit cards.
- **Battle Honours & Rank-Up Flow** — Claim button in unit details, modal with manual/roll options, integrated D6/2D6 rolls for Traits/Weapon Enhancements (duplicate reroll), Crusade Relics dropdown (Characters only, limit 1), Psychic Fortitudes, model fields (battleTraits, weaponEnhancements, crusadeRelic), honours.json data file, history logging, Renowned Heroes integration.
- **Reusable D6 Roller Widget** — lib/widgets/d6_roller.dart, supports 1D6/2D6/D3, animated shake, Epic Hero skip, reroll button, modal helper (showD6RollerModal), DiceResult class, widget tests.

### Changed
- **ENH-015**: Active Game Screen Agenda section now collapsible — default collapsed with summary bar (agenda names + total progress), tap to expand for full agenda cards. Animated chevron rotation and crossfade transition. Frees screen space for unit list during battle.
- **ENH-014**: Landing screen Recent Crusades list reformatted — structured multi-line layout with crusade name (bold) on first line, faction + points on second line (left/right aligned), detachment on third line (indented, grey). Prevents mid-phrase word wrapping.
- **ENH-012**: Settings screen backup/restore buttons stacked vertically (full-width) instead of side-by-side Row to prevent text overflow on mobile.
- **ENH-013**: Landing screen edge-to-edge — transparent status bar with light icons, dynamic top padding accounts for status bar/notch height so "Recent Crusades" heading is never clipped.
- **ENH-009**: Total Kills now displayed in unit details on OOB screen (standalone and group component units), pulled from cumulative kill tally.
- **ENH-010/011**: Post-game review layout overhaul — Agenda Recap now collapsible (collapsed by default with summary line), XP Preview integrated inline per unit card with compact breakdown chips, per-unit agenda tally adjustment controls (+/- buttons with live XP recalculation).
- RP cap enforced at 10; post-game RP award only if under cap.
- Active game kill tally now shows XP progress (3 dots + earned badge); survived/destroyed toggle as segmented button.
- Play screen agenda selection now loads from JSON data file with async loading and fallback.

### Fixed
- **BUG-020**: Add/Edit Unit modals no longer lose form state on Android when the keyboard opens/closes or text fields lose focus. Root cause: form variables were declared in the `showModalBottomSheet` builder closure and reinitialized on every MediaQuery rebuild. Fix: extracted modal content into proper StatefulWidget classes (`_AddUnitModalContent`, `_EditUnitModalContent`) with state held in State objects and TextEditingControllers for text persistence.
- **BUG-019**: Crusade History now logs all significant events — added missing history entries for basic unit add, unit removal, Supply Increase requisition, and game results (battle outcome). Fixed existing requisition history entries (Fresh Recruits, Repair, Renowned Heroes, Legendary Veterans) to use immutable provider `addEvent()` instead of direct object mutation, ensuring reliable persistence across sessions. Added 100-event rolling cap to prevent unbounded history growth (oldest entries trimmed first).
- **Agenda XP Application** — Agendas now properly award XP to units on commit. Added xpPerTally, tallyDivisor, maxXp, xpPerTier fields to GameAgenda model; calculateXpForUnit() method computes rewards; _commitResults() applies agenda XP to each unit.
- BUG-013/014/015: Campaign data management - Clearing local data now immediately removes campaigns from UI (added `clear()` method to CampaignsNotifier); restoring from Google Drive backup now properly reloads campaigns into provider state (added `reload()` method).
- BUG-010: Android Google Drive auth - Added Google services Gradle plugin, improved error handling with detailed messages for common sign-in failures (SHA-1 mismatch, missing google-services.json, network errors), dashboard now attempts sign-in with helpful feedback.
- BUG-001: Exit button now platform-aware (Android SystemNavigator, iOS/Desktop dart:io exit, Web message).
- BUG-004: Marked for Greatness +3 XP (was +1).
- BUG-005: Clear local data now navigates to landing screen after clearing.
- BUG-006: setCurrent now persists crusade to storage by default (first unit + Warlord/Enhancement save fix).
- BUG-007: Group create modal handles no-units case with dialog, autofocus on name field, inline validation.
- BUG-002: Supply Limit persistence fixed.
- BUG-003: OOB data loss in group disband/edit, enhancement add.

### Improved
- Explicit close buttons on modals (ENH-001).
- RP/CP/Supply dashboard on OOB screen (ENH-003).
- Post-game agenda recap now shows individual agenda rewards (VP/XP) and overall completion summary.

### Planned
- Polish: Consistent Supply/RP dashboard visuals, confirmation dialogs.
- Deathwatch data fill (last faction).

## [0.3.2] – 2026-01-25
Post-game/XP system overhaul: victory/defeat banner, agenda recap, Mark selector, unit cards, Commit button, XP calc (participation + kills/3 + Marked +3, Epic skip), level-up indicators/tags, active game score dialog/group framing, +1 RP on commit, Play "Load Army".

## [0.3.1] – 2026-01-24
Exit button + confirmation, group delete options, Drive v1.1 campaigns, conditional Play button, clear local data campaigns, Renowned Heroes filter, Warlord toggle hide.

## [0.3.0] – 2026-01-24 (Major)
Roster system (list/create/view/build, CP tracking), Play section (battle size, points indicator, roster selection), Campaign Manager (multi-crusade, performance tracking), Game models (Game, GameAgenda, UnitGameState), complete unit data (27/28 factions, ~1,248 units), Deathwatch pending.

## [0.2.0] – 2026-01-23
Disband Crusade feature, unit role/isEpicHero fields, Adepta Sororitas data, sync/async fixes in OOB UI, navigation fixes on disband.

## [0.1.0] – Initial
Basic crusade CRUD, OOB management (add/edit/delete units/groups), Google Drive sync (push/pull).

## Historical Summary (Pre-0.3.0)
- Early foundation: Flutter/Riverpod setup, Hive storage, GoRouter nav.
- Core features: Crusade/OOB CRUD, Drive backup v1.0, unit data loading.
- Iterations: Bug fixes (async/sync, navigation), UI polish (exit, confirmations), data completeness push.

## Archive (Very Old Entries – Optional Reference)
(Full details of pre-0.3.0 changes available in git history or old changelog versions if needed.)