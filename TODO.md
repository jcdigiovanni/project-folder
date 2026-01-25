# TODO - Active Sprint Tracker
**Last Updated:** January 25, 2026 (Late Evening – Post-Backlog Integration)

**Follow the guidelines in AGENTS.md exactly.**

## Prelude: High-Priority Bug Fixes (Integrate First)
Goal: Clear critical bugs from BACKLOG.md before or alongside new requisition work – these affect live features (post-game XP) and will be touched naturally in RP/Supply flows.

- [x] BUG-004: Fix Marked for Greatness to award +3 XP (not +1) per current 10th ed rules (update logic in post_game_screen.dart or XP calculator)
- [x] BUG-002: Ensure Supply Limit increases persist correctly (test save/load after manual or auto-increase)
- [x] BUG-003: Hide/disable Renowned Heroes requisition after global use (track usage count properly)
- [x] ENH-001: Add explicit back/close buttons to all dialogs/popups (replace tap-outside-only behavior)
- [x] ENH-003: Add RP/CP summary dashboard to Modify OOB screen (Total CP, Available RP, Remaining RP, Supply Limit/Used)

## Current Focus: Implement Core Requisitions System
Goal: Add Requisition Points (RP) tracking and purchasing flow for the universal/core requisitions from the 10th ed Crusade rules. Tie into existing OOB points (MFM v3.8+) and auto-handle Supply Limit exceeded rule.

### Phase 1 – RP Tracking & Requisition Menu Basics
- [ ] Add Campaign-level RP field (start: 5, +1 per completed game, max: 10)
- [ ] Create Requisitions screen (GoRoute: /requisitions or tab in Campaign view)
- [ ] Display current RP, Supply Limit (start: 1000 pts), Supply Used (sum of OOB unit points)
- [ ] List core requisitions with costs, descriptions, and purchase buttons (confirmation prompt)
- [ ] Implement "Increase Supply Limit" (+200 pts for 1 RP, purchasable anytime; integrate BUG-002 persistence fix)

### Phase 2 – Unit Modification Requisitions
- [ ] Implement "Fresh Recruits" (1–4 RP variable cost based on Battle Honours; add models up to datasheet max, recalculate points, enforce Supply Limit)
- [ ] Implement "Rearm and Resupply" (1 RP; before game, allow wargear swaps per datasheet, lose relics/mods if replaced, recalculate points)
- [ ] Add UI for model count adjustments and wargear selectors (leverage existing unit data layer)

### Phase 3 – Advanced/Healing Requisitions
- [ ] Implement "Repair and Recuperate" (1–5 RP variable; post-battle, remove one Battle Scar)
- [ ] Implement "Renowned Heroes" (1–3 RP variable; grant Enhancements to Characters, track global count; integrate BUG-003 hide logic)
- [ ] Implement "Legendary Veterans" (3 RP; allow non-Characters to exceed 30 XP and 3 Honours)

### Immediate Polish (After Requisitions Core)
- [ ] Auto-increase Supply Limit if points updates cause exceed (per Munitorum Field Manual rule – no RP cost)
- [ ] Add Supply Limit/Used dashboard visuals across app (progress bar, warnings; expand ENH-003)
- [ ] Confirmation prompts for all purchases + undo if possible (Hive transaction safety)
- [ ] Consistent explicit close/back buttons on all new requisition dialogs (per ENH-001)

## Completed This Session / Archive
- **Prelude Bug Fixes (Jan 25):** BUG-004 (+3 XP for Mark), BUG-002/003 (data persistence), ENH-001 (close buttons), ENH-003 (RP/CP dashboard)
- Backlog integration: Pulled high-priority bugs (BUG-002/003/004) and enhancements (ENH-001/003) into active sprint
- Roster assembly polish: Checkbox OOB → multi-select → named roster save with points total, filters, notes
- Post-Game & XP Application: Phases 5–6 complete (recap, Mark selector, notes, Commit, XP calc/apply, ranks, tallies, Drive backup prompt)
- Active game polish: Tally steppers refined, XP progress dots/badge, segmented survived/destroyed toggle
- Data layer: Tyranids + high-play factions advanced (points from MFM, flags set)

## Next After This Phase
- Battle Honours selection on rank-up (traits table, weapon mods roller/chooser, Crusade Relics for Characters)
- Out of Action tests & Battle Scars (post-game for destroyed units, scar effects)
- Enhanced agenda system (selection pre-game, detailed scoring/tracking)
- Campaign narrative tools (battle tally/victories, export/share OOB, multi-campaign support)