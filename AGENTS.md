# Claude Operating Guidelines – Read & Follow Every Time
You are assisting with Crusade Bridge development. Read all of and follow these rules **without exception** in every response/session:

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
   - Never work on main branch - before executing work you need to create a new branch from main, check it out, and make sure all commits go to that branch.  Main branch protections are on, prohibiting pushes directly to it.
   - Suggest commit one message: "feat: [short description]" or "fix: [short description]".
   - Use meaningful file names (e.g., post_game_screen.dart, xp_calculator.dart).
   - Re-use code where able - generic methods that can be reused are preferrable to long-spanning modules of complex code; be a bit fearless when it comes to restructuring repeated actions into methods we can invoke.

4. **General Behavior**
   - Stay focused on current TODO — do not suggest unrelated features unless I ask.
   - If stuck or unclear, ask clarifying questions before proceeding.
   - Keep responses concise but complete — prioritize action over long explanations.

5. **When an item completes**
   - Check it off in TODO
   - Summarize in CHANGELOG.md (e.g., "Added post-game recap & XP calc")
   - Update PROJECT_STATUS.md (move to Completed Features)
   - If deferred long-term → cut/paste to BACKLOG.md with note "Deferred from agenda/post-game phase"
   - After Phases 5–6 complete: Reset TODO to next phase (e.g., polish or data fill)

6. **Context Gathering (Critical for BUG/ENH Tasks)**
   - When receiving a task from TODO.md that references a BUG-XXX or ENH-XXX (e.g. "Fix BUG-017: Unit CP must update after rank-up"):
     - **Immediately open and read the full entry from BACKLOG.md** for that exact number.
     - Read **all sections** in order: Description, Repro Steps, Expected, Actual, Impact, Potential Fix Notes.
     - This is the **primary source of truth** for the issue, user pain, desired behavior, and any rules context.
     - **Do NOT rely only on the short title or phrasing in TODO.md** — it is brief on purpose.
   - Use the BACKLOG details to guide diagnosis, planning, and implementation.
   - If the entry mentions specific files or areas (e.g. play_screen.dart, crusade_notifier.dart), start there.
   - Confirm understanding in your first response by echoing 1–2 key points from BACKLOG (e.g. "Expected: CP updates after honor; Actual: no change").

7. **Context Gathering (Critical for FEA Tasks)**  
   - When receiving a task from TODO.md that references a FEA-XXX (e.g. "Implement FEA-001: Add Agenda – Behind Enemy Lines"):
     - **Immediately open and read the full entry from BACKLOG.md** for that exact number.
     - Read **all sections** in order: Description, Rules Summary, Expected UI/Behavior, Integration Points, Scoring/Effects, Any Data Requirements.
     - This is the **primary source of truth** for the new feature, rules details, user-facing behavior, and integration needs.
     - **Do NOT rely only on the short title or phrasing in TODO.md** — it is brief on purpose.
   - Use the BACKLOG details to guide planning, data structure (e.g., JSON if needed), UI (selection/tracking/recap), logic (progress/VP/XP), persistence, and history logging.
   - If the entry mentions specific patterns to reuse (e.g., agenda progress bars, D6 modal, confirmation dialogs), start there.
   - Confirm understanding in your first response by echoing 1–2 key points from BACKLOG (e.g. "Expected: units in enemy deployment zone grant 1 VP per turn; post-game shows completion status and VP/XP").
   - Commit as "feat: FEA-XXX – [short description]" (e.g., "feat: FEA-001 – Add Behind Enemy Lines agenda with in-game tracking and scoring").

Follow these rules **every time** — even if I don't repeat them.