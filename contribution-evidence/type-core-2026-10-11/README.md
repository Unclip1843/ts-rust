# Three independent checker cleanup proposals

These proposals target upstream `bf34f21ae40b221ea9def389778d2f90ec950398`. Each is independently applied to that parent. Their Rust changes exclude intersection pruning and the scoped comparison cache. The PRs are drafts pending validation of each exact head against the latest accepted revision.

## Current submissions

| Patch | Rust scope | Current validation |
| --- | --- | --- |
| 1-owned-insertion | +14 / -6 lines, four owned-vector callers plus helper | Patch applies; rustfmt 1.93.0 passes; independent static review |
| 2-declaration-storage | +5 / -6 lines, retained list and temporary set sizing | Patch applies; rustfmt 1.93.0 passes; independent static review; declaration-storage Lean model checked |
| 3-shared-slice | +5 lines after the equal-length check | Patch applies; rustfmt 1.93.0 passes; independent static review; identity-trace Lean theorem checked |

No independent-head Cargo build, runtime test, official regression comparison or performance run is claimed. Submission is not merge acceptance. The upstream light path requires focused tests, protected goport comparison without lost passes, and byte-equal output on Query, Hono, zod and effect. Exact-head formatting/clippy/CI and appropriate performance comparison must be completed before requesting merge, following PR #31 and docs/typechecker-accountability.md. No runner, expectation, baseline, or upstream accepted state is modified by these submissions.

## Historical evidence

See [ERRATA.md](ERRATA.md) for a correction to the historical report's physical-source-file counts; the verified execution totals below are unchanged.

`historical-combined/qualification/report.json` records the earlier combined candidate, based on upstream `9f6ee6d147de1f8216c967e2a966cacbac295984`. That candidate also contained the now-excluded intersection traversal/pruning and comparison cache. `historical-combined/source.patch` reconstructs its four Rust files; the report binds their SHA-256 hashes and binary identities. These results support prior investigation, not acceptance of the independent heads:

- 133,390 passing compiler/conformance checks across 13,468 compiled configurations; 0 failed; 1,728 explicit skips (1,720 configuration and 8 output).
- Default baseline run: 1,529 passed, 2 failed, 1 ignored, 1 filtered. The two API-session tests passed on the same binary after shortening only TMPDIR's spelling to avoid the macOS Unix-socket path limit. Original failed results are retained. The filtered compiler suite ran in all four shards.
- 879 npm compatibility tests passed on both original and combined candidate, with no lost or absent names.
- Workspace: 629 passes retained, one unchanged ancestor-package.json watch failure, two ignored snapshot writers.
- Query diagnostics were empty on original, combined candidate, and pinned Go; Hono had the same two TS7031 diagnostics on all three under the local dependency setup. These were diagnostic checks, not the official four-project emit/diagnostic gate.
- Official Linux acceptance, saved LSP/API trace batteries and comparison against upstream's accepted result set were not completed.

The individual case results, skips and original failures are retained in gzip files. Artifact SHA-256 hashes and full independent verdicts are beside them. `historical-combined/report.json` and `measurements.json` retain the older performance observations, including every measurement. The approximately 19.4% runtime / 4% RSS combined-fixture result includes the excluded cache; none of the three submissions claims those gains or any independently measured speedup. The approximately 4% memory observation at an earlier stage also included pruning, so is not an isolated PR #2 result.

## Lean source and reproducibility

The optional proof files live in `proofs/`; Lean is not added to the compiler's build or CI.

```sh
cd proofs
lean UniqueDeclarationStorage.lean
lean SharedSliceIdentity.lean
```

`lean-toolchain` pins Lean 4.33.1. `verification.json` and the .log files record fresh kernel checks and axiom output. No `sorry` or project axiom is used.

- `UniqueDeclarationStorage.lean`: ordered unique collection and a capacity bound for an abstract doubling buffer. The retained-buffer model does not model the allocator or temporary hash table; the Rust test `declaration_set_grows_past_its_hint` already exercises hint 0, repeated nodes, growth and nil nodes.
- `SharedSliceIdentity.lean`: equal-element identity comparisons preserve results and state. Rust's equal-length shared-slice pointer check establishes identical TypeId elements by inspection; the old loop already skips equal TypeIds. This theorem has no cache dependency.
- The owned-vector patch uses the existing search once with the same input and inserts at its returned index. Its correctness argument is included in the PR description; no dedicated Lean proof is claimed.

The earlier cache/pruning proofs are not proposed as dependencies of these three PRs. Relevant Lean source is supplied as supporting evidence, not whole-program formal verification.
