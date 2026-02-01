# TODO - Active Sprint Tracker
**Last Updated:** February 2, 2026 (Sprint: Progression Depth Foundations – Phases 1–3 Complete)

**Follow the guidelines in AGENTS.md exactly.**

## Current Focus: Progression Depth Foundations
Goal: Leverage the new D6 roller to complete post-battle progression (OOA/Scars), then polish agendas and clear bugs for a smooth end-to-end Crusade experience.

### Phase 3 – Out of Action (OOA) Tests & Battle Scars (Relies on D6 Roller) ✅
- [x] Integrate D6 roller into post-game flow for destroyed units (per-unit or batch "Run All" option)
- [x] OOA test logic: Roll 1D6; auto-pass for Epic Hero; on 1 → choice: Devastating Blow (lose honour) or Battle Scar
- [x] Battle Scars application: On scar → roll D6 on core table, apply scar name to unit.scars list
- [x] Track scars per unit in model; Repair and Recuperate requisition already exists to remove
- [x] UI: Dedicated OOA Resolution section in post-game, unit cards show pass/fail status

### Phase 4 – Enhanced Agenda System & Polish
- [ ] Pre-game agenda selection: Allow 1–2 agendas per player (dropdown/multi-select from core agenda list)
- [ ] In-game tracking: Add progress counter or bar in ActiveGameScreen (current VP vs target, tier indicators)
- [ ] Post-game recap: Show agenda completion status, VP earned, any XP/requisition tie-ins from rules
- [ ] Persistence: Save selected agendas to Game/Campaign model for reload/history

### Phase 5 – Bug Clearance & General Polish (Interleave as Needed)
- [ ] BUG-001: Fix Exit button (bottom ribbon) – ensure app-wide close/confirm behavior
- [ ] BUG-005: Deleting all local data clears campaigns properly (Hive box wipe)
- [ ] BUG-006: First unit add as Character + Warlord/Renowned Heroes saves correctly to permanent roster
- [ ] BUG-007: Group name field retains focus/validation during add (handle no-units case)
- [ ] Polish: Consistent Supply/RP dashboard visuals app-wide (progress bars, warnings)
- [ ] Polish: Confirmation + undo safety for rank-up, OOA, scar, and progression actions

## Deferred / Honor-System Items (Low Effort – RP Spend Only)
- [ ] Stub "Rearm and Resupply" (1 RP deduct, toast/log "Wargear swapped – honor system", no unit/wargear change or UI)
- [ ] Stub any maintenance/upgrade reqs if needed (same pattern)

## Completed This Session / Archive
- **Feb 2 Morning Merge**: Phase 1 (Reusable D6 Roller Widget) fully complete: lib/widgets/d6_roller.dart built, supports 1D6/2D6/D3, animated shake, Epic Hero skip, reroll, modal helper (showD6RollerModal), DiceResult class, widget tests.
- **Feb 2 Morning Merge**: Phase 2 (Battle Honours & Rank-Up Flow) fully complete: Claim button in unit details, modal with manual/roll options, integrated D6/2D6 rolls (Traits, Weapon Enhancements with duplicate reroll), Crusade Relics dropdown (Characters only, limit 1), Psychic Fortitudes, model fields (battleTraits, weaponEnhancements, crusadeRelic), honours.json data file, history logging, Renowned Heroes integration.
- Prior wins: Requisitions Phases 1–3 full core loop (Supply Increase, Fresh Recruits variable cost, Repair/Recuperate, Renowned Heroes, Legendary Veterans), Immediate Polish (notes field, RP cap/bar, Supply progress, over-limit warning), roster assembly, post-game/XP loop, active game polish (tallies/XP dots/segmented toggle), data layer (27/28 factions; Deathwatch pending)

## Next After This Sprint
- Campaign narrative tools (battle tally/victories log, export/share OOB JSON/text, multi-campaign switcher)
- Full Deathwatch unit data fill (MFM reference – generate separately)
- Advanced: Multi-player support, scenario/agenda expansions, campaign history export