# Word Toolkit — Agent Implementation Plan

**Status:** Master implementation plan  
**Revision:** 1.0  
**Prepared:** 11 October 2026  
**Product:** Universal-purpose Microsoft Word productivity add-in  
**Initial runtime target:** Windows desktop Microsoft Word  
**Primary workflow:** OpenCode TUI inside VS Code; the user may switch between models/providers and delegate work to different agents  
**Default technical hypothesis:** C# VSTO add-in using the documented Word object model, subject to the architecture gate in Phase 0  

> **Instruction to every agent:** Treat this file as the implementation contract, not as permission to implement every feature at once. Work in the current phase only. Preserve the phase gates. Do not report success unless the relevant build or test was actually run and its result is known.

---

## 1. Product definition

Build an independent, general-purpose Word productivity add-in inspired by the *behaviour* and breadth of formatting utilities such as Kutools for Word. It should use configurable profiles and support many document types, with legal pleadings and documents included as useful test cases rather than as the product's identity.

The first release is deliberately narrower than the long-term vision. It focuses on dependable formatting, explicitly selected cleanup, numbering analysis/repair, and review-first reconstruction of flattened footnotes.

### 1.1 Version 1.0 in scope

1. A Word ribbon entry point and a simple task-pane or dialog workflow appropriate to the selected implementation.
2. Read-only document inspection and a change summary.
3. Configurable formatting profiles.
4. Explicit, separate formatting and cleanup commands.
5. Numbering audit and repair, supporting both native Word numbering and manually typed numbering, with preview before repair.
6. Detection and review of likely flattened footnotes, followed by user-approved insertion as genuine Word footnotes.
7. Recovery safeguards, operation reports and a documented test corpus.
8. Local-only preferences and profiles by default; no document content sent to a server or model.

### 1.2 Deferred features — do not implement in v1.0

- Batch find-and-replace across files.
- Advanced content selection, page operations and broader document restructuring.
- Advanced table and image operations.
- Reference, caption, bookmark and hyperlink management beyond incidental preservation.
- Batch document/file utilities, split/merge/export workflows.
- Reusable text and clause library.
- Redaction.
- AI proofreading, rewriting, summarisation or document analysis.
- Mail merge.
- Endnote recovery (the initial recovery scope is footnotes only).
- Cloud sync, accounts, telemetry or a backend service.

Keep module boundaries clean enough to add these later, but do not create speculative abstractions for features that are not yet approved.

### 1.3 Product principles

- **General-purpose:** Do not hard-code Nigerian legal styles, court-specific rules or one fixed formatting standard.
- **Configurable:** Users can save and reuse named profiles. Ship only a small generic starter profile, clearly identified as an example.
- **Preview-first:** Numbering repair and footnote restoration always require the user to review and approve proposed changes.
- **Non-destructive by default:** Scans never modify the document. Formatting and cleanup are separate commands. A change to one property must not silently change unrelated properties.
- **Evidence-led:** The agent must validate uncertain Word object-model behaviour in desktop Word instead of trusting a plausible-looking implementation.
- **Local-first:** Never transmit document text, citations, footnotes or metadata to an external service in v1.0.
- **Observable:** Every operation provides a summary of changed, skipped, ambiguous and failed items without logging full confidential document text.
- **Maintainable:** One clear owner for Word interop, tested core logic, pinned dependencies, documented commands and small changesets.

---

## 2. Non-negotiable agent rules

1. Read `AGENTS.md` and this plan before editing code. If either does not exist yet, create the repository instruction file first and copy the relevant rules from this plan.
2. Start every work session by checking `git status`, current branch, recent commits, the current phase, and the relevant decisions in `docs/decisions/`.
3. Never discard or overwrite user changes. Do not run destructive Git commands (`reset --hard`, `clean -fd`, force push, etc.). Do not commit or push unless the user expressly asks.
4. Decompile Kutools for to understand how it's features are implemented.
5. Do not switch the architecture, target framework, UI technology, or core dependency strategy without an Architecture Decision Record (ADR) and a phase-gate review.
6. Do not add NuGet/npm dependencies without stating the reason, licence, maintenance status, target compatibility and alternatives. Pin versions and commit the applicable lock/package files.
7. Do not make network calls from the product or upload document content. Network access used by an agent to consult public documentation must not be wired into runtime behaviour.
8. Do not use AI/LLM inference inside the application in v1.0. Footnote matching must be deterministic, reviewable and explain its evidence.
9. Never equate a numeric paragraph with a footnote solely because it begins with `1.`, `2.` or a similar marker. Legal submissions, lists and citations make that unsafe.
10. Scanning is read-only. Never remove flattened source-note text until insertion of the approved real footnote has succeeded and been verified.
11. Do not promise atomic rollback unless it is implemented and demonstrated in Word. For multi-step mutations, provide a safe recovery copy or verified undo strategy, and disclose limitations.
12. Do not pass live Word COM objects across threads or retain mutable range references across structural edits without proving the approach safe. Word automation must respect the required apartment/thread model.
13. Do not mark a requirement complete because code compiles in isolation. Word integration behaviour must be verified in the actual desktop Word environment.
14. Keep user documents, test files containing real client information, secrets and credentials out of Git. Use synthetic fixtures only.
15. At the end of every agent task, return: files changed, design decisions, commands run, exact test/build outcomes, limitations, remaining risks and the next suggested task.

---

## 3. Technology decision: gate before building features

### 3.1 Initial recommendation

For a Windows-only first release, investigate **C# VSTO + the documented Microsoft Word object model** first. It offers deep access to the desktop Word object model, including native footnote collections, ranges, lists and formatting. VSTO relies on .NET Framework; do not target .NET 5+ or modern .NET for the VSTO add-in itself.

