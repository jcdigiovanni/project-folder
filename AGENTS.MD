# Claude Operating Guidelines – Read & Follow Every Time

You are assisting with Crusade Bridge development. Follow these rules **without exception** in every response/session:

1. **Task Execution**
   - Work on TODO items **sequentially** unless I explicitly say otherwise.
   - Create a new git feature branch named appropriately and checkout to the branch to do work.
   - Break large items into smaller steps; show reasoning and code snippets.
   - After completing a task (or major sub-step), ask: "Task complete. Proceed to next or commit?" and summarize the next TODO item before moving on.

1. **Documentation Discipline**
   - **After any meaningful completion** (feature added, bug fixed, polish done):
     - Summarize what was done in CHANGELOG.md format (e.g., "Added post-game recap screen with recap, Mark selector, Commit button").
     - Update PROJECT_STATUS.md: Move to "Completed Features", update metrics/roadmap if relevant.
     - Trim this TODO.md: Check off completed items, move to "Completed This Session / Archive" section.
   - **If a task is deferred** (blocked, too big, or long-term): Move it to BACKLOG.md with a note (e.g., "Deferred from post-game phase – add to future sprint").

2. **Code & Commit Style**
   - Write clean, commented Flutter/Dart code (Riverpod, Hive, GoRouter style).
   - Suggest commit message: "feat: [short description]" or "fix: [short description]".
   - Use meaningful file names (e.g., post_game_screen.dart, xp_calculator.dart).

3. **General Behavior**
   - Stay focused on current TODO — do not suggest unrelated features unless I ask.  If in doubt - ask if it needs to go to backlog.
   - If stuck or unclear, ask clarifying questions before proceeding.
   - Keep responses concise but complete — prioritize action over long explanations.

4. **When an item completes**
- Check it off in TODO
- Summarize in CHANGELOG.md (e.g., "Added post-game recap & XP calc")
- Update PROJECT_STATUS.md (move to Completed Features)
- If deferred long-term → cut/paste to BACKLOG.md with note "Deferred from agenda/post-game phase"
- After Phases 5–6 complete: Reset TODO to next phase (e.g., polish or data fill)
  
Follow these rules **every time** — even if I don't repeat them.