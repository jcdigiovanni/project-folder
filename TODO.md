# TODO - Active Sprint Tracker
**Last Updated:** February 1, 2026 (Sprint: Phase 6 Backlog Clearance In Progress)

**Follow the guidelines in AGENTS.md exactly.**

## Current Focus: Stabilization & Backlog Clearance
Goal: Clear backlog bugs/enhancements to make the full loop robust and bug-free before narrative/export features.

### Phase 6 – Backlog Integration & Remaining Fixes (Active – Pull from BACKLOG.md)
- [x] BUG-010 (Critical): Android app unable to log into Google Drive (auth flow fix) ✓
- [ ] ENH-004 (Low): Optional sound effects for D6 roller (toggle in settings)
- [ ] ENH-005 (Low): Basic campaign summary export (text/CSV beyond narrative tools)
- Guidance for Claude: Tackle remaining items. Use existing patterns (Hive transactions, modal confirmations). Keep commits atomic, test on Android/Web/Desktop.

- **BUG-013 (Medium)**: Local Data Clear Does Not Immediately Remove Campaign from UI
-- Description: After clearing local data, the Campaign remains visible in the app until restart. This leads to confusing state where users think data persists but it's actually cleared in storage.
-- Repro Steps: See common steps above; after step 4, Campaign is still shown in Landing/Dashboard.
-- Expected: Clearing local data should immediately remove all Campaigns from UI (e.g., via Riverpod notifier reset) and show empty state.
-- Actual: Campaign persists in session; disappears only on app restart.
-- Impact: UI inconsistency; users may attempt actions on "ghost" data, leading to errors. Ties to Story: Consistent App State After Operations.
-- Potential Fix Notes: Ensure Hive clear triggers full provider rebuild/invalidation (e.g., in CrusadeNotifier). Test on Android/iOS.

- **BUG-014 (Critical)**: Campaign Disappears After App Restart Following Local Clear, But Not During Session
-- Description: Post-clear, the app holds onto Campaign state in memory/session but drops it on restart, indicating incomplete clear logic. This is a variant of BUG-013 but highlights persistence issues.
-- Repro Steps: See common steps; after step 4, exit/re-enter app (step 5).
-- Expected: If clear succeeds, Campaign should be gone immediately and stay gone; no discrepancy between session and restart.
-- Actual: Visible in session, gone after restart.
-- Impact: Data illusion could cause users to lose unsynced changes; erodes trust in clear function. Ties to Story: Reliable Local Data Clearing.
-- Potential Fix Notes: Audit Hive box operations—ensure all keys (e.g., 'campaigns') are deleted and watchers notified. Add loading state or confirmation dialog post-clear.

- **BUG-015 (Critical)**: Restore from Google Drive Backup Does Not Recover Campaign Data
-- Description: After exporting to Drive and clearing local data, restoring does not bring back the Campaign, suggesting backup files miss Campaign metadata or restore logic skips it.
-- Repro Steps: See common steps; after app restart (where Campaign is gone), attempt restore from Drive backup.
-- Expected: Restore should fully reload the Campaign, including OOB/Crusade details built before export.
-- Actual: Campaign does not appear post-restore.
-- Impact: High risk of permanent data loss; defeats the purpose of backups. Affects core non-functional reqs (offline-first with sync). Ties to Story: Full Backup and Restore of Campaigns.
-- Potential Fix Notes: Verify export JSON includes top-level Campaign objects (not just OOB units). Debug Drive file parsing in restore provider; add error logging for missing keys.

## Completed This Session / Archive
- **Feb 1 Phase 6 (Partial)**: BUG-010 (Android GDrive auth - Gradle plugin + improved error messages), BUG-016 (agenda scroll overflow), BUG-017 (CP not updating after Battle Honour/Scars), ENH-006 (Android button text cutoff with Great Vibes font).
- **Feb 1 Phase 5**: Polish complete: Reusable CrusadeStatsBar widget for consistent Supply/CP/RP dashboard visuals across OOB, dashboard, and requisition screens; confirmation dialog added for Battle Honour rank-up selection.
- **Feb 1 Phase 4**: Enhanced Agenda System complete: 12 core agendas from JSON, pre-game multi-select, in-game progress tracking (icons/tiers/tally bars/milestones), post-game recap (status/VP/XP rewards/summary), persistence via Game model.
- **Feb 1 Morning Merge**: Phase 3 (OOA & Battle Scars) complete: D6 roller integration, 1D6 logic/auto-pass/prompt, scar roll/application/tracking, Repair link, UI step/indicators.
- **Prior Feb 1**: Phase 1 (D6 Roller) + Phase 2 (Battle Honours/Rank-Up) complete: roller widget (animated/Epic skip/modes/modal), rank-up modal/rolls/model fields/logging/Renowned tie-in.
- Earlier: Requisitions Phases 1–3 full loop, Immediate Polish (notes/RP cap/Supply progress), roster/post-game/XP/active game polish, data (27/28 factions; Deathwatch pending)

## Next After This Sprint
- Campaign narrative tools (battle tally/victories log, export/share OOB JSON/text, multi-campaign switcher)
- Full Deathwatch unit data fill (MFM reference – generate separately)
- Advanced: Multi-player support, scenario/agenda expansions, campaign history export