Keep Office.js as an explicit alternative if portability becomes a first-release requirement or the proof of concept reveals a blocking VSTO constraint. The product is “universal” in the sense of broad, configurable functionality—not necessarily cross-platform in v1.0.

### 3.2 Phase 0 must verify, not assume

Before locking the stack, inspect the actual machine:

- Windows edition/version and architecture.
- Installed desktop Word version, build and bitness.
- Visual Studio version and whether the Office/SharePoint development components and Word VSTO template are available.
- Installed .NET Framework developer pack/runtime relevant to the template.
- OpenCode version/provider configuration and how the chosen agent can run shell/build tools.
- Git availability and repository status.

Then run a narrowly scoped spike comparing VSTO and Office.js against the same minimum tests:

1. Add a visible Word command/ribbon control.
2. Read the active document and selected range safely.
3. Set one paragraph-format property without altering unrelated properties.
4. Inspect a native Word list and a manually typed number separately.
5. Insert one actual Word footnote at a controlled range and read back its text/reference.
6. Build and launch in the installed desktop Word.

Record the outcome in `docs/decisions/ADR-0001-platform.md`. Default to VSTO for v1.0 unless the spike identifies a documented and material blocking issue. Do not implement two add-in platforms in parallel.

### 3.3 Candidate VSTO stack

- Windows desktop Microsoft Word.
- Visual Studio with Office/SharePoint development tooling and a Word VSTO Add-in template.
- C# VSTO add-in targeting the .NET Framework version generated/supported by the installed tooling (expected target: .NET Framework 4.8; verify before setting it).
- A separate, Word-independent core library. Prefer `netstandard2.0` only if the selected dependencies and build environment validate it; otherwise target the same supported framework as the add-in and document why.
- Word object model/Office Interop only inside an adapter/integration boundary.
- A supported .NET test framework compatible with the selected targets.
- Git for versioning.
- OpenCode TUI as the orchestration surface in VS Code; Visual Studio may still be needed to create/debug/package the VSTO project.

Do not assume that VS Code alone can create, package and debug every VSTO project operation. Validate that in Phase 0.

### 3.4 Office.js alternative facts to preserve in the ADR

Word JavaScript API requirement set 1.5 introduced native footnote and endnote support and style-management APIs. That does not itself solve flattened-note detection or matching. Office.js capabilities vary by supported Word client/API requirement set; some page-layout operations may be desktop-specific. If selected, define explicit capability checks and disable unsupported functions gracefully.

Official reference points:

- OpenCode agents: https://docs.opencode.ai/docs/agents/
- OpenCode project instructions: https://docs.opencode.ai/docs/rules/
- OpenCode permissions: https://docs.opencode.ai/docs/permissions/
- OpenCode configuration: https://docs.opencode.ai/docs/config/
- Microsoft VSTO add-ins: https://learn.microsoft.com/en-us/visualstudio/vsto/create-vsto-add-ins-for-office-by-using-visual-studio?view=vs-2022
- VSTO development machine: https://learn.microsoft.com/en-us/visualstudio/vsto/how-to-configure-a-computer-to-develop-office-solutions?view=visualstudio
- VSTO support/lifecycle: https://learn.microsoft.com/en-us/visualstudio/vsto/visual-studio-tools-for-office-runtime?view=visualstudio
- Word footnotes object model: https://learn.microsoft.com/en-us/office/vba/api/word.footnotes
- Word document footnote collection: https://learn.microsoft.com/en-us/office/vba/api/word.document.footnotes
- Word JavaScript API 1.5: https://learn.microsoft.com/en-us/javascript/api/requirement-sets/word/word-api-1-5-requirement-set?view=word-js-preview

---

## 4. Repository layout and module boundaries

The final folder arrangement may reflect the generated VSTO template, but retain the following logical boundaries. Do not create all files as empty placeholders; add folders when their phase begins.

```text
WordToolkit/
├── AGENTS.md
├── WORD_TOOLKIT_IMPLEMENTATION_PLAN.md
├── README.md
├── WordToolkit.sln
├── opencode.jsonc                  # optional project config; merge carefully
├── .opencode/
│   └── agents/                     # optional project-scoped agent role definitions
├── docs/
│   ├── PRODUCT_SPEC.md
│   ├── ARCHITECTURE.md
│   ├── TEST_STRATEGY.md
│   ├── KNOWN_LIMITATIONS.md
│   ├── decisions/
│   │   └── ADR-0001-platform.md
│   ├── research/
│   │   └── feature-benchmarks.md
│   └── handoffs/
│       └── current-phase.md
├── src/
│   ├── WordToolkit.AddIn/          # VSTO entry points, ribbon, UI, interop adapter
│   │   ├── ThisAddIn.cs
│   │   ├── Ribbon/
│   │   ├── UI/
│   │   ├── WordInterop/
│   │   └── Diagnostics/
│   └── WordToolkit.Core/           # no Word COM references
│       ├── Profiles/
│       ├── Formatting/
│       ├── Cleanup/
│       ├── Numbering/
│       ├── Footnotes/
│       ├── DocumentAnalysis/
│       ├── ChangePlans/
│       └── Diagnostics/
├── tests/
│   ├── WordToolkit.Core.Tests/
│   ├── WordToolkit.WordIntegration.Tests/
│   └── fixtures/
│       ├── formatting/
│       ├── cleanup/
│       ├── numbering/
│       └── footnotes/
└── scripts/
    ├── check-environment.ps1
    └── verify-build.ps1
```

### 4.1 Boundary rules

