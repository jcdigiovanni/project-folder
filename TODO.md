# TODO - Active Sprint Tracker
**Last Updated:** February 1, 2026 (Sprint: Progression Depth Foundations)

**Follow the guidelines in AGENTS.md exactly.**

## Current Focus: Progression Depth Foundations
Goal: Build shared dice infrastructure first, then layer on rank-up progression (Honours), OOA/Scars, and agenda polish for a complete post-battle flow.

### Phase 1 – Reusable D6 Roller Widget (Foundation – Do This First) ✅
- [x] Create shared D6 roller widget (lib/widgets/d6_roller.dart)
- [x] Support 1D6 (default), configurable for 2D6 (with duplicate reroll logic), D3 via scaling
- [x] Features: Animated roll (shake effect), result display, reroll button, Epic Hero auto-skip/pass logic
- [x] UI: Card-style, title param, subtitle, confirmation callback, cancel option
- [x] Reusable across screens: Unit param for Epic skip, allowReroll flag, showD6RollerModal helper
- [x] Widget analysis passes, Hive-safe (no persistence)

### Phase 2 – Battle Honours & Rank-Up Flow (Relies on D6 Roller) ✅
- [x] Add rank-up detection & UI trigger ("Claim Battle Honour" button in expanded unit details)
- [x] Implement Battle Honours selection modal:
  - "Choose Manually" vs "Roll Random" buttons
  - D6 roller for Battle Traits (1D6 table)
  - 2D6 roller for Weapon Enhancements (with duplicate reroll)
  - Crusade Relics dropdown for Characters (limit 1)
  - Psychic Fortitudes option for Psykers
- [x] Update UnitOrGroup model: battleTraits, weaponEnhancements, crusadeRelic fields
- [x] Renowned Heroes requisition already integrated
- [x] UI: Confirmation, history logging, pendingRankUp cleared on claim

### Phase 3 – Out of Action (OOA) Tests & Battle Scars (Relies on D6 Roller)
- [ ] Integrate D6 roller into post-game flow for destroyed units (per-unit or batch)
- [ ] OOA test logic: Roll 1D6; Epic Hero/Fortification/Swarm auto-pass; on 1 → prompt Devastating Blow (lose Honour) or Battle Scar
- [ ] Battle Scars: On scar gained → roll D6 on core table (use D6 roller), apply effect flag/text to unit
- [ ] Track scars per unit; link to Repair and Recuperate requisition (already exists) to remove
- [ ] UI: Dedicated OOA resolution step in post-game; visual indicators on unit cards

### Phase 4 – Enhanced Agenda System & Polish
- [ ] Pre-game agenda selection: 1–2 agendas per player (dropdown from core list)
- [ ] In-game tracking: Progress counter/bar in ActiveGameScreen (current vs target VP)
- [ ] Post-game recap: Agenda completion status, VP earned, any XP tie-in
- [ ] Persistence: Save selected agendas to Game/Campaign model

### Phase 5 – Bug Clearance & General Polish (Interleave as Needed)
- [ ] BUG-001: Fix Exit button (bottom ribbon) – ensure app-wide close/confirm
- [ ] BUG-005: Deleting all local data clears campaigns (Hive box wipe fix)
- [ ] BUG-006: First unit add as Character + Warlord/Renowned Heroes saves to permanent roster
- [ ] BUG-007: Group name field retains focus/validation during add (no units case)
- [ ] Polish: Consistent Supply/RP dashboard visuals app-wide
- [ ] Polish: Confirmation + undo safety for rank-up, OOA, scar actions

## Deferred / Honor-System Items (Low Effort – RP Spend Only)
- [ ] Stub "Rearm and Resupply" (1 RP deduct, toast/log "Wargear swapped – honor system", no unit or wargear change)
- [ ] Stub any maintenance/upgrade reqs if needed (same pattern)

## Completed This Session / Archive
(Will populate after commits)
- Requisitions full core (Phases 1–3 + Immediate Polish)
- Roster assembly, post-game/XP loop, active game polish
- Data layer (27/28 factions; Deathwatch pending)

## Next After This Sprint
- Campaign narrative tools (battle tally/victories log, export/share OOB, multi-campaign)
- Full Deathwatch unit data fill (MFM reference – generate separately)
- Advanced: Multi-player support, scenario expansions, campaign history export