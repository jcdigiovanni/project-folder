# BACKLOG.md
**Last Updated:** February 9, 2026 (Post-Sprint Cleanup)

## Tasks

## Bugs
- No remaining bugs in backlog.

## Enhancements
- No remaining enhancements in backlog.

## Features

## Features (FEA – Drukhari Agendas)

- **DRU-FEA-001 (Medium)**: Add Agenda: Sublime Agonies
  - **Description**: Implement Sublime Agonies, accumulating Pain tokens for XP and Ascendant Lord bonuses.
  - **Rules Summary**: On Empower with Pain token, spend 1 extra and place on unit card. Post-game: Select up to 6 units with tokens for 1XP per token (max 3XP). If Ascendant Lord gained 2+ XP, +1 to territory D6.
  - **Expected UI/Behavior**: In-game: Prompt extra Pain spend on Empower. Post-game: Prompt unit select/XP apply, display territory bonus.
  - **Integration Points**: Pain token mechanics; post-game XP/territory roll.
  - **Scoring/Effects**: Max 3XP per unit; territory bonus.
  - **Any Data Requirements**: JSON entry with name, deed text; per-unit Pain token counter.

- **DRU-FEA-002 (Medium)**: Add Agenda: Demonstrate Superiority
  - **Description**: Implement Demonstrate Superiority, rewarding Ascendant Lord for specific conditions.
  - **Rules Summary**: Post-game Ascendant Lord gains 1XP per condition (Beasts/Arena, Trophy-hunter, Deadly Reaver, Send a Message, Power Monger). If 3+ XP, next territory select instead of roll.
  - **Expected UI/Behavior**: Post-game auto-check conditions, display XP/territory bonus.
  - **Integration Points**: Condition detection (destroys, position, Empower count); territory rules.
  - **Scoring/Effects**: Variable XP; territory select.
  - **Any Data Requirements**: JSON entry with name, deed text; condition list.

- **DRU-FEA-003 (Medium)**: Add Agenda: To Feed the Dark City
  - **Description**: Implement To Feed the Dark City, rewarding melee destroys for XP and Rival Activity re-roll.
  - **Rules Summary**: Melee destroy: unit gains 1XP (2XP if Character/Monster). Max 4XP per unit. If Ascendant Lord 3+ XP, re-roll Rival Activity.
  - **Expected UI/Behavior**: In-game melee tally. Post-game auto-apply XP, display re-roll option.
  - **Integration Points**: Melee destroy detection; Rival Activity rules.
  - **Scoring/Effects**: Max 4XP per unit; re-roll.
  - **Any Data Requirements**: JSON entry with name, deed text; tally field.

- **DRU-FEA-004 (Medium)**: Add Agenda: Fear’s Cold Grip
  - **Description**: Implement Fear’s Cold Grip, rewarding Battle-shock failures and destroys.
  - **Rules Summary**: Enemy Battle-shock fail: select DRUKHARI unit within 12" for 2XP. Battle-shocked destroy: unit gains 2XP. Max 4XP per unit.
  - **Expected UI/Behavior**: In-game auto-tally on Battle-shock/destroy. Post-game capped XP.
  - **Integration Points**: Battle-shock detection; post-game calc.
  - **Scoring/Effects**: Max 4XP per unit.
  - **Any Data Requirements**: JSON entry with name, deed text; tally field.

- **DRU-FEA-005 (Medium)**: Add Agenda: Herd the Prey
  - **Description**: Implement Herd the Prey, forming triangle to trap enemies for XP/RP.
  - **Rules Summary**: Post-game select 3 units on battlefield, form triangle; if 1+ enemy wholly within = 2XP each; 2+ = 3XP each + 1RP.
  - **Expected UI/Behavior**: Post-game prompt 3 unit select, auto-check trapped enemies, apply XP/RP.
  - **Integration Points**: Post-game triangle logic, RP update.
  - **Scoring/Effects**: 2-3XP per unit + optional RP.
  - **Any Data Requirements**: JSON entry with name, deed text; maxUnits: 3.

## Features (FEA – Thousand Sons Agendas)

