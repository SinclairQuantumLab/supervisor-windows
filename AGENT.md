# AGENT.md

## Purpose

- This repository documents how to use `supervisor-win` on Windows.
- This repository is for README, templates, helper scripts, and operational tricks around `supervisor-win`.
- Do not modify, vendor, or treat the upstream `supervisor-win` project itself as part of this repository.

## Locked project boundaries

- The original mixed repository was split on 2026-04-17.
- `supervisor-windows` is the active repository for Windows-only materials.
- `C:\Users\Joon\Projects\supervisor-linux` exists only as a reference/comparison source for Linux-side material.
- The GitHub repository now exists at `https://github.com/SinclairQuantumLab/supervisor-windows`.
- The repository history was bootstrapped by mirroring the old `supervisor-setting` repository first, then creating a split commit on top for the Windows-only repository.
- Until the user explicitly asks otherwise, preserve inherited content as much as possible.
- Do not do drive-by rewrites, wording cleanup, style normalization, or template redesign unless the user asks for it.

## Current repository layout

- `README.md`: Windows-only usage guide extracted from the old mixed repository.
- `windows/`: Windows supervisor templates and inherited unsorted reference files.
- `python/Startup.ps1`: Windows launcher helper.
- `python/supervisor/supervisor_helper.py`: shared Python logging helper.
- `kill_supervisord_service.bat`: root-level inherited helper script.

## Context handoff policy

- `AGENT.md` is the durable, tracked source of truth for repo purpose, boundaries, and workflow rules.
- `.codex/PROJECT_STATE.md` is the durable, tracked snapshot of current repository state, important cautions, and active phase.
- `.codex/DECISIONS.md` is the durable, tracked record of locked decisions and non-obvious constraints.
- `.codex/SESSION.md` is the durable, tracked milestone log for major repository events.
- `.codex/NEXT-STEPS.md` is the durable, tracked resumption checklist and next-action queue.
- `.codex/*.local.md` is reserved for machine-specific, worktree-specific, or thread-specific notes that should not be committed.
- Durable handoff context should live in tracked `.codex/*.md` files; only true local notes should be ignored.

## Required agent workflow

- At the start of work, read `AGENT.md` first.
- Then read `.codex/PROJECT_STATE.md`, `.codex/DECISIONS.md`, `.codex/SESSION.md`, and `.codex/NEXT-STEPS.md`.
- If relevant local notes exist, read `.codex/*.local.md` before making new assumptions.
- When durable repo state or decisions change, update the tracked `.codex/*.md` files before finishing.
- When temporary machine/worktree/thread context matters, write it under `.codex/*.local.md`.
- Keep `AGENT.md` stable. Update it only for durable rules, durable structure changes, or durable project-state milestones.

## Working rules

- Treat this repository as a usage/support repository for `supervisor-win`, not as the upstream project.
- Prefer minimal, explicit edits over broad cleanup.
- If you need Linux comparison while working on Windows material, use `C:\Users\Joon\Projects\supervisor-linux`.
- If a future task starts real post-split development, keep the split-history constraints in mind and record the new phase in `AGENT.md`, `.codex/PROJECT_STATE.md`, and `.codex/SESSION.md`.

## Current status

- Windows split is complete.
- Git has been initialized in `C:\Users\Joon\Projects\supervisor-windows` and connected to the GitHub remote.
- The mixed `supervisor-setting` source folder has been removed from this repository.
- Durable handoff context now lives in tracked files under `.codex/`; only `.local.md` notes are ignored.
- No post-split feature development has started yet.
