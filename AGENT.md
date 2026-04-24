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
- If you need Linux comparison while working on Windows material, use `C:\Users\Joon\Projects\supervisor-linux`.
- The repository root does not contain a live `logs/` directory. References to `logs` in docs and templates describe deployed supervisor directories such as `C:\supervisor\logs`, not folders that must exist inside this repo.
- If Codex Desktop or the VS Code Codex sidebar shows stale session `Last updated` metadata for this thread, check `.agent/AGENT.local.md` before assuming the repository or thread state is actually stale.
- If a future task starts real post-split development, record durable workflow changes in `AGENT.md` unless the user explicitly asks for a different handoff structure.

## Current status

- Windows split is complete.
- Git has been initialized in `C:\Users\Joon\Projects\supervisor-windows` and connected to the GitHub remote.
- The mixed `supervisor-setting` source folder has been removed from this repository.
- This repository intentionally keeps `.agent` minimal; only optional `.local.md` notes may exist there.
- No post-split feature development has started yet.
