# TODO - Active Sprint Tracker
**Last Updated:** February 1, 2026 (Sprint: Progression Depth Foundations – Phases 1–4 Complete)

**Follow the guidelines in AGENTS.md exactly.**

## Current Focus: Bug Clearance & Polish
Goal: Clear remaining bugs and polish to solidify the full Crusade loop (battle → post-game → progression → agendas).

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
- **Feb 1 Phase 4**: Enhanced Agenda System complete: 12 core agendas loaded from JSON (assets/data/core_agendas.json), pre-game multi-select, in-game progress tracking (type icons, tier indicators, tally progress bars with milestones), post-game recap with completion status, VP/XP rewards display, summary totals, agenda persistence via Game model.
- **Feb 1 Morning Merge**: Phase 3 (Out of Action Tests & Battle Scars) fully complete: D6 roller integration in post-game, per-unit/batch OOA resolution, 1D6 logic with auto-pass, prompt on 1 for Devastating Blow or Scar, scar table roll, effect application, scar tracking in model, Repair requisition link, dedicated UI step, visual indicators on unit cards.
- **Prior Feb 1**: Phase 1 (Reusable D6 Roller Widget) + Phase 2 (Battle Honours & Rank-Up Flow) complete: roller built (animated, Epic skip, modes, modal), rank-up trigger/modal, rolls for Traits/Enhancements/Relics/Psychic, model fields, honours.json, logging, Renowned tie-in.
- Earlier: Requisitions Phases 1–3 full core loop (Supply Increase, Fresh Recruits variable cost, Repair/Recuperate, Renowned Heroes, Legendary Veterans), Immediate Polish (notes field, RP cap/bar, Supply progress, over-limit warning), roster assembly, post-game/XP loop, active game polish (tallies/XP dots/segmented toggle), data layer (27/28 factions; Deathwatch pending)

## Next After This Sprint
- Campaign narrative tools (battle tally/victories log, export/share OOB JSON/text, multi-campaign switcher)
- Full Deathwatch unit data fill (MFM reference – generate separately)
- Advanced: Multi-player support, scenario/agenda expansions, campaign history export