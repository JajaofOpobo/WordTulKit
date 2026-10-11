# Static survey 2026-10-11 — installer identification (Linux, list-only)

All probes read-only. Nothing executed, extracted, copied, or modified.
Tools: `file`, `sha256sum`, `7z l`, bounded `strings`, read-only PE/overlay
parser (stdlib `struct`/`re` only). No decompiler, no extractor installed or run.

## Result table (facts)

| # | File | Size (B) | SHA-256 | File/Product version | Installer tech | Signed | Payload |
|---|---|---|---|---|---|---|---|
| A | `wordkutools.exe` | 20,776,120 | `abfc57bc46b2929d0a77aa9cca820deea50edc27b7287d2cfe6bce818b93ed2e` | **8.7.0.1** / Kutools for Word | Inno Setup | Yes (Cert dir, 13,064 B) | Opaque overlay 20,719,288 B @0xde00 |
| B | `wordkutools latest v17.exe` | 49,415,968 | `7218d64364b26df9b27b63d39e9959fcecb05185827ea4551bc14a24ab21625b` | **16.20.00** / Kutools for Word (`WordKutools.exe`, ©2025 ExtendOffice.com) | Advanced Installer 16.5 bootstrapper | Yes (Cert dir, 11,336 B) | Overlay 46,978,848 B @0x253000; embedded **7z @0x27e0a8** (`KutoolsPerUser.7z`, `WordKutools.ini`) |
| C | `wordkutools v8.2.exe` | 17,696,304 | `6a926ea01704450fb46c7c07716ae8ba4d00ae6240054e9ee52c2f1d337ba730` | **8.2.119.0** / Kutools for Word | Inno Setup | Yes (Cert dir, 6,056 B) | Opaque overlay 17,639,472 B @0xde00 |

## Structural notes (observed)

- A and C share an identical 8-section Inno stub layout
  (`CODE/DATA/BSS/.idata/.tls/.rdata/.reloc/.rsrc`, Linker 2.25) and near-
  identical early-overlay byte patterns — consistent with the same Inno stub
  generation (inference, not verified).
- B's stub is MSVC 14.23 with `.text/.rdata/.data/.rsrc/.reloc`, a Debug
  directory, and `Advanced Installer` + Caphyon `Decoder.dll` markers. The
  earlier `UPX` byte hit sits in compressed-data context (noise, not a packer
  indicator). Resource strings reference `ExtendOffice.com\Kutools for Word
  16.20.00\install`, a `prerequisites` dir, and .NET 4.6.2 (prerequisite
  check context — NOT evidence the add-in itself is managed).
- Filename-vs-version mismatch (observed): file B is named "v17" but reports
  16.20.00. Always cite file version + hash, never the filename, as identity.
- Overlay scans found no MSI (`D0CF11E0`) or CAB (`MSCF`) signatures and no
  visible `.NET` runtime markers in any payload — payloads are compressed/
  opaque until proper extraction (inference: Inno LZMA; B's 7z is listable).
- All are PE32/x86 GUI executables. No `.NET` CLR directory in any stub
  (expected — stubs are native; payload contents unknown).

## NOT established (do not assume)

Payload file lists, managed-vs-native add-in composition, feature/command
inventory, marker-matching logic, EULA text contents, download provenance of
the three files (owner-supplied; chain-of-custody before 2026-10-11 unknown).

## Next extraction steps (Windows host, per WINDOWS_RUNBOOK.md)

1. Re-verify hashes above on the host; mismatch => STOP.
2. B: `7z l` the embedded archive at 0x27e0a8 (list-only), then extract to
   quarantine `raw/B-16.20.00/` after licence gate (already owner-confirmed).
3. A/C: `innoextract -l` then extract to `raw/A-8.7.0.1/`, `raw/C-8.2.119.0/`.
4. Diff installed-file sets across versions; record version deltas in each
   feature's `IMPLEMENTATION_ASSESSMENT.md`.