- **TS-FEA-001 (Medium)**: Add Agenda: Pursuit of Knowledge
  - **Description**: Implement Pursuit of Knowledge, rewarding deployment zone dominance for XP/Lore points.
  - **Rules Summary**: Post-game if more units in opponent deployment than opponent in yours (exclude Battle-shocked), select up to 3 for 2XP; Characters roll D6: 2+ = 1 Lore point.
  - **Expected UI/Behavior**: Post-game auto-check dominance, prompt select/XP/Lore.
  - **Integration Points**: Deployment zone check; Lore point tracking.
  - **Scoring/Effects**: 2XP + optional Lore.
  - **Any Data Requirements**: JSON entry with name, deed text, maxUnits: 3.

- **TS-FEA-002 (Medium)**: Add Agenda: Malefic Sigils
  - **Description**: Implement Malefic Sigils, casting sigils per quarter for XP and Plots re-roll.
  - **Rules Summary**: Per-turn PSYKER manifest in quarter casts sigil. 3 quarters = 1XP each caster; 4 = 1XP each + Warlord XP. If Warlord 2+ XP, re-roll Plots and Schemes test.
  - **Expected UI/Behavior**: In-game per-turn sigil cast prompt/check. Post-game XP/re-roll display.
  - **Integration Points**: Manifest detection, quarter tracking; Plots test.
  - **Scoring/Effects**: Variable XP; re-roll.
  - **Any Data Requirements**: JSON entry with name, deed text; per-quarter sigil state.

- **TS-FEA-003 (Medium)**: Add Agenda: Arcana Long Buried
  - **Description**: Implement Arcana Long Buried, searching objectives for XP/Arcana.
  - **Rules Summary**: Pre-Shooting task unit to search controlled objective. Success: 2XP (3 if opponent zone), D6: 3+ Character = 1 Arcana point. Max 3XP per unit.
  - **Expected UI/Behavior**: In-game task prompt. End-turn auto-check/XP/Arcana.
  - **Integration Points**: Objective search task; Arcana tracking.
  - **Scoring/Effects**: 2-3XP + optional Arcana.
  - **Any Data Requirements**: JSON entry with name, deed text; per-objective searched flag.

- **TS-FEA-004 (Medium)**: Add Agenda: Sorcerous Prowess
  - **Description**: Implement Sorcerous Prowess, rewarding Psychic destroys for XP and free Diabolic Ritual.
  - **Rules Summary**: PSYKER destroy: 1XP (2XP if Psychic attack). Max 3XP per unit. If Character 2+ XP, select for Diabolic Ritual 0RP.
  - **Expected UI/Behavior**: In-game tally Psychic destroys. Post-game capped XP/free Requisition prompt.
  - **Integration Points**: Psychic attack detection; Diabolic Ritual.
  - **Scoring/Effects**: Max 3XP; free Requisition.
  - **Any Data Requirements**: JSON entry with name, deed text; tally field.

## Features (FEA – Grey Knights Agendas)

- **GK-FEA-001 (Medium)**: Add Agenda: Purge Corruption
  - **Description**: Implement Purge Corruption, purging table quarters for XP and Vision/Banishment rewards.
  - **Rules Summary**: Pre-Shooting task unit to purge quarter (no shoot/charge). Success if alone in quarter: 1XP. Max 3XP per unit. Post-game D6 + purged quarters: 7+ = change Vision to Sanctic or +1 Banishment point.
  - **Expected UI/Behavior**: In-game task prompt. Next turn auto-check/XP. Post-game roll/reward.
  - **Integration Points**: Quarter purge task; Vision/Banishment tracking.
  - **Scoring/Effects**: Max 3XP; Vision/Banishment.
  - **Any Data Requirements**: JSON entry with name, deed text; per-quarter corrupted/purged state.

