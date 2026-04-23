# .codex/DECISIONS.md

## Locked decisions

- This repository must not modify the upstream `supervisor-win` project.
- The split phase allowed only extraction and minimum context repair.
- Linux material was moved out to `C:\Users\Joon\Projects\supervisor-linux` and is now a sibling split/reference.
- Until the user explicitly asks otherwise, preserve inherited content as much as possible.
- Development context should be durable and repo-portable by default: tracked context goes in `.codex/*.md`, while true local-only notes go in `.codex/*.local.md`.

## History-sensitive constraints

- The GitHub repo was seeded by mirroring `supervisor-setting`, then local history was repositioned with `fetch` plus `reset --mixed origin/main`, and the Windows split work was recorded as a follow-up commit.
- Before rebasing, resetting, or force-pushing, inspect the current relationship between local `main` and `origin/main`; the imported history is nontrivial.
