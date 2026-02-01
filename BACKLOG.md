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

- **BUG-016 (Medium)**: Select Agenda Screen Won't Scroll and Shows Bottom Overflow Warning
-- Description: On the Select Agenda screen (part of starting/playing a game), the list of agendas is visible but the screen doesn't scroll properly. A big yellow and black "caution tape" stripe appears at the bottom saying "Bottom Overflowed by 396 pixels". You can still tap the two visible agendas and move to the next screen, but the overflow warning looks bad and means some content might be cut off or hard to reach on smaller screens/phones.
-- Repro Steps: Start a new game or go to the Play section of a Crusade. Reach the screen where you select an Agenda. Look at the agenda list – you'll see the yellow/black overflow stripe at the bottom.
Try to scroll down – it doesn't let you see more agendas if there are many.
Note: You can still click the visible ones and proceed.
-- Expected: The agenda list should scroll smoothly if there are more agendas than fit on the screen (no yellow/black warning stripe). Everything should be visible and tappable without cutoff.
-- Actual: Yellow and black overflow stripe shows ("Bottom Overflowed by 396 pixels"), screen doesn't scroll, but the visible agendas still work.
-- Impact: Makes the screen look broken/unprofessional (yellow/black stripe is a debug warning). On smaller phones or in portrait mode it could hide agendas completely, forcing users to guess or restart. Feels clunky even though you can proceed. Ties to overall polish and usability in the Play/Game flow.
-- Potential Fix Notes: The error points to a Column widget in lib/screens/play_screen.dart (around line 651) that's inside a layout that doesn't allow scrolling. Wrapping the agenda list in something scrollable (like SingleChildScrollView or ListView) or making sure the Column uses Expanded/Flexible widgets should fix the overflow and enable scrolling.

## Enhancements (Remaining – Polish Debt)
- **ENH-007 (Medium)**: Support Draws/Ties in Battle Results for Crusade Tallies
-- Description: The app currently only tracks victories or defeats after a game, but my buddy and I had a 45-45 draw (tie) in points. The app doesn't have an option to record a draw, so there's no way to log a tied result properly. This means the post-game progression (like experience, requisition points, or narrative notes) might not handle ties correctly or at all right now.
-- Repro Steps: Finish a battle where both players end up with the same victory points (e.g., 45-45 draw/tie).
Go to the post-game / tally screen in the app.
Try to enter the result – only win or loss options are available (no draw/tie button or field).
-- Expected: There should be a clear way to select/record a "Draw" or "Tie" outcome (maybe a third button or dropdown choice). Once selected, the app should:
Award the standard 1 Requisition Point (RP) to each player (as per rules – you get 1 RP per battle regardless of result). Handle any Agenda experience or other Crusade progression that applies on draws (or at least not block it).
Let me note it was a draw in the battle log or Crusade history for narrative flavor.
-- Actual: No draw option exists, so I can't accurately record the result. The app probably forces a win/loss, which could mess up tracking or feel wrong for tied games.
-- Impact: Draws happen in 40k (especially close games), and not supporting them makes the Crusade tracking feel incomplete or inaccurate. It breaks immersion for narrative campaigns where ties have meaning (e.g., "stalemate in the ruins"). Since the rules give RP on any result (win/lose/draw), the app should reflect that without forcing a fake winner. Fixing this would make the Play/Post-Game flow more robust and fun for multiplayer games.
-- Potential Fix Notes: Add a "Draw" / "Tie" button or toggle on the battle result screen (likely in lib/screens/play_screen.dart or a new post_game_result_screen.dart). Update the logic to award 1 RP to both sides on draw, and ensure any Agenda/XP checks don't assume a winner. Keep it simple – no need for VP input if the mission already handles scoring; just the outcome type.

## Deferred / Honor-System Items (RP Spend Only – No Enforcement)
- **DEF-001 (Low)**: Stub "Rearm and Resupply" (1 RP deduct, toast/log "Wargear swapped – honor system", no unit/wargear change or UI)
- **DEF-002 (Low)**: Stub "Maintenance and Upgrades" (if rules require; similar RP-only pattern: deduct 1–2 RP, log event)

## Data Fills (Separate Generation)
- **DATA-001 (Medium)**: Full Deathwatch unit data (MFM v3.8 page 19 reference; extract points/flags like prior factions – generate externally)

## Archived/Resolved This Sprint
