# BACKLOG.md
**Last Updated:** February 9, 2026 (Post-Sprint Cleanup)

## Tasks

## Bugs
- No remaining bugs in backlog.

## Enhancements
- No remaining enhancements in backlog.

## Features
## Features (FEA – Adepta Sororitas Requisitions)

- **FEA-001 (Medium)**: Add Requisition: Divine Calling
  - **Description**: Implement Divine Calling, allowing a SAINT POTENTIA model to abandon a Trial and start a new one with partial Saint points.
  - **Rules Summary**: Cost: 1 RP. Purchase at the end of a battle when your SAINT POTENTIA model abandons its current Trial and starts a new one. After resetting its Saint points to 0, it gains a number of Saint points towards its new Trial equal to half the number of Saint points it had gained towards that abandoned Trial (rounding up).
  - **Expected UI/Behavior**: In Requisitions screen: Select SAINT POTENTIA model with current Trial, spend 1 RP, confirm abandonment, auto-calculate and apply half Saint points (rounded up) to new Trial, reset old.
  - **Integration Points**: Requisition screen/tab; RP deduction/validation; SAINT POTENTIA model tracking (Saint points, Trial status); history log entry; confirmation dialog.
  - **Scoring/Effects**: Reset Saint points to 0 on old Trial, add half (rounded up) to new Trial.
  - **Any Data Requirements**: JSON entry with name, cost: 1, description, eligibility (SAINT POTENTIA model with current Trial); Saint points calculation logic.

- **FEA-002 (Medium)**: Add Requisition: Ascension to the Order
  - **Description**: Implement Ascension to the Order, upgrading a Sisters Novitiates Squad to an Orders Militant squad.
  - **Rules Summary**: Cost: 2 RP. Purchase before a battle. Select one SISTERS NOVITIATES SQUAD unit on your Order of Battle with the Blooded rank or higher. Remove that unit from your Order of Battle and add one BATTLE SISTERS SQUAD, DOMINION SQUAD or RETRIBUTOR SQUAD unit to your Order of Battle. The new unit has the same Battle Honours and Battle Scars as the unit it replaced, and has 5 more XP than the unit it replaced.
  - **Expected UI/Behavior**: In Requisitions screen: Filter eligible SISTERS NOVITIATES SQUAD (Blooded+ rank), spend 2 RP, select new squad type, confirm upgrade, transfer Battle Honours/Scars/XP (+5 XP), update OOB.
  - **Integration Points**: Requisition screen/tab; RP deduction/validation; unit upgrade logic (remove old, add new); Battle Honours/Scars/XP transfer; OOB update; history log entry.
  - **Scoring/Effects**: New unit inherits Honours/Scars +5 XP.
  - **Any Data Requirements**: JSON entry with name, cost: 2, description, eligibility (SISTERS NOVITIATES SQUAD, Blooded+ rank); upgrade options list (BATTLE SISTERS, DOMINION, RETRIBUTOR).

- **FEA-003 (Medium)**: Add Requisition: The Penitent Path
  - **Description**: Implement The Penitent Path, converting a squad to a penitent or mortifier unit after a Devastating Blow.
  - **Rules Summary**: Cost: 2 RP. Purchase before a battle. Select one of the following: Select one BATTLE SISTERS SQUAD, DOMINION SQUAD or RETRIBUTOR SQUAD unit on your Order of Battle that has suffered a Devastating Blow result. Remove that unit from your Order of Battle and add one REPENTIA SQUAD unit to your Order of Battle. Select one REPENTIA SQUAD unit on your Order of Battle that has suffered a Devastating Blow result. Remove that unit from your Order of Battle and add one MORTIFIERS unit to your Order of Battle. In either case, the new unit has the same Battle Honours, Battle Scars and XP as the unit it replaced, and until it is removed from your Order of Battle, it will gain 2XP from Dealers of Death, instead of just 1XP.
  - **Expected UI/Behavior**: In Requisitions screen: Filter eligible squads (with Devastating Blow), spend 2 RP, select upgrade path, confirm, transfer Honours/Scars/XP, apply Dealers of Death bonus (2XP instead of 1).
  - **Integration Points**: Requisition screen/tab; RP deduction/validation; unit upgrade logic; Battle Honours/Scars/XP transfer; Dealers of Death XP bonus flag; OOB update; history log entry.
  - **Scoring/Effects**: New unit inherits Honours/Scars/XP; +2XP from Dealers of Death.
  - **Any Data Requirements**: JSON entry with name, cost: 2, description, eligibility (specific squads with Devastating Blow); upgrade options (REPENTIA SQUAD, MORTIFIERS); Dealers of Death bonus flag.

