# AGENTS.md — Word Toolkit

## 1. Project purpose

Build **Word Toolkit**, a universal, Windows-first Microsoft Word productivity add-in. The initial release focuses on:

1. Configurable document-formatting profiles.
2. Explicit, independently selectable formatting-cleanup operations.
3. Numbering inspection and review-first numbering repair.
4. Review-first recovery of footnotes flattened into ordinary document text.
5. Verification, diagnostics, safe failure and recovery.

The product is general-purpose. Nigerian legal documents may be useful test cases, but do not hard-code Nigerian legal conventions or present this as a legal-only product.

Deferred unless the project owner explicitly changes scope: batch find-and-replace, advanced selection/page operations, table/image tools, references/bookmarks/hyperlinks, batch file utilities, reusable-content libraries, redaction, AI-assisted editing and mail merge.

## 2. Source of truth and decision hierarchy

Before making changes, inspect the existing repository and read the project implementation plan.

Use this precedence order:

1. Explicit instructions from the project owner in the current task.
2. Accepted architecture decisions and approved feature specifications in `docs/`.
3. This file.
4. The implementation plan and backlog.
5. Agent assumptions.

If two sources conflict, do not silently choose one. Explain the conflict and ask the project owner, unless a reversible investigation can resolve it safely.

Do not overwrite, delete, rename or restructure existing files without first inspecting them and understanding their role. Preserve working project configuration and generated Office add-in entry points.

## 3. Agent operating rules

- Start each task by inspecting repository status, relevant files, tests, dependencies and current architecture.
- State the task's intended outcome, assumptions, files likely to change and validation plan before substantial edits.
- Work only within the assigned scope. Do not opportunistically implement deferred features.
- Prefer small, reviewable changes over large rewrites.
- Do not report a build, test, API behaviour or compatibility result as verified unless it was actually checked. Distinguish **verified**, **inferred**, **unverified** and **blocked**.
- If tools, Word, a licence, a test fixture or a required API are unavailable, document the limitation; do not fabricate results.
- Do not add cloud services, telemetry, external APIs, AI dependencies or a backend without explicit approval.
- Do not put confidential document text, personal data, document contents or footnote text into routine logs.
- Avoid unnecessary dependencies. Explain the purpose and maintenance cost of each new dependency.
- Keep documentation, tests and implementation aligned.
- Do not change architecture, target framework, manifest format or build system without recording the reason and obtaining approval when the change is consequential.

## 4. Reverse engineering and independent reimplementation

The objective is to understand feature behaviour, investigate implementation pitfalls where permitted, and independently implement equivalent or improved functionality.

- Prefer official documentation, public feature descriptions, controlled behavioural experiments and independently authored test fixtures.
- Static analysis, decompilation or other technical inspection of Kutools may only be undertaken after the project owner has established that the method is permitted.
- Do not copy, paste, translate line-by-line, port or depend on Kutools source code, decompiled methods, proprietary resources, internal identifiers or copied implementation structure.
- Do not use decompiled code as a code-generation prompt or feed it to an implementation agent. Keep any authorised investigation materials separate from the production implementation workspace.
- Translate findings into a **behavioural specification**: inputs, options, observable outcomes, edge cases, failure conditions and acceptance tests.
- Implement from that specification using independently designed code and documented Microsoft Word APIs.
- Record the provenance of findings and distinguish direct observation from inference.
- A functional similarity does not, by itself, resolve all legal questions. Escalate uncertainty about licence scope, copyright, interoperability exceptions or technical restrictions to the project owner for legal assessment.

For each investigated feature, produce:
1. `FEATURE_SPEC.md` or an equivalent feature specification.
2. `IMPLEMENTATION_ASSESSMENT.md` documenting observed behaviour, verified defects, hypotheses, performance concerns and limitations.
3. An independent design proposal.
4. Reproducible test cases and results.
5. An implementation and regression report.

Do not call a suspected weakness a confirmed defect without evidence. Benchmark performance hypotheses where practical.

## 5. Architecture principles

- Keep document-processing rules separate from UI and Word-specific integration code.
- Isolate Word object-model or Office.js calls behind a small, documented integration layer.
- Use typed models for formatting profiles, document snapshots, candidate matches, proposed changes, validation results and reports.
- Prefer **analyse → plan → preview → approve → apply → verify → report** for document-changing operations.
- Make scans read-only.
- Never silently combine unrelated operations (for example, font formatting must not also remove blank paragraphs).
- Preserve properties not explicitly targeted by the selected operation.
- Design destructive operations to fail safely and provide a documented recovery path.
- Avoid passing live Word COM objects to background threads. Respect Word's threading and object-model constraints.
- Do not assume every Word client or version supports every API. Check capabilities at runtime where applicable.
- Keep the core algorithms independently testable wherever possible.
- Use a Windows desktop Word proof of concept to validate critical behaviour before finalising the architecture.

## 6. Formatting profiles

Profiles must be configurable and general-purpose. Do not hard-code one national or professional formatting convention.

A profile may define:
- Font family and size.
- Explicitly selected character properties.
- Paragraph alignment, line spacing, spacing before/after and indentation.
- Style and heading mappings.
- Optional page and section settings, only where supported and verified.
- Separate, opt-in cleanup operations.

Profile import must validate its schema and values. Applying a profile must produce a preview or change summary where practical and preserve untargeted properties. Test mixed styles, direct formatting, multiple sections, tables, headers, footers, fields and existing notes.

