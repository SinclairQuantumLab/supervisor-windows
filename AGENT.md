# AGENT.md

## Purpose

- This repository documents how to use `supervisor-win` on Windows.
- This repository is for README, templates, helper scripts, and operational tricks around `supervisor-win`.
- Do not modify, vendor, or treat the upstream `supervisor-win` project itself as part of this repository.

## Locked project boundaries

- The original mixed repository was split on 2026-04-17 from `supervisor-setting` commit d1f44233a3bccc7364d7ea797976f2e0ddf3d9c7.
- `supervisor-windows` is the active repository for Windows-only materials.
- `C:\Users\Joon\Projects\supervisor-linux` exists only as a reference/comparison source for Linux-side material.
- The GitHub repository now exists at `https://github.com/SinclairQuantumLab/supervisor-windows`.
- The GitHub repository name is `supervisor-windows`, but the intended local deployment folder is `C:\Users\<USERNAME>\Projects\supervisor`.
- The Linux split is expected to use the same local deployment folder name convention later.
- The repository history was bootstrapped by mirroring the old `supervisor-setting` repository first, then creating a split commit on top for the Windows-only repository.
- Until the user explicitly asks otherwise, preserve inherited content as much as possible.
- Do not do drive-by rewrites, wording cleanup, style normalization, or template redesign unless the user asks for it.

## Current repository layout

- `README.md`: Windows-only usage guide extracted from the old mixed repository.
- `windows/`: Windows supervisor templates and inherited unsorted reference files.
- `python/Startup.ps1`: Windows launcher helper.
- `python/supervisor/supervisor_helper.py`: shared Python logging helper.
- `mount-supervisord-task-scheduler.ps1`: Task Scheduler registration helper for running `supervisord` in the logged-in user's desktop session.
- `kill-service.ps1`: generic helper that accepts an exact Windows Service `Name`, then kills the process started by that service. README explains how to use it for old `supervisor-win` service migration.
- `windows/unsorted/`: inherited service-era helper scripts and test artifacts kept for reference.
- `.agent/AGENT.local.md`: optional local-only notes for the current machine, worktree, or thread.

## Context handoff policy

- `AGENT.md` is the durable, tracked source of truth for repo purpose, boundaries, and workflow rules.
- This repository does not use tracked `.agent/*.md` handoff files.
- `.agent/*.local.md` is optional and reserved for machine-specific, worktree-specific, or thread-specific notes that should not be committed.
- Do not assume any `.agent/*.md` file exists other than `AGENT.md` and optional `.local.md` notes.

## Required agent workflow

- At the start of work, read `AGENT.md` first.
- If relevant local notes exist, read `.agent/*.local.md` before making new assumptions.
- When temporary machine/worktree/thread context matters, write it under `.agent/*.local.md`.
- Do not expect, read, or create tracked `.agent/*.md` handoff files unless the user explicitly asks for them.
- Keep `AGENT.md` stable. Update it only for durable rules, durable structure changes, or durable project-state milestones.

## Working rules

- Treat this repository as a usage/support repository for `supervisor-win`, not as the upstream project.
- Prefer minimal, explicit edits over broad cleanup.
- `README.md` is for hands-on introduction, setup instructions, usage guidance, and other content that helps a normal user apply this repository immediately.
- Do not use `README.md` as a place for developer notes, issue-history notes, debugging notes, or reassuring explanations aimed at maintainers. If a rare developer-facing note truly belongs in the repository, keep it in a `Developer's note` section at the bottom.
- Apply the same rule to script comments: comments should explain current behavior, safety constraints, or copy-paste flow, not preserve project history or prior implementation context.
- Prefer user-facing wording over Microsoft/API-style wording in README and script comments. Say what the user is doing, such as "kill the process started by this service", instead of internal phrasing like "the PID reported by Windows".
- Keep high-level intros especially plain and confidence-building. Put technical precision next to the exact code that needs it, not in the first sentence where it can make the tool feel intimidating.
- When the user asks what a syntax element means, treat that as evidence future users may also need a tiny inline comment at that exact spot. Add the smallest helpful explanation there instead of a broad tutorial.
- For helper scripts launched with `powershell -NoExit -File`, avoid `exit` for normal error/cancel paths because it can close the window before the user reads the message. Prefer printing the message and `return`.
- The current preferred Windows runtime model is Task Scheduler at user logon, task name `supervisor`, `Run only when user is logged on`, highest privileges enabled, launching `Startup_supervisord.ps1` so `supervisord` runs in the interactive user session instead of Session 0.
- The preferred global command is `supervisorctl`, made available by symlinking `.venv\Scripts\supervisorctl.exe` into `%USERPROFILE%\.local\bin`. Do not invent a separate `supervisor` wrapper unless the user explicitly asks for one.
- `mount-supervisord-task-scheduler.ps1` should only register the Task Scheduler task. Keep config creation, password editing, and other setup actions as explicit README steps unless the user asks for a one-shot helper.
- In README command examples, never document direct `.\<script>.ps1` execution. Use `powershell -ExecutionPolicy Bypass -File ...` for `.ps1` files. If admin rights are needed, prefer a separate `Start-Process powershell -Verb RunAs ...` command so the user can launch only that step as Administrator from the normal PowerShell flow.
- Keep detailed Task Scheduler PowerShell code in script files and keep README commands short enough for users to copy and run.
- Keep PowerShell helper scripts transparent and procedural. For one-off setup or migration steps, prefer visible variables and step-by-step flow over helper functions, `[CmdletBinding()]`, `ShouldProcess`, or module-style structure unless the abstraction is reused or materially improves safety.
- Also document the GUI Task Scheduler path, because Windows UI labels and PowerShell task syntax may drift over time.
- If you need Linux comparison while working on Windows material, use `C:\Users\Joon\Projects\supervisor-linux`.
- The repository intentionally keeps `logs/.gitignore` and `conf.d/logs/.gitignore` placeholders so log directories exist after clone while runtime log files stay untracked.
- If Codex Desktop or the VS Code Codex sidebar shows stale session `Last updated` metadata for this thread, check `.agent/AGENT.local.md` before assuming the repository or thread state is actually stale.
- If a future task starts real post-split development, record durable workflow changes in `AGENT.md` unless the user explicitly asks for a different handoff structure.

## Current status

- Windows split is complete.
- Git is currently checked out at `C:\Users\Joon\Projects\supervisor` and connected to the `supervisor-windows` GitHub remote.
- The mixed `supervisor-setting` source folder has been removed from this repository.
- This repository intentionally keeps `.agent` minimal; only optional `.local.md` notes may exist there.
- Post-split development has started around the Task Scheduler user-session runtime model and the new README draft.
