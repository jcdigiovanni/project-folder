# design.md - 40K Crusade Bridge App (Flutter Mobile-First Edition)

## Project Overview & Architecture
**Goal**: Deliver a responsive, touch-first Flutter app with clean dark theme, phased navigation, modular group support, Warlord/Epic Hero handling, and army avatar display. Single codebase targets mobile (primary) and desktop (companion).

**High-Level Architecture**:
[Flutter App]
├── main.dart (entry, theme, routing, initial fetch/setup)
├── models/
│   ├── crusade.dart (Crusade, UnitOrGroup with isWarlord/isEpicHero)
│   ├── roster.dart
│   └── ingame_state.dart
├── services/
│   ├── storage_service.dart (Hive/Isar for local persistence)
│   ├── drive_sync_service.dart (Google Sign-In + Drive API v3 - Save/Load)
│   ├── reference_data_service.dart (hardcoded/bundled unit names/points/enhancements + optional fetch)
│   └── image_service.dart (army icon handling)
├── providers/ (Riverpod)
│   ├── crusade_provider.dart
│   ├── oob_provider.dart
│   ├── roster_provider.dart
│   └── ingame_provider.dart
├── screens/
│   ├── landing_screen.dart
│   ├── new_crusade_screen.dart
│   ├── oob_modify_screen.dart (collapsible list + group builder + Warlord toggle)
│   ├── roster_assemble_screen.dart
│   ├── play_game_screen.dart (in-game tallies, minimal UI)
│   ├── post_game_screen.dart (recap + assign + OOA + victor + Epic Hero skip)
│   ├── maintenance_screen.dart (requisitions/honors/scars)
│   └── resources_screen.dart (links + reference update)
├── widgets/
│   ├── army_avatar.dart (circular icon with custom/faction fallback)
│   ├── unit_card.dart (collapsible, Warlord/Epic Hero badges)
│   ├── points_input.dart (required field + reference display)
│   └── d6_roller.dart (for OOA tests)
└── theme.dart (dark theme, fonts, pastel accents)
text**State Management**: Riverpod (scoped providers for current Crusade, in-game state, etc.).  
**Navigation**: GoRouter (typed routes, shell for bottom nav mobile / rail desktop).  
**Storage**: Hive (fast NoSQL for models) + path_provider for icon files.  
**Sync**: google_sign_in + googleapis (Drive v3 app data folder) – manual Save/Load.  
**Reference Data**: Bundled JSON (unit names/points/variants/enhancements) in assets + optional fetch for updates.  
**Offline**: All core ops local; sync/reference fetch async with indicators.

**Responsive Design**:
- Mobile: BottomNavigationBar, full-screen modals, large touch targets (min 48dp).
- Desktop: NavigationRail or Drawer, larger cards/tables, keyboard focus.
- Use `MediaQuery` / `LayoutBuilder` + `OrientationBuilder` for layout switching.

## Theme & UI Style
**Dark Theme** (Material 3):
- Background: #0A0A0A → #121212 subtle gradient
- Primary accent: #C2185B (magenta-pink)
- Sailor Moon highlights: #FFB6C1 (light pink), #FFD1DC (pastel pink), #FFF59D (soft yellow)
- Text: #E0E0E0 primary, #B0BEC5 secondary
- Cards: elevation 4, rounded 12dp, subtle #424242 border

**Fonts** (Google Fonts):
- Body/data: `Inter` (high readability)
- Headers/group names/buttons: `Great Vibes` (script, pastel pink/yellow glow)
- Secondary (faction/labels): `Orbitron` (sci-fi)

