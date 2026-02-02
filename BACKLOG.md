# BACKLOG.md
**Last Updated:** February 2, 2026 (Post-Sprint Cleanup)

## Tasks

## Bugs
- No remaining bugs in backlog.

## Enhancements
- No remaining enhancements in backlog.

## Features

- **FEA-001 (Medium)**: Add Agenda: Battlefield Survivors
  - **Description**: Implement the Battlefield Survivors agenda for Tyrannic War Crusade mode, allowing players to select units for survival-based XP rewards.
  - **Rules Summary**: At battle start, select up to three units on the battlefield. At battle end: If not destroyed, gain 2XP; if not Below Half-strength, gain 1 additional XP.
  - **Expected UI/Behavior**: Pre-game: Checkbox or multi-select for up to 3 units. In-game: No tracking needed. Post-game: Auto-check unit status, display rewards in recap.
  - **Integration Points**: Tie into unit selection in pre-game setup; post-game recap screen for auto-calculation and display; unit XP update.
  - **Scoring/Effects**: XP only (2 or 3 per unit based on status); no VP or CP.
  - **Any Data Requirements**: JSON entry with name, deed text, max_selections: 3; no in-game tally.

- **FEA-002 (Medium)**: Add Agenda: Swarm the Planet
  - **Description**: Implement the Swarm the Planet agenda, rewarding control of table quarters at battle end.
  - **Rules Summary**: At battle end, for each table quarter with more of your units wholly within it than opponent's, select one of your units there for 2XP.
  - **Expected UI/Behavior**: No pre-game selection. Post-game: Auto-detect quarter control, prompt multi-select for up to 4 units (one per quarter).
  - **Integration Points**: Post-game recap: Calculate quarter control based on unit positions (assume manual input or map integration if exists); unit XP update.
  - **Scoring/Effects**: 2XP per selected unit; up to 8XP if all quarters controlled.
  - **Any Data Requirements**: JSON entry with name, deed text; logic for quarter detection (4 quarters).

- **FEA-003 (Medium)**: Add Agenda: Headhunters
  - **Description**: Implement the Headhunters agenda, rewarding destruction of enemy Characters.
  - **Rules Summary**: Each time your model destroys an enemy CHARACTER unit, its unit gains 2XP; if Warlord, 4XP instead.
  - **Expected UI/Behavior**: Pre-game: No selection. In-game: Tally for Character destroys (track Warlord separately). Post-game: Auto-apply XP based on tallies.
  - **Integration Points**: In-game tally screen: Add "Character Destroyed" + "Was Warlord?" checkbox; post-game XP calc integration.
  - **Scoring/Effects**: 2XP per Character destroy, 4XP for Warlord.
  - **Any Data Requirements**: JSON entry with name, deed text; tally field for characters/warlord.

- **FEA-004 (Medium)**: Add Agenda: Monstrous Targets
  - **Description**: Implement the Monstrous Targets agenda, rewarding destruction of enemy Monsters/Vehicles.
  - **Rules Summary**: Each time your model destroys an enemy MONSTER or VEHICLE (exclude Dedicated Transports), its unit gains 2XP; if Titanic, 4XP instead.
  - **Expected UI/Behavior**: Pre-game: No selection. In-game: Tally for Monster/Vehicle destroys (track Titanic separately). Post-game: Auto-apply XP.
  - **Integration Points**: In-game tally screen: Add "Monster/Vehicle Destroyed" + "Was Titanic?" checkbox; post-game XP calc.
  - **Scoring/Effects**: 2XP per destroy, 4XP for Titanic.
  - **Any Data Requirements**: JSON entry with name, deed text; tally field for monster/vehicle/titanic.

- **FEA-005 (Medium)**: Add Agenda: Eradicate the Swarm
  - **Description**: Implement the Eradicate the Swarm agenda, rewarding high-kill shooting/fighting phases.
  - **Rules Summary**: Each time your unit shoots/fights and destroys 6+ enemy models, it gains 1XP.
  - **Expected UI/Behavior**: Pre-game: No selection. In-game: Per-unit tally for "Shooting/Fight phases with 6+ destroys". Post-game: Auto-apply XP based on tallies.
  - **Integration Points**: In-game tally screen: Add per-unit counter for qualifying phases; post-game XP calc.
  - **Scoring/Effects**: 1XP per qualifying phase.
  - **Any Data Requirements**: JSON entry with name, deed text; unit-level phase tally field.

- **FEA-006 (Medium)**: Add Agenda: Critical Objectives
  - **Description**: Implement the Critical Objectives agenda, rewarding control of opponent-selected objectives.
  - **Rules Summary**: Opponent selects 2 objectives; at battle end, if you control one, select up to 3 units within range of it for 2XP each.
  - **Expected UI/Behavior**: Pre-game: Prompt for opponent-selected objectives (manual input). Post-game: Auto-check control, prompt multi-select for up to 3 units.
  - **Integration Points**: Pre-game setup: Objective input; post-game recap: Control check, unit select/XP apply.
  - **Scoring/Effects**: 2XP per selected unit (up to 6XP).
  - **Any Data Requirements**: JSON entry with name, deed text; objective tracking field.