- **GK-FEA-002 (Medium)**: Add Agenda: Empyric Interdiction
  - **Description**: Implement Empyric Interdiction, rewarding Deep Strike destroys for XP and Vision/Banishment.
  - **Rules Summary**: Deep Strike arrive + destroy: 1XP. Max 3XP per unit. Post-game D6 + units gained XP: 7+ = Vision to Sanctic or +1 Banishment.
  - **Expected UI/Behavior**: In-game auto on Deep Strike destroy. Post-game roll/reward.
  - **Integration Points**: Deep Strike detection; Vision/Banishment.
  - **Scoring/Effects**: Max 3XP; Vision/Banishment.
  - **Any Data Requirements**: JSON entry with name, deed text.

- **GK-FEA-003 (Medium)**: Add Agenda: Unmake Omens
  - **Description**: Implement Unmake Omens, controlling objectives for XP and Vision/Banishment.
  - **Rules Summary**: Post-game select up to 3 units on different controlled objectives: 2XP each. D6 + controlled objectives: 7+ = Vision to Sanctic or +1 Banishment.
  - **Expected UI/Behavior**: Post-game prompt select/XP, roll/reward.
  - **Integration Points**: Objective control; Vision/Banishment.
  - **Scoring/Effects**: 2XP per unit; Vision/Banishment.
  - **Any Data Requirements**: JSON entry with name, deed text, maxUnits: 3.

- **GK-FEA-004 (Medium)**: Add Agenda: Destroy the Infernal
  - **Description**: Implement Destroy the Infernal, rewarding Chaos destroys for XP and Banishment.
  - **Rules Summary**: Chaos destroy: 1XP (2XP if Monster/Vehicle). Max 4XP per unit. If Chaos Incursion and 3+ units gained XP: D3 Banishment points.
  - **Expected UI/Behavior**: In-game tally Chaos destroys. Post-game capped XP/Banishment.
  - **Integration Points**: Chaos detection; Banishment tracking.
  - **Scoring/Effects**: Max 4XP; D3 Banishment.
  - **Any Data Requirements**: JSON entry with name, deed text; tally field.

- **GK-FEA-005 (Medium)**: Add Agenda: No Witnesses
  - **Description**: Implement No Witnesses, rewarding table wipe for XP, Banishment, RP.
  - **Rules Summary**: Post-game no enemy units: each on-battlefield unit 2XP; if Chaos Incursion: +1 Banishment +1RP.
  - **Expected UI/Behavior**: Post-game auto-check wipe/XP/Banishment/RP.
  - **Integration Points**: Victory check; Banishment/RP.
  - **Scoring/Effects**: 2XP per unit; Banishment/RP.
  - **Any Data Requirements**: JSON entry with name, deed text.

## Features (FEA – Chaos Knights Agendas)

- **CK-FEA-001 (Medium)**: Add Agenda: Malicious Hunt
  - **Description**: Implement Malicious Hunt, hunting highest-Wounds Prey for XP and War Dog Domination.
  - **Rules Summary**: Prey = highest Wounds enemy (exclude Transport). If destroyed by Chaos Knights: unit gains 3XP. If War Dog: +1 War Dog Domination level.
  - **Expected UI/Behavior**: Pre-game auto-Prey select. Post-game check destroy/XP/Domination.
  - **Integration Points**: Prey detection; Domination tracking.
  - **Scoring/Effects**: 3XP; Domination level.
  - **Any Data Requirements**: JSON entry with name, deed text.

- **CK-FEA-002 (Medium)**: Add Agenda: Tear Down the False Gods
  - **Description**: Implement Tear Down the False Gods, desecrating Sacred Sites for XP and Dark Gods level.
  - **Rules Summary**: Opponent sets 3 Sacred Sites. Control + desecrate: select unit in range for 2XP. 2+ desecrated: +1 Dark Gods level.
  - **Expected UI/Behavior**: Pre-game opponent site input. Per-Command/end check desecrate/XP/level.
  - **Integration Points**: Site markers; Dark Gods tracking.
  - **Scoring/Effects**: 2XP per desecrate; level increase.
  - **Any Data Requirements**: JSON entry with name, deed text; site flags.

