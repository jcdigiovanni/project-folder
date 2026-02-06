# TODO - Active Sprint Tracker
**Last Updated:** February 5, 2026 (Sprint: Phase 6 Backlog Clearance In Progress)

**Follow the guidelines in AGENTS.md exactly.**

## Current Focus: BUGS AND ENHANCEMENTS
- Read BACKLOG.md and work on all BUG, ENH, and FEA items as needed.
  
### Current Work: Bugs and Enhancements (30 JAN-6 FEB)
- All sprint items complete! Ready for next sprint.

## Completed This Session / Archive
- **Feb 5-6**: BUG-019 (History logging: added missing events for unit add/remove, supply increase, game results; fixed requisition mutation pattern to use immutable provider addEvent; added 100-event rolling cap), ENH-014 (Landing screen crusade list multi-line layout: name/faction/points/detachment on separate lines), ENH-012 (Settings backup/restore buttons stacked vertically for mobile), ENH-013 (Landing screen edge-to-edge with transparent status bar and notch-safe padding). Google Drive re-enabled — Android sign-in fixed (OAuth client IDs consolidated to Crusade Tracker GCP project, SHA-1 fingerprint registered, google-services.json with populated oauth_client), Web client ID updated to match. Verified working on Android and Chrome. Windows uses Chrome/web for Drive (google_sign_in plugin does not support Windows desktop). History confirmed to persist through backup/restore.
- **Feb 3**: ENH-009 (Total Kills in OOB unit details), ENH-010 (XP Preview in post-game screen with per-unit breakdown), ENH-011 (Post-game layout overhaul: collapsible agenda recap, inline XP preview per unit card, per-unit agenda tally adjustments).
- **Feb 2**: Fixed agenda XP values (added xpPerTally/xpPerTier to JSON - Headhunters 2XP, Drive Home the Blade 3XP, etc.), FEA-001 to FEA-011 (11 Tyrannic War agendas imported: Battlefield Survivors, Swarm the Planet, Headhunters, Monstrous Targets, Eradicate the Swarm, Critical Objectives, Drive Home the Blade, Cleanse Infestation, Forward Observers, Recover Mission Archives, Malefic Hunter). Agenda Data Sanitization (emptied core_agendas.json, removed fallback agendas, added empty state UI), BUG-018 (edit/level-up units in groups), ENH-007 (draw/tie support), BUG-015 update (campaign restore), ENH-008 (Crusade Points display).

## Next After This Sprint
- Campaign narrative tools (battle tally/victories log, export/share OOB JSON/text, multi-campaign switcher)
- Full Deathwatch unit data fill (MFM reference – generate separately)
- Advanced: Multi-player support, scenario/agenda expansions, campaign history export