- **FEA-004 (Medium)**: Add Requisition: Glorious Redemption
  - **Description**: Implement Glorious Redemption, upgrading a Repentia Squad with 3 Redemption points to a elite squad.
  - **Rules Summary**: Cost: 1 RP. Purchase before a battle. Select one REPENTIA SQUAD unit on your Order of Battle that has 3 Redemption points (see the Atonement in Battle Agenda). Remove that unit from your Order of Battle and add a SERAPHIM SQUAD, ZEPHYRIM SQUAD, CELESTIAN SACRESANTS or PARAGON WARSUITS unit to your Order of Battle. The new unit has the same Battle Honours and Battle Scars as the unit it replaced, and gains one Battle Trait of your choice (this must be a Battle Trait it can have, but does not count towards the maximum number of Battle Traits a unit can have). If the Legendary Veterans Requisition is used on this unit, that Requisition only costs you 1RP.
  - **Expected UI/Behavior**: In Requisitions screen: Filter REPENTIA SQUAD with 3 Redemption points, spend 1 RP, select new squad type, confirm, transfer Honours/Scars, add extra Battle Trait, note Legendary Veterans discount.
  - **Integration Points**: Requisition screen/tab; RP deduction/validation; unit upgrade logic; Honours/Scars transfer; extra Battle Trait addition (bypass max); Legendary Veterans cost override; OOB update; history log entry.
  - **Scoring/Effects**: New unit inherits Honours/Scars; +1 Battle Trait; Legendary Veterans costs 1RP.
  - **Any Data Requirements**: JSON entry with name, cost: 1, description, eligibility (REPENTIA SQUAD with 3 Redemption points); upgrade options (SERAPHIM, ZEPHYRIM, CELESTIAN SACRESANTS, PARAGON WARSUITS); Battle Trait addition flag.

- **FEA-005 (Medium)**: Add Requisition: In Suffering, Enlightenment
  - **Description**: Implement In Suffering, Enlightenment, allowing intentional failure of Out of Action test for Battle Scar/Honour and Saint/Martyr points.
  - **Rules Summary**: Cost: 1 RP. Purchase after a battle, before an ADEPTA SORORITAS unit from your Crusade army takes an Out of Action test. That test is automatically failed and that unit gains 1 Battle Scar and 1 Battle Honour of your choice. If that unit was a SAINT POTENTIA, it also gains 3 Saint points and 1 Martyr point. You cannot use this Requisition on the same unit more than once.
  - **Expected UI/Behavior**: In Requisitions screen: Filter eligible ADEPTA SORORITAS unit before Out of Action test, spend 1 RP, confirm intentional fail, apply Battle Scar/Honour, add Saint/Martyr points if SAINT POTENTIA, enforce once-per-unit.
  - **Integration Points**: Requisition screen/tab; RP deduction/validation; Out of Action override; Battle Scar/Honour addition; Saint/Martyr point tracking; once-per-unit flag; history log entry.
  - **Scoring/Effects**: +1 Battle Scar +1 Battle Honour; +3 Saint points +1 Martyr point if SAINT POTENTIA.
  - **Any Data Requirements**: JSON entry with name, cost: 1, description, eligibility (ADEPTA SORORITAS unit before Out of Action, not used on unit before); once-per-unit flag.

- **FEA-006 (Medium)**: Add Requisition: Saintly Benedictions
  - **Description**: Implement Saintly Benedictions, setting initial Miracle dice to 6 for the first battle round.
  - **Rules Summary**: Cost: 1 RP. Purchase before a battle. During the first battle round of that battle, each of the Miracle dice you gain at the start of each player’s turn is automatically a 6.
  - **Expected UI/Behavior**: In Requisitions screen: Spend 1 RP, confirm, set initial Miracle dice to 6 for first round (track in game state).
  - **Integration Points**: Requisition screen/tab; RP deduction/validation; Miracle dice generation override (first round only); game state tracking; history log entry.
  - **Scoring/Effects**: Initial Miracle dice auto-6 in first round.
  - **Any Data Requirements**: JSON entry with name, cost: 1, description, eligibility (pre-battle); first-round dice override flag.

## Deferred / Honor-System Items (RP Spend Only – No Enforcement)
- **DEF-002 (Low)**: Stub "Maintenance and Upgrades" (if rules require; similar RP-only pattern: deduct 1–2 RP, log event)

## Data Fills (Separate Generation)
- **DATA-001 (Medium)**: Full Deathwatch unit data (MFM v3.8 page 19 reference; extract points/flags like prior factions – generate externally)

## Archived/Resolved This Sprint
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