- **FEA-007 (Medium)**: Add Agenda: Drive Home the Blade
  - **Description**: Implement the Drive Home the Blade agenda, rewarding units deep in enemy territory.
  - **Rules Summary**: At battle end, select up to 3 non-Aircraft units wholly within 6" of opponent's battlefield edge (or deployment zone if no edge) for 3XP each.
  - **Expected UI/Behavior**: No pre-game. Post-game: Prompt multi-select for qualifying units, auto-apply XP.
  - **Integration Points**: Post-game recap: Manual qualify check (user confirmation), unit select/XP apply.
  - **Scoring/Effects**: 3XP per selected unit (up to 9XP).
  - **Any Data Requirements**: JSON entry with name, deed text; no special tally.

- **FEA-008 (Medium)**: Add Agenda: Cleanse Infestation
  - **Description**: Implement the Cleanse Infestation agenda, rewarding tasked units for cleansing objectives.
  - **Rules Summary**: Pre-Shooting: Task a non-Battle-shocked unit to cleanse (can't shoot/charge that turn). At turn end, if in range of controlled infested objective, cleanse it and gain 2XP.
  - **Expected UI/Behavior**: In-game: Per-turn task button for unit, mark as tasked. Post-turn: Auto-check control/range, apply XP if cleansed.
  - **Integration Points**: In-game screen: Task mode/button, objective status; post-turn calc; post-game recap.
  - **Scoring/Effects**: 2XP per successful cleanse.
  - **Any Data Requirements**: JSON entry with name, deed text; objective infested flag, per-unit task state.

- **FEA-009 (Medium)**: Add Agenda: Forward Observers
  - **Description**: Implement the Forward Observers agenda, rewarding tasked reconnaissance units.
  - **Rules Summary**: Pre-Shooting: Task a non-Battle-shocked unit that Remained Stationary to recon (can't shoot/charge). At end of opponent's next turn (or battle end), if wholly in opponent's deployment zone, gain 2XP + 1CP.
  - **Expected UI/Behavior**: In-game: Task button for qualifying unit. End-of-opponent-turn check: Auto-apply rewards if in zone.
  - **Integration Points**: In-game screen: Task mode, position check (manual or map); CP/XP update; post-game recap.
  - **Scoring/Effects**: 2XP + 1CP per successful recon.
  - **Any Data Requirements**: JSON entry with name, deed text; unit task state, deployment zone flag.

- **FEA-010 (Medium)**: Add Agenda: Recover Mission Archives
  - **Description**: Implement the Recover Mission Archives agenda, rewarding tasked archive recovery.
  - **Rules Summary**: Pre-Shooting: Task an Infantry/Mounted non-Battle-shocked unit to recover (can't shoot/charge). At turn end, if in range of controlled objective outside your deployment, roll D6: 4-5 = 1XP, 6 = 2XP + 1CP.
  - **Expected UI/Behavior**: In-game: Task button for qualifying unit. End-turn: Auto-roll D6 (use roller), apply rewards.
  - **Integration Points**: In-game screen: Task mode, objective check; D6 roller integration; CP/XP update; post-game recap.
  - **Scoring/Effects**: 1-2XP + optional 1CP per roll.
  - **Any Data Requirements**: JSON entry with name, deed text; unit task state, objective flag.

- **FEA-011 (Medium)**: Add Agenda: Malefic Hunter
  - **Description**: Implement the Malefic Hunter agenda, rewarding destruction of Psykers/Synapse units.
  - **Rules Summary**: Each time your model destroys enemy PSYKER or SYNAPSE unit, its unit gains 1XP; if Character, +1 additional XP.
  - **Expected UI/Behavior**: Pre-game: No selection. In-game: Tally for Psykers/Synapse destroys (track Character separately). Post-game: Auto-apply XP.
  - **Integration Points**: In-game tally screen: Add "Psyker/Synapse Destroyed" + "Was Character?" checkbox; post-game XP calc.
  - **Scoring/Effects**: 1XP per destroy, +1 if Character.
  - **Any Data Requirements**: JSON entry with name, deed text; tally field for psykers/synapse/character.

## Deferred / Honor-System Items (RP Spend Only – No Enforcement)
- **DEF-001 (Low)**: Stub "Rearm and Resupply" (1 RP deduct, toast/log "Wargear swapped – honor system", no unit/wargear change or UI)
- **DEF-002 (Low)**: Stub "Maintenance and Upgrades" (if rules require; similar RP-only pattern: deduct 1–2 RP, log event)

## Data Fills (Separate Generation)
- **DATA-001 (Medium)**: Full Deathwatch unit data (MFM v3.8 page 19 reference; extract points/flags like prior factions – generate externally)

## Archived/Resolved This Sprint
- **BUG-015 Update (Critical)**: Restore from Google Drive Backup Does Not Recover Campaign Data - Fixed missing await on saveCrusade/saveCampaign calls in restoreFromBackup().
- **ENH-008 (Medium)**: Display Crusade Points on In-Game Screen - Added _CrusadePointsBar widget showing "Crusade Points: X" at top of active game screen.