**theme.dart** snippet:
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0A0A0A),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFC2185B),
    brightness: Brightness.dark,
  ),
  textTheme: TextTheme(
    bodyMedium: GoogleFonts.inter(fontSize: 16, color: Colors.grey[300]),
    headlineMedium: GoogleFonts.greatVibes(
      fontSize: 36,
      color: const Color(0xFFFFB6C1),
      shadows: [Shadow(blurRadius: 4, color: Colors.black.withOpacity(0.6))],
    ),
    headlineSmall: GoogleFonts.orbitron(fontSize: 24, color: Colors.white),
    labelLarge: GoogleFonts.greatVibes(fontSize: 20, color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1E1E1E),
      foregroundColor: const Color(0xFFFFB6C1),
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
);
```

## Screen-by-Screen Design & Key Widgets

1. **Landing Screen**  
   - Scaffold with AppBar ("40K Crusade Bridge" + ArmyAvatar if loaded)  
   - Body: GridView or Column of large ElevatedButtons (responsive)  
     - New Crusade  
     - Load Crusade  
     - Build/Modify OOB  
     - Assemble Roster  
     - Play Game  
     - Save to Drive  
     - Load from Drive  
     - Resources  
   - BottomNavigationBar (mobile): Icons for Home / OOB / Play / Sync  

2. **New Crusade Screen/Modal**  
   - Form:  
     - TextField (name)  
     - Dropdown (faction)  
     - Dropdown (detachment + custom text field if selected)  
   - ArmyAvatar preview + "Change Icon" button (opens image_picker)  
   - Submit → create Crusade (auto-assign faction icon, 1000 supply limit, 5 RP) → navigate to Modify OOB  

3. **Modify OOB / Maintenance Screen**  
   - ListView of ExpansionTile cards (groups collapsible)  
   - Group header:  
     - Small ArmyAvatar  
     - Group name  
     - Total points sum  
     - Expand icon  
   - Component rows (when expanded):  
     - Name  
     - Points (editable)  
     - Models current/max  
     - Notes  
     - Honors/scars lists  
   - Character units: SwitchListTile "Warlord" (validate only one per OOB)  
   - Epic Hero units: Grayed-out XP/honors fields + badge "Epic Hero"  
   - FloatingActionButton:  
     - + Add Unit  
     - + Add Group  
   - Add modal:  
     - Dropdown (faction unit names)  
     - Variant/size dropdown (if applicable, e.g., Seraphim 5/10 models)  
     - Points (required field)  
     - Warlord toggle (if Character)  

4. **Assemble Roster Screen**  
   - Selection list from OOB (checkboxes, collapsed groups)  
   - Running totals:  
     - Points used / Supply %  
     - Crusade Points  
   - Save button → prompt for name → store roster  

5. **Play Game Screen**  
   - Load roster → minimal roster view (collapsed groups)  
   - Per unit/group row:  
     - Name + points  
     - Kill tally stepper (+/- buttons)  
     - Defeated checkbox  
     - Agenda tally fields (dynamic)  
   - Reference button → bottom sheet with notes, statsText, honors/scars (large readable text)  
   - Top bar: Agendas list (editable text), points/CP reminder  
   - FAB: "Conclude Game" → transition to Post-Game  

6. **Post-Game Screen**  
   - Stepper or tabbed sections:  
     - Recap tallies / defeated  
     - Assign group kills/XP to components (dropdowns per unit)  
     - Agenda XP application  
     - Mark for Greatness (select one unit/group)  
     - Out of Action tests (D6 roller with reroll option; skip Epic Heroes)  
     - Victor bonus (dropdown: Extra Honor, Bonus RP, Additional MfG, Custom text)  
   - Final "Apply & Save" button → update OOB, prompt Save to Drive  

7. **Google Drive Sync Modal**  
   - After one-time sign-in: List of saved files (if multiple)  
   - Buttons:  
     - "Save to Drive" (upload current state)  
     - "Load from Drive" (download and apply)  
   - Progress indicators: "Saving…", "Loading…"  
   - Auto-prompt after major actions (post-game, OOB edits)  

8. **Army Avatar Widget**  
   - Reusable `ArmyAvatar` widget: CircleAvatar with:  
     - FileImage (custom armyIconPath)  
     - Fallback: AssetImage (factionIconAsset)  
     - Fallback: Default generic icon  
   - Used in:  
     - AppBar headers  
     - OOB/roster lists  
     - Sync modal preview  

9. **Resources Screen**  
   - List of ListTile with tappable links:  
     - Wahapedia 10th Edition  
     - Warhammer Community downloads  
     - Crusade Rules PDF  
     - Munitorum Field Manual  

## Navigation & Routing (GoRouter)
- ShellRoute with bottom nav (mobile) / rail (desktop)  
- Routes:  
  - `/landing`  
  - `/new-crusade`  
  - `/oob`  
  - `/roster-assemble`  
  - `/play/:rosterId`  
  - `/post-game`  
  - `/resources`

## Edge Cases & Polish
- Warlord: Alert if attempting >1, auto-deselect old one  
- Epic Hero: Disable XP/OOA/honors UI elements (gray out, hide inputs)  
- Points: Required field on add/edit, group auto-sum displayed  
- Image fallback: Default icon if custom file load fails  
- Loading indicators for Drive operations  
- Error toasts (e.g., invalid points, sync failure)  
- Tooltips/rules reminders on key fields (e.g., Warlord, Epic Hero)