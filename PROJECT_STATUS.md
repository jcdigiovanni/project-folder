# Crusade Bridge - Project Status

**Last Updated:** January 25, 2026

🎯 **Current Status:** Active Development – Post-Game & Rank Up System
The app has a complete battle flow from roster selection through agenda tracking to post-game commit. XP calculation and level up detection are live. Next focus: Battle Honour selection on rank up.

---

## Recent Session Summary (2026-01-25)

### Completed Today:
- **Post-Game Review Screen** - Full implementation with unit summary, agenda recap, score display, Mark for Greatness selector, and Commit Results flow
- **XP Calculation System** - Participation (+1), Kill Tally (+1 per 3 cumulative kills), Marked for Greatness (+3)
- **Tally Updates** - Automatic played/survived/destroyed counters on commit
- **Level Up Detection** - `pendingRankUp` flag set when unit crosses XP threshold
- **Level Up Visual Indicators** - "Level Up!" amber tag on collapsed units, highlighted XP row in expanded view
- **Group Visual Framing** - Units in groups shown with pink border and group name header on active game screen
- **Score Input** - You vs Opp score entry on victory/defeat dialog
- **RP Award** - +1 RP to crusade on game commit
- **Load Army Button** - Added to play screen when no rosters exist

### Previous Session (2026-01-24):
- Conditional buttons, confirmations, Warlord toggle hide
- Drive v1.1 (campaign backups), clear local clears campaigns
- Tyranids units added, faction icons finalized

---

## 📊 Metrics

- **Version**: 0.3.2
- **Commits (Jan 24-25)**: ~20+ affecting crusade_bridge
- **New Screens**: `post_game_screen.dart`, `active_game_screen.dart` (enhanced)
- **New Model Fields**: `pendingRankUp`, `groupId`, `groupName`
- **New Routes**: `/postgame/:gameId`

---

## ✅ Completed Features

### Core & Maintenance
- ✅ Crusade CRUD (create/load/delete/disband with confirmations)
- ✅ OOB management (add/edit/delete units/groups, hierarchical UI)
- ✅ Requisitions (Renowned Heroes: RP spend, detachment-filtered enhancements)
- ✅ Google Drive Sync v1.1 (campaign backups, human-readable filenames)

### Gameplay - Full Battle Flow
- ✅ Campaign Manager
- ✅ Play Screen (battle size, roster selection, Load Army button)
- ✅ Active Game Screen (agenda tracking, kills, defeated status)
- ✅ Group visual framing (pink border, group name header)
- ✅ Victory/Defeat with score input
- ✅ Post-Game Review Screen (agenda recap, Mark for Greatness, unit summary)
- ✅ Commit Results (XP calc, tally updates, RP award)
- ✅ Level Up Detection & Visual Indicators

### Data & Reference
- ✅ ~27 factions with unit data
- ✅ Enhancements across 20+ factions (MFM v3.8)
- ✅ isCharacter/isEpicHero flags

---

## 🚧 In Progress

### Phase 7: Rank Up / Battle Honour System
- [ ] Change `pendingRankUp` from boolean to integer counter
- [ ] Make "Level Up!" tag tappable to invoke rank up flow
- [ ] Create rank up dialog (show new rank, Battle Honour selection)
- [ ] Decrement counter on acknowledgment (support multiple pending rank ups)
- [ ] Update unit's `honours` list when Battle Honour selected

---

## 📋 Feature Status

| Feature                       | Status        | Notes                                              |
|-------------------------------|---------------|----------------------------------------------------|
| Create/Load/Delete Crusade    | ✅ Complete   | With confirmations and navigation                  |
| Modify OOB                    | ✅ Complete   | Groups, Warlord/Epic Hero, requisitions            |
| Google Drive Sync             | ✅ Complete   | v1.1 with campaigns                                |
| Requisitions (Renowned Heroes)| ✅ Complete   | Detachment-filtered, RP validation                 |
| Unit Data Coverage            | 🟢 Advanced   | ~27 factions                                       |
| Roster Assembly               | ✅ Complete   | Checkbox OOB → named roster                        |
| Play Game / Agenda Tracking   | ✅ Complete   | Active game screen with full tracking              |
| Post-Game / XP Progression    | ✅ Complete   | Recap, Mark for Greatness, XP calc, commit         |
| Level Up Detection            | ✅ Complete   | Visual indicators on OOB screen                    |
| Battle Honour Selection       | 🟡 In Progress| Rank up acknowledgment flow                        |
| Maintenance Mode              | 🟡 Partial    | Requisitions live; more planned                    |

---

## 🐛 Known Issues / Backlog

See [BACKLOG.md](BACKLOG.md) for full list:

**High Priority:**
- BUG-001: Exit button doesn't function
- BUG-002: Supply limit increases not persisting
- BUG-004: Marked for Greatness awards 1 XP instead of 3

**Medium Priority:**
- BUG-003: Renowned Heroes requisition still showing after use
- ENH-001: Back button in dialogs/popups
- ENH-003: Show RP/CP summary on OOB screen

---

## 🎯 Roadmap

### Phase 1: Core & Maintenance ✅ Complete
- [x] Crusade CRUD + Drive sync
- [x] OOB + requisitions
- [x] Data foundation

### Phase 2: Gameplay ✅ Complete
- [x] Campaign Manager
- [x] Active Game Screen + agenda tracking
- [x] Post-game recap/XP/commit
- [x] Roster assembly

### Phase 3: Rank Up & Honours 🟡 Active
- [ ] Battle Honour selection on rank up
- [ ] Multiple pending rank ups support
- [ ] Tappable Level Up tag

### Phase 4: Advanced & Polish (Future)
- [ ] More requisitions (Supply Limit, Rearm, Fresh Recruits)
- [ ] Battle Scars system
- [ ] Analytics/export
- [ ] Testing

---

## 📝 Notes

- **Goal**: Sleek, approachable Crusade companion app
- **Stack**: Flutter + Riverpod + Hive + Google Drive
- **Data**: Points/enhancements from Munitorum Field Manual v3.8
- **XP Thresholds**: Battle-ready (0-5), Blooded (6-15), Battle-hardened (16-30), Heroic (31-50), Legendary (51+)
