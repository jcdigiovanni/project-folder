# TODO - Active Sprint Tracker
**Last Updated:** February 1, 2026 (Sprint: Progression Depth Foundations – Phases 1–4 Complete)

**Follow the guidelines in AGENTS.md exactly.**

## Current Focus: Stabilization & Backlog Clearance
Goal: Polish remaining visuals/UX, add undo safety, and clear backlog bugs/enhancements to make the full loop robust and bug-free before narrative/export features.

### Phase 5 – Bug Clearance & General Polish (Active – Prioritize These)
- [ ] Polish: Consistent Supply/RP dashboard visuals app-wide (progress bars, color warnings, consistent styling)
- [ ] Polish: Confirmation + undo safety for rank-up, OOA, scar, progression actions (Hive transactions, rollback on cancel/failure)

### Phase 6 – Backlog Integration & Remaining Fixes (Pull from BACKLOG.md)
- [ ] BUG-008 (Low): Async/sync mismatches in unit selection UI (lag on OOB load)
- [ ] BUG-009 (Low): Navigation issues on crusade disband (backstack overflow)
- [ ] BUG-010 (Critical): Android app unable to log into Google Drive (auth flow fix)
- [ ] ENH-004 (Low): Optional sound effects for D6 roller (toggle in settings)
- [ ] ENH-005 (Low): Basic campaign summary export (text/CSV beyond narrative tools)
- [ ] ENH-006 (Medium): Fix Android button text cutoff (Good Vibes font issue – buttons cut off 2/3 down)
- Guidance for Claude: Tackle critical/medium first (BUG-010, ENH-006), then low-priority polish. Use existing patterns (Hive transactions, modal confirmations). Keep commits atomic, test on Android/Web/Desktop.

## Completed This Session / Archive
- **Feb 1 Phase 4**: Enhanced Agenda System complete: 12 core agendas from JSON, pre-game multi-select, in-game progress tracking (icons/tiers/tally bars/milestones), post-game recap (status/VP/XP rewards/summary), persistence via Game model.
- **Feb 1 Morning Merge**: Phase 3 (OOA & Battle Scars) complete: D6 roller integration, 1D6 logic/auto-pass/prompt, scar roll/application/tracking, Repair link, UI step/indicators.
- **Prior Feb 1**: Phase 1 (D6 Roller) + Phase 2 (Battle Honours/Rank-Up) complete: roller widget (animated/Epic skip/modes/modal), rank-up modal/rolls/model fields/logging/Renowned tie-in.
- Earlier: Requisitions Phases 1–3 full loop, Immediate Polish (notes/RP cap/Supply progress), roster/post-game/XP/active game polish, data (27/28 factions; Deathwatch pending)

## Next After This Sprint
- Campaign narrative tools (battle tally/victories log, export/share OOB JSON/text, multi-campaign switcher)
- Full Deathwatch unit data fill (MFM reference – generate separately)
- Advanced: Multi-player support, scenario/agenda expansions, campaign history export