- **CK-FEA-003 (Medium)**: Add Agenda: Seize Riches
  - **Description**: Implement Seize Riches, destroying enhanced units for XP/tech-trophies and Idolators level.
  - **Rules Summary**: Destroy within 6" with Enhancement/Relic: 2XP +1 tech-trophy. 2+ trophies: +1 Idolators Influence level.
  - **Expected UI/Behavior**: In-game tally enhanced destroys. Post-game trophies/level.
  - **Integration Points**: Enhancement/Relic detection; Idolators tracking.
  - **Scoring/Effects**: 2XP per; level increase.
  - **Any Data Requirements**: JSON entry with name, deed text; trophy counter.

- **CK-FEA-004 (Medium)**: Add Agenda: Tyrannical Domination
  - **Description**: Implement Tyrannical Domination, controlling non-deployment objectives for XP.
  - **Rules Summary**: Rounds 3-5: per non-deployment controlled objective, select Titanic unit in range for 1XP. Post-game Warlord XP = controlled non-deployment objectives.
  - **Expected UI/Behavior**: Per-round prompt select/XP. Post-game Warlord XP.
  - **Integration Points**: Objective control; round tracking.
  - **Scoring/Effects**: Variable XP.
  - **Any Data Requirements**: JSON entry with name, deed text.

## Features (FEA – Death Guard Agendas)

- **DG-FEA-001 (Medium)**: Add Agenda: Sow the Seeds of Corruption
  - **Description**: Implement Sow the Seeds of Corruption, seeding objectives for XP and Fecundity increase.
  - **Rules Summary**: Select 1 objective per zone. End-turn if Infantry in range/no enemy: seed + select unit 2XP. Post-game 2 seeded: D6 4+ +1 Fecundity; 3 seeded: +1 Fecundity.
  - **Expected UI/Behavior**: Pre-game objective select. End-turn auto-seed/XP. Post-game roll/Fecundity.
  - **Integration Points**: Objective seeding; Fecundity characteristic.
  - **Scoring/Effects**: 2XP per seed; Fecundity increase.
  - **Any Data Requirements**: JSON entry with name, deed text; per-objective seeded flag.

- **DG-FEA-002 (Medium)**: Add Agenda: Unwitting Vectors
  - **Description**: Implement Unwitting Vectors, rolling for surviving enemies to increase Survival Rate.
  - **Rules Summary**: Post-game D6 per enemy unit (+2 if Below Starting Strength). 6+ = +1 Survival Rate + select non-destroyed unit 3XP.
  - **Expected UI/Behavior**: Post-game auto-roll per enemy, apply rate/XP.
  - **Integration Points**: Survival Rate characteristic.
  - **Scoring/Effects**: +1 Survival Rate; 3XP.
  - **Any Data Requirements**: JSON entry with name, deed text.

- **DG-FEA-003 (Medium)**: Add Agenda: Viral Harvest
  - **Description**: Implement Viral Harvest, exhuming No Man’s Land objectives for XP and Adaptability.
  - **Rules Summary**: Pre-Shooting task Infantry to exhume controlled Vector Target (no shoot/charge). Success: 1XP. Post-game D6 + successes: 7+ +1 Adaptability.
  - **Expected UI/Behavior**: In-game task prompt. End-turn auto-check/XP. Post-game roll/Adaptability.
  - **Integration Points**: Vector Target flags; Adaptability characteristic.
  - **Scoring/Effects**: Max 3XP per unit; Adaptability increase.
  - **Any Data Requirements**: JSON entry with name, deed text; per-objective exhumed flag.

- **DG-FEA-004 (Medium)**: Add Agenda: Vile Research
  - **Description**: Implement Vile Research, tallying Afflicted destroys for XP and Tailor the Toxins.
  - **Rules Summary**: Afflicted destroy: +1 research tally +1XP (max 3 per unit). Post-game 1-3 tally = Tailor Toxins once; 4+ = twice.
  - **Expected UI/Behavior**: In-game tally Afflicted destroys. Post-game capped XP/Tailor prompts.
  - **Integration Points**: Afflicted detection; Tailor the Toxins Requisition.
  - **Scoring/Effects**: Max 3XP per unit; Tailor uses.
  - **Any Data Requirements**: JSON entry with name, deed text; research tally.

