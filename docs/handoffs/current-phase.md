# Current phase — Phase 0: repository, environment, architecture spike

- **Date:** 2026-10-11
- **Phase:** 0 (foundational preparation; platform NOT locked)
- **Previous commits seen:** `78d8bdf`, `e5c4a12`, `cbd6697` on `main` (clean, in sync with `origin/main`)

## Objective of this handoff

Record the outcome of foundational preparation so a later agent (possibly a
different model, possibly on a Windows host) can continue Phase 0 without
relying on chat history.

## Environment (verified on the Linux prep host)

- Zorin OS 18.1 (Ubuntu noble), x86_64; Git 2.43.0; PowerShell 7.6.6 (`pwsh`).
- OpenCode v2.0.26; VS Code 1.141.0; Node v18.19.1; Python 3.12.3.
- NOT installed: `dotnet`, desktop Word, Visual Studio/MSBuild, `python-docx`, `pytest`.
- Present but NOT a Word substitute: LibreOffice 26.2.5.2.
- No `opencode.jsonc`, no `.opencode/agents/`.

## Decisions made (with reasons)

1. **Scaffold only; no feature code.** Phase 0 exit gate requires a Windows
   spike. Creating feature modules now would violate the architecture gate
   (`AGENTS.md` §3, plan §8). Reason: avoid locking interfaces before the
   platform is proven.
2. **VSTO remains the default hypothesis but is NOT selected.** No Windows
   host exists here, so the six spike tests could not run. Reason: evidence-led
   selection per plan §3.
3. **Decompilation conflict resolved in favour of `AGENTS.md`.** The plan §2
   rule 4 ("Decompile Kutools…") conflicts with `AGENTS.md` §4 (decompilation
   only after the owner permits it; no copying). Precedence order in
   `AGENTS.md` §2 ranks this file above the plan. Default: public docs +
   black-box observation only, until the owner explicitly permits otherwise.
4. **Existing `docs/` files left untouched.** The plan's layout shows
   `AGENTS.md` at the repo root, but the live files are under `docs/`. No
   move/rename was made to avoid a source-of-truth split; the divergence is
   recorded here for the owner to decide.
5. **No dependencies added; nothing committed.** Pinned-dependency and
   no-commit-without-approval rules observed.

## Files read

- `docs/AGENTS.md` (full)
- `docs/README.md` (full; 2 lines)
- `docs/WORD_TOOLKIT_IMPLEMENTATION_PLAN.md` (full, §§1–14)
- `git status`, `git log`, environment probes (OS, dotnet, Word, VS, LibreOffice, tooling)

## Files changed (new files only, uncommitted)

- `docs/decisions/ADR-0001-platform.md` — platform ADR, status Proposed, with
  verified prep-host facts and the blocked spike checklist.
- `docs/handoffs/current-phase.md` — this file.
- `scripts/check-environment.ps1` — read-only environment reporter (no registry
  writes, no installs, no Office activation, no trust-setting changes; detects
  Word/VS without launching them).
- `.gitignore` — .NET/VSTO/VS, Word lock/temp files, test output, secrets;
  synthetic `tests/fixtures/**/*.docx` explicitly kept.
- `docs/research/feature-benchmarks.md` — benchmark log stub with the §12 entry
  template; no findings yet.

## Commands run (prep host)

- `git status -sb`, `git log --oneline -5`
- `dotnet --info`, `python3 --version`, `node/npm --version`, `pwsh --version`,
  `opencode --version`, `code --version`
- `soffice --version`, `which winword/soffice/libreoffice/devenv/msbuild`,
  `ls ~/.wine`, `ls /mnt/c`
- `pwsh -NoProfile -File scripts/check-environment.ps1` (after creating it)
- `git status --short` (confirm only new files, no modifications)

## Build / test results

- No build exists yet (no solution/project files). Nothing compiled.
- No unit or integration tests exist yet. Nothing passed or failed.
- `check-environment.ps1` run: exit 0 on 2026-10-11 (pwsh 7.6.6, Linux).
  Confirmed: no `dotnet`, no desktop Word, no VS/MSBuild, no pytest/python-docx;
  LibreOffice 26.2.5.2 present (not a Word substitute); no `.sln`/project files
  (expected in Phase 0); git 2.43.0, OpenCode v2.0.26, VS Code 1.141.0.

## Tests not run and why

- **Phase 0 VSTO spike (all six tests): BLOCKED** — no Windows host, no desktop
  Word, no Visual Studio, no .NET Framework targeting pack on this machine.
- **Office.js spike: NOT run** — only warranted if VSTO prerequisites fail or
  portability becomes a v1.0 requirement; neither condition is established.

## Known limitations / risks

- Platform decision is provisional; any schedule assuming VSTO is at risk until
  the Windows spike passes.
- LibreOffice presence may tempt fixture validation; it cannot verify Word
  object-model behaviour — label any such checks clearly.
- `python-docx`/`pytest` absence means even local fixture-generation tooling is
  not yet validated; that is Phase 1 test-project work, not Phase 0.
- The root-vs-`docs/` layout divergence (`AGENTS.md`, plan location) needs an
  owner ruling before agents start citing paths.

## Dependencies added or proposed

- None added. None proposed.

## Next recommended action (single bounded task)

Provide or designate a Windows host with desktop Word + Visual Studio, then run
Prompt A (plan §11) followed by the six-test spike, and update
`docs/decisions/ADR-0001-platform.md` from Proposed to Accepted/Rejected with
measured evidence. Do not start Phase 1 until that gate passes.
