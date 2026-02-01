# Changelog

All notable changes to the Crusade Bridge project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Out of Action (OOA) & Battle Scars system** — Post-game integration, per-unit/batch resolution, 1D6 roll with auto-pass (Epic/Fort/Swarm), prompt on 1 for Devastating Blow or Scar, scar table roll (D6), effect application, scar tracking in model, Repair requisition link, dedicated UI step, visual indicators on unit cards.
- **Battle Honours & Rank-Up Flow** — Claim button in unit details, modal with manual/roll options, integrated D6/2D6 rolls for Traits/Weapon Enhancements (duplicate reroll), Crusade Relics dropdown (Characters only, limit 1), Psychic Fortitudes, model fields (battleTraits, weaponEnhancements, crusadeRelic), honours.json data file, history logging, Renowned Heroes integration.
- **Reusable D6 Roller Widget** — lib/widgets/d6_roller.dart, supports 1D6/2D6/D3, animated shake, Epic Hero skip, reroll button, modal helper (showD6RollerModal), DiceResult class, widget tests.

### Changed
- RP cap enforced at 10; post-game RP award only if under cap.
- Active game kill tally now shows XP progress (3 dots + earned badge); survived/destroyed toggle as segmented button.

### Fixed
- BUG-004: Marked for Greatness +3 XP (was +1).
- BUG-002: Supply Limit persistence fixed.
- BUG-003: OOB data loss in group disband/edit, enhancement add.

### Improved
- Explicit close buttons on modals (ENH-001).
- RP/CP/Supply dashboard on OOB screen (ENH-003).

### Planned
- Enhanced agendas (pre-game selection, in-game tracking, post-game recap).
- Bug clearance (Exit button, local data clear, save issues).
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