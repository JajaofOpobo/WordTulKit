# Authorisation record — Kutools technical inspection

- **Permission granted by:** project owner, 2026-10-11, via explicit instruction
  to "commence decompilation as part of the preparation to move to windows".
- **Gate satisfied:** `AGENTS.md` §4 allows static analysis / decompilation /
  other technical inspection of Kutools only after the owner establishes the
  method is permitted. That establishment is this record.
- **Authorised scope:** read-only static inspection and disassembly of the
  Kutools for Word binaries listed below, SOLELY to understand feature
  behaviour, investigate implementation pitfalls, and produce behavioural
  specifications for independent reimplementation. Owner scope answer
  2026-10-11: **multiple builds** — inspect two or more versions and record
  version deltas (binaries A/B/C in the provenance table).

## Prohibitions that remain in force (NOT lifted by this authorisation)

1. No copying, pasting, line-by-line translation, porting, or depending on
   Kutools source code, decompiled methods, proprietary resources, internal
   identifiers, or copied implementation structure.
2. Decompiled output must NEVER be used as a code-generation prompt or fed to
   an implementation agent. Implementers receive only the approved behavioural
   specification and tests.
3. Raw investigation materials (extracted binaries, disassembly, decompiled
   trees) live in the quarantine directory OUTSIDE the repository and are
   NEVER committed. Only behavioural specs and provenance records enter `docs/`.
4. Every finding records provenance and distinguishes direct observation from
   inference. A suspected weakness is not a confirmed defect without evidence.

## Legal escalation (owner's assessment — agent makes no legal determination)

Owner answer 2026-10-11: **"Licensed and checked"** — the owner confirms a
legitimate licence and that the EULA position on reverse engineering for this
purpose has been checked. Recorded as the owner's assessment; the agent makes
no legal determination. If that position ever changes, stop deep inspection
and re-scope to public documentation + black-box observation only.

- [x] A legitimate copy/licence for the Kutools version under inspection.
- [x] The Kutools EULA's position on reverse engineering / decompilation has
      been checked (licence scope, any interoperability-exception reliance).
- [x] Technical-protection-measure concerns assessed (no circumvention
      performed; list-only probes only to date).

Functional similarity alone does not resolve licence/copyright questions
(`AGENTS.md` §4). If any answer above is negative, stop and re-scope to
public documentation + black-box observation only.

## Provenance — materials on hand (prep host, `~/Downloads/`)

| File | Size | SHA-256 (short) | Identification (read-only probes) |
|---|---|---|---|
| `wordkutools.exe` | 20,776,120 B | `abfc57bc…93ed2e` | Inno Setup; **v8.7.0.1**, "Kutools for Word Setup", ExtendOffice. (Filename version resolved by survey.) |
| `wordkutools latest v17.exe` | 49,415,968 B | `7218d643…24ab216` | Advanced Installer 16.5 bootstrapper; **v16.20.00** (`WordKutools.exe`), ©2025 ExtendOffice.com. Filename "v17" ≠ file version — cite version+hash. |
| `wordkutools v8.2.exe` | 17,696,304 B | `6a926ea0…f1d337ba` | Inno Setup; **v8.2.119.0** confirmed, ExtendOffice. |

Full SHA-256 values: `STATIC_SURVEY_2026-10-11.md` (result table).

## Methods used to date (all read-only; nothing executed, extracted, or modified)

`ls`, `file`, `sha256sum`, `7z l` (PE headers only — 7-Zip does not parse Inno
payloads as archives), bounded `strings` scan for publisher/installer markers,
read-only PE/overlay structural parse (section tables, data directories,
overlay offsets, signature/marker counts — stdlib only), UTF-16 version-resource
read. Full findings: `STATIC_SURVEY_2026-10-11.md`.
No installer was run (all are Windows PE32; this host is Linux, Wine absent).
No payload was extracted or copied. No debugger/disassembler/decompiler was run.
