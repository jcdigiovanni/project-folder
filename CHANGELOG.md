# Changelog

All notable changes to the Crusade Bridge project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Roster assembly feature
- Game play tracking
- Maintenance and upgrade system
- Battle honors management
- Requisition system
- Campaign statistics
- Unit data for remaining 22 factions

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
