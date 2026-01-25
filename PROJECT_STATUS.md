# Crusade Bridge - Project Status

**Last Updated:** January 25, 2026 (Evening)

### Executive Summary – Wins & Momentum
Over the past few days (Jan 23–25), we've gone from solid maintenance base to **playable gameplay alpha** with real Crusade battle flow emerging — and today delivered **foundational Play screen functionality** that makes tallies, agendas, and post-game viable.  

Brass highlights:  
- Jan 24 burst: 11/12 QOL items delivered (conditional UI, confirmations, filters, Warlord safeguards, Drive v1.1 campaign backups) — direct execution of design.md "sleek/low-clutter" vision.  
- Jan 25 code push: **ActiveGameScreen created & routed**, **Game model/state infrastructure** fully wired (per-component agendas/tallies, unit assignment limits, group framing), **agenda tracking Phases 1–4 complete** (display, tally controls, tier UI, completion stub), **post-game stub** ready — bringing us very close to a full testable loop.  
- Data expanded (~27 factions, broad enhancements v3.8), icons batched, validation added.  
- Docs rationalized: lean TODO.md (active sprint), curated BACKLOG.md, consolidated README — reducing maintenance debt.  

Velocity strong (18+ commits in 3 days), quality high (atomic, co-authored polish), vision intact — we're on track for a genuinely usable table-side tool.

**Current Phase:** Gameplay Implementation (Post-Game & XP active)  
**Vision Alignment:** Delivering requirements.md (clean flows, offline-first), design.md (intuitive/low-clutter), tasks.md (phased delivery).

### Recent Work Summary (Jan 23–25)
- **Jan 25 (Lunch + Morning)**  
  - Code: ActiveGameScreen routed (/game/:gameId), Game model enhancements (agenda limits, per-component states, group affiliation), crusade_provider game lifecycle (add/update/getGame), post-game stub.  
  - Agenda tracking Phases 1–4 complete: placeholder agendas, tally/tier UI, completion stub.  
  - Docs: Added BACKLOG.md, refactored/trimmed TODO.md (active Phases 5–6), removed redundant README, consolidated root README with Documentation Map.  

- **Jan 24 Burst (13 commits)**  
  - UX/QOL: Conditional Play button, exit/confirmation, group delete options, Warlord hide, Renowned Heroes detachment filter, Drive v1.1 (campaign backups).  
  - Data: Tyranids units, icon batches, validation/sanitization.  
  - Gameplay: Campaign Manager added, Play Screen started.  

- **Jan 23 Prep**  
  - OOB enhancements + data prep.

### Progress Against North Star Artifacts
- **requirements.md** — Core 85–90% (CRUD, OOB, requisitions, sync); gameplay stories advancing (tallies/agendas/XP).  
- **design.md** — Strong: collapsible/conditional UI, filters reduce clutter.  
- **tasks.md** — Milestone 1–3 advanced; Milestone 4 active (Play foundations live).

### Key Metrics (Jan 23–25)
- Commits: ~18+  
- Lines Changed: Hundreds (models +44, providers +29, screens additions)  
- Faction Coverage: ~27 units JSONs, 20+ detachments enhancements  

### Completed Features
- Crusade/OOB/requisitions with low-clutter UX
- Drive Sync v1.1 + campaign backups
- Agenda tracking Phases 1–4 (display, tallies, tiers, completion stub)
- ActiveGameScreen + game state infrastructure
- **Post-Game Screen & XP/Progression (Phases 5–6) — Complete**
  - Full post-game review with recap, Mark for Greatness, unit summary
  - XP calculation (participation, kills, marked bonus; Epic Hero skip)
  - Rank progression with pendingRankUp flag
  - Optional game notes field
  - Drive backup prompt after commit

### In Progress
- Agenda progress indicators (Immediate Polish phase)
- D6 roller widget for OOA tests
- Remaining data flags

### Recently Completed
- Kill tally XP progress indicator (3 dots showing progress to next XP)
- Survived/Destroyed segmented toggle (clearer unit status)
- **Bug fixes:** Marked for Greatness +3 XP, data persistence in OOB operations
- **Enhancements:** Close buttons on modals, RP/CP dashboard in OOB screen  

### Roadmap
- Phase 1–3: Core → Complete/Advanced  
- Phase 4: Gameplay → Active (near testable loop)  
- Phase 5: Polish → Upcoming  

### Known Debt
- Edit dialog preservation  
- Drive error/loading states  
- Remaining faction data  

Steady, high-quality progress — core delivered, gameplay accelerating, vision intact. Ready for testable battle loop soon.