# Changelog

All notable changes to the Crusade Bridge project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Requisitions Phase 3: Advanced/Healing Requisitions**
  - Repair and Recuperate: Remove Battle Scars from units (cost = scar count)
  - Renowned Heroes: Grant Enhancements to Characters (1-3 RP based on count)
  - Legendary Veterans: Allow non-Characters to exceed 30 XP and 3 Honours caps

- **Requisitions Phase 2: Fresh Recruits**
  - Add models to existing units up to datasheet maximum
  - Variable RP cost: 1 RP base + 1 per Battle Honour on the unit
  - Shows eligible units with next size option and points difference
  - Enforces Supply Limit (blocks if upgrade would exceed)
  - Records requisition events in crusade history

- **Requisitions Phase 1 Complete**
  - RP display now shows X / 10 format (max cap enforced)
  - Supply Used display with progress bar showing OOB points vs Supply Limit
  - Over-limit warning when Supply Used exceeds Supply Limit
  - Increase Supply Limit requisition functional (+200 pts for 1 RP)

- **Post-Game Screen Enhancements**
  - Optional game notes field for recording battle details
  - Google Drive backup prompt after committing results

### Changed
- **RP System**
  - RP now caps at 10 maximum (per 10th ed Crusade rules)
  - Post-game RP award only applies if under cap

- **Active Game Screen Polish**
  - Kill tally now shows XP progress indicator (3 dots + earned XP badge)
  - Survived/Destroyed toggle redesigned as segmented button (clearer status)

### Fixed
- **BUG-004:** Marked for Greatness now awards +3 XP (was incorrectly +1) per 10th ed rules
- **BUG-002:** Supply Limit increases now persist correctly (was missing games/rosters/history on save)
- **BUG-003:** Fixed data loss in 4 OOB operations (group disband, group edit, enhancement add) - missing rosters/games fields

### Improved
- **ENH-001:** Added explicit close buttons to modal bottom sheets (Create Group, Add Unit, Edit Group, Renowned Heroes, Add Crusade Force)
- **ENH-003:** OOB screen now shows full dashboard: Supply (used/limit), Remaining pts, Total CP, Available RP

### Planned
- Battle honours selection on rank up
- Maintenance and upgrade system
- Deathwatch unit data (only missing faction)

---

## [0.3.2] - 2026-01-25

### Added
- **Post-Game Review Screen**
  - Victory/Defeat banner with final score display
  - Agenda recap section showing tally totals and tier achievements
  - Mark for Greatness selector (1 unit per battle, +1 XP bonus)
  - Unit summary cards with adjustable kills and destroyed status
  - Commit Results button with confirmation dialog

- **XP Calculation System**
  - Participation XP: +1 XP for each unit that participated
  - Kill Tally XP: +1 XP per 3 cumulative kills (tracks across games)
  - Marked for Greatness XP: +1 XP bonus for selected unit
  - Epic Heroes correctly excluded from XP gains

- **Level Up Detection & Indicators**
  - `pendingRankUp` field on UnitOrGroup model
  - "Level Up!" amber tag on collapsed units in OOB screen
  - Highlighted XP row with rank badge in expanded unit details
  - Automatic detection when unit crosses XP threshold

- **Active Game Enhancements**
  - Score input dialog (You vs Opp) on Victory/Defeat
  - Group visual framing with pink border and group name header
  - `groupId` and `groupName` fields on UnitGameState for tracking

- **Play Screen**
  - "Load Army" button when no rosters exist

- **Crusade Rewards**
  - +1 RP awarded to crusade on game commit

### Changed
- Victory/Defeat now navigates to Post-Game Review instead of Dashboard
- Unit states now track group membership for visual grouping

### Technical
- New route: `/postgame/:gameId`
- New screen: `post_game_screen.dart`
- New model fields: `UnitOrGroup.pendingRankUp`, `UnitGameState.groupId`, `UnitGameState.groupName`
- Regenerated Hive adapters for model changes

---

## [0.3.1] - 2026-01-24

### Added
- **Exit App Button**
  - Added Exit button to bottom navigation bar
  - Confirmation dialog before exiting
  - Uses `SystemNavigator.pop()` for clean app exit

- **Group Deletion Confirmation**
  - Warning dialog when deleting a group with units
  - Shows unit count and names (up to 3)
  - "Ungroup Only" option returns units to OOB without deleting
  - "Delete All" option removes group and all units

