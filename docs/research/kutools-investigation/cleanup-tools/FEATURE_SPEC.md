# FEATURE SPEC (draft) — Cleanup command behaviour

```text
FEATURE: Whitespace/paragraph cleanup commands (scope and granularity)
STATUS: draft (capture plan only — nothing observed yet)
SOURCE BINARIES: A=8.7.0.1 (Inno), B=16.20.00 (AdvInstaller), C=8.2.119.0 (Inno).
  Compare all three; record version deltas. Cite hash+version per claim.
SOURCE REFERENCES: plan §§3/10 (CLN-001/002 fixtures); AGENTS.md §§5/6.

INPUT FIXTURE AND STARTING CONDITIONS:
  Build synthetic fixtures mirroring CLN matrix: repeated ordinary spaces,
  non-breaking spaces, Unicode whitespace, empty paragraphs, manual line
  breaks, tabs, tables, footnote ranges, tracked changes. Drive each Kutools
  cleanup command against each fixture.

OPERATION OPTIONS SELECTED:
  Enumerate every cleanup-related command and dialog option (names +
  navigation path). Exercise options singly.

OBSERVED OUTPUT: NOT YET OBSERVED (requires Windows black-box run).

PRESERVATION CHECKS:
  Each command's exact scope: which whitespace classes change, which are
  left alone; blank-paragraph deletion separate from reporting (mirror
  CLN-001/002); NBSP/Unicode/fields/tables/footnotes/tracked-changes intact
  unless a specific tested rule targets them.

EDGE CASES AND FAILURE CONDITIONS: NOT YET OBSERVED. Priority: whether any
  formatting command silently bundles cleanup — our v1.0 forbids hidden
  side effects (AGENTS.md §5).

IN-SCOPE FOR WORD TOOLKIT v1.0: separate explicit commands with read-only
  preview/counts. DELIBERATELY OUT OF SCOPE: destructive cleanup as a side
  effect of profile application.

INDEPENDENT IMPLEMENTATION IDEA: pending observations; per-command
  scan-then-confirm plans over document snapshots.

TEST CASES: CLN-001/002 matrix (plan §10.2) for parity/difference notes.

PROVENANCE PER CLAIM: none yet — this file is a capture plan.
```
