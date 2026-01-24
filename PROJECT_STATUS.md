# Crusade Bridge - Project Status

**Last Updated:** January 24, 2026

## 🎯 Current Status: Active Development

### Recent Session Summary (2026-01-24)

This session focused on UX improvements and data management enhancements: added Exit app button to navigation, made Play conditional on having a loaded crusade, upgraded Google Drive backup to include campaigns (v1.1), added group deletion confirmation with ungroup option, and improved the Renowned Heroes enhancement flow.

---

## 📊 Metrics

### Code Changes
- **Files Modified:** 5
- **Lines Added:** ~120
- **Lines Modified:** ~60
- **New Methods:** 3
- **Bug Fixes:** 2 (warnings)

### Files Touched
1. `lib/main.dart` - Exit button, conditional Play button, refactored navigation
2. `lib/screens/settings_screen.dart` - Clear campaigns with crusades
3. `lib/services/google_drive_service.dart` - Backup/restore campaigns (v1.1)
4. `lib/screens/oob_modify_screen.dart` - Group delete confirmation, enhancement filtering
5. `lib/screens/campaign_view_screen.dart` - Removed unused import

---

## ✅ Completed Features

### Data Management
- ✅ Crusade deletion (disband) functionality
- ✅ Proper navigation flow on crusade deletion
- ✅ Confirmation dialogs with warnings
- ✅ Auto-refresh crusade list after changes

### Unit Data Structure
- ✅ Enhanced unit JSON schema with `role`, `isEpicHero`, and `isCharacter` fields
- ✅ All 27 factions with detachments and enhancements defined
- ✅ 27/28 unit data files populated (~1,248 total units)
- ✅ Role-based UI logic (Warlord designation for HQ non-Epic Heroes)
- ✅ Synchronous data access methods for cached unit data

### Bug Fixes
- ✅ Fixed async/sync mismatch in OOB modify screen
- ✅ Fixed routing error when disbanding crusades
- ✅ Removed redundant refresh button from landing screen
- ✅ Fixed unused import warning in campaign_view_screen
- ✅ Fixed unnecessary non-null assertion in oob_modify_screen

### UX Improvements
- ✅ Exit app button with confirmation dialog
- ✅ Play button hidden when no crusade loaded
- ✅ Group deletion confirmation with "Ungroup Only" option
- ✅ Warlord toggle hidden when warlord already exists
- ✅ Renowned Heroes enhancement limited to current detachment

---

## 🚧 In Progress

### Next Immediate Tasks
- [ ] Create Deathwatch unit data file (only missing faction)
- [ ] In-game unit tracking (kills, destroyed status, marked for greatness)
- [ ] Post-game flow (experience, battle honors, requisitions)
- [ ] Implement maintenance/upgrade system

---

## 📋 Feature Status

| Feature | Status | Notes |
|---------|--------|-------|
| Create Crusade | ✅ Complete | Full faction/detachment selection |
| Load Crusade | ✅ Complete | From local storage |
| Delete Crusade | ✅ Complete | With confirmation dialog |
| Modify OOB | ✅ Complete | Add/edit/delete units and groups |
| Unit Data (All Factions) | ✅ Complete | 27/28 factions populated (~1,248 units) |
| Unit Data (Deathwatch) | ⏳ Pending | Only missing unit file |
| Assemble Roster | ✅ Complete | Create/view/edit rosters from OOB |
| Play Game | 🚧 In Progress | Battle size selection, roster selection done |
| Campaign Manager | ✅ Complete | Multi-force campaigns with win tracking |
| Maintenance Mode | ⏳ Planned | Coming soon |
| Resources | ⏳ Planned | Coming soon |
| Google Drive Sync | ✅ Complete | Push/pull crusades + campaigns (v1.1) |

---

## 🏗️ Architecture

### Key Services
- **StorageService** - Hive-based local persistence (Crusades + Campaigns)
- **ReferenceDataService** - Faction/unit data with caching
- **GoogleDriveService** - Cloud sync functionality
- **SyncService** - Conflict resolution logic

### Providers
- **CrusadeProvider** - Current crusade state management
- **CampaignsProvider** - Campaign CRUD and force management

### Data Models
- **Crusade** - Main crusade data structure
- **UnitOrGroup** - Individual units or grouped units
- **Roster** - Battle-ready unit selection from OOB
- **Campaign** - Standalone campaign with multi-crusade support
- **CrusadeCampaignLink** - Per-crusade performance tracking in campaigns
- **Game** - Individual game session tracking
- **GameAgenda** - Objective (binary/tiered) or tally agenda tracking
- **UnitGameState** - In-game unit status (kills, destroyed, marked for greatness)
- **Faction/Detachment** - Reference data structure

---

## 📈 Progress Tracking

### Faction Data Completion
- **Factions & Detachments:** 27/27 ✅ (100%)
- **Unit Data Files:** 27/28 (96.4%)

| Faction | Units | Status |
|---------|-------|--------|
| Adepta Sororitas | 32 | ✅ |
| Adeptus Astartes | 99 | ✅ |
| Adeptus Custodes | 15 | ✅ |
| Adeptus Mechanicus | 31 | ✅ |
| Aeldari | 51 | ✅ |
| Astra Militarum | 64 | ✅ |
| Black Templars | 103 | ✅ |
| Blood Angels | 118 | ✅ |
| Chaos Daemons | 53 | ✅ |
| Chaos Knights | 11 | ✅ |
| Chaos Space Marines | 47 | ✅ |
| Dark Angels | 109 | ✅ |
| Death Guard | 36 | ✅ |
| Deathwatch | - | ⏳ Missing |
| Drukhari | 23 | ✅ |
| Emperor's Children | 22 | ✅ |
| Genestealer Cults | 24 | ✅ |
| Grey Knights | 25 | ✅ |
| Imperial Agents | 28 | ✅ |
| Imperial Knights | 12 | ✅ |
| Leagues of Votann | 21 | ✅ |
| Necrons | 47 | ✅ |
| Orks | 52 | ✅ |
| Space Wolves | 106 | ✅ |
| T'au Empire | 38 | ✅ |
| Thousand Sons | 34 | ✅ |
| Tyranids | 33 | ✅ |
| World Eaters | 19 | ✅ |
| **Total** | **~1,248** | |

---

## 🎯 Roadmap

### Phase 1: Core Functionality ✅
- [x] Crusade CRUD operations
- [x] OOB management
- [x] Google Drive sync
- [x] Complete faction data (27/28 done, only Deathwatch missing)

### Phase 2: Gameplay Features (Current)
- [x] Roster assembly
- [x] Campaign tracking
- [ ] In-game unit tracking
- [ ] Post-game flow
- [ ] Battle honors
- [ ] Requisitions

### Phase 3: Advanced Features
- [ ] Unit maintenance
- [ ] Statistics/analytics
- [ ] Export/sharing

---

## 🐛 Known Issues

None currently tracked.

---

## 💡 Technical Debt

1. **Deathwatch Unit Data** - Create deathwatch.json unit file (only missing faction)
2. **Filename Inconsistency** - `black_templar.json` should be `black_templars.json` (plural)
3. **Error Handling** - Could add more robust error handling in sync operations
4. **Testing** - No automated tests yet

---

## 📝 Notes

- Using Flutter with Riverpod for state management
- Hive for local storage
- Google Drive API for cloud sync
- Material Design 3 theming
