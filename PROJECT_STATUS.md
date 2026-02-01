# Crusade Bridge - Project Status

**Last Updated:** February 1, 2026 (Battle Honours System)

### Executive Summary – Wins & Momentum
Over the past week (Jan 23–Feb 1), we've advanced from maintenance foundation to a **playable alpha with full battle loop potential** — completing **Battle Honours & Rank-Up** system brings the progression loop near completion.

Brass highlights:
- Jan 31 merge: Requisitions phase 3 (advanced/healing), phase 2 (Fresh Recruits with variable RP), phase 1 (RP cap/display/progress bar, Supply Limit increase) — direct delivery of requirements.md progression stories.
- Jan 25 code push: ActiveGameScreen routed, Game model enhancements, agenda Phases 1–4 complete, post-game stub — enabling tallies/agendas.
- Jan 24 burst: 11/12 QOL items (conditional UI, confirmations, filters, Drive v1.1), data expansions (Tyranids/icons/validation), Campaign Manager, Play Screen start.
- Data at ~27 factions, enhancements broad (v3.8 accurate to MFM images).
- Docs rationalized: lean TODO.md, curated BACKLOG.md, consolidated README.

Velocity high (20+ commits), quality strong (atomic, co-authored), vision intact — on track for beta with testable loop.

**Current Phase:** Gameplay Implementation (Post-Game & XP active)
**Vision Alignment:** Delivering requirements.md (clean flows, offline-first), design.md (intuitive/low-clutter), tasks.md (phased delivery).

### Recent Work Summary (Jan 23–Feb 1)
- **Feb 1 (Battle Honours & D6 Roller)**
  - **Battle Honours System**: "Claim Battle Honour" button on ranked-up units, selection modal with 4 honour types (Battle Traits, Weapon Enhancements, Crusade Relics, Psychic Fortitudes), choose manually or roll random.
  - **D6 Roller Widget**: Reusable dice roller (lib/widgets/d6_roller.dart) — 1D6, D3, 2D6 modes, animated shake, Epic Hero auto-pass, duplicate reroll.
  - **Model Updates**: UnitOrGroup extended with battleTraits, weaponEnhancements, crusadeRelic fields.
  - **Data**: battle_honours.json with core tables for all honour types and battle scars.

- **Jan 31 Merge (1 commit)**  
  - Requisitions phase 3: Repair/Recuperate (remove scars, cost = count), Renowned Heroes (enhancements to Characters, 1–3 RP), Legendary Veterans (non-Characters exceed 30 XP/3 Honours).  
  - Phase 2: Fresh Recruits (add models, base 1 RP +1 per Honour, Supply Limit check).  
  - Phase 1: RP cap 10, Supply Used progress bar, over-limit warning, Increase Supply Limit (+200 pts/1 RP).  
  - Post-game: Optional notes field, RP award if under cap.  
  - ActiveGame: Kill tally XP indicator (3 dots), survived/destroyed segmented toggle.  
  - Fixes: Marked for Greatness +3 XP, Supply Limit persistence, 4 OOB operations data loss, visibility in Renowned Heroes.  
  - Improved: Close buttons on modals, RP/CP dashboard on OOB.  

- **Jan 25 (5 commits)**  
  - Code: ActiveGameScreen routed, Game model (agenda limits, per-component states, group affiliation), crusade_provider game lifecycle, post-game stub.  
  - Agenda Phases 1–4 complete: placeholders, tally/tier UI, component controls, completion stub.  
  - Docs: BACKLOG.md added, TODO.md trimmed, redundant README removed, root README consolidated.  

- **Jan 24 Burst (13 commits)**  
  - UX/QOL: Conditional Play button, exit/confirmation, group delete, Warlord hide, Renowned Heroes filter, Drive v1.1 (campaign backups).  
  - Data: Tyranids units, icon batches, validation/sanitization.  
  - Gameplay: Campaign Manager added, Play Screen started.  

- **Jan 23 Prep (4 commits)**  
  - OOB enhancements + data prep.

### Progress Against North Star Artifacts
- **requirements.md** — Core 85–90% (CRUD, OOB, sync); gameplay 70% (tallies/agendas/XP advancing). Requisitions phase 3 fulfills progression stories.  
- **design.md** — Strong: collapsible/conditional UI, filters reduce clutter; post-game notes/segmented toggle align with intuitive design.  
- **tasks.md** — Milestone 1–3 advanced; Milestone 4 active (Play foundations complete, post-game stubbed); Milestone 5 partial (polish started).

### Key Metrics (Jan 23–31)
- Commits: ~22+  
- Lines Changed: Hundreds (models +44, providers +29, screens additions)  
- Faction Coverage: ~27 units JSONs, 20+ detachments enhancements  

### Completed Features
- Crusade/OOB/requisitions with low-clutter UX  
- Drive Sync v1.1 + campaign backups  
- Agenda tracking Phases 1–4 (display, tallies, tiers, completion stub)  
- ActiveGameScreen + game state infrastructure  
- Requisitions phases 1–3 (Supply Limit, Fresh Recruits, Repair/Recuperate, Renowned Heroes, Legendary Veterans)  

### In Progress
- Post-Game Screen & XP/Progression (Phases 5–6)  
- Tally polish & agenda indicators  
- Remaining data flags  

### Roadmap
- Phase 1–3: Core → Complete/Advanced  
- Phase 4: Gameplay → Active (near testable loop)  
- Phase 5: Polish → Upcoming  

### Known Debt
- Edit dialog preservation  
- Drive error/loading states  
- Remaining faction data  

Steady, high-quality progress — core delivered, gameplay accelerating, vision intact. Ready for testable battle loop soon.