- `WordToolkit.Core` must not reference `Microsoft.Office.Interop.Word`, VSTO, COM or UI frameworks.
- Core features consume plain data-transfer objects/document snapshots and return immutable or effectively immutable **change plans**.
- `WordToolkit.AddIn` is the only place that reads/writes live Word objects.
- Word interop wrappers must explicitly manage COM object lifetime and avoid unnecessary chained COM calls.
- The UI must call a plan/preview workflow before executing destructive changes.
- Profiles contain only settings, not document content.
- Reports contain counts, operation identifiers, range/paragraph identifiers where appropriate, and safe diagnostic details; do not log full note/citation text by default.

---

## 5. OpenCode TUI and multi-agent operating model

Different models may work on this repository at different times. Durable repository artefacts—not chat history—are the source of truth.

### 5.1 Roles

Use OpenCode's built-in agents where available; the role names below describe responsibilities and need not map to a particular model/vendor.

| Role | Suggested OpenCode mechanism | Access pattern | Responsibilities |
|---|---|---|---|
| Coordinator/integrator | Build primary agent or selected coding agent | Read/write, approved shell | Owns phase sequencing, integration, documentation, tests and final acceptance. One coordinator per phase. |
| Planner/architecture reviewer | Plan primary agent | Read-only analysis; ask before any writes | Audits scope, explores trade-offs, drafts plans/ADRs; does not implement. |
| Repository explorer | `@explore` subagent or equivalent read-only agent | Read-only | Maps existing code, finds entry points and reports facts with file paths. |
| Documentation researcher | `@scout` subagent or equivalent read-only research agent | Read-only | Consults official Microsoft/OpenCode documentation and records cited findings; does not modify implementation. |
| Feature implementer | `@general` or another explicitly assigned worker | Narrow, task-specific writes | Implements one module within assigned files and API contracts. |
| Test specialist | Separate worker/model | Prefer test-only file ownership | Designs fixtures, test cases and test harness; does not rewrite production code unless the task explicitly authorises it. |
| Reviewer/security auditor | Read-only custom subagent or model | No file edits; shell only with approval | Finds defects, unsafe mutation paths, missing tests, data-leak risk and unsupported API assumptions. |

OpenCode's current documented model distinguishes primary agents from subagents; primary agents can be changed with the TUI's agent switch, while subagents can be invoked by mention when configured/available. Do not assume every provider or model supports the same tool set. If subagent invocation is unavailable, run the role as a separate session and use the written handoff contract below.

### 5.2 Coordination rules

1. **One writer per file at a time.** Never assign two agents to edit the same source file concurrently.
2. Parallel work is permitted first for read-only research, architecture critique, test-case proposals and independent files. Integrate sequentially.
3. Do not let a worker redefine public interfaces without first updating `docs/ARCHITECTURE.md` or the relevant API contract and obtaining coordinator approval.
4. Avoid asking many agents the same broad question. Give each role a bounded deliverable and explicit non-goals.
5. The coordinator must inspect the actual diff and run tests; a worker's claim that tests passed is not sufficient without command/output evidence.
6. A worker may propose dependencies, but the coordinator approves them.
7. A new agent starting a session must read `AGENTS.md`, this plan, `docs/handoffs/current-phase.md`, the relevant ADR and `git status` before editing.
8. Every completed task updates `docs/handoffs/current-phase.md` with accepted decisions, files changed, verification, known defects and next action.
9. Keep phase work small enough to review. Do not delegate “implement the whole add-in” to one agent.
10. If agents disagree, write the competing claims and evidence in an ADR or issue note. Do not settle a technical dispute by majority vote or confidence alone.

### 5.3 Safe use of OpenCode permissions

- Keep permission prompts enabled for unknown shell commands and file writes until the environment is trusted.
- Do not enable blanket auto-approval for the entire repository during early phases.
- Explicitly deny destructive commands such as recursive deletion, `git reset --hard`, `git clean -fd`, `git push --force`, or commands that alter user documents without permission.
- Allow low-risk read-only commands such as `git status`, `git diff`, file searches and documented test commands once reviewed.
- Review `opencode.jsonc` before merging; do not overwrite a pre-existing personal/global config or hard-code a model/provider unavailable to the user.
- Do not paste confidential Word document contents into an external provider. Use synthetic fixtures and redact logs.

### 5.4 Handoff format — mandatory for all delegated tasks

Each agent must return this structure, and the coordinator must store a concise version in `docs/handoffs/current-phase.md`:

```text
TASK / PHASE:
ROLE AND MODEL (if relevant):
FILES READ:
FILES CHANGED:
DECISIONS MADE (with reasons):
COMMANDS RUN:
BUILD / TEST RESULTS (exact outcomes):
TESTS NOT RUN AND WHY:
KNOWN LIMITATIONS / RISKS:
DEPENDENCIES ADDED OR PROPOSED:
NEXT RECOMMENDED ACTION:
```

### 5.5 Suggested OpenCode flow in VS Code

1. Open the repository folder in VS Code and open the integrated terminal.
2. Run `opencode` from the repository root.
3. Begin in Plan mode/agent for Phase 0. Ask it to read this plan and `AGENTS.md`, inspect the environment and propose the next safe action without changing source files.
4. Use a read-only documentation/repository agent for bounded research where available.
5. Switch to Build or the selected implementation agent only after approving the phase plan.
6. After a discrete change, inspect `git diff --stat`, `git diff`, repository status and the actual test/build results.
7. Update the handoff note before changing models or ending the session.

Useful prompts and detailed phase tasks are provided in Section 11.

---

## 6. Prerequisites and environment bootstrap

### 6.1 Windows prerequisites for the default VSTO path

Verify rather than blindly install:

