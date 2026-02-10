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
- **EC-FEA-001–004 (Medium)**: Added 4 Emperor's Children faction agendas — Excess of Indulgence, Flawless Performance, Perfect the Art, Captive Audience.
- **GSC-FEA-001–005 (Medium)**: Added 5 Genestealer Cults faction agendas — Genestealer's Kiss, Silence Detractor, Telepathic Domination, Prepared for the Ordeal, Topple the False Temple.
- **IK-FEA-001–005 (Medium)**: Added 5 Imperial Knights faction agendas — Sally Forth, Break Their Will, Petitioned for Aid, Honour Must Be Satisfied, Death Before Dishonour.
- **VOT-FEA-001–004 (Medium)**: Added 4 Leagues of Votann faction agendas — Prospecting, Yield Prophecy, Exhaustive Pursuit, Debt to Be Paid.
- **TAU-FEA-001–004 (Medium)**: Added 4 T'au Empire faction agendas — Coordinated Strike, Decisive Strike, For the Greater Good, Targeted Elimination.
- **AdMech-FEA-001–005 (Medium)**: Added 5 Adeptus Mechanicus faction agendas — Cold Logic, Tech Scavengers, Omnissiah's Will, Break the Seals, Claim Legendary Archeotech.
- **AM-FEA-006–010 (Medium)**: Added 5 Astra Militarum faction agendas — Advance For the Emperor!, Propaganda Targets, Inspired Command, Hold the Line, Arming the Assault.
- **CSM-FEA-001–006 (Medium)**: Added 6 Chaos Space Marines faction agendas — Claim and Despoil, Blasphemous Ritual, Path to Glory, Warlord's Glory, Glory of the Gods, Glory of Conquest.
- **BUG-020 (High)**: Fixed Add/Edit Unit modals losing all form state on Android when keyboard opens/closes or text fields lose focus. Root cause: form variables in showModalBottomSheet builder closure reinitialized on MediaQuery rebuilds. Fix: extracted into StatefulWidget classes with persistent State objects and TextEditingControllers.
- **ENH-015 (High)**: Made Agenda Section Collapsible on Active Game Screen — default collapsed with summary bar showing agenda names + total progress, tap to expand for full agenda cards with tracking controls. Animated chevron and crossfade transitions. Frees up screen space for unit management during battle.