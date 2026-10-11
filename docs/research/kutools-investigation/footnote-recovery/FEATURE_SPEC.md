# FEATURE SPEC (draft) — Footnote handling behaviour

```text
FEATURE: Footnote-related commands (detection, conversion, flattened-note handling)
STATUS: draft (capture plan only — nothing observed yet)
SOURCE BINARIES: A=8.7.0.1 (Inno), B=16.20.00 (AdvInstaller), C=8.2.119.0 (Inno).
  Compare all three; record version deltas. Cite hash+version per claim.
SOURCE REFERENCES: plan §§5/6/10 (FN-001..006 fixtures); AGENTS.md §8.

INPUT FIXTURE AND STARTING CONDITIONS:
  Build synthetic fixtures mirroring FN matrix: single flattened note,
  sequential notes, mixed native+flattened, duplicate/missing/ambiguous
  markers, multi-paragraph notes, notes adjacent to lists/tables. Drive each
  Kutools footnote command against each fixture.

OPERATION OPTIONS SELECTED:
  Enumerate every footnote-related command and dialog option (names +
  navigation path). Exercise options singly. Record default settings.

OBSERVED OUTPUT: NOT YET OBSERVED (requires Windows black-box run).

PRESERVATION CHECKS:
  Native footnotes intact; source text handling on success vs failure;
  ambiguity surfaced for review (mirror FN-003/FN-004/FN-006).

EDGE CASES AND FAILURE CONDITIONS: NOT YET OBSERVED. Priority: what Kutools
  does with duplicate/missing markers and mid-batch failure — our v1.0 must
  be at least as safe (verified recovery, never silent loss).

IN-SCOPE FOR WORD TOOLKIT v1.0: review-first candidate matching; per-match
  approval; footnotes only (no endnotes). DELIBERATELY OUT OF SCOPE:
  unattended/auto restoration.

INDEPENDENT IMPLEMENTATION IDEA: pending observations; genuine Word footnotes
  via documented object model; insert-then-verify-then-remove discipline.

TEST CASES: FN-001..006 matrix (plan §10.2) for parity/difference notes.

PROVENANCE PER CLAIM: none yet — this file is a capture plan.
```