- Windows 11 or another Windows release that is currently supported and verified compatible with the installed Office/Visual Studio toolchain.
- Desktop Microsoft Word installed, activated and launchable.
- Visual Studio edition/version with **Office/SharePoint development** components and the Word VSTO Add-in template.
- The .NET Framework developer pack/runtime required by that VSTO template; VSTO remains .NET Framework-based (do not retarget the add-in to .NET 5+).
- Git for Windows.
- OpenCode installed and able to run from the VS Code integrated terminal.
- VS Code or another editor of choice. Visual Studio may still be needed for VSTO project creation, debugging and packaging.
- A dedicated test account/profile or clean Word session if possible.

Do not assume the starter template exists just because Visual Studio is installed. Verify the template in the New Project dialog. Document actual versions in `docs/decisions/ADR-0001-platform.md`.

### 6.2 Bootstrap sequence

1. Create a new empty repository or confirm that the chosen repository contains no unrelated work. Do not initialise over an existing codebase without inspection.
2. Add the root `AGENTS.md` and this plan to the repository.
3. Create `docs/decisions/ADR-0001-platform.md` and record environment facts before architecture selection.
4. Create a minimal VSTO Word Add-in from the installed Visual Studio template. Preserve template-generated manifest/deployment settings.
5. Build and run the untouched template. Verify Word launches with the add-in loaded and no startup error.
6. Add a visible test ribbon command that reads document name (or an anonymised safe identifier), paragraph count and current selection length without changing the document.
7. Add a simple operation that sets one explicitly selected paragraph property and verify unrelated properties visually and through the object model.
8. Test the basic footnote insertion/readback spike on a newly created synthetic document.
9. Record build commands, project/target framework, Office bitness, test-framework choice and launch procedure in `README.md`.
10. Commit the verified baseline only if the user has authorised commits; otherwise leave the diff ready for review.

### 6.3 Environment script expectations

`scripts/check-environment.ps1` should be read-only and report, where it can do so reliably:

- Windows version/architecture.
- Git and relevant .NET SDK/framework information.
- Visual Studio installation/tool components if detectable.
- Word installation/version/bitness if detectable without changing settings.
- Whether solution/project files and expected build tools are found.

It must not edit registry values, install packages, activate Office, change macro/add-in trust settings or elevate privileges automatically.

---

## 7. Data and operation contracts

Define these contracts before feature code grows. Use names appropriate to the final implementation, but preserve the meanings.

### 7.1 Document snapshot

A read-only representation of the parts of the Word document needed by an operation. Capture only fields needed for analysis: stable snapshot paragraph index, start/end positions or identifiers, text (held in memory only), style name, paragraph-format fields, list state/numbering metadata, superscript spans and note metadata where available.

Do not serialise the full snapshot to logs. For large documents, assess memory use and avoid loading redundant COM objects. The snapshot must clearly distinguish observed facts from inferred candidates.

### 7.2 Change plan

A complete proposed operation containing:

- Operation ID and type.
- Source document identity safe for display (not the full document content).
- A list of proposed edits with target identifiers and before/after properties or text ranges.
- Warnings, unresolved conditions and preconditions.
- A statement of what will intentionally not change.
- A validation method and postconditions.

The plan must not mutate Word. Execution revalidates each target because the document may have changed after preview.

### 7.3 Execution result

Return structured counts and results: applied, skipped, ambiguous, failed, and rolled back/recovered if applicable. Include concise safe diagnostics and enough location information for the user to find a result. Do not log full confidential footnote/citation content by default.

### 7.4 Profile contract

Profiles are versioned settings documents. Include a stable profile ID, schema version, readable name, description, explicit target scope, property rules, cleanup flags and compatibility notes. Validate import/export. Never encode document-specific text, user identity or hidden content into a profile. Migrations must be deterministic and tested.

---

## 8. Phase plan and exit gates

No phase may be called complete until its exit criteria are satisfied. If the gate fails, fix the blockers or document an approved limitation; do not skip the gate to reach later features.

### Phase 0 — Repository, environment, and architecture spike

**Goal:** establish the baseline and select the implementation technology using evidence.

**Tasks**

- Inspect the repository and working tree; do not assume it is empty.
- Verify the installed Word, Visual Studio, framework and OpenCode setup.
- Create the logical repository structure and durable project instructions.
- Run the minimum VSTO spike. Use a minimal Office.js spike only if VSTO prerequisites fail, a key API fails, or portability is made a first-release requirement.
- Create the ADR with the chosen platform, alternatives considered, measured results, supported environment, known trade-offs and reversal conditions.
- Create synthetic test documents and define how integration testing runs.

**Exit gate**

- A tiny add-in builds and loads in desktop Word.
- A formatting change can be applied to a controlled range without incidental changes.
- Native numbering can be distinguished from a manually typed number in the test cases.
- A genuine footnote can be inserted at a controlled reference location and read back.
- ADR-0001 is reviewed and the technology is locked for v1.0.

### Phase 1 — Working shell and quality baseline

**Goal:** a robust empty product shell that can inspect documents without changing them.

**Tasks**

- Create ribbon groups/buttons: `Formatting`, `Numbering`, `Footnotes`, `Profiles`, `Report`.
- Add a task pane/dialog only where it improves preview/review; keep it minimal.
- Add central error handling and safe diagnostic reporting.
- Add unit-test and integration-test projects.
- Create `README.md`, `PRODUCT_SPEC.md`, `ARCHITECTURE.md`, `TEST_STRATEGY.md`, and `KNOWN_LIMITATIONS.md`.
- Set formatting/analyzer rules suited to the chosen language, pin dependency versions and establish the build command.

**Exit gate**

- Add-in startup is reliable across several Word launches.
- Read-only inspection returns meaningful document facts.
- A failing command does not crash Word or leave an unexplained partial change.
- Core unit tests run from a documented command.