- **Google Drive Campaigns Backup (v1.1)**
  - Backup now includes both crusades and campaigns
  - Restore handles campaigns from v1.1+ backups
  - Backward compatible with v1.0 crusade-only backups
  - New filename format: `CrusadeBridge_Xc_Ycamp_DATE.json`

### Changed
- **Conditional Play Button**
  - Play button now only shows when a crusade is loaded
  - Without crusade: Home, Load, Settings, Exit (4 items)
  - With crusade: Home, Dashboard, Play, Settings, Exit (5 items)

- **Clear Local Data**
  - Now clears both crusades and campaigns
  - Updated dialog text to mention campaigns

- **Renowned Heroes Enhancement**
  - Enhancement dropdown now filters to current detachment only
  - Previously showed all faction enhancements incorrectly

- **Warlord Toggle**
  - Now hidden when a warlord already exists in the OOB
  - Checks both top-level units and units inside groups

### Fixed
- Removed unused `go_router` import in `campaign_view_screen.dart`
- Removed unnecessary non-null assertion in `oob_modify_screen.dart`

### Technical
- Updated backup version from 1.0 to 1.1
- Refactored bottom navigation index calculation for conditional items

---

## [0.3.0] - 2026-01-24

### Added
- **Roster System**
  - Roster list screen with create/delete functionality
  - Roster view screen with unit summary and stats
  - Roster build screen for assembling units from OOB
  - Crusade Points (CP) tracking per roster
  - `calculateTotalCrusadePoints()` method on Roster model

- **Play Section**
  - Battle size selection (Combat Patrol, Incursion, Strike Force, Onslaught, Apocalypse)
  - Points indicator system (green: under/at limit, yellow: up to 5% over, red: >5% over)
  - Roster selection with CP display
  - No-roster state handling with redirect to OOB or roster creation

- **Campaign Manager (Major Feature)**
  - Standalone Campaign model elevated above Crusades
  - Multiple crusade forces can participate in a single campaign
  - `CrusadeCampaignLink` model for per-crusade performance tracking (wins/losses/draws)
  - Campaign list screen with active/ended sections
  - Campaign view screen with force cards and win rate display
  - Add/remove crusade forces from campaigns
  - End/reactivate campaign functionality
  - Campaign Manager button on landing screen

- **Game Data Models**
  - `Game` model for tracking individual game sessions
  - `GameAgenda` model with objective (binary/tiered) and tally types
  - `UnitGameState` model for in-game unit tracking (kills, destroyed status)
  - `BattleSizeType` and `GameResult` constants

- **Provider & Storage**
  - `CampaignsNotifier` with full CRUD operations
  - Campaign provider with `addCrusadeToCampaign`, `removeCrusadeFromCampaign`, `recordGameResult`
  - `getCampaignsForCrusade()` method to find campaigns containing a specific force
  - Campaign storage operations in StorageService
  - New Hive adapters for Campaign, CrusadeCampaignLink, Game, GameAgenda, UnitGameState

- **Complete Unit Data (Major Milestone)**
  - 27 of 28 factions now have complete unit data (~1,248 total units)
  - Full detachment and enhancement data for all 27 factions
  - Unit schema includes: name, role, sizeOptions, pointsOptions, isEpicHero, isCharacter
  - Only Deathwatch unit file remaining

### Changed
- Refactored Campaign model to be standalone (no longer embedded in Crusade)
- Removed `campaigns` field from Crusade model
- Updated navigation to route Play button to `/play`
- Dashboard "Assemble Roster" and "Play Game" buttons now functional

### Fixed
- Pre-populate smallest unit size/points when selecting a unit in OOB
- Roster view "Record Game" replaced with "View Stats" button

### Technical
- Added routes: `/rosters`, `/roster/:rosterId`, `/roster/:rosterId/edit`, `/play`, `/campaigns`, `/campaign/:campaignId`
- Hive TypeIds: Campaign (4), GameAgenda (5), UnitGameState (6), Game (7), CrusadeCampaignLink (8)

---

## [0.2.0] - 2026-01-23

### Added
- **Disband Crusade Feature**
  - Added "Disband Crusade" tile to dashboard action grid
  - Implemented confirmation dialog with warning message
  - Added `deleteCrusade()` method to `StorageService`
  - Added `deleteCrusade()` method to `CurrentCrusadeNotifier`
  - Proper navigation flow: navigate first, then delete data

