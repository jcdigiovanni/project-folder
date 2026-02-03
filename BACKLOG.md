# BACKLOG.md
**Last Updated:** February 2, 2026 (Post-Sprint Cleanup)

## Tasks

## Bugs
- No remaining bugs in backlog.

## Enhancements
- No remaining enhancements in backlog.

## Features

- **FEA-012 (Medium)**: Add Agenda: Test of Faith
  - **Description**: Implement the Test of Faith agenda, rewarding units for successful Acts of Faith and punishing Battle-shock failures.
  - **Rules Summary**: Each time a unit performs an Act of Faith, you can discard 1 additional Miracle dice and place it on that unit’s Crusade card. Each time a unit fails a Battle-shock test, remove all Miracle dice from its card. At battle end, each unit gains 1XP per Miracle dice on its card (max 3XP). If a SAINT POTENTIA model gains XP this way, it also gains 1 Saint point.
  - **Expected UI/Behavior**: Pre-game: No selection. In-game: When Act of Faith performed, prompt to discard extra Miracle dice (track count on unit). On Battle-shock fail: Auto-remove dice. Post-game: Auto-calc XP and display in recap.
  - **Integration Points**: Tie into Act of Faith mechanics (if tracked), Battle-shock tests; post-game XP calc/recap; Saint point tracking for Potentia models.
  - **Scoring/Effects**: 1XP per Miracle dice (max 3 per unit); +1 Saint point for Potentia.
  - **Any Data Requirements**: JSON entry with name, deed text; per-unit Miracle dice counter field.

- **FEA-013 (Medium)**: Add Agenda: Atonement in Battle
  - **Description**: Implement the Atonement in Battle agenda, allowing penitent or scarred units to gain XP, remove scars, and earn Redemption points by destroying enemies.
  - **Rules Summary**: Pre-game select up to 3 ADEPTA SORORITAS units that are PENITENT or have Fatigued/Disgraced/Mark of Shame/Battle-weary scars. At battle end, each that destroyed 1+ enemy units gains 3XP, loses one listed scar (your choice), and if REPENTIA SQUAD, gains 1 Redemption point.
  - **Expected UI/Behavior**: Pre-game: Multi-select up to 3 qualifying units. In-game: No tracking. Post-game: Auto-check destroy condition, apply XP/scar removal/Redemption, display in recap.
  - **Integration Points**: Pre-game unit selection (filter for PENITENT/scarred); post-game destroy check; scar removal (link to Repair); Redemption point tracking for Repentia.
  - **Scoring/Effects**: 3XP per qualifying unit; scar removal; +1 Redemption point for Repentia.
  - **Any Data Requirements**: JSON entry with name, deed text, max_selections: 3; qualifying unit filter logic.

- **FEA-014 (Medium)**: Add Agenda: Defend the Shrine
  - **Description**: Implement the Defend the Shrine agenda, with opponent selecting a shrine objective; reward control with XP and potential upgrades/relics/Saint points.
  - **Rules Summary**: After deployment, opponent selects 1 objective not in their zone as Sacred Shrine. Each of your turns if you control it, select 1 unit in range for 1XP. At battle end: If not controlled, lose the normal 1 Requisition point. If controlled, select 1 model in range (no Epic Heroes) for 1 Weapon Modification, 1 Crusade Relic (Characters only), or 3 Saint points (Potentia only).
  - **Expected UI/Behavior**: Pre-game/post-deployment: Prompt opponent objective select (manual input). In-game: Per-turn control check, prompt unit select for XP. Post-game: Control check, penalty warning, prompt model select for reward.
  - **Integration Points**: Objective input/tracking; turn-based control check; post-game Requisition penalty; reward application (Weapon Mod, Relic, Saint points).
  - **Scoring/Effects**: 1XP per turn control select; major reward if final control (no RP if lost).
  - **Any Data Requirements**: JSON entry with name, deed text; objective marker flag for shrine.

- **FEA-015 (Medium)**: Add Agenda: Pious Purgation
  - **Description**: Implement the Pious Purgation agenda, rewarding shooting/fighting phases that destroy enemies, with bonuses for Psykers or Torrent/Melta weapons.
  - **Rules Summary**: Each time an ADEPTA SORORITAS unit shoots/fights and destroys 1+ enemy units, gain 1XP. +1XP if any destroyed were PSYKER; +1XP if any destroyed by Torrent or Melta weapon (max 3XP per unit per battle). SAINT POTENTIA gains +1 Saint point if any XP earned.
  - **Expected UI/Behavior**: Pre-game: No selection. In-game: Per-phase tally for destroys, Psyker flag, Torrent/Melta flag. Post-game: Auto-apply XP (capped), display in recap.
  - **Integration Points**: In-game phase tally (shooting/fight); weapon type check (Torrent/Melta); Psyker detection; post-game XP calc; Saint point for Potentia.
  - **Scoring/Effects**: 1–3XP per unit per battle; +1 Saint point for Potentia.
  - **Any Data Requirements**: JSON entry with name, deed text; per-unit phase tally fields (destroys, Psyker, Torrent/Melta).


## Deferred / Honor-System Items (RP Spend Only – No Enforcement)
- **DEF-001 (Low)**: Stub "Rearm and Resupply" (1 RP deduct, toast/log "Wargear swapped – honor system", no unit/wargear change or UI)
- **DEF-002 (Low)**: Stub "Maintenance and Upgrades" (if rules require; similar RP-only pattern: deduct 1–2 RP, log event)

## Data Fills (Separate Generation)
- **DATA-001 (Medium)**: Full Deathwatch unit data (MFM v3.8 page 19 reference; extract points/flags like prior factions – generate externally)

## Archived/Resolved This Sprint
- **FEA-001 to FEA-011 (Medium)**: 11 Tyrannic War agendas added to core_agendas.json - Battlefield Survivors, Swarm the Planet, Headhunters, Monstrous Targets, Eradicate the Swarm, Critical Objectives, Drive Home the Blade, Cleanse Infestation, Forward Observers, Recover Mission Archives, Malefic Hunter.
- **BUG-015 Update (Critical)**: Restore from Google Drive Backup Does Not Recover Campaign Data - Fixed missing await on saveCrusade/saveCampaign calls in restoreFromBackup().
- **ENH-008 (Medium)**: Display Crusade Points on In-Game Screen - Added _CrusadePointsBar widget showing "Crusade Points: X" at top of active game screen.