### Phase 2 — Profile model and formatting engine

**Goal:** users can define and apply a formatting profile to a selection or entire document.

**Minimum property groups**

- Character: font family, font size, bold, italic, underline and only other well-supported properties justified by the UI.
- Paragraph: alignment, line spacing, space before/after, first-line/left/right indentation, and selected keep/widow settings if supported.
- Style mapping: apply or map built-in/custom paragraph styles safely; avoid globally redefining built-in styles without explicit user choice.
- Page layout: page size, orientation and margins where the chosen platform can apply them safely. Treat section-specific settings separately and surface their scope clearly.
- Scope: selection, selected paragraphs, or full document.

**Rules**

- Do not reset an entire `Font`, `ParagraphFormat` or style object to change a single property.
- Represent unspecified properties as “leave unchanged.”
- Do not apply a profile by indiscriminately replacing the whole document's formatting.
- Preview scope, targeted properties, likely affected paragraph count and warnings.
- Preserve tables, headers, footers, fields, hyperlinks, content controls, comments and tracked changes unless the operation explicitly targets them and tests demonstrate safe behaviour.

**Exit gate**

- Profiles can be created, edited, duplicated, saved, imported and exported.
- Invalid profile data is rejected with actionable errors.
- Tests prove a single-property change leaves non-target properties untouched.
- Multi-section page-layout behaviour has been tested or clearly marked as unsupported.

### Phase 3 — Explicit cleanup tools

**Goal:** provide targeted cleanup without destructive bundling.

Implement each command separately and make its scope visible:

- Trim repeated ordinary spaces (never change intentional whitespace without a rule).
- Find/report multiple consecutive blank paragraphs; deletion is a separate confirmed operation.
- Normalise tabs only when the user selects a configured rule; do not convert all tabs to spaces unconditionally.
- Report manual line breaks and paragraph breaks; replace only when the user chooses a specific cleanup rule.
- Optional cleanup of excess paragraph spacing and empty paragraphs, separate from character formatting.

**Exit gate**

- Each cleanup tool has positive cases, negative cases, and preservation tests.
- A scan shows proposed counts before edits.
- Unicode, non-breaking spaces, fields, tables and footnote ranges are covered by relevant tests.
- Nothing runs destructive cleanup as a hidden side effect of applying a font or paragraph profile.

### Phase 4 — Numbering audit and repair

**Goal:** accurately report numbering anomalies and offer separate, preview-first repairs.

**Detect at least**

- Native Word list items and their list-level metadata.
- Native multilevel/nested lists and restart sequences.
- Manually typed numeric prefixes.
- Missing, repeated or out-of-order manual numbering.
- Numeric content that should remain ordinary text (e.g. years, legal provisions, case citations, dates, enumerations within prose).
- Mixed native and manual numbering in the same sequence.

**Repair design**

- Read-only audit comes first.
- Offer a native-list repair command independently from manual-numbering conversion/repair.
- Never infer list membership from a prefix regex alone.
- Preview all affected paragraphs, intended sequence and nesting before applying a repair.
- Do not remove manually typed markers until the new numbering has been applied and verified.
- Process targets in a stable order and revalidate ranges immediately before each edit.
- Test restart-at-one, continue-numbering, nested levels, list items split by headings, tables, section boundaries and mixed numbering.

**Exit gate**

- All test fixtures are classified into the expected categories.
- No ambiguous case is silently repaired.
- Before/after checks prove that the paragraph text is preserved except for approved markers and that list nesting/order is retained.

### Phase 5 — Footnote candidate scanner and matcher (read-only)

**Goal:** locate and explain likely flattened footnote content before allowing edits.

**Supported first-release cases**

1. Superscript numeric reference in body + note block with the same numeric prefix.
2. A document or trailing block with consecutively numbered candidate notes.
3. Pasted text where the superscript formatting is gone but the numbering and likely note-block structure remain.
4. PDF-to-Word conversions where markers or note text have become ordinary text, where enough sequence/placement evidence survives.
5. Mixed documents containing real Word footnotes as well as flattened note text.

**Candidate evidence**

- Actual Word footnotes, which must be distinguished from flattened text.
- Superscript status and reference marker text.
- Candidate note prefix and observed sequence.
- Paragraph start/end position, document order, proximity to likely note block and paragraph formatting.
- Match uniqueness and contradictions.

**Output states**

- `HighConfidence`: evidence is strong and unambiguous, but still requires review/approval in v1.0.
- `NeedsReview`: more than one plausible match or incomplete formatting/sequence evidence.
- `Unmatched`: no defensible match found.

The UI must explain why each candidate is suggested. Store numeric scores only if their derivation is documented; avoid presenting arbitrary percentages as statistical certainty.

**Exit gate**

- Scan is read-only.
- Existing genuine footnotes are reported and never misclassified as flattened candidates.
- Ordinary numbered legal paragraphs and regular numbered lists have negative test coverage.
- Ambiguous candidate matches remain unresolved.

### Phase 6 — Review-first footnote restoration

**Goal:** convert user-approved flattened notes into genuine Word footnotes without losing content.

**Review interface**

Show reference excerpt/location, marker, candidate footnote content, source location, evidence, confidence state, and approve/reject/edit-match controls. Avoid displaying an entire confidential document when only a local excerpt is needed.

**Mutation rules**

