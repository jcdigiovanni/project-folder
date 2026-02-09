# BACKLOG.md
**Last Updated:** February 9, 2026 (Post-Sprint Cleanup)

## Tasks

## Bugs
- No remaining bugs in backlog.

## Enhancements
- No remaining enhancements in backlog.

## Features
- No remaining features in backlog.

## Deferred / Honor-System Items (RP Spend Only – No Enforcement)
- **DEF-001 (Low)**: Stub "Rearm and Resupply" (1 RP deduct, toast/log "Wargear swapped – honor system", no unit/wargear change or UI)
- **DEF-002 (Low)**: Stub "Maintenance and Upgrades" (if rules require; similar RP-only pattern: deduct 1–2 RP, log event)

## Data Fills (Separate Generation)
- **DATA-001 (Medium)**: Full Deathwatch unit data (MFM v3.8 page 19 reference; extract points/flags like prior factions – generate externally)

## Archived/Resolved This Sprint
- **SM-FEA-001–004 (Medium)**: Added 4 Space Marines faction agendas — Angels of Death, Know No Fear, Armoured Assault, Quest of Atonement.
- **NEC-FEA-001–004 (Medium)**: Added 4 Necrons faction agendas — The Unending Tally, Supremacy Through Annihilation, Territorial Imperative, Inescapable Retribution.
- **ORK-FEA-001–004 (Medium)**: Added 4 Orks faction agendas — Scrap 'Em, Show 'Em How It's Done, Skrag Da Killiest Gitz, Overwhelming Aggression.
- **TYR-FEA-001–004 (Medium)**: Added 4 Tyranids faction agendas — Infest the Prey World, Hunt and Slay, Tyrannoform the Prey World, Tyranid Attack.
- **WE-FEA-001–004 (Medium)**: Added 4 World Eaters faction agendas — Blood for the Blood God!, Skulls for the Skull Throne!, Anoint the Field, A Tribute to Murder.
- **DG-FEA-001–004 (Medium)**: Added 4 Death Guard faction agendas — Sow the Seeds of Corruption, Unwitting Vectors, Viral Harvest, Vile Research.
- **CK-FEA-001–004 (Medium)**: Added 4 Chaos Knights faction agendas — Malicious Hunt, Tear Down the False Gods, Seize Riches, Tyrannical Domination.
- **GK-FEA-001–005 (Medium)**: Added 5 Grey Knights faction agendas — Purge Corruption, Empyric Interdiction, Unmake Omens, Destroy the Infernal, No Witnesses.
- **TS-FEA-001–004 (Medium)**: Added 4 Thousand Sons faction agendas — Pursuit of Knowledge, Malefic Sigils, Arcana Long Buried, Sorcerous Prowess.
- **DRU-FEA-001–005 (Medium)**: Added 5 Drukhari faction agendas — Sublime Agonies, Demonstrate Superiority, To Feed the Dark City, Fear's Cold Grip, Herd the Prey.
- **AEL-FEA-001–004 (Medium)**: Added 4 Aeldari faction agendas — Fulcrum of Fate, Eldritch Supremacy, Few in Number, Evasive Warfare. Data-driven JSON file (aeldari.json), auto-loaded for Aeldari crusades.
- **CUST-FEA-001–004 (Medium)**: Added 4 Adeptus Custodes faction agendas — Pursuit of Excellence, Judgement Delivered, Great Tithe, Unto the Dark Cells. Data-driven JSON file (adeptus_custodes.json), auto-loaded for Custodes crusades.
- **BUG-020 (High)**: Fixed Add/Edit Unit modals losing all form state on Android when keyboard opens/closes or text fields lose focus. Root cause: form variables in showModalBottomSheet builder closure reinitialized on MediaQuery rebuilds. Fix: extracted into StatefulWidget classes with persistent State objects and TextEditingControllers.
- **ENH-015 (High)**: Made Agenda Section Collapsible on Active Game Screen — default collapsed with summary bar showing agenda names + total progress, tap to expand for full agenda cards with tracking controls. Animated chevron and crossfade transitions. Frees up screen space for unit management during battle.