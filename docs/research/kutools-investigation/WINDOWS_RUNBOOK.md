# Windows runbook — deep inspection host

For the Windows machine (desktop Word + Visual Studio present). Perform steps
in order; stop at any gate that fails and record the outcome.

## 0. Prerequisites

- [ ] Owner confirmed licence + EULA position (`AUTHORISATION.md` checklist).
- [ ] Primary binary selected (default candidate: `wordkutools latest v17.exe`).
- [ ] Isolated host or VM snapshot available (installer will be RUN for
      black-box observation; keep a clean rollback point).
- [ ] Quarantine dir created: `../WordTulKit-investigation/` with `binaries/`, `raw/`.

## 1. Verify provenance (on the Windows host, before anything else)

```powershell
Get-FileHash .\wordkutools*.exe -Algorithm SHA256
# Must match the SHA-256 values in AUTHORISATION.md. Mismatch => STOP.
```

## 2. Stage quarantine copies (never work on the originals)

Copy the selected installer(s) into `../WordTulKit-investigation/binaries/`.
Confirm the copies re-hash identically.

## 3. Identify the payload WITHOUT running it

- Inno Setup builds (`wordkutools.exe`, `wordkutools v8.2.exe`): list with
  `innoextract -l <file>` (pin the tool version; record it). Extraction to
  `raw/<binary-name>/` only after the licence gate passes.
- v17 build (`wordkutools latest v17.exe`, non-Inno): identify the packer
  (strings / PE-section review, read-only), then decide: extract if a
  list-only method exists, else proceed to step 4 and treat installed-file
  inspection as the fallback.

## 4. Black-box behaviour capture (preferred evidence — weigh heaviest)

1. Snapshot the VM. Install into the isolated host.
2. For each v1.0-scope feature, record per `FEATURE_SPEC_TEMPLATE.md`: fixture
   in, options chosen, observable out, preservation checks. Drive Word with
   synthetic `.docx` fixtures only — never real client documents.
3. Note exact Kutools/Word version strings from Help/About dialogs.

## 5. Static inspection (secondary evidence — supports, never leads)

- Disassemble/decompile (ILSpy / dnSpy / `ilspycmd` — pin versions, record
  commands) into `raw/` ONLY, to resolve behavioural ambiguities found in
  step 4 (e.g. marker-matching rules, ordering guarantees, failure paths).
- Translate each answer into behavioural wording in the feature's
  `IMPLEMENTATION_ASSESSMENT.md` the same day. Raw listings are never quoted
  into `docs/` beyond short factual identifiers strictly needed for
  reproducibility (file name + version + hash).

## 6. Per-feature close-out

In `docs/research/kutools-investigation/<feature>/`:

- `FEATURE_SPEC.md` (from template) — coordinator-approved before any
  implementation task references it.
- `IMPLEMENTATION_ASSESSMENT.md` — observed behaviour, verified defects (with
  evidence), hypotheses (labelled), performance notes, limitations, and the
  independent design proposal naming only documented Word APIs.

## Stop conditions

- Hash mismatch, licence/EULA answer negative, or host without rollback.
- Any step that would commit, transmit, or embed proprietary material.
- Pressure to "just port it" — porting is forbidden; re-specify behaviourally.
