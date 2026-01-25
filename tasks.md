# tasks.md - 40K Crusade Bridge App (Flutter Mobile-First Edition)

## Overview
This document provides a step-by-step implementation plan for building the app based on the locked requirements.md and design.md in sources.

- **Goal**: Generate a complete, runnable Flutter project that matches the spec.
- **Approach**: Sequential tasks, starting with setup → core models → theme/UI → screens → services → polish.
- **Dependencies**: Flutter SDK installed, Dart knowledge not required (AI generates code).
- **Tools/Packages**: Use only those listed in requirements.md (Riverpod, Hive/Isar, GoRouter, google_sign_in + googleapis, image_picker, etc.).
- **Testing**: Add basic widget tests or manual verification notes where relevant.
- **Milestones**: Grouped into phases for easier iteration.

## Phase 1: Project Setup & Foundation (1-2 hours)
1. **Initialize Flutter project**  
   - Run `flutter create 40k_crusade_bridge` (or use existing folder)  
   - Update `pubspec.yaml` with name, description, version, and all required dependencies/assets/fonts  
   - Add assets: icons/factions/*.png (generic faction icons), data/reference_units.json (starter points/names)  
   - Add fonts: Inter, Great Vibes, Orbitron via Google Fonts  

2. **Set up Riverpod & GoRouter**  
   - Create `lib/main.dart` with MaterialApp.router, theme (darkTheme from theme.dart), and GoRouter shell  
   - Define initial routes (/landing as home)  

3. **Create theme.dart**  
   - Implement darkTheme as per design.md snippet  
   - Use GoogleFonts for Inter, Great Vibes, Orbitron  
   - Apply pastel pink/yellow accents, beveled buttons, etc.  

4. **Create basic models (lib/models/)**  
   - crusade.dart: Crusade class with id, name, faction, detachment, supplyLimit, rp, battleHistory, oob, templates, armyIconPath, factionIconAsset  
   - unit_or_group.dart: UnitOrGroup class with id, type, name, customName, points, components (List<UnitOrGroup>?), modelsCurrent, modelsMax, xp, honours (List<String>), scars (List<String>), crusadePoints, tallies (Map), notes, statsText, isWarlord (bool?), isEpicHero (bool?)  
   - roster.dart: Roster class  
   - ingame_state.dart: InGameState class  

## Phase 2: Storage & Services (2-4 hours)
5. **Implement storage_service.dart**  
   - Use Hive (or Isar) for local persistence  
   - Register adapters for Crusade, UnitOrGroup, etc.  
   - Methods: saveCrusade, loadCrusade, saveRoster, loadRosters, etc.  
   - Handle army icon files via path_provider  

6. **Implement drive_sync_service.dart**  
   - Google Sign-In + Drive API v3 (app data folder)  
   - Methods: signIn, saveToDrive (serialize Crusade to JSON + icon file), loadFromDrive (list files, download/apply)  
   - Handle progress, errors, one-time auth  

7. **Implement reference_data_service.dart**  
   - Load bundled reference_units.json from assets  
   - Optional fetch from GitHub URL (or user-defined) for points updates  
   - Cache locally, provide lookup for unit names/points/variants/enhancements  

8. **Implement image_service.dart**  
   - Pick & save custom army icon using image_picker  
   - Resize/crop to square if desired  
   - Return file path for Crusade model  

## Phase 3: Core Widgets & Reusables (2-3 hours)
9. **Create army_avatar.dart**  
   - Reusable CircleAvatar with FileImage (custom) or AssetImage (faction) fallback  
   - Add subtle pastel border/glow  

10. **Create unit_card.dart**  
    - Collapsible ExpansionTile or Card for units/groups  
    - Show name, points, models, Warlord/Epic Hero badges, honors/scars summary  
    - Expand to show components or edit fields  

11. **Create points_input.dart**  
    - NumberField or TextField with validation (required, positive)  
    - Optional reference points display from lookup  

12. **Create d6_roller.dart**  
    - Simple D6 button with animation/result display  
    - Reroll option  

## Phase 4: Screens & Navigation (4-8 hours)
13. **Implement landing_screen.dart**  
    - AppBar + ArmyAvatar  
    - Grid/Column of large buttons  
    - Bottom nav shell integration  

14. **Implement new_crusade_screen.dart**  
    - Form with name, faction dropdown, detachment (predefined + custom)  
    - ArmyAvatar preview + change button  
    - Submit → save new Crusade → navigate to oob  

15. **Implement oob_modify_screen.dart**  
    - Collapsible list (ExpansionTiles) of groups/units  
    - Warlord toggle (SwitchListTile, enforce one)  
    - Epic Hero gray-out/disable  
    - FAB for add unit/group modal (dropdown, variant, points required)  
    - Group sum calculation  

16. **Implement roster_assemble_screen.dart**  
    - Checkboxes from OOB, collapsed groups  
    - Running points/CP totals  
    - Save roster  

17. **Implement play_game_screen.dart**  
    - Minimal roster view, tallies/steppers, defeated checkboxes  
    - Reference bottom sheet  
    - Conclude FAB to post-game  

18. **Implement post_game_screen.dart**  
    - Stepper: Recap → Assign kills/XP → Agenda → MfG → OOA (skip Epic Heroes) → Victor bonus  
    - Apply to OOB, prompt Save to Drive  

19. **Implement resources_screen.dart**  
    - List of tappable links (InkWell + url_launcher)  

20. **Wire navigation**  
    - Define full GoRouter routes  
    - Add shell with responsive nav (bottom mobile, rail desktop)  

## Phase 5: Polish, Edge Cases & Testing (2-4 hours)
21. **Add validation & alerts**  
    - Warlord >1 alert  
    - Points required  
    - Epic Hero disable logic  

22. **Add loading/error states**  
    - Drive ops progress indicators  
    - Error toasts/snackbars  

23. **Add tooltips & reminders**  
    - On Warlord/Epic Hero fields  

24. **Basic testing**  
    - Manual run on emulator/device  
    - Add simple widget tests for ArmyAvatar, points input  

25. **Final touches**  
    - Responsive checks (mobile/desktop)  
    - Export/import full Crusade JSON (optional)  
    - Clean up debug prints  

## Milestones & Order
- **Milestone 1**: Setup + theme + models + storage (run empty app)  
- **Milestone 2**: Landing + New Crusade + basic OOB list  
- **Milestone 3**: Full OOB modify + roster assemble  
- **Milestone 4**: Play + Post-Game flows  
- **Milestone 5**: Sync + polish + edge cases  

Once this tasks.md is reviewed/approved, we can start generating code (e.g., pubspec.yaml + main.dart first, then models, then screens one by one).

Let me know if any task needs reordering, splitting, or more detail — or say "start code generation with Phase 1" to begin outputting files!