- **Unit Data Enhancements**
  - Added `role` field to unit data schema (HQ, Troops, Elites, Fast Attack, Heavy Support, Dedicated Transport)
  - Added `isEpicHero` boolean field to identify named characters
  - Completed Adepta Sororitas faction data with 32 units
  - Role-based Warlord designation (HQ units that are not Epic Heroes)

- **Synchronous Data Access**
  - Added `getUnitsSync()` method to `ReferenceDataService`
  - Added `getUnitDataSync()` method to `ReferenceDataService`
  - Async data preloading when faction is selected in UI

### Fixed
- **Critical Bug: Async/Sync Mismatch**
  - Fixed async method calls in synchronous UI builders in `oob_modify_screen.dart`
  - Unit dropdown now properly loads from cache after faction selection
  - Size variant dropdown correctly accesses cached unit data
  - Warlord toggle properly checks unit role from cached data
  - Epic Hero flag correctly retrieved during unit creation

- **Navigation Issue**
  - Fixed GoException when disbanding crusade
  - Changed navigation path from `/` to `/landing` for proper routing

### Changed
- Restructured `factions_and_detachments.json` to new format
- Updated OOB modify screen to preload unit data asynchronously
- Enhanced unit JSON schema with additional metadata fields

### Removed
- Removed redundant refresh icon from landing screen
- Removed hamburger menu from dashboard (redundant with action tiles)

---

## [0.1.0] - 2026-01-XX

### Added
- Initial project setup with Flutter and Riverpod
- Basic crusade CRUD operations
- Order of Battle (OOB) management
  - Add individual units
  - Create unit groups
  - Edit units and groups
  - Delete units and groups
- Google Drive sync functionality
  - Push crusades to Drive
  - Pull crusades from Drive
  - Conflict detection and resolution
- Local storage with Hive
- Faction and detachment selection
- Custom army icon support
- Bottom navigation with context-aware menu
- Material Design 3 dark theme
- Landing screen with crusade list
- Dashboard with action tiles
- Settings screen
- Reference data service with caching

### Technical
- Set up GoRouter for navigation
- Implemented Riverpod state management
- Created data models (Crusade, UnitOrGroup)
- Integrated Google Drive API
- Implemented Hive adapters for data persistence

---

## Development Notes

### Session 2026-01-23
**Focus:** Bug fixes, data enhancements, and crusade management

**Files Modified:**
- `lib/services/reference_data_service.dart` (+32 lines)
- `lib/services/storage_service.dart` (+3 lines)
- `lib/providers/crusade_provider.dart` (+7 lines)
- `lib/screens/oob_modify_screen.dart` (~40 lines modified)
- `lib/screens/crusade_dashboard_screen.dart` (+45 lines)
- `lib/screens/landing_screen.dart` (-12 lines)
- `assets/data/units/adepta_sororitas.json` (formatted + enhanced)

**Impact:**
- Resolved critical async/sync issue that prevented unit selection
- Enabled users to delete crusades safely
- Enhanced unit data structure for better game rules support
- Improved code maintainability with sync data access methods

**Technical Debt Addressed:**
- Fixed async method calls in sync contexts
- Improved data caching strategy
- Cleaned up redundant UI elements

**Technical Debt Created:**
- Need to populate 22 remaining faction unit files
- Consider adding loading indicators during async data fetching

---

## Migration Notes

### From 0.1.0 to 0.2.0

**Breaking Changes:**
None - backward compatible with existing crusade data.

**Data Updates:**
If you have custom unit data files, you'll need to add the following fields:
```json
{
  "role": "HQ|Troops|Elites|Fast Attack|Heavy Support|Dedicated Transport",
  "isEpicHero": true|false
}
```

**Code Changes:**
If you're calling `ReferenceDataService.getUnits()` or `getUnitData()` in synchronous contexts, update to use the new sync methods:
- `getUnits()` → `getUnitsSync()` (after preloading)
- `getUnitData()` → `getUnitDataSync()` (after preloading)

---

## Legend

- **Added** - New features
- **Changed** - Changes to existing functionality
- **Deprecated** - Features that will be removed in future versions
- **Removed** - Features that have been removed
- **Fixed** - Bug fixes
- **Security** - Security-related changes
