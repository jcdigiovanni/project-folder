# requirements.md - 40K Crusade Bridge App (Flutter Mobile-First Edition)

## Project Overview
**App Name**: 40K Crusade Bridge  

**Description**: A cross-platform app for Warhammer 40,000 10th Edition Crusade players, emphasizing modular unit groups and phased workflows. Mobile-first for in-game portability (phone/tablet reference/tallies), desktop companion for data entry. Clean, minimalistic dark-themed UI with interactive elements. No built-in datasheets (legal safety)—link to Wahapedia/Warhammer Community. Manual Google Drive sync for cross-device portability. Includes army icon/avatar for quick visual identification of Crusades.

**Target Platforms** (Single Flutter Codebase):
- Primary: Mobile (Android/iOS) – Touch-optimized for table play.
- Secondary: Desktop (Windows 11 primary; macOS/Linux bonus) – Keyboard/large-screen editing.
- Offline-first: Local persistence; Drive sync manual.

**Core Constraints**:
- AI-generated full Flutter project (lib/main.dart, screens/, models/, services/, pubspec.yaml).
- Minimal dependencies: Flutter basics + state management (Riverpod preferred), storage (Hive/Isar for local), google_sign_in + googleapis (for Drive), path_provider, file_picker, image_picker (for custom army icon), intl (dates).
- Zero cost: Free packages/APIs (Drive app data free tier ample).
- Scope: Core Crusade rules; predefined factions/detachments/unit name lists (hardcoded JSON). No expansions or full datasheets.

## User Stories (Prioritized, Mobile-First)
1. **Landing Screen**  
   Large touch-friendly buttons: "New Crusade", "Load Crusade", "Build/Modify OOB", "Assemble Roster", "Play Game", "Save to Drive", "Load from Drive", "Resources" (links to Wahapedia etc.).

2. **New Crusade**  
   Modal: Name, faction dropdown, detachment (predefined per faction or custom text) → Auto-init supply limit 1000, RP 5, empty OOB → Auto-assign generic faction icon → Transition to Modify OOB.

3. **Modify OOB / Maintenance**  
   Collapsible list (groups/units), add/edit/remove (dropdowns for unit names or custom), group builder (multi-add components from faction list or custom), requisitions/honors/scars/relics (text inputs/lists). Edit army icon (optional custom upload). For Characters, toggle "Warlord" (enforce one per OOB). Auto-flag Epic Heroes (disable XP/honors/OOA edits).

4. **Assemble Roster**  
   Select from OOB (collapsed groups + units), track points/CP, save transient roster (nameable).

5. **Play Game**  
   Load roster, select agendas (custom text), in-game: Tallies/kills/defeated checkboxes/agenda fields per unit/group; reference notes/upgrades/honors/scars; auto-save local.

6. **Post-Game**  
   Recap/adjust tallies (assign group kills/XP to components), agenda XP, Mark for Greatness (select one), Out of Action tests (D6 sim with reroll option; skip for Epic Heroes), victor bonus (dropdown: Extra Honor, Bonus RP, Additional MfG, Custom text), confirm → Apply to OOB → Prompt Save to Drive. No XP gain for Epic Heroes.

7. **Google Drive Sync**  
   Buttons: "Save to Drive" (upload current Crusade state), "Load from Drive" (download and apply); sign-in once; list files if multiple; prompt after major actions (post-game, OOB edits). Include custom army icon file in save/load.

8. **Army Icon/Avatar**  
   Display small circular avatar on key screens (Landing list, AppBar headers, sync modal) for quick Crusade identification. Default: Generic faction icon (bundled assets). Optional: User uploads custom image (PNG/JPG/GIF) via image picker → saved locally and synced.

9. **Resources**  
   Modal/bottom sheet with tappable links: Wahapedia 10th Ed, Warhammer Community downloads, Crusade Rules PDF, Munitorum Field Manual.

## High-Level Flows (Mobile-Optimized)
- Responsive: Mobile → Bottom nav/touch modals, large tappables; Desktop → Side nav/larger forms, keyboard support.
- Phases: Build → Assemble → Play (minimal UI, collapsed groups) → Post-Game → Maintenance.
- Sync: Manual, opt-in, prompted after big actions ("Save this updated Crusade to Drive?").
- Army Icon: Visible in headers/lists for instant recognition; custom upload in New Crusade or edit settings.

## Non-Functional Requirements
- **UI/UX**: Dark theme (#0A0A0A–#121212 bg), large tappables (48dp+), collapsible accordions for groups (collapsed in play), tooltips/rules reminders. Pastel pink (#FFB6C1 / #FFD1DC) and soft yellow (#FFF59D) accents on headers/group names/buttons (Sailor Moon crossover nod). Fonts: Inter (body/readability), Great Vibes (headers/group names/buttons), Orbitron (secondary sci-fi accents).
- **Performance**: Fast local ops; Drive ops async with loading indicators ("Saving…", "Loading…").
- **Persistence**: Local (Hive/Isar JSON + files for icons), manual Drive JSON + icon upload/download.
- **Auth**: One-time Google Sign-In for Drive scope (app data only).
- **Accessibility**: High contrast, keyboard nav on desktop, ARIA-like semantics.
- **Edge Cases**: Offline sync skip, conflict prompts on load, group component tracking, image load fallback, max honors/scars enforcement. Enforce one Warlord per OOB; disable XP/OOA/honors for Epic Heroes.

## Data Model (High-Level)
- **Crusade**:
```json
{
  "id": "unique-string",
  "name": "string",
  "faction": "string",
  "detachment": "string",
  "supplyLimit": 1000,
  "rp": 5,
  "battleHistory": [ /* {date, outcome, bonus, notes} */ ],
  "oob": [UnitOrGroup],
  "templates": [UnitOrGroup],  // reusable groups
  "armyIconPath": "string?",   // local file path for custom
  "factionIconAsset": "string?" // e.g., 'assets/icons/factions/adepta_sororitas.png'
}
```

- **UnitOrGroup**:
```json
JSON{
  "id": "unique-string",
  "type": "unit" | "group",
  "name": "string",
  "customName": "string?",
  "points": number,
  "components": [UnitOrGroup]?,  // recursive for groups
  "modelsCurrent": number,
  "modelsMax": number,
  "xp": number,
  "honours": ["string"],
  "scars": ["string"],
  "crusadePoints": number,
  "tallies": { "played": number, "survived": number, "destroyed": number },
  "notes": "string?",
  "statsText": "string?",  // user-entered reference
  "isWarlord": "bool?",  // toggle for Characters (enforce one per OOB)
  "isEpicHero": "bool?"  // flag for special handling (no XP/OOA/honors)
}
```

- **Roster**: { name, selectedIds: [], agendas: [text], points, crusadePoints }
- **InGameState**: Temp overlay on roster for tallies/defeated (auto-saved).

## Predefined Data (hardcoded JSON/constants):

- **Factions list**
- **Detachments per faction**
- **Unit names per faction (dropdown source)**
- **Faction-to-icon asset map**

## Reference Data (Optional Dataslate Lookup)
- Optional one-time fetch of public community JSON (e.g., https://raw.githubusercontent.com/Ektoer/wh40k/main/wh40k_10th.json) for baseline unit stats/weapons/abilities.
- Bundled fallback copy in assets for offline-first use.
- Cached locally; user can trigger update from Settings/Resources.
- Customizable fetch URL in settings for resilience.
- When adding unit: auto-fill structured fields (read-only, user override allowed).
- Disclaimer: Community-sourced reference only; always confirm with official sources.