# TODO - Active Sprint Tracker
**Last Updated:** February 9, 2026 (Sprint: Phase 6 Backlog Clearance In Progress)

**Follow the guidelines in AGENTS.md exactly.**

## Current Focus: BUGS AND ENHANCEMENTS
- Read BACKLOG.md and work on all BUG, ENH, and FEA items as needed.
- Generate workflows for properly implementing the faction-specific Requisitions - ask for clarity as needed since these can be complicated to introduce.
  
### Current Work: Bugs and Enhancements (9 FEB)
- All sprint items complete! Ready for next sprint.

## Completed This Session / Archive
- **Feb 9-10**: Replaced 4 incorrect Sororitas honor-system requisitions with 6 correct full-mechanics versions (FEA-001–006): Divine Calling, Ascension to the Order, The Penitent Path, Glorious Redemption, In Suffering Enlightenment, Saintly Benedictions. Added generic faction tracking fields to UnitOrGroup model. Extracted shared RequisitionOption widget and honor-system utils. Separate faction requisition file architecture.
- **Feb 9**: Added 4 Adepta Sororitas faction-specific requisitions (honor system) with inline faction header. Refactored Rearm and Resupply to generic honor-system modal. Extensible for future factions.
- **Feb 9**: Added Black Templars (4+4 base SM) and Imperial Agents (5) faction agendas — 9 new agendas across 2 factions. All factions in factions_and_detachments.json now have agenda coverage (except Chaos Daemons — no faction-specific agendas).

## Next After This Sprint
- Campaign narrative tools (battle tally/victories log, export/share OOB JSON/text, multi-campaign switcher)
- Full Deathwatch unit data fill (MFM reference – generate separately)
- Advanced: Multi-player support, scenario/agenda expansions, campaign history export