# Kutools investigation workspace — handling rules

Read `AUTHORISATION.md` first. This area holds **behavioural specifications
derived from authorised inspection**. It must never contain proprietary code.

## Layout

```text
docs/research/kutools-investigation/
├── AUTHORISATION.md            # permission record + binary provenance (this log)
├── README.md                   # this file
├── WINDOWS_RUNBOOK.md          # procedure for the deep-inspection host
├── FEATURE_SPEC_TEMPLATE.md    # per-feature spec template
└── <feature>/                  # one folder per investigated feature, when begun
    ├── FEATURE_SPEC.md
    └── IMPLEMENTATION_ASSESSMENT.md
```

Raw materials (extracted installer payloads, disassembly listings, decompiler
project trees, screenshots of proprietary UI text beyond short factual labels)
live ONLY in the quarantine directory **outside this repository**:

```text
../WordTulKit-investigation/   # sibling of the repo; NOT in git; NEVER committed
├── binaries/    # copies of the installer files under inspection (hash-verified)
└── raw/         # extraction + disassembly output (local eyes only)
```

## Rules

1. **Specs describe behaviour, not implementation.** Inputs, options, observable
   outcomes, edge cases, failure conditions, acceptance tests. No proprietary
   identifiers, string tables, or structural detail beyond what a black-box
   observer could verify.
2. **Every claim carries provenance:** observed-directly (tool + command) vs
   inferred (marked as hypothesis). No inferred claim ships as a requirement.
3. **Implementation agents never see `raw/`.** They receive the approved
   `FEATURE_SPEC.md` + fixtures only.
4. **One feature, one folder.** Start with v1.0 scope only: formatting
   profiles, common cleanup, numbering inspection/repair, footnote recovery
   (plan §12). Benchmarking must not expand v1.0 without an owner decision.
5. **Each feature delivers all five** (`AGENTS.md` §4): feature spec,
   implementation assessment, independent design proposal, reproducible test
   cases + results, implementation/regression report — before any production
   code is written from it.

## Status

2026-10-11 (later): owner answers recorded — primary scope **multiple builds**
with version deltas; licence/EULA **confirmed by owner** (their assessment);
Windows host **not yet available** (maximum Linux-static work now complete);
all four feature areas prioritised — draft capture-plan `FEATURE_SPEC.md`
files created under `numbering/`, `footnote-recovery/`, `formatting-profiles/`,
`cleanup-tools/`. Factual survey in `STATIC_SURVEY_2026-10-11.md`. No
extraction, no decompiler run. Deep work awaits the Windows host.
