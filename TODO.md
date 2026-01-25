# TODO - Active Sprint Tracker
**Last Updated:** January 25, 2026 (Lunch)

## Current Focus: Complete Agenda Tracking & Post-Game Loop (Phases 5–6)

### Phase 5 – Post-Game Screen Basics
- [ ] Create post_game_screen.dart
- [ ] Display recap: tallies, defeats, agenda results per unit/group
- [ ] Add "Mark for Greatness" single-unit selector
- [ ] Final score / agenda summary input
- [ ] "Commit Results" button with pre-commit adjustment prompt

### Phase 6 – XP, Progression & Apply
- [ ] Calculate XP:
  - Participation: +1 per unit played
  - Kills: +1 per 3 enemy models/units destroyed (from tallies)
  - Marked: +1 bonus if selected for Greatness
- [ ] Apply XP to units (update XP field + crusadePoints)
- [ ] Check & apply rank progression (use thresholds below)
- [ ] Update permanent tallies (played/survived/destroyed)
- [ ] Save changes to Crusade OOB & prompt Drive backup

### Polish & Immediate Next
- [ ] Refine tally steppers in ActiveGameScreen (e.g., +1/3 kills, survived auto-check)
- [ ] Add agenda progress indicators (current vs target)
- [ ] Improve group/component framing visuals for tallies/agendas

## Completed This Session / Archive
- Phases 1–4: ActiveGameScreen created, navigation wired, Game init on deploy, placeholder agendas + tally UI + tier selection, component listing, game completion stub, saving
- UX batch: conditional buttons, confirmations, Warlord hide, detachment filters, Drive v1.1 campaigns
- Data: Tyranids units, icon batches, validation/sanitization

## Next After This Phase
- Roster assembly polish (checkbox OOB → named save)
- Additional requisitions (Supply increase, Rearm/Resupply, Fresh Recruits)
- Fill remaining isCharacter/isEpicHero flags + select high-play faction units (Orks, Necrons, etc.)

When an item completes:
- Check it off here
- Summarize in CHANGELOG.md (e.g., "Added post-game recap & XP calc")
- Update PROJECT_STATUS.md (move to Completed Features)
- If deferred long-term → cut/paste to BACKLOG.md with note "Deferred from agenda/post-game phase"
