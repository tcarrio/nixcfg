# Serena MCP Integration Rules

## Cursor Rules — Serena-Focused Configuration

> **Scope**: This rules file governs all AI behavior specifically related to the Serena MCP server.

---

## 1. Serena Activation & Project Onboarding

### R1 — Always Provide the Full Project Path
When invoking any Serena tool during project analysis or any task execution, **always pass the full absolute path of the project** to activate the project context.

- On **Windows**, the full path is required to properly activate the project within Serena.
- If the project has **not yet completed the Serena onboarding process**, you **must** run the onboarding process before proceeding with any other Serena operations.
- After onboarding, **verify that the necessary Serena memory files have been created** before continuing.

**Trigger pattern**: Any time the AI begins work on a project — especially at the start of a new session or a new task — check whether Serena has been activated for the current project.

---

## 2. File Operations via Serena

### R4 — Use `mcp_serena_create_text_file` for All File Writes
**Do not** use `edit_file` or other incremental modification tools for file creation or modification. These tools have proven unreliable in complex refactoring scenarios.

**Required approach**:
1. Read the current file in full to understand its complete state.
2. Build a complete, correct new version of the file in memory.
3. Overwrite the entire file using **`mcp_serena_create_text_file`**.

This applies to all file modifications — no exceptions for "small" changes.

### R3 — Never Use Regular Expressions for File Matching
Regular expressions are prohibited for file matching and replacement operations because unintended broad matches can cause irreversible damage.

**Required approach**: Read the entire file → build the corrected version in full → write the complete file back via `mcp_serena_create_text_file`.

---

## 3. Verification After Every Serena File Operation

### R5 — Verify File Contents After Every Write
After any file modification via Serena tools, **immediately verify** that the file contents are exactly as expected.

**Steps**:
1. After writing, use the appropriate Serena read tool to read back the file.
2. Confirm the content matches the intended state exactly.
3. If the content does not match, retry the write immediately (see R6).

Additionally, **maintain a project progress record file** (via Serena) to track current task progress and mark the status of each step.

### R6 — Retry Failed Writes Immediately
If a file modification does not produce the expected result:
1. Do **not** proceed to the next step.
2. Recheck the current state of the file.
3. Retry the write operation.
4. If the retry also fails, escalate by overwriting the entire file with the full intended content.

---

## 4. Project State Awareness

### S1 — Always Use the Latest File State
When modifying a file through Serena, **always fetch the current version of the file** before making changes. Never operate on a stale or cached version of a file.

### S2 — Analyze from Current Project State
When fixing errors (compilation, runtime, warnings), base all analysis on the **current, live state of the project** as read through Serena. Do not guess or infer — use actual file contents.

### R7 — Warnings Must Be Fixed
All compiler or tool warnings surfaced during Serena-assisted operations **must be resolved**. Do not leave warnings unaddressed.

---

## 5. Serena Memory & Onboarding Checklist

When beginning work on a project, execute the following checklist via Serena:

```
Serena Onboarding Checklist:
1. Invoke Serena with the full absolute project path.
2. Confirm the project has been activated (check for existing memory files).
3. If no memory files exist → run the Serena onboarding process.
4. Verify memory files have been created successfully.
5. Read key project files to establish current project state before beginning any task.
```

---

## 6. Serena Tool Usage in the RIPER-5 Flow

Serena tools map to the following protocol modes:

| RIPER-5 Mode | Serena Tool Usage |
|---|---|
| **RESEARCH** | Read files, traverse project structure, build dependency maps |
| **INNOVATE** | No direct file writes; use read tools to explore alternative patterns |
| **PLAN** | No file writes; document the plan including exact file paths to be modified |
| **EXECUTE** | Use `mcp_serena_create_text_file` for all writes; verify after each write; update progress file |
| **REVIEW** | Read files back to verify implementation matches the plan |

---

## 7. Error Handling & Recovery via Serena

### Three-Strikes Rule Applied to Serena Operations
If a file write or modification via Serena **fails twice in succession** on the same file or component:

1. **Stop immediately** — do not attempt a third patch in the same mode.
2. **Return to RESEARCH mode** — re-read all relevant files in full via Serena.
3. **Widen the scope** — read all files that may be related to the failure, not just the target file.
4. **Build a new, holistic plan** that addresses root causes before re-entering EXECUTE mode.

---

## 8. Prohibited Behaviors When Using Serena

The following are strictly prohibited during any Serena-assisted session:

- ❌ Using `edit_file` or incremental patching tools instead of `mcp_serena_create_text_file`
- ❌ Using regular expressions for file matching or content replacement
- ❌ Proceeding to the next task step without verifying the file write succeeded
- ❌ Operating on stale or unverified file contents
- ❌ Declaring a task "complete" or "successful" without a readback verification via Serena
- ❌ Skipping the Serena onboarding process on a new project
- ❌ Invoking Serena without providing the full absolute project path on Windows
- ❌ Leaving warnings unresolved after a Serena-assisted file operation

---

## 9. Quick Reference — Key Serena Rules

| Rule | Summary |
|---|---|
| **R1** | Always pass the full project path; run onboarding if memory files don't exist |
| **R3** | No regex for file matching — read the whole file, rewrite it completely |
| **R4** | Use `mcp_serena_create_text_file` for all writes; never use `edit_file` |
| **R5** | Verify file contents after every write; maintain a progress record file |
| **R6** | If a write fails, recheck and retry immediately before proceeding |
| **S1** | Always fetch the latest file state before modifying |
| **S2** | Base all error analysis on the current live project state |
| **R7** | All warnings must be fixed — never leave them unaddressed |