## 7. Numbering safety

Distinguish at minimum:
- Native Word lists.
- Native multilevel lists.
- Manually typed number prefixes.
- Numeric references within prose.
- Mixed or ambiguous structures.

Provide a read-only audit before repair. Treat renumbering and conversion of manually typed numbers as separate, review-first operations. Do not use a broad regular expression to renumber every paragraph. Preserve text, nesting, sequence restarts and intended indentation. Report ambiguity instead of guessing.

## 8. Footnote recovery safety

Initial scope: **footnotes only**. Endnotes are deferred unless explicitly approved.

The scanner should identify existing native footnotes and candidate flattened notes, then propose associations using configurable markers, detectable formatting, numbering patterns, document order and surrounding structure. A numeric paragraph or superscript is not, on its own, proof of a footnote.

Each candidate should record:
- Source/reference location.
- Candidate note location and text.
- Match evidence and explanation.
- Confidence category: high confidence, needs review or unmatched.
- Validation status.

The user must review and approve each proposed match. The module must not invent missing references or citation text.

When restoring a note:
1. Revalidate the source locations immediately before editing.
2. Insert a genuine Word footnote using the supported object model.
3. Verify that the note exists and contains the intended content.
4. Remove flattened source text only after successful insertion and verification.
5. Account for range invalidation as edits change document positions.
6. Preserve unrelated text, punctuation, formatting, lists and existing native footnotes.
7. Report restored, skipped, unmatched and failed items.

If safe matching or insertion cannot be established, stop and request user review. Do not claim automatic rollback unless it has been tested.

## 9. Testing requirements

Use three complementary layers:

1. **Unit tests:** profile validation, text analysis, marker parsing, matching, numbering classification, change-plan generation and validation logic.
2. **Integration tests:** actual document changes inside a supported desktop Word environment.
3. **Regression fixtures:** synthetic `.docx` documents with known expected outcomes, including edge cases and failures.

At minimum test:
- Mixed styles, direct formatting and multiple sections.
- Blank paragraphs, tabs, repeated spaces and manual line breaks.
- Native lists, nested lists, restart points, manually typed numbers and numeric references in prose.
- Existing footnotes mixed with flattened candidates, missing and duplicate markers, ambiguous numbered paragraphs and notes adjacent to other structures.
- Pasted and PDF-converted content.
- Tables, headers, footers, hyperlinks, fields and content controls.
- Tracked changes, protected/read-only documents, large documents and failed multi-step edits.

Compare before/after content and relevant formatting. Assert that differences are limited to the intended changes. A unit test alone does not prove Word integration behaviour. Never claim integration tests passed if they were not run in desktop Word.

## 10. Multi-agent coordination (OpenCode in VS Code)

Different agents may be assigned research, specification, testing, implementation or review. Assume agents may use different models and have different strengths.

### Roles

- **Coordinator / lead agent:** owns the task breakdown, source-of-truth documents, integration decisions and final report. Normally the only agent allowed to change shared architecture documents.
- **Research agent:** gathers official API documentation and reports capability requirements, limitations and source references. Does not modify production code.
- **Feature analyst:** documents observed behaviour, test cases, edge cases and implementation hypotheses. Does not implement the feature unless explicitly assigned.
- **Test engineer:** creates fixtures, test plans and assertions within assigned files. Does not change production logic to make tests pass.
- **Implementation agent:** implements a narrowly defined module against an approved specification.
- **Independent reviewer:** reviews the diff, risks and test evidence. Must not approve its own work.

### Coordination rules

- Before delegating, create a task brief containing objective, in-scope files, out-of-scope files, interfaces, dependencies, acceptance criteria and required evidence.
- Give each agent a bounded task and a unique branch/worktree or isolated file ownership when concurrent editing is possible.
- Do not let two agents edit the same files simultaneously.
- The coordinator owns shared interfaces, dependency changes, architecture decisions and merges.
- Agents must report files changed, commands run, tests actually executed, results, assumptions, risks and unresolved questions.
- Require agents to inspect the current repository state before working; do not assume their context includes earlier conversations or decisions.
- Do not merge a contribution solely because an agent says it is complete. Review the diff and run relevant tests.
- Resolve conflicting recommendations through evidence, tests and documented decisions rather than agent seniority or model preference.
- If the OpenCode setup does not support safe isolated concurrent work, delegate sequentially rather than risk overlapping edits.
- Do not expose proprietary investigative material to implementation agents; pass them the approved behavioural specification and tests instead.

## 11. Definition of done

A feature is not complete until:
- Its scope and acceptance criteria are documented.
- Implementation is independently authored and appropriately reviewed.
- Unit tests pass.
- Required Word integration tests have been run, or their inability to run is clearly marked as a release blocker.
- Failure paths and ambiguous inputs are handled explicitly.
- The operation preserves unrelated document content.
- User-visible results and known limitations are documented.
- The diff contains no unrelated changes.
- The coordinator records the outcome and any remaining work.

## 12. Required agent report format

At the end of each task, report:

1. **Outcome:** completed, partially completed, blocked or rejected.
2. **Files changed:** paths and purpose.
3. **Technical decisions:** decisions made and rationale.
4. **Verification:** exact commands and tests run, with results.
5. **Evidence status:** verified, inferred, unverified or blocked.
6. **Risks and limitations:** especially Word-version/API dependencies and document-integrity risks.
7. **Follow-up:** next smallest actionable task.

Never claim that a feature is production-ready based only on compilation or generated code.