1. Require explicit user approval for every proposed mapping before execution; no unattended/automatic restoration in v1.0.
2. Revalidate document identity and target ranges immediately before edits.
3. Create a recoverable copy or use a verified Word undo grouping strategy; be explicit about the guarantee.
4. Insert the genuine Word footnote at the approved location using the Word object model. Let Word manage native reference numbering.
5. Read back the inserted footnote and compare its content with the approved source text.
6. Remove the flattened source note only after successful insertion and verification; if verification fails, leave the source text untouched and report failure.
7. Apply edits in an order that minimises range shifting (normally from later positions to earlier positions where applicable), but confirm this is safe with actual Word ranges before relying on it.
8. Never renumber ordinary body paragraphs just to force a note match.
9. Report inserted, skipped, unmatched and failed mappings.
10. Ensure an operation can be cancelled before mutation. During multi-step execution, detect partial failure and use the verified recovery path.

**Test cases**

- A single flattened footnote.
- Several consecutive flattened footnotes.
- Superscript references, ordinary baseline numbers and bracketed reference markers.
- Missing reference, missing note, duplicate note number, duplicate potential reference.
- Numbered paragraphs, numbered submissions and footnotes in the same document.
- Existing genuine notes interspersed with flattened candidates.
- Flattened notes at the end and within the body.
- PDF-conversion artefacts, odd whitespace, line breaks and paragraph splits.
- Notes containing punctuation, Unicode characters, hyperlinks and multi-paragraph text.
- Protected/read-only documents, tracked changes, tables and section boundaries where applicable.
- Failure during the second or later insertion.

**Exit gate**

- All restored notes are genuine Word footnotes, confirmed from Word's object model after insertion.
- Source note text is removed only when verified successful.
- No test loses source text on simulated failures.
- Ambiguous mappings require human decision and can be skipped.
- The result has been manually inspected in Word with a representative synthetic test set.

### Phase 7 — Integrated regression, performance and release readiness

**Goal:** deliver a testable, supportable Windows desktop add-in.

- Run unit tests, static analysis and build checks.
- Run Word integration tests on a clean Word session and at least one ordinary user profile.
- Exercise large synthetic documents and avoid pathological per-paragraph COM round trips where possible.
- Test cancellation, exceptions, read-only docs and unsupported Word API/runtime conditions.
- Verify ribbon state and error reporting after failed operations.
- Check installation, update/uninstall and add-in load behaviour with the chosen VSTO deployment strategy.
- Create a release checklist and a known-limitations document. Do not claim broad compatibility beyond the tested Office versions.

**Exit gate**

- Clean build succeeds.
- Unit tests pass.
- Required Word integration tests pass on the target environment.
- No open critical/high-severity data-loss defect.
- Installation and recovery procedures are documented and tested.

---

## 9. Formatting profile schema and execution details

The chosen schema may evolve, but should have equivalent capabilities to this example. It is illustrative, not a final serialization contract.

```json
{
  "schemaVersion": 1,
  "id": "profile-guid",
  "name": "General Clean Document",
  "description": "Example profile; customise before use.",
  "scope": "document",
  "character": {
    "fontName": { "mode": "set", "value": "Arial" },
    "fontSizePt": { "mode": "set", "value": 11 },
    "bold": { "mode": "preserve" },
    "italic": { "mode": "preserve" },
    "underline": { "mode": "preserve" }
  },
  "paragraph": {
    "alignment": { "mode": "set", "value": "left" },
    "spaceBeforePt": { "mode": "set", "value": 0 },
    "spaceAfterPt": { "mode": "set", "value": 6 },
    "lineSpacing": { "mode": "preserve" },
    "firstLineIndentPt": { "mode": "preserve" }
  },
  "cleanup": {
    "trimRepeatedSpaces": false,
    "removeEmptyParagraphs": false,
    "normaliseTabs": false,
    "replaceManualLineBreaks": false
  }
}
```

Rules:

- Validate property value ranges and enum values.
- `preserve` means do not set or reset that property.
- Avoid representing a missing setting as a default value that modifies the document unexpectedly.
- Schema upgrades require a migration function and fixtures for old profiles.
- The UI must distinguish formatting settings from cleanup settings.

---

## 10. Test architecture and fixture matrix

### 10.1 Layers

1. **Pure unit tests:** profile validation, cleanup algorithms over strings/snapshots, candidate scoring, marker parsing and change-plan validation.
2. **Adapter tests:** Word interop adapter behaviour isolated as far as practical, with explicit tests for range resolution and COM failure paths.
3. **Word integration tests:** execute against real desktop Word and synthetic documents. These are necessary for footnote insertion, list numbering and section/page-layout operations.
4. **Manual visual checks:** verify ribbon behaviour, task-pane review flow, superscript/reference appearance, page flow and notes at page bottoms.
5. **Regression tests:** every found defect adds a reproducible fixture or test before/with its fix.

### 10.2 Minimum fixture matrix

| Fixture ID | Subject | Required assertion |
|---|---|---|
| FMT-001 | Mixed font family/size | Only targeted characters/properties change |
| FMT-002 | Multiple sections with different margins/orientation | Scope and section-specific changes are explicit; unrelated sections stay unchanged |
| CLN-001 | Repeated spaces and non-breaking spaces | Only selected whitespace rules change |
| CLN-002 | Empty paragraphs and manual line breaks | Report-first; no implicit removal |
| NUM-001 | Native simple list | Native list state is detected correctly |
| NUM-002 | Native multilevel list | Level/indent relationship is preserved |
| NUM-003 | Manually typed numbered paragraphs | Marker text is detected as manual, not native numbering |
| NUM-004 | Years, subsection references, dates and citations | Ordinary numeric text is not treated as a list solely due to its prefix/content |
| NUM-005 | Mixed native/manual list | Ambiguity is reported; no silent conversion |
| FN-001 | Single flattened note | Correct candidate is proposed and can be restored |
| FN-002 | Several sequential notes | Order and reference associations are preserved |
| FN-003 | Existing real + flattened notes | Existing notes remain intact; flattened ones remain candidates |
| FN-004 | Duplicate/missing/ambiguous marker | Requires review or remains unmatched |
| FN-005 | Multi-paragraph note | All approved note text is retained |
| FN-006 | Failed insertion | Original flattened text remains or safe recovery is completed and verified |
| INT-001 | Read-only/protected document | Operation is blocked gracefully with a clear message |
| INT-002 | Large synthetic document | Bounded time/memory; no unresponsive UI caused by inefficient COM calls |

