# TODO - Active Sprint Tracker
**Last Updated:** February 1, 2026 (Sprint: Phase 6 Backlog Clearance In Progress)

**Follow the guidelines in AGENTS.md exactly.**

## Current Focus: Stabilization & Backlog Clearance
Goal: Clear backlog bugs/enhancements to make the full loop robust and bug-free before narrative/export features.

### Phase 6 – Bugs and Enhancements (30 JAN-6 FEB)
- Guidance for Claude: Tackle remaining items. Use existing patterns (Hive transactions, modal confirmations). Keep commits atomic, test on Android/Web/Desktop.
- - **BUG-018 (Medium)**: Can't Level Up or Edit Units While in a Group – Forces Clunky Workflow
-- Description: You can only level up or make general edits (like name changes) to a unit if it's directly on the OOB, not if it's inside a unit group. This means users have to constantly remove the unit from the group, edit/level it, then add it back – and repeat every time another change is needed. It doesn't crash the app, but it's a pain and feels like extra unnecessary steps.

- **ENH-007 (Medium)**: Support Draws/Ties in Battle Results for Crusade Tallies
-- Description: The app currently only tracks victories or defeats after a game, but my buddy and I had a 45-45 draw (tie) in points. The app doesn't have an option to record a draw, so there's no way to log a tied result properly. This means the post-game progression (like experience, requisition points, or narrative notes) might not handle ties correctly or at all right now.

## Completed This Session / Archive
- **Feb 1 Phase 6**: BUG-010 (Android GDrive auth), BUG-013/014/015 (Campaign provider state sync on clear/restore), BUG-016 (agenda scroll overflow), BUG-017 (CP not updating after Battle Honour/Scars), ENH-006 (Android button text cutoff with Great Vibes font).
- **Feb 1 Phase 5**: Polish complete: Reusable CrusadeStatsBar widget for consistent Supply/CP/RP dashboard visuals across OOB, dashboard, and requisition screens; confirmation dialog added for Battle Honour rank-up selection.
- **Feb 1 Phase 4**: Enhanced Agenda System complete: 12 core agendas from JSON, pre-game multi-select, in-game progress tracking (icons/tiers/tally bars/milestones), post-game recap (status/VP/XP rewards/summary), persistence via Game model.
- **Feb 1 Morning Merge**: Phase 3 (OOA & Battle Scars) complete: D6 roller integration, 1D6 logic/auto-pass/prompt, scar roll/application/tracking, Repair link, UI step/indicators.
- **Prior Feb 1**: Phase 1 (D6 Roller) + Phase 2 (Battle Honours/Rank-Up) complete: roller widget (animated/Epic skip/modes/modal), rank-up modal/rolls/model fields/logging/Renowned tie-in.
- Earlier: Requisitions Phases 1–3 full loop, Immediate Polish (notes/RP cap/Supply progress), roster/post-game/XP/active game polish, data (27/28 factions; Deathwatch pending)

## Next After This Sprint
- Campaign narrative tools (battle tally/victories log, export/share OOB JSON/text, multi-campaign switcher)
- Full Deathwatch unit data fill (MFM reference – generate separately)
- Advanced: Multi-player support, scenario/agenda expansions, campaign history export