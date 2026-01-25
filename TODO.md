# Agenda Tracking Implementation

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
- [ ] Create `post_game_screen.dart` - review and finalize battle results
- [ ] Display unit summary (kills, defeated status, agenda results)
- [ ] Add "Mark for Greatness" selector (1 unit per battle)
- [ ] Display final score and agenda recap
- [ ] Add "Commit Results" button to finalize
- [ ] Allow adjustments before committing

### Phase 6: XP Calculation Framework
- [ ] Create XP calculation logic in model/service
- [ ] **Participation XP**: 1 XP for each unit that participated in battle
- [ ] **Kill Tally XP**: 1 XP per 3 kills (based on cumulative permanent kill tally)
- [ ] **Marked for Greatness XP**: 1 XP bonus (Victor Bonus may allow additional marks)
- [ ] Update unit permanent tallies after commit:
  - `played`: +1 for each unit
  - `survived`: +1 if not destroyed
  - `destroyed`: +1 if was destroyed
- [ ] Apply XP gains to units
- [ ] Handle rank progression based on XP thresholds

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
