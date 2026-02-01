# Claude Operating Guidelines – Read & Follow Every Time
You are assisting with Crusade Bridge development. Follow these rules **without exception** in every response/session:

1. **Task Execution**
   - Work on TODO items **sequentially** unless I explicitly say otherwise.
   - Create a new git feature branch named appropriately and checkout to the branch to do work.
   - Break large items into smaller steps; keep feedback pointed and succinct.
   - After completing a task (or major sub-step), ask: "Task complete. Proceed to next or commit?" and summarize the next TODO item before moving on.

2. **Documentation Discipline**
   - **After any meaningful completion** (feature added, bug fixed, polish done):
     - Summarize what was done in CHANGELOG.md format (e.g., "Added post-game recap screen with recap, Mark selector, Commit button").
     - Update PROJECT_STATUS.md: Move to "Completed Features", update metrics/roadmap if relevant.
     - Trim this TODO.md: Check off completed items, move to "Completed This Session / Archive" section.
   - **If a task is deferred** (blocked, too big, or long-term): Move it to BACKLOG.md with a note (e.g., "Deferred from post-game phase – add to future sprint").

3. **Code & Commit Style**
   - Write clean, commented Flutter/Dart code (Riverpod, Hive, GoRouter style).
   - Suggest commit one message: "feat: [short description]" or "fix: [short description]".
   - Use meaningful file names (e.g., post_game_screen.dart, xp_calculator.dart).

4. **General Behavior**
   - Stay focused on current TODO — do not suggest unrelated features unless I ask.
   - If stuck or unclear, ask clarifying questions before proceeding.
   - Keep responses concise but complete — prioritize action over long explanations.

5. **Context Gathering (Critical for BUG/ENH Tasks)**
   - When receiving a task from TODO.md that references a BUG-XXX or ENH-XXX (e.g. "Fix BUG-017: Unit CP must update after rank-up"):
     - **Immediately open and read the full entry from BACKLOG.md** for that exact number.
     - Read **all sections** in order: Description, Repro Steps, Expected, Actual, Impact, Potential Fix Notes.
     - This is the **primary source of truth** for the issue, user pain, desired behavior, and any rules context.
     - **Do NOT rely only on the short title or phrasing in TODO.md** — it is brief on purpose.
   - Use the BACKLOG details to guide diagnosis, planning, and implementation.
   - If the entry mentions specific files or areas (e.g. play_screen.dart, crusade_notifier.dart), start there.
   - Confirm understanding in your first response by echoing 1–2 key points from BACKLOG (e.g. "Expected: CP updates after honor; Actual: no change").

Follow these rules **every time** — even if I don't repeat them.