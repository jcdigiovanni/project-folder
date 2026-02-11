# BACKLOG.md
**Last Updated:** February 9, 2026 (Post-Sprint Cleanup)

## Tasks

## Bugs
- No remaining bugs in backlog.

## Enhancements
- No remaining enhancements in backlog.

## Features
- **FEA-017 (Medium)**: Add Trials of a Living Saint system for SAINT POTENTIA models
  - **Description**: Implement the full Trials of a Living Saint rules for SAINT POTENTIA models in Adepta Sororitas Crusade forces. This includes tracking Trials, accumulating Saint points, completing Trials, ascension to Living Saint, and associated bonuses/penalties.
  - **Rules Summary** (verbatim from Wahapedia):
    - **Trials of a Living Saint**: Each SAINT POTENTIA model in your Crusade army has a Trial of a Living Saint. At the start of the crusade, randomly determine which Trial that model is undertaking (roll one D6 and consult the table below), or select one of your choice. Each time that model gains Saint points, record them on its Crusade card. When that model reaches the required number of Saint points for its current Trial, it completes that Trial and immediately ascends to become a Living Saint. Remove that model from your Order of Battle and add a LIVING SAINT model to your Order of Battle. The new LIVING SAINT model has the same Battle Honours and Battle Scars as the SAINT POTENTIA model it replaced, and has the same number of XP as the SAINT POTENTIA model it replaced.
    - **Trial Table** (D6):
      1. Trial of Humility – Gain 1 Saint point each time this model is targeted by an enemy unit's attack and survives.
      2. Trial of Purity – Gain 1 Saint point each time this model destroys an enemy PSYKER unit.
      3. Trial of Zeal – Gain 1 Saint point each time this model destroys an enemy unit in the Fight phase.
      4. Trial of Faith – Gain 1 Saint point each time this model performs an Act of Faith.
      5. Trial of Sacrifice – Gain 1 Saint point each time this model suffers a Devastating Blow.
      6. Trial of Martyrdom – Gain 1 Saint point each time this model is destroyed.
    - **Ascension**: When the SAINT POTENTIA model completes its Trial, it ascends to Living Saint. The LIVING SAINT model gains the Living Saint ability (Aura: While a friendly ADEPTA SORORITAS unit is within 6" of this model, each time a model in that unit would lose a wound, roll one D6: on a 5+, that wound is not lost). The LIVING SAINT model cannot gain further Saint points or undertake Trials.
  - **Expected UI/Behavior**:
    - In unit details or Crusade force overview for SAINT POTENTIA models: Show current Trial name (with description), current Saint points / required points progress bar or counter.
    - Pre-crusade or when adding SAINT POTENTIA: Prompt to roll D6 (or select) Trial.
    - During battles: Auto-track Saint points based on conditions (destroy Psykers, Fight phase destroys, Acts of Faith, Devastating Blows, destruction).
    - On Trial completion: Auto-trigger ascension dialog – remove SAINT POTENTIA, add LIVING SAINT with inherited Honours/Scars/XP, apply Living Saint aura ability.
    - UI: Trial progress visible in unit card; ascension confirmation with summary of benefits.
  - **Integration Points**:
    - Unit model: Add fields for `trialId` (1-6 or string), `saintPoints` (current), `maxSaintPoints` (per trial), `isLivingSaint` flag.
    - Saint point triggers: Hook into destroy events (Psyker/Fight phase), Act of Faith, Devastating Blow, unit destruction.
    - Ascension: Replace unit in OOB, inherit data, add Living Saint ability (aura).
    - History log entry for ascension and point gains.
    - Post-game recap: Show Saint point gains and ascension if triggered.
  - **Scoring/Effects**:
    - Per-trial: 1 Saint point per qualifying event (different triggers per Trial).
    - Ascension: Replace SAINT POTENTIA with LIVING SAINT (inherits Honours/Scars/XP).
    - Living Saint: Aura – friendly ADEPTA SORORITAS within 6" get 5+ Feel No Pain equivalent (D6 5+ ignore wound).
  - **Any Data Requirements**:
    - JSON config file (e.g., `adepta-sororitas-trials.json`) with array of trials: id, name, description, trigger condition (for auto-tracking), required points.
    - Unit model extension: trialId, saintPoints, isLivingSaint flag.

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