# Agenda Tracking Implementation

## Status Update (1/25/26)

### Completed Today:
- ✅ **Post-Game Screen** - Full implementation with unit summary, agenda recap, score display, and Mark for Greatness selector
- ✅ **XP Calculation System** - Participation (+1), Kill Tally (+1 per 3 kills cumulative), Marked for Greatness (+1)
- ✅ **Tally Updates** - Automatic update of played/survived/destroyed counters
- ✅ **RP Award** - +1 RP to crusade on game commit
- ✅ **Level Up Detection** - `pendingRankUp` flag set when unit crosses XP threshold
- ✅ **Level Up Visual Indicators** - "Level Up!" tag on collapsed units, highlighted XP row in expanded view
- ✅ **Group Visual Framing** - Units in groups shown with border and group name header on active game screen
- ✅ **Score Input** - You vs Opp score entry on victory/defeat dialog
- ✅ **Load Army Button** - Added to play screen when no rosters exist

### In Progress:
- 🔄 Phase 7: Rank Up / Battle Honour acknowledgment system

### Key Files Modified:
- `lib/screens/post_game_screen.dart` - New post-game review screen
- `lib/screens/active_game_screen.dart` - Victory/defeat with scores, group framing
- `lib/screens/oob_modify_screen.dart` - Level up indicators
- `lib/screens/play_screen.dart` - Load Army button
- `lib/models/crusade_models.dart` - `pendingRankUp` field, `groupId`/`groupName` on UnitGameState
- `lib/main.dart` - `/postgame/:gameId` route

---

## Overview
Implement in-game agenda tracking for Crusade games. Track per-unit data for agendas during gameplay in preparation for the post-game update/paperwork phase.

## Placeholder Agendas
1. **Tally Agenda** - User can enter tallies for units accomplishing something (e.g., kills, objectives held)
2. **Tiered Agenda** - Two levels of accomplishment:
   - Tier 1: Unit survived the battle
   - Tier 2: Unit survived with half or more wounds remaining

## Data Structure
- Track game -> List units (component units, not groups) -> Data field per agenda

## Tasks

### Phase 1: Game Screen Foundation
- [x] Create `active_game_screen.dart` - main screen for tracking in-game data
- [x] Wire up navigation from play_screen.dart Deploy button to active game screen
- [x] Create Game object with initialized unit states when deploying roster

### Phase 2: Agenda Data Setup
- [x] Create placeholder agenda definitions (tally + tiered)
- [x] Initialize agendas when game starts
- [x] Display active agendas on game screen

### Phase 3: Unit Tracking UI
- [x] List all component units (expanded from groups) on game screen
- [x] For tally agenda: Add increment/decrement controls per unit
- [x] For tiered agenda: Add tier selection (none/survived/survived with wounds) per unit

### Phase 4: Game State Management
- [x] Save game state to storage
- [x] Handle game completion flow
- [x] Score input on victory/defeat
- [x] Group visual framing for grouped units

### Phase 5: Post-Game Paperwork
- [x] Create `post_game_screen.dart` - review and finalize battle results
- [x] Display unit summary (kills, defeated status, agenda results)
- [x] Add "Mark for Greatness" selector (1 unit per battle)
- [x] Display final score and agenda recap
- [x] Add "Commit Results" button to finalize
- [x] Allow adjustments before committing

### Phase 6: XP Calculation Framework
- [x] Create XP calculation logic in model/service
- [x] **Participation XP**: 1 XP for each unit that participated in battle
- [x] **Kill Tally XP**: 1 XP per 3 kills (based on cumulative permanent kill tally)
- [x] **Marked for Greatness XP**: 1 XP bonus (Victor Bonus may allow additional marks)
- [x] Update unit permanent tallies after commit:
  - `played`: +1 for each unit
  - `survived`: +1 if not destroyed
  - `destroyed`: +1 if was destroyed
- [x] Apply XP gains to units
- [x] Detect rank changes and set `pendingRankUp` flag
- [x] Show "Level Up!" tag on OOB collapsed units
- [x] Highlight XP row in expanded unit details when pending rank up
- [x] Award +1 RP to crusade on game commit

### Phase 7: Rank Up / Battle Honour System
- [ ] Change `pendingRankUp` from boolean to integer counter (track multiple pending rank ups)
- [ ] Make "Level Up!" tag on OOB screen tappable to invoke rank up flow
- [ ] Create rank up dialog/screen:
  - Display unit's new rank
  - Show list of available Battle Honours to choose from
  - Confirm selection and apply honour to unit
- [ ] Create rank up acknowledgment flow (decrement counter by 1, not clear entirely)
- [ ] Allow selecting a Battle Honour when acknowledging rank up
- [ ] Clear `pendingRankUp` only when counter reaches 0
- [ ] Handle edge case: unit ranks up multiple times in one game (large XP gain)
- [ ] Update unit's `honours` list when Battle Honour is selected

## XP Thresholds (for reference)
- Battle-ready: 0-5 XP
- Blooded: 6-15 XP
- Battle-hardened: 16-30 XP
- Heroic: 31-50 XP
- Legendary: 51+ XP

## Current File References
- Models: `lib/models/crusade_models.dart`
  - `GameAgenda` class (lines 789-862) - supports tally and tiered types
  - `UnitGameState` class (lines 864-916) - per-unit tracking
  - `Game` class (lines 970+) - game session with agendas and unit states
- Play Screen: `lib/screens/play_screen.dart`
  - Deploy button TODO at line 443
