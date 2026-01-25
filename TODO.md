# Claude Operating Guidelines – Read & Follow Every Time

You are assisting with Crusade Bridge development. Follow these rules **without exception** in every response/session:

1. **Task Execution**
   - Work on TODO items **sequentially** unless I explicitly say otherwise.
   - Break large items into smaller steps; show reasoning and code snippets.
   - After completing a task (or major sub-step), ask: "Task complete. Proceed to next?" before moving on.

2. **Documentation Discipline**
   - **After any meaningful completion** (feature added, bug fixed, polish done):
     - Summarize what was done in CHANGELOG.md format (e.g., "Added post-game recap screen with recap, Mark selector, Commit button").
     - Update PROJECT_STATUS.md: Move to "Completed Features", update metrics/roadmap if relevant.
     - Trim this TODO.md: Check off completed items, move to "Completed This Session / Archive" section.
   - **If a task is deferred** (blocked, too big, or long-term): Move it to BACKLOG.md with a note (e.g., "Deferred from post-game phase – add to future sprint").

3. **Code & Commit Style**
   - Write clean, commented Flutter/Dart code (Riverpod, Hive, GoRouter style).
   - Suggest commit message: "feat: [short description]" or "fix: [short description]".
   - Use meaningful file names (e.g., post_game_screen.dart, xp_calculator.dart).

4. **General Behavior**
   - Stay focused on current TODO — do not suggest unrelated features unless I ask.  If in doubt - ask if it needs to go to backlog.
   - If stuck or unclear, ask clarifying questions before proceeding.
   - Keep responses concise but complete — prioritize action over long explanations.

Follow these rules **every time** — even if I don't repeat them.

# TODO - Active Sprint Tracker
**Last Updated:** January 25, 2026 (Post-Lunch)

## Claude Operating Guidelines – Read & Follow Every Time
[Insert the full guidelines section above here]

## Current Focus: Complete Post-Game & XP Application (Phases 5–6)
Goal: Full testable battle loop – Play (tallies/agendas) → Post-Game (recap/XP/apply) → OOB updated.

### Phase 5 – Post-Game Screen Basics
- [ ] Create post_game_screen.dart (GoRoute: /post-game/:gameId)
- [ ] Display recap: tallies (kills/defeated), agenda results per unit/group
- [ ] Add "Mark for Greatness" single-unit selector (dropdown or checkbox from eligible units)
- [ ] Final score/agenda summary input (optional notes field)
- [ ] "Commit Results" button with pre-commit confirmation prompt

### Phase 6 – XP, Progression & Apply
- [ ] Implement XP calculation:
  - Participation: +1 per unit played (not defeated)
  - Kills: +1 per 3 enemy models/units destroyed (from tallies)
  - Marked: +1 bonus if selected for Greatness
  - No XP for Epic Heroes (enforce via model flag)
- [ ] Apply XP to units (update XP field + crusadePoints)
- [ ] Check & apply rank progression (thresholds: 0–5 Battle-ready, 6–15 Blooded, 16–30 Battle-hardened, 31–50 Heroic, 51+ Legendary)
- [ ] Update permanent tallies (played/survived/destroyed)
- [ ] Save changes to Crusade OOB & prompt Drive backup

### Immediate Polish (After Phases 5–6)
- [ ] Refine tally steppers in ActiveGameScreen (e.g., +1/3 kills, survived auto-check)
- [ ] Add agenda progress indicators (current vs target)
- [ ] Improve group/component framing visuals for tallies/agendas
- [ ] Add D6 roller widget for OOA tests (with reroll button, Epic Hero skip)

## Completed This Session / Archive
- Phases 1–4: ActiveGameScreen created/routed, Game init on deploy, placeholder agendas + tally/tier UI, component listing/controls, game completion stub, saving
- UX batch (Jan 24): conditional buttons, confirmations, Warlord hide, detachment filters, Drive v1.1 campaigns
- Data: Tyranids units, icon batches, validation/sanitization

## Next After This Phase
- Roster assembly polish (checkbox OOB → named save)
- Additional requisitions (Supply increase, Rearm/Resupply, Fresh Recruits)
- Fill remaining isCharacter/isEpicHero flags + high-play faction units (Orks, Necrons, etc.)

When an item completes:
- Check it off here
- Summarize in CHANGELOG.md (e.g., "Added post-game recap & XP calc")
- Update PROJECT_STATUS.md (move to Completed Features)
- If deferred long-term → cut/paste to BACKLOG.md with note "Deferred from agenda/post-game phase"
- After Phases 5–6 complete: Reset TODO to next phase (e.g., polish or data fill)