## Features (FEA – World Eaters Agendas)

- **WE-FEA-001 (Medium)**: Add Agenda: Blood for the Blood God!
  - **Description**: Implement Blood for the Blood God!, rewarding melee destroys but punishing Fall Back.
  - **Rules Summary**: Melee destroy: unit gains 1XP (max 3 per battle). Note Fall Back moves; post-game each Fall Back unit takes Out of Action test.
  - **Expected UI/Behavior**: In-game melee tally. Track Fall Back. Post-game capped XP/OOA tests.
  - **Integration Points**: Melee destroy detection; OOA tests.
  - **Scoring/Effects**: Max 3XP per unit; OOA risk.
  - **Any Data Requirements**: JSON entry with name, deed text; per-unit Fall Back flag.

- **WE-FEA-002 (Medium)**: Add Agenda: Skulls for the Skull Throne!
  - **Description**: Implement Skulls for the Skull Throne!, rewarding Character/Monster melee destroys.
  - **Rules Summary**: Melee destroy Character/Monster: 2XP (4XP if Warlord). Max 5XP per unit. 4+ XP = +1 Skull point.
  - **Expected UI/Behavior**: In-game melee tally Character/Monster/Warlord. Post-game capped XP/Skull point.
  - **Integration Points**: Skull Harvest tracking.
  - **Scoring/Effects**: Max 5XP; Skull point.
  - **Any Data Requirements**: JSON entry with name, deed text; tally field.

- **WE-FEA-003 (Medium)**: Add Agenda: Anoint the Field
  - **Description**: Implement Anoint the Field, anointing/drowning quarters for XP and Judgement bonus.
  - **Rules Summary**: Enemy wholly in quarter destroyed: anoint (twice = drown). Post-game 3 drowned = 2XP each non-destroyed; 4 = 3XP + +1 Judgement roll.
  - **Expected UI/Behavior**: In-game quarter anoint tally. Post-game XP/Judgement bonus.
  - **Integration Points**: Quarter tracking; Judgement rules.
  - **Scoring/Effects**: Variable XP; Judgement bonus.
  - **Any Data Requirements**: JSON entry with name, deed text; per-quarter anoint counter.

- **WE-FEA-004 (Medium)**: Add Agenda: A Tribute to Murder
  - **Description**: Implement A Tribute to Murder, exalting Veneration Sites for XP and free Requisition.
  - **Rules Summary**: Pre-Shooting task unit to exalt controlled unexalted site (no shoot/charge). Success: 2XP. 3+ exalted = one World Eaters Requisition 0RP.
  - **Expected UI/Behavior**: In-game task prompt. End-turn auto-check/XP. Post-game free Requisition.
  - **Integration Points**: Veneration Site flags; Requisition rules.
  - **Scoring/Effects**: 2XP per exalt; free Requisition.
  - **Any Data Requirements**: JSON entry with name, deed text; per-site exalted flag.

## Features (FEA – Tyranids Agendas)

