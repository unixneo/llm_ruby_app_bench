# Zenodo Release Checklist

This checklist prepares the repository for a Zenodo GitHub release archive.

Release version: `v0.1.0`

## Archive Metadata

- `CITATION.cff` provides GitHub and citation metadata.
- `.zenodo.json` provides Zenodo deposit metadata.
- `LICENSE` is MIT.
- Repository URL: https://github.com/unixneo/llm_ruby_app_bench
- Release version: `v0.1.0`

## Current Artifact Scope

- Prompts completed: P0001-P0022
- Results completed: R0001-R0022
- Algorithms implemented:
  - TSP: brute force, nearest neighbor, Held-Karp, OR-Tools reference
  - VRP: Clarke-Wright Savings, OR-Tools CVRP reference
  - Assignment: Hungarian algorithm, OR-Tools LinearSumAssignment reference
  - Max Flow: Edmonds-Karp, OR-Tools SimpleMaxFlow reference
- Error ledgers:
  - Claude/Architect: CLE0001-CLE0012
  - Codex/Coder: CE0001-CE0010
- Correction ledger: C001-C008

## Pre-Release Verification

Run these from the repository root with plain project commands:

```bash
ruby scripts/verify_solver_architecture.rb
SKIP_HELD_KARP=1 bin/rails test
bin/rails test
git status --short
```

Expected current verification baseline from R0022:

```text
80 runs, 547 assertions, 0 failures, 0 errors, 13 skips
80 runs, 781 assertions, 0 failures, 0 errors, 0 skips
```

## Archive Boundary Check

Zenodo archives the GitHub release contents, not local ignored files. Before tagging:

- Confirm no credentials are tracked.
- Confirm `/config/master.key` is ignored.
- Confirm `.bundle/` and `vendor/bundle/` are ignored.
- Confirm logs, temporary files, and runtime storage are ignored.
- Confirm `README.md` and `DOCUMENTS/ABSTRACT.md` reflect the current prompt/result state.

## Release Steps

1. Review the clean working tree and metadata.
2. Create release tag `v0.1.0`.
3. Create a GitHub release from that tag.
4. Let Zenodo archive the GitHub release.
5. After Zenodo mints the DOI, update `CITATION.cff`, `.zenodo.json`, and `README.md` with the DOI in a follow-up commit if required.
