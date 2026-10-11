# FEATURE SPEC (draft) — Formatting profile behaviour

```text
FEATURE: Formatting application commands (font/paragraph/page scope behaviour)
STATUS: draft (capture plan only — nothing observed yet)
SOURCE BINARIES: A=8.7.0.1 (Inno), B=16.20.00 (AdvInstaller), C=8.2.119.0 (Inno).
  Compare all three; record version deltas. Cite hash+version per claim.
SOURCE REFERENCES: plan §§2/9/10 (FMT-001/002 fixtures); AGENTS.md §6.

INPUT FIXTURE AND STARTING CONDITIONS:
  Build synthetic fixtures mirroring FMT matrix: mixed fonts/sizes, direct
  formatting over styles, multiple sections with differing layout, tables,
  headers/footers, fields. Apply each Kutools formatting command to
  selection-scope and document-scope variants.

OPERATION OPTIONS SELECTED:
  Enumerate every formatting-related command and dialog option (names +
  navigation path). Exercise options singly.

OBSERVED OUTPUT: NOT YET OBSERVED (requires Windows black-box run).

PRESERVATION CHECKS:
  Single-property change leaves untargeted properties/styles/sections
  untouched (mirror FMT-001/002); tables/headers/footers/fields preserved.

EDGE CASES AND FAILURE CONDITIONS: NOT YET OBSERVED. Priority: whether any
  command resets whole Font/ParagraphFormat objects or redefines built-in
  styles globally — our v1.0 forbids both unless explicitly chosen.

IN-SCOPE FOR WORD TOOLKIT v1.0: configurable named profiles; set-vs-preserve
  semantics; scope selection. DELIBERATELY OUT OF SCOPE: one fixed national
  formatting standard (profiles stay general-purpose).

INDEPENDENT IMPLEMENTATION IDEA: pending observations; typed versioned
  profiles; change-plan preview; per-property application via documented APIs.

TEST CASES: FMT-001/002 matrix (plan §10.2) for parity/difference notes.

PROVENANCE PER CLAIM: none yet — this file is a capture plan.
```