- **TYR-FEA-001 (Medium)**: Add Agenda: Infest the Prey World
  - **Description**: Implement Infest the Prey World, gaining Biomass points for quarter control and XP for deployment zone units.
  - **Rules Summary**: At battle end, gain 1 Biomass point for each table quarter with more ENDLESS MULTITUDE units wholly within it (not within 6" of battlefield center). Each ENDLESS MULTITUDE unit wholly within opponent’s deployment zone gains 2XP.
  - **Expected UI/Behavior**: Post-game auto-detect quarter control and deployment zone units, display Biomass/XP gains in recap.
  - **Integration Points**: Quarter detection logic; Biomass point tracking; post-game XP apply.
  - **Scoring/Effects**: 1 Biomass per qualifying quarter; 2XP per qualifying unit.
  - **Any Data Requirements**: JSON entry with name, deed text; quarter control check.

- **TYR-FEA-002 (Medium)**: Add Agenda: Hunt and Slay
  - **Description**: Implement Hunt and Slay, opponent selects Prey Targets for XP and Biomass rewards.
  - **Rules Summary**: Opponent selects up to 5 Prey Targets. Each Fight phase destroy of Prey Target noted. Post-game: destroying unit gains XP = 2x Prey Targets destroyed; force gains Biomass (1 for 2-3, D3 for 4+).
  - **Expected UI/Behavior**: Pre-game opponent input for Prey Targets. In-game Fight phase tally. Post-game auto-calc XP/Biomass, display in recap.
  - **Integration Points**: Prey Target selection; Fight phase destroy detection; Biomass tracking.
  - **Scoring/Effects**: Variable XP per unit; Biomass based on total destroys.
  - **Any Data Requirements**: JSON entry with name, deed text; Prey Target list, Biomass table.

- **TYR-FEA-003 (Medium)**: Add Agenda: Tyrannoform the Prey World
  - **Description**: Implement Tyrannoform the Prey World, implanting spores for XP and Biomass.
  - **Rules Summary**: Pre-Shooting select INFANTRY (non-Character) >12" from existing markers to implant spore (no shoot/charge). End-turn place marker within 1". Post-game: implanting unit gains 2x markers XP; force gains Biomass (1 for 3, D3 for 4, 3 for 5+).
  - **Expected UI/Behavior**: In-game pre-Shooting prompt for implant, place marker. Post-game auto-calc XP/Biomass.
  - **Integration Points**: Spore marker placement/tracking; post-game calc.
  - **Scoring/Effects**: Variable XP per unit; Biomass based on total markers.
  - **Any Data Requirements**: JSON entry with name, deed text; spore marker counter.

- **TYR-FEA-004 (Medium)**: Add Agenda: Tyranid Attack
  - **Description**: Implement Tyranid Attack, rewarding table wipe for XP, Biomass, and Battles Played.
  - **Rules Summary**: Post-game no enemy models remaining: each on-battlefield TYRANIDS unit gains 3XP; force gains 4 Biomass + 2 Battles Played points (instead of 1).
  - **Expected UI/Behavior**: Post-game auto-check wipe, apply rewards, display in recap.
  - **Integration Points**: Victory check; Biomass/Battles Played tracking.
  - **Scoring/Effects**: 3XP per unit; 4 Biomass + extra Battles Played.
  - **Any Data Requirements**: JSON entry with name, deed text.

## Features (FEA – Orks Agendas)

- **ORK-FEA-001 (Medium)**: Add Agenda: Scrap ’Em
  - **Description**: Implement Scrap ’Em, rewarding engagement/destruction of enemy Vehicles for XP and Stompin’ points.
  - **Rules Summary**: Post-game each ORKS unit in Engagement Range of enemy VEHICLE or destroyed VEHICLE in melee gains 1XP. If MEK unit gained XP, force gains 2 Stompin’ points.
  - **Expected UI/Behavior**: Post-game auto-check conditions, apply XP/Stompin’, display in recap.
  - **Integration Points**: Vehicle detection; Stompin’ points tracking.
  - **Scoring/Effects**: 1XP per qualifying unit; 2 Stompin’ if MEK.
  - **Any Data Requirements**: JSON entry with name, deed text.

- **ORK-FEA-002 (Medium)**: Add Agenda: Show ’Em How It’s Done
  - **Description**: Implement Show ’Em How It’s Done, rewarding Warlord destroys of key enemies.
  - **Rules Summary**: Warlord destroy Character/Monster/Vehicle: gains 2XP (3XP if Waaagh!boss).
  - **Expected UI/Behavior**: In-game tally Warlord destroys. Post-game apply XP.
  - **Integration Points**: Destroy detection; Waaagh!boss check.
  - **Scoring/Effects**: 2-3XP to Warlord.
  - **Any Data Requirements**: JSON entry with name, deed text.

- **ORK-FEA-003 (Medium)**: Add Agenda: Skrag Da Killiest Gitz
  - **Description**: Implement Skrag Da Killiest Gitz, targeting highest-points enemy for XP and Stompin’.
  - **Rules Summary**: Pre-game opponent selects highest-points enemy as Da Killiest Gitz. Below Half-strength by ORKS attack: 3XP to attacker. Destroyed: 3XP to destroyer + 3 Stompin’ to force.
  - **Expected UI/Behavior**: Pre-game input for target. In-game track status. Post-game apply XP/Stompin’.
  - **Integration Points**: Target selection; Stompin’ tracking.
  - **Scoring/Effects**: 3XP per event; 3 Stompin’ on destroy.
  - **Any Data Requirements**: JSON entry with name, deed text.

- **ORK-FEA-004 (Medium)**: Add Agenda: Overwhelming Aggression
  - **Description**: Implement Overwhelming Aggression, rewarding quarter dominance for XP and Stompin’.
  - **Rules Summary**: Post-game per quarter with more ORKS units wholly within: select 1 for 2XP. If all 4 quarters, +2 Stompin’.
  - **Expected UI/Behavior**: Post-game auto-detect dominance, prompt select/XP, apply Stompin’.
  - **Integration Points**: Quarter control check; Stompin’ tracking.
  - **Scoring/Effects**: 2XP per selected unit; 2 Stompin’ if all quarters.
  - **Any Data Requirements**: JSON entry with name, deed text.

## Features (FEA – Necrons Agendas)

- **NEC-FEA-001 (Medium)**: Add Agenda: The Unending Tally
  - **Description**: Implement The Unending Tally, rewarding Destroyer Cult multi-destroys.
  - **Rules Summary**: DESTROYER CULT unit destroys 2+ enemy units in a battle round: gains 2XP.
  - **Expected UI/Behavior**: In-game round tally for Destroyer Cult. Post-round apply XP.
  - **Integration Points**: Round destroy detection.
  - **Scoring/Effects**: 2XP per qualifying round.
  - **Any Data Requirements**: JSON entry with name, deed text.

- **NEC-FEA-002 (Medium)**: Add Agenda: Supremacy Through Annihilation
  - **Description**: Implement Supremacy Through Annihilation, targeting high-value enemies for XP.
  - **Rules Summary**: Pre-game select up to 3 highest-points opponent units as Annihilation targets. Destroy target: destroying unit gains 2XP.
  - **Expected UI/Behavior**: Pre-game target selection. Post-game auto-apply XP.
  - **Integration Points**: Target selection; destroy check.
  - **Scoring/Effects**: 2XP per target destroyed.
  - **Any Data Requirements**: JSON entry with name, deed text, maxTargets: 3.

- **NEC-FEA-003 (Medium)**: Add Agenda: Territorial Imperative
  - **Description**: Implement Territorial Imperative, rewarding objective destroys and conquest for XP.
  - **Rules Summary**: Destroy enemy starting turn in objective range: destroying unit gains 1XP. Pre-Shooting select INFANTRY in objective range outside deployment (no shoot/charge): conquer objective (once per), unit gains 2XP.
  - **Expected UI/Behavior**: In-game destroy tally + conquest prompt. Post-game XP apply.
  - **Integration Points**: Objective conquer tracking.
  - **Scoring/Effects**: 1XP per destroy; 2XP per conquer.
  - **Any Data Requirements**: JSON entry with name, deed text.

- **NEC-FEA-004 (Medium)**: Add Agenda: Inescapable Retribution
  - **Description**: Implement Inescapable Retribution, reclaiming Dynastic Treasure for XP and Relic exchange.
  - **Rules Summary**: Opponent selects No Man’s Land objective as Dynastic Treasure. End-Movement CHARACTER in range can reclaim (no shoot/charge). If in range next Command phase: reclaim success, remove marker. Reclaiming Character gains 4XP; post-game exchange 1 Crusade Relic for eligible Necrons Relic.
  - **Expected UI/Behavior**: Pre-game opponent input. In-game reclaim prompt. Next Command auto-check/success/XP/Relic exchange.
  - **Integration Points**: Treasure marker; Relic exchange.
  - **Scoring/Effects**: 4XP; Relic exchange.
  - **Any Data Requirements**: JSON entry with name, deed text.

## Features (FEA – Space Marines Agendas – General)

- **SM-FEA-001 (Medium)**: Add Agenda: Angels of Death
  - **Description**: Implement Angels of Death, rewarding total victory.
  - **Rules Summary**: Post-game no enemy units: each on-battlefield ADEPTUS ASTARTES unit gains 2XP; force gains 2 Honour points.
  - **Expected UI/Behavior**: Post-game auto-check wipe, apply XP/Honour.
  - **Integration Points**: Honour points tracking.
  - **Scoring/Effects**: 2XP per unit; 2 Honour.
  - **Any Data Requirements**: JSON entry with name, deed text.

- **SM-FEA-002 (Medium)**: Add Agenda: Know No Fear
  - **Description**: Implement Know No Fear, rewarding Battle-shock resistance.
  - **Rules Summary**: Post-game units that never failed Battle-shock gain 1XP (2XP if Below Half-strength).
  - **Expected UI/Behavior**: In-game Battle-shock tracking. Post-game auto-apply XP.
  - **Integration Points**: Battle-shock detection.
  - **Scoring/Effects**: 1-2XP per unit.
  - **Any Data Requirements**: JSON entry with name, deed text.

- **SM-FEA-003 (Medium)**: Add Agenda: Armoured Assault
  - **Description**: Implement Armoured Assault, rewarding Vehicle performance.
  - **Rules Summary**: Post-game surviving VEHICLE gains 1XP; destroyed VEHICLE that destroyed 2+ enemies gains 1XP.
  - **Expected UI/Behavior**: Post-game auto-check/apply XP.
  - **Integration Points**: Vehicle destroy tally.
  - **Scoring/Effects**: 1XP per qualifying Vehicle.
  - **Any Data Requirements**: JSON entry with name, deed text.

- **SM-FEA-004 (Medium)**: Add Agenda: Quest of Atonement
  - **Description**: Implement Quest of Atonement, for scarred units destroying key enemies.
  - **Rules Summary**: Pre-game select 1 unit with Battle-weary/Disgraced/Mark of Shame. Post-game melee destroy Character/Monster/Vehicle: lose 1 scar + 5XP.
  - **Expected UI/Behavior**: Pre-game select scarred unit. Post-game check/apply scar loss/XP.
  - **Integration Points**: Scar tracking.
  - **Scoring/Effects**: Scar loss + 5XP.
  - **Any Data Requirements**: JSON entry with name, deed text, maxUnits: 1.


## Deferred / Honor-System Items (RP Spend Only – No Enforcement)
- **DEF-001 (Low)**: Stub "Rearm and Resupply" (1 RP deduct, toast/log "Wargear swapped – honor system", no unit/wargear change or UI)
- **DEF-002 (Low)**: Stub "Maintenance and Upgrades" (if rules require; similar RP-only pattern: deduct 1–2 RP, log event)

## Data Fills (Separate Generation)
- **DATA-001 (Medium)**: Full Deathwatch unit data (MFM v3.8 page 19 reference; extract points/flags like prior factions – generate externally)

## Archived/Resolved This Sprint
- **AEL-FEA-001–004 (Medium)**: Added 4 Aeldari faction agendas — Fulcrum of Fate, Eldritch Supremacy, Few in Number, Evasive Warfare. Data-driven JSON file (aeldari.json), auto-loaded for Aeldari crusades.
- **CUST-FEA-001–004 (Medium)**: Added 4 Adeptus Custodes faction agendas — Pursuit of Excellence, Judgement Delivered, Great Tithe, Unto the Dark Cells. Data-driven JSON file (adeptus_custodes.json), auto-loaded for Custodes crusades.
- **BUG-020 (High)**: Fixed Add/Edit Unit modals losing all form state on Android when keyboard opens/closes or text fields lose focus. Root cause: form variables in showModalBottomSheet builder closure reinitialized on MediaQuery rebuilds. Fix: extracted into StatefulWidget classes with persistent State objects and TextEditingControllers.
- **ENH-015 (High)**: Made Agenda Section Collapsible on Active Game Screen — default collapsed with summary bar showing agenda names + total progress, tap to expand for full agenda cards with tracking controls. Animated chevron and crossfade transitions. Frees up screen space for unit management during battle.