### 10.3 Test data policy

- Create synthetic `.docx` files. Never commit real case files, contracts or client communications.
- Keep expected results as explicit fixture metadata, not assumptions embedded only in a model prompt.
- Record Word version/build and relevant environment details for integration runs.
- Where Word automation tests need an interactive desktop, mark that requirement clearly rather than reporting them as ordinary headless tests.
- Verify document preservation using both object-model checks and reopened-file checks where appropriate.

---

## 11. Copy-ready prompts for OpenCode / delegated agents

Use one prompt per task. The coordinator should paste the relevant prompt into the selected primary agent or mention a configured subagent. A different model must be able to complete the assignment using the repository files and handoff note—do not rely on hidden chat context.

### Prompt A — Phase 0 environment and architecture reconnaissance

```text
Read AGENTS.md and WORD_TOOLKIT_IMPLEMENTATION_PLAN.md first. You are a read-only reconnaissance agent. Do not change source files or install anything.

Inspect the current repository and, where tools permit, the Windows/Word/Visual Studio/OpenCode environment. Research only official Microsoft and OpenCode documentation for relevant platform constraints. Compare Windows-native C# VSTO with Word Office.js for this product's current v1.0 scope: configurable formatting, separate cleanup, numbering audit/repair, and review-first flattened-footnote restoration. The product is general-purpose; the initial runtime target is Windows desktop Word.

Deliver a concise evidence-based report with: actual environment findings, unknowns, links to official sources, required proof-of-concept tests, trade-offs, recommended ADR wording, and any blocker that would change the default VSTO recommendation. Do not claim an API works without a source or a test. Return the mandatory handoff format. No edits.
```

### Prompt B — Bootstrap the minimal add-in

```text
Read AGENTS.md, this plan, and ADR-0001. Implement Phase 1 only. First inspect git status and existing files; preserve all existing user work. Use the approved architecture and the generated Visual Studio VSTO template where applicable.

Create the smallest working shell: ribbon with Formatting, Numbering, Footnotes, Profiles and Report entry points; a read-only document inspection command; central error handling; core and integration test projects; and the minimum documentation/verification scripts. Do not implement formatting rules, numbering repair or footnote recovery yet. Do not add unrelated dependencies.

Build the solution and launch it in desktop Word if the environment permits. Distinguish tests that actually ran from tests that could not run. Update docs/handoffs/current-phase.md and return the mandatory handoff format.
```

### Prompt C — Independent architecture and API reviewer

```text
You are a read-only reviewer. Do not edit files. Read AGENTS.md, the implementation plan, ADR-0001, the source project and the current git diff.

Find architecture violations, unverified Word API assumptions, accidental coupling to COM, risky COM lifetime/thread behaviour, framework incompatibilities, dependency/licence risks, and any feature that cannot meet the stated acceptance criteria. Check key claims against official Microsoft documentation. Prioritise issues by severity and cite exact files/symbols plus source URLs. Do not propose a rewrite when a targeted correction is sufficient. Return findings only, with no unsupported praise or claims that unrun tests passed.
```

### Prompt D — Formatting profile engine

```text
Implement Phase 2 only, following AGENTS.md, the approved ADR, and the existing architecture. Own only the profile/core formatting files and the corresponding tests assigned by the coordinator. Do not edit the add-in entry point or ribbon UI unless the coordinator assigns those files.

Build typed, versioned profiles with explicit 'set' versus 'preserve' semantics, validation, import/export, change-plan creation and a safe Word interop adapter. Character and paragraph formatting are independent from cleanup. Never reset entire formatting objects merely to set one property. Add unit tests and desktop Word integration tests for property preservation, selection/document scope, and multi-section layout. If any property cannot be applied reliably, report it and leave it unsupported instead of approximating silently.

Do not add deferred modules. Build/test what is possible, update the handoff file, and return the mandatory handoff format.
```

### Prompt E — Cleanup commands

```text
Implement Phase 3 only. Inspect the approved APIs and fixtures first. Each cleanup is a separate command with read-only preview and explicit execution. Begin with repeated ordinary spaces, reports for empty paragraphs/manual line breaks, and opt-in configured transformations. Preserve non-breaking spaces, Unicode, fields, links, tables, existing Word footnotes and tracked changes unless a specific test proves the operation safe.

Do not bundle cleanup into formatting-profile application. Add positive and negative tests before enabling each destructive operation. Do not remove blank paragraphs or replace manual line breaks by default. Update known limitations and handoff notes. Return commands and exact verification results.
```

### Prompt F — Numbering audit and repair

```text
Implement Phase 4 only. Distinguish native Word list numbering from manually typed number text and ordinary numeric references. Create read-only audit results first, then separate change plans for native-list correction and manually typed numbering repair. A regex or numeric paragraph prefix alone is not enough evidence for conversion.

Every repair must show the complete set of affected paragraphs, expected sequence and nesting before confirmation. Revalidate ranges immediately before mutation, preserve body text except for specifically approved marker changes, and verify postconditions. Add fixtures for simple/nested lists, restart/continue numbering, gaps, duplicate/manual markers, citations, dates and mixed native/manual lists. Ambiguous cases must be skipped or sent for review. Update the handoff file and report exact test outcomes.
```

