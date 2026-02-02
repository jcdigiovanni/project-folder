# BACKLOG.md
**Last Updated:** February 1, 2026 (Post-TODO Sprint Alignment)

## Bugs (Remaining – Low Priority)
- **BUG-011 (Low)**: Trying to take focus off of the soft keyboard on Adroid app causes currently selected options and text to be cleared on the Add Unit screen
- **BUG-012 (Low)**: In order to make edits to a unit (ie: change custom name) that is a part of a unit group, the unit first needs to be dropped from the group.  The unit can then be upgraded and then re-added to the group.  This is a clunky and unintuitive workflow 
- **BUG-018 (Medium)**: Can't Level Up or Edit Units While in a Group – Forces Clunky Workflow
-- Description: You can only level up or make general edits (like name changes) to a unit if it's directly on the OOB, not if it's inside a unit group. This means users have to constantly remove the unit from the group, edit/level it, then add it back – and repeat every time another change is needed. It doesn't crash the app, but it's a pain and feels like extra unnecessary steps.
-- Repro Steps: Create a unit and add it to a new unit group on the OOB. Try to level up the unit or edit something simple (like its name) while it's in the group – you can't. Remove the unit from the group, then level/edit it. Add it back to the group. Notice you have to do steps 3-4 again for any future edits.
-- Expected: Users should be able to level up or edit units right from within their group on the OOB, without needing to remove/add them each time. The app should handle groups smoothly so edits don't require this back-and-forth.
-- Actual: Edits and level-ups are blocked while in a group, forcing the remove-edit-add-repeat dance every time.
-- Impact: Makes managing grouped units tedious and frustrating, especially for armies with lots of squads/groups. Users might avoid groups altogether or make mistakes forgetting to re-add units. It's not a breaker but kills the flow and feels like bad design.
-- Potential Fix Notes: In the OOB or unit group view (likely lib/screens/oob_screen.dart or group_edit.dart), enable editing/level-up directly on grouped units without requiring removal. Maybe show a warning or auto-handle the group update behind the scenes. This ties to any existing TODO items about group editing polish.

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

- **ENH-008 (Medium)**: Display Crusade Points on In-Game Screen
-- Description: During an active game (in-game / play screen), the current Crusade Points total for the army needs to be shown clearly. This is the cumulative points value from the Order of Battle (units + enhancements, etc.), used for army building and balance checks. Make sure it's labeled fully as "Crusade Points" (never abbreviated to "CP", since CP means Command Points in 40k gameplay and could confuse players). Place it in a prominent spot: either in the top ribbon/bar (near the victory/defeat buttons) or at the top of the Agenda/box section.
-- Repro Steps / Current Behavior: Start or load a Crusade and begin a game (reach the in-game screen with agendas, tallies, victory/defeat options). Look for the army's total Crusade Points value. It's not displayed anywhere visible (or if it is, it's abbreviated/misplaced and easy to mistake for Command Points).
-- Expected: The screen shows the current total Crusade Points (pulled from OOB calculation) in clear text: "Crusade Points: X" (full words, no "CP").
-- Placement options:
--- Preferred: Top ribbon/bar, alongside or near victory/defeat buttons for quick reference.
--- Alternative: Top of the Agenda section/box, so it's visible while selecting/using agendas.
Updates dynamically if anything changes mid-game (though rare in standard play).
Readable in dark theme, touch-friendly size/font.
-- Actual: No visible display of Crusade Points on the in-game screen (or if present, not labeled clearly/fully, leading to potential confusion with Command Points).
-- Impact: Players need to know their army's Crusade Points total during games (e.g., for quick reference or narrative notes). Hiding it forces switching back to OOB/roster screens mid-game, breaking flow. Using "CP" risks confusion with in-game Command Points mechanics. Adding this makes the play screen more complete and self-contained, improving usability for real matches.
-- Potential Fix Notes: Calculate from the current Crusade/OOB model (likely in crusade_notifier.dart or similar provider). Add a simple Text widget or Card in the play_screen.dart layout (top AppBar/ribbon or Agenda header). Ensure label is "Crusade Points" verbatim.

## Deferred / Honor-System Items (RP Spend Only – No Enforcement)
- **DEF-001 (Low)**: Stub "Rearm and Resupply" (1 RP deduct, toast/log "Wargear swapped – honor system", no unit/wargear change or UI)
- **DEF-002 (Low)**: Stub "Maintenance and Upgrades" (if rules require; similar RP-only pattern: deduct 1–2 RP, log event)

## Data Fills (Separate Generation)
- **DATA-001 (Medium)**: Full Deathwatch unit data (MFM v3.8 page 19 reference; extract points/flags like prior factions – generate externally)

## Archived/Resolved This Sprint
