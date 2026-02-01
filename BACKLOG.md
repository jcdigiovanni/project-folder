# BACKLOG.md
**Last Updated:** February 1, 2026 (Post-TODO Sprint Alignment)

## Bugs (Remaining – Low Priority)
- **BUG-011 (Low)**: Trying to take focus off of the soft keyboard on Adroid app causes currently selected options and text to be cleared on the Add Unit screen
- **BUG-012 (Low)**: In order to make edits to a unit (ie: change custom name) that is a part of a unit group, the unit first needs to be dropped from the group.  The unit can then be upgraded and then re-added to the group.  This is a clunky and unintuitive workflow
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

## Enhancements (Remaining – Polish Debt)

## Deferred / Honor-System Items (RP Spend Only – No Enforcement)
- **DEF-001 (Low)**: Stub "Rearm and Resupply" (1 RP deduct, toast/log "Wargear swapped – honor system", no unit/wargear change or UI)
- **DEF-002 (Low)**: Stub "Maintenance and Upgrades" (if rules require; similar RP-only pattern: deduct 1–2 RP, log event)

## Data Fills (Separate Generation)
- **DATA-001 (Medium)**: Full Deathwatch unit data (MFM v3.8 page 19 reference; extract points/flags like prior factions – generate externally)

## Archived/Resolved This Sprint
