# TODO - Active Sprint Tracker
**Last Updated:** February 2, 2026 (Sprint: Phase 6 Backlog Clearance In Progress)

**Follow the guidelines in AGENTS.md exactly.**

## Current Focus: Post-game experience validation ✓ COMPLETE

Goal: Implement new Adepta Sororitas faction-specific agendas. ✓ COMPLETE
Instructions - follow all normal instructions.  Read BACKLOG.md FEATURE items and implement these factions-specific agendas.  To be clear - these Agendas should only appear if the player's roster faction matches the agenda faction.

✓ Added faction filtering to agenda loading (play_screen.dart)
✓ Added 4 Adepta Sororitas agendas: Test of Faith, Atonement in Battle, Defend the Shrine, Pious Purgation

### Current Work: Bugs and Enhancements (30 JAN-6 FEB)
- Guidance for Claude: Tackle remaining items. Use existing patterns (Hive transactions, modal confirmations). Keep commits atomic, test on Android/Web/Desktop.

- All sprint items complete! Ready for next sprint.

## Completed This Session / Archive
- **Feb 2**: Fixed agenda XP values (added xpPerTally/xpPerTier to JSON - Headhunters 2XP, Drive Home the Blade 3XP, etc.), FEA-001 to FEA-011 (11 Tyrannic War agendas imported: Battlefield Survivors, Swarm the Planet, Headhunters, Monstrous Targets, Eradicate the Swarm, Critical Objectives, Drive Home the Blade, Cleanse Infestation, Forward Observers, Recover Mission Archives, Malefic Hunter). Agenda Data Sanitization (emptied core_agendas.json, removed fallback agendas, added empty state UI), BUG-018 (edit/level-up units in groups), ENH-007 (draw/tie support), BUG-015 update (campaign restore), ENH-008 (Crusade Points display).

## Next After This Sprint
- Campaign narrative tools (battle tally/victories log, export/share OOB JSON/text, multi-campaign switcher)
- Full Deathwatch unit data fill (MFM reference – generate separately)
- Advanced: Multi-player support, scenario/agenda expansions, campaign history export