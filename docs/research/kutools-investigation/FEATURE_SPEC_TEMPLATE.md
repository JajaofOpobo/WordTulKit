# Feature spec template (copy to `<feature>/FEATURE_SPEC.md`)

```text
FEATURE:
STATUS (draft / approved):
SOURCE BINARY (file name + SHA-256 short + version string):
SOURCE REFERENCES (public URLs shaping scope):

INPUT FIXTURE AND STARTING CONDITIONS:
  (synthetic fixture ID + document state; never real client content)

OPERATION OPTIONS SELECTED:
  (each user-visible option exercised, one at a time)

OBSERVED OUTPUT (visible behaviour):
  (before/after facts a black-box observer can verify)

PRESERVATION CHECKS:
  (unrelated content/properties confirmed untouched)

EDGE CASES AND FAILURE CONDITIONS:
  (ambiguous inputs, limits, error paths + observed messages/behaviour)

IN-SCOPE FOR WORD TOOLKIT v1.0 / DELIBERATELY OUT OF SCOPE:

INDEPENDENT IMPLEMENTATION IDEA (documented Word APIs only):
  (no proprietary identifiers, structure, or logic transcription)

TEST CASES (fixture IDs + exact expected outcomes):

PROVENANCE PER CLAIM (observed: tool+command | inferred: hypothesis):
```

Approval: coordinator signs `STATUS: approved` with date. Only approved specs
may be referenced by implementation tasks. Unapproved drafts must not be built from.
