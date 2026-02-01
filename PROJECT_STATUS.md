**Last Updated:** February 1, 2026 (Phases 1–4 Complete – Enhanced Agendas)

**Recent Work (Feb 1)**
- Completed Phase 4: Enhanced Agenda System
  - 12 core Crusade agendas from JSON data file (core_agendas.json)
  - Pre-game multi-select with type indicators (tally/objective)
  - In-game tracking: AgendaProgressCard, TierProgressIndicator, TallyProgressBar with milestones
  - Post-game recap: completion status badges, VP/XP rewards per agenda, summary totals banner
  - Full persistence via Game model (Hive + JSON serialization)
- Completed Phase 3: Out of Action (OOA) Tests & Battle Scars
  - OOA Resolution section in post-game for destroyed units
  - D6 roll (2+ to pass), Epic Hero auto-pass
  - Failure choice: Devastating Blow (lose honour) or Battle Scar
  - Battle Scar D6 table roll with auto-application
  - "Run All OOA Tests" batch button, visual status cards
- Completed Phase 2: Battle Honours & Rank-Up full flow
- Completed Phase 1: Reusable D6 roller widget
- Requisitions core (Phases 1–3) merged and polished

**Completed Features (Updated)**
- Full Crusade game loop: roster → play → agendas → in-game tracking → post-game → XP/progression
- Enhanced agenda system with data-driven JSON agendas
- Progression foundations: D6 roller + Battle Honours/Rank-Up + OOA/Scars system
- Requisitions full core loop (Supply Increase, Fresh Recruits, Repair/Recuperate, Renowned Heroes, Legendary Veterans)

**In Progress**
- Phase 5: Bug clearance (Exit button, data clear, save issues)

**Roadmap**
- Bug clearance → narrative/export for beta/testable loop
- Fill Deathwatch data (last faction)