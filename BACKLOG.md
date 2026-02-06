# BACKLOG.md
**Last Updated:** February 6, 2026 (Post-Sprint Cleanup)

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
- **ENH-015 (High)**: Made Agenda Section Collapsible on Active Game Screen — default collapsed with summary bar showing agenda names + total progress, tap to expand for full agenda cards with tracking controls. Animated chevron and crossfade transitions. Frees up screen space for unit management during battle.
- **BUG-019 (High)**: History logging fixed — added missing events for unit add/remove, supply increase, game results. Fixed requisition mutation pattern (direct mutation → immutable provider addEvent). Added 100-event rolling cap to prevent unbounded history growth.
- **ENH-014 (Medium)**: Landing screen crusade list multi-line layout — name (bold) on first line, faction + points on second line, detachment (indented, grey) on third line.
- **ENH-012 (Medium)**: Stack Backup/Restore buttons vertically on Settings page — replaced Row with full-width stacked buttons for mobile readability.
- **ENH-013 (Medium)**: Landing screen edge-to-edge — transparent status bar, dynamic top padding for notch/status bar, dark theme icons.
- **ENH-011 (Medium)**: Improve Post-Game Review Screen Layout — Collapsible agenda recap (collapsed by default with summary), inline XP preview per unit card with breakdown chips, per-unit agenda tally +/- controls with live XP recalculation.
