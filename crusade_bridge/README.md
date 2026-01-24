# Crusade Bridge

A comprehensive Flutter application for managing Warhammer 40,000 Crusade campaigns.

## 📱 Overview

Crusade Bridge is a mobile-first companion app for tracking and managing your Warhammer 40K Crusade forces. Build your Order of Battle, track battle honors, manage requisitions, and sync your crusade data across devices via Google Drive.

## ✨ Features

### Current Features

- **Crusade Management**
  - Create new crusades with faction and detachment selection
  - Load and switch between multiple crusades
  - Disband crusades with confirmation
  - Requisition Points (RP) tracking

- **Order of Battle (OOB)**
  - Add individual units with size/points variants
  - Create unit groups for organized force management
  - Edit unit names and notes
  - Track model counts and point totals
  - Warlord designation for HQ units
  - Epic Hero identification
  - Character unit identification
  - Expandable unit details with visual frames
  - XP tracking and rank progression
  - Battle honours and scars display
  - Crusade Points (CP) calculation

- **Requisitions System** 🆕
  - Renowned Heroes: Add detachment enhancements to character units (1 RP)
  - Enhancement point cost tracking
  - Eligibility validation (characters only, non-Epic Heroes)
  - More requisitions coming soon

- **Cloud Sync**
  - Push crusades to Google Drive with human-readable filenames 🆕
  - Pull crusades from Google Drive with rich metadata display 🆕
  - Smart file updates using crusade ID matching 🆕
  - Automatic conflict detection and resolution
  - Timestamped version tracking
  - Multi-crusade backup support

- **Data Management**
  - Local storage with Hive
  - Faction and detachment data for all 26 factions
  - Unit data for Adepta Sororitas and Leagues of Votann 🆕
  - Enhancement data for detachments 🆕
  - Auto-loading and caching for performance

### Coming Soon
- Additional unit data for remaining factions
- More requisition types (Increase Supply, Rearm & Resupply, Fresh Recruits)
- Roster assembly for battles
- Game tracking and battle results
- Post-game unit updates (XP, honours, scars)
- Battle honours and scars management UI
- Campaign statistics and analytics

## 🏗️ Architecture

### Tech Stack
- **Framework:** Flutter
- **State Management:** Riverpod
- **Local Storage:** Hive
- **Cloud Storage:** Google Drive API
- **Navigation:** GoRouter
- **Theme:** Material Design 3

### Project Structure
```
lib/
├── models/          # Data models (Crusade, UnitOrGroup)
├── providers/       # Riverpod state providers
├── screens/         # UI screens
├── services/        # Business logic (Storage, Sync, Reference Data)
├── utils/          # Helper utilities
├── widgets/        # Reusable UI components
└── theme.dart      # App theming

assets/
└── data/
    ├── factions_and_detachments.json
    └── units/       # Per-faction unit data
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK
- Android Studio / Xcode for mobile development
- Google Cloud project with Drive API enabled (for sync features)

### Installation

1. Clone the repository
```bash
git clone [repository-url]
cd crusade_bridge
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

### Configuration

For Google Drive sync functionality, you'll need to:
1. Create a Google Cloud project
2. Enable Google Drive API
3. Configure OAuth 2.0 credentials
4. Add credentials to the app configuration

## 📊 Data Structure

### Faction Data (v2.0)
Located in `assets/data/factions_and_detachments.json`:
```json
{
  "version": "2.0",
  "factions": {
    "Faction Name": {
      "icon": "path/to/icon.png",
      "detachments": {
        "Detachment Name": {
          "enhancements": [
            {"name": "Enhancement Name", "points": 15}
          ]
        }
      }
    }
  }
}
```

### Unit Data
Located in `assets/data/units/[faction_name].json`:
```json
{
  "faction": "Faction Name",
  "version": "1.0",
  "units": [
    {
      "name": "Unit Name",
      "role": "HQ|Troops|Elites|Fast Attack|Heavy Support|Dedicated Transport",
      "sizeOptions": [5, 10],
      "pointsOptions": [100, 200],
      "isEpicHero": false,
      "isCharacter": true
    }
  ]
}
```

## 🎮 Usage

### Creating a Crusade
1. Tap "New Crusade" on the landing screen
2. Select your faction
3. Choose a detachment
4. Set supply limit and starting RP
5. Name your crusade
6. Optionally add a custom army icon

### Managing Your OOB
1. Navigate to "Modify OOB" from the dashboard
2. Add units by selecting faction, unit, and size variant
3. Create groups to organize your force
4. Edit unit names and add notes
5. Track points against your supply limit

### Syncing with Google Drive
1. Tap "Save to Drive" to push your crusade
2. Use "Restore from Drive" to pull crusades
3. Handle conflicts when local and remote versions differ

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## 📝 License

[License information to be added]

## 🙏 Acknowledgments

- Games Workshop for Warhammer 40,000
- Flutter and Dart teams
- Community contributors

## 📞 Support

For questions or support, please open an issue on GitHub.

---

**Current Version:** Alpha Development (v0.2.0 - Requisitions Update)
**Last Updated:** January 23, 2026

**Recent Updates:**
- ✨ Requisitions system with Renowned Heroes
- ✨ Enhancement system for character units
- ✨ Improved Google Drive backup with readable filenames
- ✨ Visual polish with unit expansion frames
- 🐛 Fixed async unit loading issues
- 📦 Added Leagues of Votann unit data

See [PROGRESS_UPDATE_2026-01-23.md](PROGRESS_UPDATE_2026-01-23.md) for detailed changes.
