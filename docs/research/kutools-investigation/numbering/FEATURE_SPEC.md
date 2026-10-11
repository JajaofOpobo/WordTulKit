# FEATURE SPEC (draft) — Numbering inspection and repair behaviour

```text
FEATURE: Numbering audit + repair commands (native vs manually typed numbers)
STATUS: draft (capture plan only — nothing observed yet)
SOURCE BINARIES: A=8.7.0.1 (Inno), B=16.20.00 (AdvInstaller), C=8.2.119.0 (Inno).
  Compare all three; record version deltas. Cite hash+version per claim.
SOURCE REFERENCES: plan §§4/10 (NUM-001..005 fixtures); AGENTS.md §7.

INPUT FIXTURE AND STARTING CONDITIONS:
  Build synthetic fixtures mirroring Word Toolkit's NUM matrix: native simple
  list, native multilevel + restarts, manually typed prefixes, prose numerics
  (years, provisions, dates), mixed native/manual. Drive each Kutools
  numbering command against each fixture.

OPERATION OPTIONS SELECTED:
  Enumerate every numbering-related command and dialog option found in the
  Kutools tab/menus (names + navigation path). Exercise options singly.

OBSERVED OUTPUT: NOT YET OBSERVED (requires Windows black-box run).

PRESERVATION CHECKS:
  Text preserved except approved marker changes; nesting/order retained;
  ambiguous cases flagged rather than converted (mirror NUM-005).

EDGE CASES AND FAILURE CONDITIONS: NOT YET OBSERVED.

IN-SCOPE FOR WORD TOOLKIT v1.0: audit-first workflow; separate native vs
  manual repair; preview before apply. DELIBERATELY OUT OF SCOPE: bulk
  auto-conversion without review.

INDEPENDENT IMPLEMENTATION IDEA: pending observations; must use documented
  Word list APIs only.

TEST CASES: NUM-001..005 matrix (plan §10.2) to be executed against both
  Kutools behaviour and our implementation for parity/difference notes.

PROVENANCE PER CLAIM: none yet — this file is a capture plan.
```
