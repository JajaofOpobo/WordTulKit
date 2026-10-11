# ADR-0001: v1.0 implementation platform

- **Status:** Proposed (Phase 0 — NOT locked)
- **Date:** 2026-10-11
- **Deciders:** Project owner (approval pending)
- **Context:** Word Toolkit v1.0 scope (configurable formatting profiles, explicit
  cleanup, numbering audit/repair, review-first flattened-footnote restoration)
  on Windows desktop Microsoft Word.

## 1. Environment facts (verified on the prep host)

All values below were observed directly on the machine used for foundational
preparation. They describe the *prep host*, not the eventual build/test host.

| Fact | Observed value | How verified |
|---|---|---|
| OS | Zorin OS 18.1 (Ubuntu `noble` base), kernel `7.0.0-38-generic` | `uname -a`, `/etc/os-release` |
| Architecture | x86_64 | `arch` |
| Git | 2.43.0, worktree clean on `main`, in sync with `origin/main` | `git --version`, `git status -sb` |
| .NET / dotnet | NOT installed (`dotnet: command not found`) | `dotnet --info` |
| Desktop Microsoft Word | NOT installed (no Wine, no `/mnt/c`, no `winword`) | `which winword`, `ls ~/.wine`, `ls /mnt/c` |
| Visual Studio / MSBuild / devenv | NOT installed | `which devenv msbuild` |
| LibreOffice | 26.2.5.2 present (`soffice`) | `soffice --version` |
| PowerShell | PowerShell 7.6.6 (`pwsh`) available; Windows PowerShell absent | `pwsh --version` |
| Node / npm | v18.19.1 / 9.2.0 | `node --version`, `npm --version` |
| Python | 3.12.3; `python-docx` NOT installed; `pytest` NOT installed | `python3 --version`, import probe |
| OpenCode | v2.0.26 | `opencode --version` |
| VS Code | 1.141.0 | `code --version` |
| `opencode.jsonc` / `.opencode/agents/` | Absent | directory listing |

**Inferred (not a substitute):** LibreOffice can open `.docx` fixtures for visual
sanity checks, but it is NOT an acceptable substitute for Word integration tests.
Word object-model behaviour (footnotes, lists, ranges, COM lifetime/threading)
must be verified in genuine desktop Word per `AGENTS.md` §§5, 9.

## 2. Options considered

### Option A (default hypothesis): C# VSTO + documented Word object model

- Deep desktop Word access: native footnote collections, ranges, lists,
  formatting — matching the v1.0 feature set.
- Source: [Create VSTO Add-ins for Office by using Visual Studio][vsto-create],
  [how to configure a computer to develop Office solutions][vsto-config],
  [VSTO runtime/support][vsto-runtime], [Word.Footnotes API][word-footnotes],
  [Document.Footnotes][doc-footnotes].
- Constraints (from official docs, unverified on our hosts — no Windows
  machine available): VSTO is **.NET Framework-based** (do not retarget the
  add-in to .NET 5+); requires Visual Studio with Office/SharePoint components
  and the Word VSTO template; build/debug/package likely needs Visual Studio,
  not VS Code alone.

### Option B (alternative): Office.js (Word JavaScript API)

- Portable across Word clients; requirement set 1.5 introduced native
  footnote/endnote and style-management APIs — but that alone does not solve
  flattened-note detection/matching.
- Source: [Word JavaScript API requirement set 1.5][word-js-15].
- Constraints: capabilities vary by client and requirement set; some
  page-layout operations may be desktop-specific; explicit runtime capability
  checks and graceful degradation would be required.

## 3. Decision (proposed, not locked)

**Retain VSTO as the default hypothesis for v1.0; DO NOT lock the platform yet.**
Locking requires the Phase 0 spike below to pass on a real Windows host.

## 4. Required spike before locking (blocked on this host)

On a Windows machine with desktop Word + Visual Studio, run the same minimum
tests against the candidate stack and record measured results here:

1. Add a visible Word command/ribbon control.
2. Read the active document and selected range safely.
3. Set one paragraph-format property without altering unrelated properties.
4. Inspect a native Word list and a manually typed number separately.
5. Insert one genuine Word footnote at a controlled range; read back text/reference.
6. Build and launch in the installed desktop Word.

Record with the spike: Windows edition/version/arch, Word version/build/bitness,
Visual Studio version + Office components + template presence, .NET Framework
developer pack/runtime, solution target framework, test-framework choice, build
and launch commands with exact outputs.

## 5. Reversal conditions

Abandon the VSTO default and evaluate Office.js (via a second ADR revision) if
any of the following is documented with evidence:

- No Windows + Word + Visual Studio host can be provided for build/test.
- The VSTO template, required .NET Framework target, or a v1.0-critical API
  (footnote insertion/readback, list inspection, single-property formatting)
  fails with a material, unworkable constraint.
- Portability becomes an explicit first-release requirement from the owner.

Do not implement two add-in platforms in parallel.

## 6. Consequences of this ADR while Proposed

- No feature code (Phases 1–6) is authorised; only Phase 0 scaffolding.
- No NuGet/npm dependencies are added.
- No Word-integration pass/fail claims may be made until the spike runs.
- The prep-host facts above must be re-recorded on the Windows spike host.

## 7. Method-permission note (conflict resolved in favour of AGENTS.md)

The implementation plan §2 rule 4 instructs decompiling Kutools to understand
its implementation. `AGENTS.md` §4 (higher precedence than the plan) permits
static analysis/decompilation only after the owner establishes the method is
allowed, and forbids copying/porting proprietary code or structure. Pending an
explicit owner decision, the project uses **official documentation, public
feature descriptions, controlled black-box experiments, and independently
authored fixtures only**. No decompilation has been performed.

[vsto-create]: https://learn.microsoft.com/en-us/visualstudio/vsto/create-vsto-add-ins-for-office-by-using-visual-studio?view=vs-2022
[vsto-config]: https://learn.microsoft.com/en-us/visualstudio/vsto/how-to-configure-a-computer-to-develop-office-solutions?view=visualstudio
[vsto-runtime]: https://learn.microsoft.com/en-us/visualstudio/vsto/visual-studio-tools-for-office-runtime?view=visualstudio
[word-footnotes]: https://learn.microsoft.com/en-us/office/vba/api/word.footnotes
[doc-footnotes]: https://learn.microsoft.com/en-us/office/vba/api/word.document.footnotes
[word-js-15]: https://learn.microsoft.com/en-us/javascript/api/requirement-sets/word/word-api-1-5-requirement-set?view=word-js-preview
