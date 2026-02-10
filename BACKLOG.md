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
- **BT-FEA-001–004 (Medium)**: Added 4 Black Templars agendas (+ 4 base SM) — Fulfil Your Vows, Reconsecration, First-Hand Experience, Recovering Sacred Wargear.
- **IA-FEA-001–005 (Medium)**: Added 5 Imperial Agents agendas — Aggressive Negotiation, Strategic Excruciation, Execution Order, Clandestine Infiltration, Long Vigil.
- **DW-FEA-001–004 (Medium)**: Added 4 Deathwatch agendas (+ 4 base SM) — A Deadly Prize, Furor Tactics, Malleus Tactics, Purgatus Tactics.
- **BA-FEA-001–004 (Medium)**: Added 4 Blood Angels agendas (+ 4 base SM) — For Baal and the Angel!, Search for the Cure, Against the Darkness, Liberators from Tyranny.
- **DA-FEA-001–004 (Medium)**: Added 4 Dark Angels agendas (+ 4 base SM) — Interrogate the Mysterious Figure, Encircle the Foe, The Deathwing Cometh, Mental Interrogation.
- **SW-FEA-001–003 (Medium)**: Added 3 Space Wolves agendas (+ 4 base SM) — Show Them How We Fight, Savage Fury, Howls of Vengeance.
- **BUG-020 (High)**: Fixed Add/Edit Unit modals losing all form state on Android when keyboard opens/closes or text fields lose focus. Root cause: form variables in showModalBottomSheet builder closure reinitialized on MediaQuery rebuilds. Fix: extracted into StatefulWidget classes with persistent State objects and TextEditingControllers.
- **ENH-015 (High)**: Made Agenda Section Collapsible on Active Game Screen — default collapsed with summary bar showing agenda names + total progress, tap to expand for full agenda cards with tracking controls. Animated chevron and crossfade transitions. Frees up screen space for unit management during battle.