### Prompt G — Footnote scanner/matcher (read-only)

```text
Implement Phase 5 only: read-only detection of flattened footnote candidates. Do not insert/delete anything in Word. Support common numeric and superscript marker patterns, plausible numbered note blocks, copied/pasted text, PDF-conversion artefacts and documents that mix native Word footnotes with flattened candidate text.

Build a structured snapshot/candidate model; record source positions, candidate text in memory, note-prefix/order/formatting evidence, uniqueness, contradictions and confidence state (HighConfidence, NeedsReview, Unmatched). Explain every proposed association. Numeric paragraphs, dates, legal provisions, citations and native lists require negative cases. Do not use AI or send content to external APIs. Add deterministic unit fixtures and a read-only Word scan integration test. Never claim perfect recovery. Return the mandatory handoff format.
```

### Prompt H — Footnote restoration

```text
Implement Phase 6 only, using the reviewed scanner and approved change-plan contract. Footnote restoration requires per-match human approval in v1.0. Revalidate target references before mutation; create a transparent recovery copy or use a verified undo/recovery mechanism; insert a genuine Word footnote; read it back and verify the inserted content; remove source flattened text only after successful verification.

If insertion or verification fails, leave source note content intact or execute and verify recovery, then report the failure. Do not infer missing notes, force-number body paragraphs, or auto-approve high-confidence cases. Test mixed native/flattened notes, ambiguous cases, duplicate/missing markers, multi-paragraph content and simulated partial failure in actual desktop Word. Provide evidence for range-mutation order and recovery claims. Update limitations and handoff notes.
```

### Prompt I — Test engineer (test-only ownership)

```text
You are the test engineer and own only tests/fixtures plus test documentation unless the coordinator explicitly assigns other files. Read AGENTS.md, the current phase handoff, current implementation and all acceptance criteria.

Create or extend synthetic Word fixture specifications for formatting, cleanup, native/manual/nested numbering, flattened footnotes, mixed native and flattened notes, ambiguous/missing references, protected documents and partial failure. Add regression tests for confirmed defects. Do not weaken assertions, delete failing tests or change production code just to make tests pass. Identify tests that require interactive desktop Word and label them clearly. Return exact commands, outputs, uncovered cases and the mandatory handoff format.
```

### Prompt J — Security/privacy and reliability review

```text
Perform a read-only security, privacy and data-loss review of the current diff. Do not edit files. Inspect dependency changes, logging, local profile storage, document-content retention, network calls, file/path handling, recovery copies, range mutation, error handling, COM object lifetime and user-consent points.

Verify there is no runtime upload/telemetry, no unapproved LLM call, no document body or footnote text in ordinary logs, no silent deletion of flattened source text, and no undocumented auto-repair. Report severity, exploit/failure scenario, exact affected location and smallest defensible fix. Verify claims against tests or official docs, not only source appearance. Return the mandatory handoff format.
```

### Prompt K — Release readiness reviewer

```text
Act as an independent release gate reviewer. Do not edit code. Read the product spec, ADR, known limitations, test strategy, current diff and test artefacts. Check each v1.0 acceptance criterion against actual evidence. Run only approved, non-destructive checks and clearly distinguish executed tests from unexecuted tests.

Report: pass/fail per phase gate; critical/high/medium/low defects; missing integration tests; unsupported or unverified Office versions; packaging/install/uninstall gaps; privacy risks; and a go/no-go recommendation. Do not mark release-ready if any critical data-loss issue is open or required Word integration tests have not run.
```

---

## 12. Research and behavioural benchmarking of Kutools

The project may use Kutools' public feature descriptions and black-box observation of commands as a functional benchmark. Reverse-engineer it.

Maintain `docs/research/feature-benchmarks.md` with one entry per studied command:

- Feature name and source URL.
- Input fixture and starting conditions.
- Operation options selected.
- Expected visible behaviour and observed output.
- What is intentionally in scope for Word Toolkit v1.0.
- Edge cases and preservation requirements.
- Independent implementation idea using documented Word APIs.
- Test cases that demonstrate parity or document deliberate differences.

Start with formatting profiles, common cleanup, numbering inspection/repair and footnote recovery. Do not let benchmark research expand v1.0 without an explicit scope decision.

---

## 13. Definition of done for every task

A task is done only when all applicable conditions are met:

- [ ] Work stayed within the approved task and assigned file scope.
- [ ] No existing work was overwritten or discarded.
- [ ] Implementation follows the current ADR and module boundaries.
- [ ] Relevant tests were added or an explicit reason for not adding them is documented.
- [ ] Build/tests were run where available and results are accurately reported.
- [ ] Unrun desktop Word checks are clearly labelled, never represented as passing.
- [ ] Destructive paths have preview, user confirmation and verified recovery behaviour.
- [ ] No document text is sent outside the process or included in routine logs.
- [ ] Dependency/version/architecture changes are documented.
- [ ] `docs/handoffs/current-phase.md` is updated for cross-agent continuity.
- [ ] `git diff` was reviewed and no unrelated formatting/refactoring was introduced.
- [ ] The next action is a single bounded task with clear ownership.

---

## 14. Immediate next action

**Do not begin with the formatting engine. Begin with Phase 0.** In OpenCode Plan mode, run Prompt A to inspect the repository and environment. Then validate the starter VSTO project in desktop Word and perform the small formatting/numbering/footnote spike. Review ADR-0001 before authorising feature implementation.

The single most important acceptance standard for this project is document integrity. An incomplete feature with an honest limitation is preferable to a feature that silently damages text, numbering, footnotes or formatting.
