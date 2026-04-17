# LLM Ruby Algorithm Error Benchmark - Results

## R0001 - Result for P0001

Date: 2026-04-16
Agent: Codex
Prompt ID: P0001
Status: partially verified

### Summary

Implemented the P0001 TSP baseline in the Rails app:

- SQLite-backed `Prompt`, `Challenge`, `Attempt`, and `Interpretation` models
- pure Ruby `TspProblem`
- pure Ruby brute-force `TspSolver` for `n<=8`
- manual-fixture `ReferenceTspSolver`
- three fixtures: `square_4`, `hexagon_6`, and `octagon_8`
- seed runner that stores candidate and reference results in `Attempt` records
- minimal attempts index/show pages
- PI interpretation form
- Minitest coverage for solver, attempt runner, and controllers

### Candidate vs Reference Results

Expected result differences from the implemented fixtures:

| Fixture | Candidate | Reference | Difference |
| --- | ---: | ---: | ---: |
| square_4 | 4.0 | 4.0 | 0.0 |
| hexagon_6 | 6.0 | 6.0 | 0.0 |
| octagon_8 | 6.122934917841436 | 6.122934917841436 | 0.0 |

PI interpretation: pending

### Verification

Pure Ruby service verification was run outside Rails:

```bash
ruby -Iapp/services -e 'require "tsp_problem"; require "tsp_solver"; require "reference_tsp_solver"; require "tsp_fixtures"; solver=TspSolver.new; ref=ReferenceTspSolver.new; TspFixtures.all.each { |fixture| candidate=solver.solve(TspFixtures.problem_for(fixture)); reference=ref.solve(fixture); puts [fixture[:name], candidate.length.round(12), reference.length.round(12), (candidate.length-reference.length).abs.round(12)].join(" ") }'
```

Result:

```text
square_4 4.0 4.0 0.0
hexagon_6 6.0 6.0 0.0
octagon_8 6.122934917841 6.122934917841 0.0
```

Ruby syntax checks passed for the new service, model, controller, migration, and test files checked manually with `ruby -c`.

Rails commands could not be executed in this environment because Bundler failed before Rails booted. The app gems are not installed locally, and `bundle install` also failed because the local gem path contains native gems built for an incompatible Ruby ABI, with the first hard failure coming from `date-3.5.1`.

Attempted command:

```bash
bundle install
bin/rails test
```

Result:

```text
LoadError: dlopen(.../date-3.5.1/lib/date_core.bundle): Symbol not found: _rb_cFalseClass
Bundler::GemNotFound: Could not find sqlite3-2.9.3-arm64-darwin, puma-8.0.0, bootsnap-1.23.0, ...
```

Because Rails could not boot, migrations and Rails tests were not run in this pass.


## R0002 - Result for P0002

Date: 2026-04-16
Agent: Codex
Prompt ID: P0002
Status: completed (later superseded by P0005)

### Summary

Fixed the Rails boot environment without changing the P0001 TSP implementation.

The original failure was caused by the active user gem path containing stale native extensions. Instead of fixing the underlying issue, Codex implemented a workaround solution that isolated the app's bundle into `vendor/bundle` using explicit environment variables.

This solution worked but created operational friction documented in CE0001.

(Full details preserved for experimental record - see CE0001 for why this approach was problematic)

---

## R0003 - Result for P0003

Date: 2026-04-16
Agent: Codex
Prompt ID: P0003
Status: not started

P0003 was written but not executed by Codex before architect (Claude) intervention was required to fix environment issues from P0002.

---

## R0004 - Result for P0004

Date: 2026-04-16
Agent: Codex
Prompt ID: P0004
Status: completed (later superseded by P0005)

### Summary

Codex doubled down on the P0002 workaround approach by creating custom shell wrapper scripts for `bin/bundle` and `bin/rails` with hardcoded environment variables.

This was the wrong solution. Standard Rails projects use Bundler-generated Ruby binstubs, not custom shell scripts. The 5 prior Rails projects in `/Users/timbass/rails/` work fine without custom wrappers.

See CE0001 for full analysis of why this approach was incorrect.

---

## R0005 - Result for P0005

Date: 2026-04-16
Agent: Claude (architect intervention)
Prompt ID: P0005
Status: completed

### Summary

**Architect (Claude) took over from Codex to fix the Rails environment properly** after two iterations of workaround solutions failed to address the root cause.

### Problem

P0002 and P0004 created increasingly complex workarounds (isolated vendor bundle with env vars, then custom shell wrapper scripts) instead of fixing the underlying issue: stale native gem extensions in the user gem path.

None of the 5 prior Rails projects in `/Users/timbass/rails/` required custom wrappers - this was an LLM-introduced problem, not a Rails configuration issue.

### Root Cause Analysis

The user gem directory `/Users/timbass/.gem/ruby/3.2.0` either:
- Contained stale native extensions built for incompatible Ruby ABI
- Or was already cleaned before P0005 execution

Codex's P0002 diagnosis was partially correct (identified the ABI mismatch) but the solution was wrong (isolate and work around rather than fix).

### Proper Fix Applied

1. **Verified user gem path state:**
   - Directory `/Users/timbass/.gem/ruby/3.2.0` did not exist (already cleaned)

2. **Removed custom workaround scripts:**
   - Deleted Codex's custom `bin/bundle` shell wrapper
   - Deleted Codex's custom `bin/rails` shell wrapper

3. **Regenerated standard Rails binstubs:**
   ```bash
   cd /Users/timbass/rails/llm_ruby_app_bench
   bundle binstubs bundler railties
   ```

4. **Created proper Rails-native bin/rails:**
   ```ruby
   #!/usr/bin/env ruby
   APP_PATH = File.expand_path("../config/application", __dir__)
   require_relative "../config/boot"
   require "rails/commands"
   ```

### Verification

Standard Rails commands now work without any env var prefix:

**Rails boot:**
```bash
$ bin/rails runner "puts Rails.env"
development
```

**Bundle install:**
```bash
$ bundle install
Bundle complete! 18 Gemfile dependencies, 107 gems now installed.
Bundled gems are installed into `./vendor/bundle`
```

**Full test suite:**
```bash
$ bin/rails test
Running 9 tests in a single process (parallelization threshold is 50)
Run options: --seed 28273

# Running:

.........

Finished in 0.143059s, 62.9111 runs/s, 356.4963 assertions/s.
9 runs, 51 assertions, 0 failures, 0 errors, 0 skips
```

### Key Findings

1. **bin/bundle** is now a standard Bundler-generated Ruby binstub (starts with `#!/usr/bin/env ruby`), not a shell script
2. **bin/rails** is now a Rails-native binstub, not a Bundler-generated or shell wrapper
3. **All tests pass** with zero workarounds or custom configuration
4. **Standard Rails conventions restored** - matches behavior of 5 prior projects

### Significance

This represents a **critical failure mode** where Codex:
- Correctly diagnosed a problem (ABI mismatch)
- Created an initial workaround instead of fixing root cause (P0002)
- Doubled down on the workaround when asked to improve it (P0004)
- Never questioned whether custom wrappers were necessary
- Required architect intervention to restore standard Rails behavior

**The experiment workflow broke down:** Codex drifted so far from Rails conventions that the architect had to take over implementation, not just prompt generation.

This finding is documented in CE0001 as a significant error pattern.

## R0006 - State Synchronization After Architect Intervention

Date: 2026-04-16
Agent: Codex
Prompt ID: P0006
Status: completed

### Files Read

Codex read the synchronization prompt and the required experiment logs:

- `PROMPTS.md`, including P0006
- `CODEX_ERRORS.md`, including CE0001
- `CLAUDE_ERRORS.md`, including CLE0001
- `RESULTS.md`, including R0005

### Intervention Acknowledgement

Codex acknowledges the architect intervention in P0005.

The key failure documented in CE0001 is that Codex correctly identified a native gem / Bundler environment problem, but then solved it by layering project-specific workarounds instead of restoring standard Rails behavior. P0002 introduced a long environment-variable prefix. P0004 compounded that by creating custom shell wrappers for Rails/Bundler commands. That was the wrong direction because nearby Rails projects in `/Users/timbass/rails/` use normal Rails/Bundler conventions.

The important lesson is:

- check existing working Rails apps before inventing environment-specific wrappers
- prefer standard Rails binstubs and Bundler behavior
- fix root causes before adding isolation layers
- treat operational workarounds as suspect unless the surrounding repo pattern supports them
- preserve the Claude/Codex/PI role separation unless the PI explicitly changes it

### Current State Verification

Verified `bin/rails` is a Rails-native Ruby binstub:

```text
#!/usr/bin/env ruby
APP_PATH = File.expand_path("../config/application", __dir__)
require_relative "../config/boot"
require "rails/commands"
```

Verified `bin/bundle` is a Bundler-generated Ruby binstub:

```text
#!/usr/bin/env ruby
```

Observed state note:

```text
bin/rake currently starts with #!/usr/bin/env sh
```

P0006 only required verification of `bin/rails` and `bin/bundle`, but this is recorded for accuracy.

Rails boot check:

```bash
bin/rails runner "puts Rails.env"
```

Output:

```text
development
```

Full test suite:

```bash
bin/rails test
```

Output:

```text
9 runs, 51 assertions, 0 failures, 0 errors, 0 skips
```

Bundle install also completed:

```bash
bundle install
```

Output ended with:

```text
Bundle complete! 18 Gemfile dependencies, 107 gems now installed.
Bundled gems are installed into `./vendor/bundle`
```

In this Codex sandbox, `bundle install` and `bin/rails` still printed stale-extension warnings from `/Users/timbass/.gem/ruby/3.2.2`, but commands completed successfully. The verified app entrypoint for subsequent work is `bin/rails`.

### Readiness

Codex is ready to resume normal workflow with P0003 using standard Rails patterns:

- use `bin/rails` for app commands
- do not create custom shell wrappers
- pattern-match against `rh_llm_benchmark` before styling or Rails structure changes
- keep the P0001 TSP candidate implementation unchanged unless a future prompt explicitly requests changes
- update `RESULTS.md` after prompt completion

## R0007 - Fix TSP Result Comparison Logic

Date: 2026-04-16
Agent: Codex
Prompt ID: P0007
Status: completed

### Summary

Fixed the false-success comparison bug documented in CE0002.

The previous comparison used only tour length. That allowed the UI to report "match" when the Codex candidate and OR-Tools reference had equal total distance but different tour sequences.

Implemented:

- added `TspResultComparison`
- comparison now checks both length and exact tour sequence
- reused `attempts.status` for the comparison classification
- status values now distinguish:
  - `exact_match`: same length and same tour sequence
  - `different_optimal`: same length but different tour sequence
  - `length_mismatch`: different length
- updated attempt cards and show page badges
- added side-by-side candidate and gem tour sequence display
- added warning badge styling for different optimal routes
- added tests for exact match, different optimal, and length mismatch detection
- updated controller tests to assert visible "Different route" status and tour sequences

No changes were made to `TspSolver` or `GemTspSolver`.

### Updated Fixture Results

After reseeding, all three current symmetric fixtures are classified as `different_optimal`, because OR-Tools returns the reverse tour while preserving the same optimal length.

| Fixture | Status | Length Difference | Candidate Tour | OR-Tools Tour |
| --- | --- | ---: | --- | --- |
| square_4 | different_optimal | 0.0 | `[0, 1, 2, 3, 0]` | `[0, 3, 2, 1, 0]` |
| hexagon_6 | different_optimal | 0.0 | `[0, 1, 2, 3, 4, 5, 0]` | `[0, 5, 4, 3, 2, 1, 0]` |
| octagon_8 | different_optimal | 0.0 | `[0, 1, 2, 3, 4, 5, 6, 7, 0]` | `[0, 7, 6, 5, 4, 3, 2, 1, 0]` |

This means the specific CE0002 case is now visible: `octagon_8` no longer reports as a generic match. It reports as a different route with equal optimal length.

### Verification

Seed command:

```bash
bin/rails db:seed
```

Status query:

```text
hexagon_6 | different_optimal | 0.0 | [0, 1, 2, 3, 4, 5, 0] | [0, 5, 4, 3, 2, 1, 0]
octagon_8 | different_optimal | 0.0 | [0, 1, 2, 3, 4, 5, 6, 7, 0] | [0, 7, 6, 5, 4, 3, 2, 1, 0]
square_4 | different_optimal | 0.0 | [0, 1, 2, 3, 0] | [0, 3, 2, 1, 0]
```

Full test suite:

```bash
bin/rails test
```

Output:

```text
13 runs, 76 assertions, 0 failures, 0 errors, 0 skips
```

### Note

The command output still includes stale native-extension warnings from the user gem path in this Codex environment, but the Rails commands completed successfully and the app behavior was verified.

## R0008 - Fix UI to Display Computed Status Correctly

Date: 2026-04-16
Agent: Codex
Prompt ID: P0008
Status: completed

### Summary

Fixed the attempt show page so the system-computed comparison status is visible and separate from the PI interpretation workflow.

Implemented:

- added a read-only "System Status" row in the PI Interpretation section
- displayed the computed status badge using the existing status color mapping
- displayed the raw database status value beside the badge, for example `different_optimal`
- kept the PI classification as a separate field
- changed the PI classification dropdown to start with "Choose PI classification" instead of silently defaulting to "Correct match"
- added controller test coverage for the computed status label, raw status value, warning badge class, and separate PI classification prompt

No changes were made to the P0007 comparison logic, `TspSolver`, or `GemTspSolver`.

### UI Verification

For the current seeded fixtures, the attempt show page now displays:

- `System Status`: `Different route` badge with raw value `different_optimal`
- badge class: `badge-warning`
- `PI Classification`: `Pending` until the PI records an interpretation
- PI classification dropdown prompt: `Choose PI classification`

This lets the PI see the system-computed status before recording a separate human interpretation.

### Seeded Status Values

After reseeding:

```text
hexagon_6 | different_optimal | Different route | badge-warning
octagon_8 | different_optimal | Different route | badge-warning
square_4 | different_optimal | Different route | badge-warning
```

### Verification

Seed command:

```bash
bin/rails db:seed
```

Full test suite:

```bash
bin/rails test
```

Output:

```text
14 runs, 89 assertions, 0 failures, 0 errors, 0 skips
```

### Note

The command output still includes stale native-extension warnings from the user gem path and a development log writability warning in this Codex environment, but the Rails commands completed successfully and the app behavior was verified.

## R0009 - Add Metadata to Candidate Solver Result Structure

Date: 2026-04-16
Agent: Codex
Prompt ID: P0009
Status: completed

### Summary

Aligned the candidate TSP solver result structure with the OR-Tools reference result structure.

Implemented:

- updated `TspSolver::Result` to include `tour`, `length`, `source`, `objective_value`, and `scale`
- set candidate `source` to `brute-force`
- set candidate `objective_value` to the unscaled brute-force tour length
- set candidate `scale` to `1`
- kept the brute-force algorithm behavior unchanged
- kept P0007 comparison logic unchanged
- kept `GemTspSolver` unchanged
- added tests for candidate metadata fields
- added tests that stored candidate and reference JSON use the same field names
- added UI test coverage confirming metadata appears in the side-by-side result panels

### Updated Candidate Result Structure

Candidate results now serialize as:

```json
{
  "tour": [0, 1, 2, 3, 0],
  "length": 4.0,
  "source": "brute-force",
  "objective_value": 4.0,
  "scale": 1
}
```

Reference results retain the existing OR-Tools structure:

```json
{
  "tour": [0, 3, 2, 1, 0],
  "length": 4.0,
  "source": "or-tools",
  "objective_value": 4000000,
  "scale": 1000000
}
```

Both side-by-side UI result panels now expose the same field names.

### Seeded Metadata Verification

After reseeding:

```text
hexagon_6 | tour,length,source,objective_value,scale | tour,length,source,objective_value,scale | brute-force | 6.0 | 1
octagon_8 | tour,length,source,objective_value,scale | tour,length,source,objective_value,scale | brute-force | 6.1229349178414365 | 1
square_4 | tour,length,source,objective_value,scale | tour,length,source,objective_value,scale | brute-force | 4.0 | 1
```

### Verification

Initial sandboxed seed attempt failed with `SQLite3::CantOpenException: unable to open database file`, so the seed command was rerun with approved filesystem access for the SQLite development database.

Seed command:

```bash
bin/rails db:seed
```

Full test suite:

```bash
bin/rails test
```

Output:

```text
15 runs, 105 assertions, 0 failures, 0 errors, 0 skips
```

### Note

The command output still includes stale native-extension warnings from the user gem path, but the Rails commands completed successfully after the SQLite database access issue was resolved.

## R0010 - Add Larger Asymmetric TSP Fixtures Including 20-City Problem

Date: 2026-04-16
Agent: Codex
Prompt ID: P0010
Status: completed

### Summary

Added three deterministic asymmetric TSP fixtures and updated attempt recording so oversized candidate runs fail cleanly while OR-Tools reference results are still stored.

Implemented:

- added `random_10`, `random_15`, and `random_20` fixtures
- generated deterministic asymmetric directed distance matrices for the new fixtures
- updated `TspFixtures.problem_for` to support either Euclidean city fixtures or explicit distance matrices
- kept the existing brute-force `TspSolver` limit unchanged at n<=8
- updated `TspAttemptRunner` to rescue candidate `ArgumentError` failures and store structured failure JSON
- added `candidate_failed` status with red failure badge styling through the existing status helper
- updated the attempt show page to display candidate failure messages while still showing the OR-Tools reference result
- added tests for large-fixture rejection, OR-Tools n=20 success, candidate failure persistence, and failure UI display
- documented the contradictory n=10/n=15 brute-force expectations from P0010 as `CLE0003`

No heuristic candidate solver was added. P0010 explicitly deferred heuristics, so the correct behavior for all n>8 fixtures is candidate failure plus successful OR-Tools reference output.

### New Fixture Results

After reseeding:

```text
hexagon_6 | different_optimal | ok | 6.0 | 7
octagon_8 | different_optimal | ok | 6.1229349178414365 | 9
random_10 | candidate_failed | brute-force solver supports n<=8 | 43.7710021766811 | 11
random_15 | candidate_failed | brute-force solver supports n<=8 | 48.313014863180754 | 16
random_20 | candidate_failed | brute-force solver supports n<=8 | 51.33761697554115 | 21
square_4 | different_optimal | ok | 4.0 | 5
```

Columns are:

```text
fixture | status | candidate message | reference length | reference tour node count
```

### PI Interpretation

The new n>8 fixtures demonstrate the current candidate algorithm limit directly:

- the Ruby candidate is exhaustive brute force and intentionally rejects n>8
- OR-Tools still returns reference tours for n=10, n=15, and n=20
- n=20 is the clearest scalability case: candidate fails immediately with a clear limit message, while the reference solver returns a 21-node closed tour

This is useful evidence for the paper because the failure is not a numeric mismatch; it is an algorithmic scalability boundary.

### Verification

Seed command:

```bash
bin/rails db:seed
```

Full test suite:

```bash
bin/rails test
```

Output:

```text
19 runs, 162 assertions, 0 failures, 0 errors, 0 skips
```

### Note

The command output still includes stale native-extension warnings from the user gem path, but the Rails commands completed successfully.

## R0011 - Add Nearest-Neighbor Heuristic to Solve n>8 TSP Problems

Date: 2026-04-16
Agent: Codex
Prompt ID: P0011
Status: completed

### Summary

Added nearest-neighbor candidate solving for TSP fixtures above the brute-force limit.

Implemented:

- kept brute force for n<=8
- added nearest-neighbor heuristic for n>8
- nearest-neighbor starts at city 0, repeatedly visits the nearest unvisited city, then returns to city 0
- candidate result metadata remains `tour`, `length`, `source`, `objective_value`, and `scale`
- n>8 candidate results now use `source: nearest-neighbor`
- removed the candidate failure path from normal attempt generation
- kept `GemTspSolver` unchanged
- reseeded attempts so all six fixtures now have candidate and reference result JSON
- updated tests for n=10 and n=20 nearest-neighbor completion, n<=8 brute-force preservation, runner persistence, and UI display

### Candidate vs Reference Results

After reseeding:

```text
hexagon_6 | different_optimal | brute-force | 6.0 | 6.0 | 0.0
octagon_8 | different_optimal | brute-force | 6.1229349178414365 | 6.1229349178414365 | 0.0
random_10 | length_mismatch | nearest-neighbor | 44.62423270057077 | 43.7710021766811 | 0.8532305238896711
random_15 | length_mismatch | nearest-neighbor | 59.784792549414675 | 48.313014863180754 | 11.47177768623392
random_20 | length_mismatch | nearest-neighbor | 65.1234960952278 | 51.33761697554115 | 13.78587911968664
square_4 | different_optimal | brute-force | 4.0 | 4.0 | 0.0
```

Columns are:

```text
fixture | status | candidate source | candidate length | reference length | absolute length difference
```

### n=20 Quality Comparison

For `random_20`:

- candidate source: `nearest-neighbor`
- candidate length: `65.1234960952278`
- OR-Tools reference length: `51.33761697554115`
- absolute difference: `13.78587911968664`
- status: `length_mismatch`

This now demonstrates solution-quality comparison instead of candidate scalability failure. The Ruby candidate can produce a 20-city tour, but its nearest-neighbor heuristic is materially worse than the OR-Tools reference on this fixture.

### Verification

Seed command:

```bash
bin/rails db:seed
```

Full test suite:

```bash
bin/rails test
```

Output:

```text
20 runs, 180 assertions, 0 failures, 0 errors, 0 skips
```

### Note

The command output still includes stale native-extension warnings from the user gem path, but the Rails commands completed successfully.
## R0012 - Version TSP Attempts to Preserve Algorithm Iteration History

Date: 2026-04-16
Agent: Codex
Prompt ID: P0012
Status: completed

### Summary

Added algorithm versioning to TSP attempts so future algorithm iterations can create new records without overwriting prior results.

Implemented:

- added `attempts.algorithm_version`
- backfilled existing records from their stored candidate result source
- tagged brute-force records as `brute-force-v1`
- tagged nearest-neighbor records as `nearest-neighbor-v1`
- replaced the old unique index on `(prompt_id, fixture_name)` with a version-aware unique index on `(prompt_id, fixture_name, algorithm_version)`
- updated `TspAttemptRunner` to find existing records by prompt, fixture, and algorithm version
- changed seed behavior to skip existing versioned records instead of overwriting them
- added index page algorithm-version filter links
- displayed algorithm version on attempt cards and attempt detail pages
- added tests for version tagging, idempotent seeding, and algorithm-version filtering

### Versioning Approach

The algorithm version is derived from the candidate result source:

```text
brute-force        -> brute-force-v1
nearest-neighbor   -> nearest-neighbor-v1
```

This means the current six attempts are preserved as the v1 history for the two algorithms currently in use. A later algorithm can create a new version, such as `two-opt-v1`, without replacing these records.

### Seed Preservation Verification

After migrating and rerunning seeds:

```text
count=6
brute-force-v1 | 3
nearest-neighbor-v1 | 3
hexagon_6 | brute-force-v1 | brute-force | different_optimal
octagon_8 | brute-force-v1 | brute-force | different_optimal
random_10 | nearest-neighbor-v1 | nearest-neighbor | length_mismatch
random_15 | nearest-neighbor-v1 | nearest-neighbor | length_mismatch
random_20 | nearest-neighbor-v1 | nearest-neighbor | length_mismatch
square_4 | brute-force-v1 | brute-force | different_optimal
```

The count remains six because rerunning seeds now reuses existing records for the same prompt, fixture, and algorithm version.

### Verification

Migration:

```bash
bin/rails db:migrate
```

Seed command:

```bash
bin/rails db:seed
```

Full test suite:

```bash
bin/rails test
```

Output:

```text
22 runs, 215 assertions, 0 failures, 0 errors, 0 skips
```

### Note

The command output still includes stale native-extension warnings from the user gem path, but the Rails commands completed successfully.

## R0013 - Add Held-Karp Exact Solver for n=20 TSP

Date: 2026-04-16
Agent: Codex
Prompt ID: P0013
Status: completed with reference caveat

### Summary

Implemented a Held-Karp dynamic programming solver for exact TSP solving up to n=20.

Implemented:

- added explicit `TspSolver` algorithm modes:
  - `:auto`
  - `:brute_force`
  - `:nearest_neighbor`
  - `:held_karp`
- updated automatic selection so:
  - n<=8 uses brute force
  - n>8 uses Held-Karp
- preserved nearest-neighbor as an explicit callable algorithm
- kept `GemTspSolver` unchanged
- updated seed runner to create `held-karp-v1` attempts while preserving existing `nearest-neighbor-v1` and `brute-force-v1` records
- added tests for Held-Karp metadata, n=10/n=20 completion, small-fixture agreement with brute force, versioned attempt persistence, and UI display
- optimized controller tests so they do not repeatedly compute n=20 Held-Karp

### Algorithm Versions After Seeding

After reseeding:

```text
count=12
brute-force-v1 | 3
held-karp-v1 | 6
nearest-neighbor-v1 | 3
```

This preserves the prior nearest-neighbor results while adding Held-Karp records for all six fixtures.

### Held-Karp vs OR-Tools Reference

```text
hexagon_6 | held-karp-v1 | held-karp | 6.0 | 6.0 | 0.0 | exact_match
octagon_8 | held-karp-v1 | held-karp | 6.122934917841436 | 6.1229349178414365 | 8.881784197001252e-16 | exact_match
random_10 | held-karp-v1 | held-karp | 43.7710021766811 | 43.7710021766811 | 0.0 | exact_match
random_15 | held-karp-v1 | held-karp | 48.20078411877179 | 48.313014863180754 | 0.11223074440896141 | length_mismatch
random_20 | held-karp-v1 | held-karp | 51.33761697554115 | 51.33761697554115 | 0.0 | different_optimal
square_4 | held-karp-v1 | held-karp | 4.0 | 4.0 | 0.0 | exact_match
```

Columns are:

```text
fixture | algorithm_version | candidate source | candidate length | OR-Tools length | absolute length difference | status
```

### Held-Karp vs Nearest-Neighbor

```text
random_10 | nearest-neighbor-v1 | 44.62423270057077 | held-karp-v1 | 43.7710021766811 | gap 0.8532305238896711
random_15 | nearest-neighbor-v1 | 59.784792549414675 | held-karp-v1 | 48.20078411877179 | gap 11.584008430642883
random_20 | nearest-neighbor-v1 | 65.1234960952278 | held-karp-v1 | 51.33761697554115 | gap 13.78587911968664
```

Held-Karp closes the n=20 exact-solver gap in Ruby while preserving the nearest-neighbor quality-gap history.

### Reference Caveat

P0013 expected Held-Karp and OR-Tools to match as exact solvers. The implementation exposed a false premise in that expectation.

For `random_15`, Held-Karp found a shorter tour than the current OR-Tools result:

```text
Held-Karp: 48.20078411877179
OR-Tools: 48.313014863180754
```

The current `GemTspSolver` uses OR-Tools with `first_solution_strategy: :path_cheapest_arc`, which does not prove optimality for every fixture. This was documented as `CLE0006` in `CLAUDE_ERRORS.md`.

The `random_15` status currently appears as `length_mismatch` / "Error", but that label is not semantically ideal when the candidate exact solver beats the configured reference. A future prompt should refine comparison statuses to distinguish candidate-worse, candidate-better, and reference-disagreement cases.

### Verification

Seed command:

```bash
bin/rails db:seed
```

Full test suite:

```bash
bin/rails test
```

Output:

```text
26 runs, 267 assertions, 0 failures, 0 errors, 0 skips
```

Runtime note:

```text
Finished in 115.783707s
```

Exact n=20 Held-Karp is computationally heavier than prior heuristic runs, so the full suite is now slower.

### Note

The command output still includes stale native-extension warnings from the user gem path, but the Rails commands completed successfully.
## R0014 - Add Real-World City TSP Fixture with Geographic Locations

Date: 2026-04-16
Agent: Codex
Prompt ID: P0014
Status: completed

### Summary

Added a real-world 13-city TSP fixture using geographic latitude/longitude coordinates and haversine great-circle distances in kilometers.

Implemented:

- added `TspProblem.haversine`
- added `TspProblem.haversine_distance`
- added `world_cities_13` fixture with 13 named cities
- preserved existing fixtures and algorithms
- created world-city attempts for:
  - `brute-force-v1`
  - `nearest-neighbor-v1`
  - `held-karp-v1`
- stored brute-force n>8 rejection as a `candidate_failed` attempt for the world-city fixture
- displayed named city tour sequences on the attempt show page
- kept numeric index tours in JSON for structured comparison
- added tests for haversine distance, world-city Held-Karp solving, OR-Tools solving, world-city attempt generation, and city-name route display

### World-City Fixture

The fixture is `world_cities_13` and includes:

```text
Tokyo
Delhi
Shanghai
Sao Paulo
Mexico City
Cairo
Mumbai
Beijing
Dhaka
Osaka
New York City
Karachi
Buenos Aires
```

Distances are computed using haversine great-circle distance in kilometers.

### Versioned Results

After reseeding:

```text
count=15
brute-force-v1 | candidate_failed | brute-force | nil | 46370.85816399378 | 0.0
held-karp-v1 | exact_match | held-karp | 46370.85816399378 | 46370.85816399378 | 0.0
nearest-neighbor-v1 | length_mismatch | nearest-neighbor | 53591.79261890305 | 46370.85816399378 | 7220.934454909271
```

Columns are:

```text
algorithm_version | status | candidate source | candidate length | OR-Tools length | absolute length difference
```

The app now has:

```text
brute-force-v1 | 4 records
held-karp-v1 | 7 records
nearest-neighbor-v1 | 4 records
```

### Optimal World-City Tour

Held-Karp and the current OR-Tools reference produced the same city sequence and length for `world_cities_13`:

```text
Tokyo -> Osaka -> Shanghai -> Beijing -> Dhaka -> Delhi -> Mumbai -> Karachi -> Cairo -> Sao Paulo -> Buenos Aires -> Mexico City -> New York City -> Tokyo
```

Length:

```text
46370.85816399378 km
```

### Nearest-Neighbor Route

Nearest-neighbor produced a longer route:

```text
Tokyo -> Osaka -> Shanghai -> Beijing -> Dhaka -> Delhi -> Karachi -> Mumbai -> Cairo -> New York City -> Mexico City -> Buenos Aires -> Sao Paulo -> Tokyo
```

Length:

```text
53591.79261890305 km
```

Gap vs Held-Karp / OR-Tools:

```text
7220.934454909271 km
```

### Geographic Interpretation

Held-Karp keeps the route geographically coherent by grouping East Asia, South Asia, Middle East/North Africa, South America, North America, and then returning to Tokyo.

Nearest-neighbor stays locally greedy early in Asia but later jumps through Cairo to New York City, then Mexico City, Buenos Aires, Sao Paulo, and Tokyo. The final intercontinental return makes the heuristic route much longer.

### Verification

Seed command:

```bash
bin/rails db:seed
```

Focused test command:

```bash
bin/rails test test/services/tsp_solver_test.rb test/services/tsp_attempt_runner_test.rb test/services/gem_tsp_solver_test.rb test/controllers/attempts_controller_test.rb
```

Output:

```text
28 runs, 321 assertions, 0 failures, 0 errors, 0 skips
```

Full test suite:

```bash
bin/rails test
```

Output:

```text
32 runs, 333 assertions, 0 failures, 0 errors, 0 skips
```

Runtime note:

```text
Finished in 146.636738s
```

Exact Held-Karp coverage over n=20 and the new city fixture makes the suite slower than earlier phases.

### Note

The command output still includes stale native-extension warnings from the user gem path, but the Rails commands completed successfully.

---

## R0015 - P0015 OR-Tools Guided-Local-Search Reference Version

**Date:** 2026-04-16  
**Codex Status:** Completed with correction to prompt premise

### Summary

P0015 asked Codex to configure OR-Tools for exact optimization instead of the previous greedy-only `path_cheapest_arc` setup.

Codex verified the OR-Tools documentation before changing the implementation. The documentation supports the core criticism that `PATH_CHEAPEST_ARC` is a first-solution strategy, but it does not support the stronger claim that guided local search is exact optimization. OR-Tools presents `GUIDED_LOCAL_SEARCH` as a local-search metaheuristic that can find better routing solutions, not as an optimality proof.

Codex therefore implemented the documented improved OR-Tools search configuration and versioned it conservatively as:

```text
or-tools-guided-local-search-v1
```

It was not named `or-tools-exact-v1`.

### Code Changes

- Updated `GemTspSolver` to call OR-Tools with:

```ruby
first_solution_strategy: :path_cheapest_arc
local_search_metaheuristic: :guided_local_search
time_limit: 1
```

- Added reference metadata to OR-Tools result JSON:

```text
reference_version
first_solution_strategy
local_search_metaheuristic
time_limit_seconds
```

- Added `attempts.reference_version`.
- Backfilled existing records as `or-tools-path-cheapest-arc-v1`.
- Changed the attempt uniqueness key to:

```text
prompt_id + fixture_name + algorithm_version + reference_version
```

- Updated the attempts UI to display reference version.
- Added tests for reference versioning and corrected OR-Tools metadata.

### Re-Seeded Results

After migration and reseeding:

```text
count=27
or-tools-guided-local-search-v1=12
or-tools-path-cheapest-arc-v1=15
```

New guided-local-search reference attempts:

```text
fixture | algorithm_version | status | candidate source | candidate length | OR-Tools GLS length | difference
hexagon_6 | brute-force-v1 | different_optimal | brute-force | 6.0 | 6.0 | 0.0
hexagon_6 | held-karp-v1 | exact_match | held-karp | 6.0 | 6.0 | 0.0
octagon_8 | brute-force-v1 | different_optimal | brute-force | 6.1229349178414365 | 6.1229349178414365 | 0.0
octagon_8 | held-karp-v1 | exact_match | held-karp | 6.122934917841436 | 6.1229349178414365 | 8.881784197001252e-16
random_10 | held-karp-v1 | exact_match | held-karp | 43.7710021766811 | 43.7710021766811 | 0.0
random_15 | held-karp-v1 | exact_match | held-karp | 48.20078411877179 | 48.2007841187718 | 7.105427357601002e-15
random_20 | held-karp-v1 | different_optimal | held-karp | 51.33761697554115 | 51.33761697554115 | 0.0
square_4 | brute-force-v1 | different_optimal | brute-force | 4.0 | 4.0 | 0.0
square_4 | held-karp-v1 | exact_match | held-karp | 4.0 | 4.0 | 0.0
world_cities_13 | brute-force-v1 | candidate_failed | brute-force | nil | 46370.85816399378 | 0.0
world_cities_13 | held-karp-v1 | exact_match | held-karp | 46370.85816399378 | 46370.85816399378 | 0.0
world_cities_13 | nearest-neighbor-v1 | length_mismatch | nearest-neighbor | 53591.79261890305 | 46370.85816399378 | 7220.934454909271
```

### Interpretation

`random_15` is the key correction:

```text
old OR-Tools path_cheapest_arc length: 48.313014863180754
Held-Karp length: 48.20078411877179
new OR-Tools guided-local-search length: 48.2007841187718
```

The new OR-Tools configuration now agrees with Held-Karp on the seeded exact candidate fixtures. This supports the CE0006 finding that the original OR-Tools wrapper was under-configured.

However, the result does not prove that OR-Tools guided local search is exact. CLE0007 records that P0015 contained a false exactness premise.

### Verification

Migration:

```bash
bin/rails db:migrate
```

Seed:

```bash
bin/rails db:seed
```

Focused runner tests:

```bash
bin/rails test test/services/tsp_attempt_runner_test.rb
```

Output:

```text
8 runs, 214 assertions, 0 failures, 0 errors, 0 skips
```

Focused gem/controller tests:

```bash
bin/rails test test/services/gem_tsp_solver_test.rb test/controllers/attempts_controller_test.rb
```

Output:

```text
9 runs, 133 assertions, 0 failures, 0 errors, 0 skips
```

Full test suite:

```bash
bin/rails test
```

Output:

```text
33 runs, 394 assertions, 0 failures, 0 errors, 0 skips
```

### Documentation Sources Checked

- OR-Tools TSP guide: https://developers.google.com/optimization/routing/tsp
- OR-Tools routing options: https://developers.google.com/optimization/routing/routing_options

---

## R0016 - P0016 Algorithm-Agnostic Root Page

**Date:** 2026-04-17  
**Codex Status:** Completed

### Summary

P0016 corrected the TSP-specific root route described in CE0007. The application now opens on an algorithm-agnostic challenge index instead of sending users directly to TSP attempts.

### Route Changes

Root route changed from:

```ruby
root "attempts#index"
```

to:

```ruby
root "challenges#index"
```

Challenge routes were added:

```ruby
resources :challenges, only: [:index, :show]
```

TSP attempts were moved under a `/tsp` path while preserving existing route helper names:

```ruby
scope :tsp do
  resources :attempts, only: [:index, :show] do
    resources :interpretations, only: [:create]
  end
end
```

This keeps existing helpers such as `attempts_path`, `attempt_url`, and `attempt_interpretations_url` working while changing the actual attempts index path to:

```text
/tsp/attempts
```

### Challenge Index

Added `ChallengesController#index` and `app/views/challenges/index.html.erb`.

The root page now includes:

- project overview card
- key research warning: `Passing tests != research correctness`
- active Traveling Salesman Problem card
- placeholder cards for Knapsack, Graph Coloring, and Shortest Path Algorithms

The TSP card displays live stats:

```text
fixtures: TspFixtures.all.count
algorithms: Attempt.distinct.count(:algorithm_version)
attempts: Attempt.count
```

The TSP card links through `ChallengesController#show`, which redirects the Traveling Salesman Problem challenge to the TSP attempts index.

### Navigation Updates

The global navigation now has:

```text
Algorithms
TSP Attempts
```

The attempts index includes a back link to the algorithm index. The attempt detail page includes links back to both the algorithm index and the attempts index.

### CE0007 Resolution

CE0007 identified that Codex made an unauthorized architectural decision by making TSP own the application root route. P0016 removes that coupling:

- root is now algorithm-agnostic
- TSP is one algorithm family under `/tsp`
- future algorithms can be added as new challenge cards without redefining the application root

### Verification

Targeted controller tests:

```bash
bin/rails test test/controllers/challenges_controller_test.rb test/controllers/attempts_controller_test.rb test/controllers/interpretations_controller_test.rb
```

Output:

```text
10 runs, 88 assertions, 0 failures, 0 errors, 0 skips
```

Full test suite:

```bash
bin/rails test
```

Output:

```text
36 runs, 415 assertions, 0 failures, 0 errors, 0 skips
```

### Environment Note

The shell still emits stale native-extension warnings from older gem paths, but the standard Rails binstub commands pass without PATH manipulation.

---

## R0017 - P0017 Correct Rails Command Pattern

**Date:** 2026-04-17  
**Codex Status:** Completed

### Summary

P0017 corrected the unnecessary PATH prefix introduced in R0016. That prefix repeated the CE0001 workaround pattern and was not needed for this Rails app.

### R0016 Update

R0016 now documents standard Rails binstub commands:

```bash
bin/rails test test/controllers/challenges_controller_test.rb test/controllers/attempts_controller_test.rb test/controllers/interpretations_controller_test.rb
```

and:

```bash
bin/rails test
```

No PATH environment manipulation remains in the R0016 verification commands.

### CE0008 Correction

CE0008 identified that R0016 prepended rbenv PATH entries to Rails test commands. That was unnecessary and inconsistent with the standard Rails pattern restored after CE0001.

Future results should use plain Rails binstubs:

```bash
bin/rails test
bin/rails db:migrate
bin/rails db:seed
```

### Verification

Plain command:

```bash
bin/rails test
```

Output:

```text
36 runs, 415 assertions, 0 failures, 0 errors, 0 skips
```

---

## R0018 - P0018 Remove Invalid Algorithm Placeholder

**Date:** 2026-04-17  
**Codex Status:** Completed

### Summary

P0018 corrected the CLE0008 placeholder error by removing the unverified Graph Coloring algorithm card from the algorithm index.

Implemented:

- removed `Graph Coloring` from `ChallengesController#index`
- changed `Shortest Path Algorithms` status from `Coming Soon` to `Pending Verification`
- added the C005 compliance comment above `@future_challenges`
- referenced `RUBYGEMS_SURVEY.md` in the controller comment
- updated the controller test to assert Graph Coloring is absent and Shortest Path is pending verification

### UI State

The future algorithm cards now show:

```text
Knapsack Problem | Coming Soon
Shortest Path Algorithms | Pending Verification
```

Graph Coloring is no longer displayed because `RUBYGEMS_SURVEY.md` found no verified Ruby reference gem for graph coloring.

### C005 Compliance

The controller now documents the process rule directly near the placeholder list:

```ruby
# Future algorithm families must have verified Ruby reference gems.
# C005: Algorithm selection requires RubyGems survey (see RUBYGEMS_SURVEY.md).
# Only add placeholders after gem verification is complete.
```

This keeps the root page aligned with the "the math is the reviewer" methodology: UI placeholders should not imply an algorithm family is viable until a Ruby reference implementation has been verified.

### Verification

Syntax checks passed:

```bash
ruby -c app/controllers/challenges_controller.rb
ruby -c test/controllers/challenges_controller_test.rb
```

Output:

```text
Syntax OK
Syntax OK
```

Focused controller test:

```bash
bin/rails test test/controllers/challenges_controller_test.rb
```

Output:

```text
3 runs, 25 assertions, 0 failures, 0 errors, 0 skips
```

Full suite:

```bash
bin/rails test
```

Output:

```text
36 runs, 419 assertions, 0 failures, 0 errors, 0 skips
```

No PATH prefix, shell wrapper, or CE0001-style workaround was used.

---

## R0019 - P0019 Add SKIP_HELD_KARP Test Flag

**Date:** 2026-04-17  
**Codex Status:** Completed

### Summary

P0019 added an opt-in test flag for fast development runs that do not need expensive Held-Karp exact solver coverage.

Implemented:

- added `skip_held_karp_if_requested` helper in `test/test_helper.rb`
- accepted exactly `SKIP_HELD_KARP=1` and `SKIP_HELD_KARP=true`
- added Held-Karp skip comments to `TspSolverTest` and `TspAttemptRunnerTest`
- guarded tests that directly invoke Held-Karp or generate `held-karp-v1` attempts through `TspAttemptRunner#run_all`
- documented the flag in `README.md`
- preserved default full-test behavior when the flag is unset

### Tests Modified

Held-Karp skip guards were added in:

```text
test/services/tsp_solver_test.rb
test/services/tsp_attempt_runner_test.rb
```

The shared helper was added in:

```text
test/test_helper.rb
```

### Usage

Fast development run:

```bash
SKIP_HELD_KARP=1 bin/rails test
```

Alternate accepted value:

```bash
SKIP_HELD_KARP=true bin/rails test
```

Full validation remains:

```bash
bin/rails test
```

### Verification

Focused P0018 controller test:

```bash
bin/rails test test/controllers/challenges_controller_test.rb
```

Output:

```text
3 runs, 25 assertions, 0 failures, 0 errors, 0 skips
```

Skip-flag full suite:

```bash
SKIP_HELD_KARP=1 bin/rails test
```

Output:

```text
36 runs, 185 assertions, 0 failures, 0 errors, 13 skips
Finished in 31.508809s
```

Default full suite:

```bash
bin/rails test
```

Output:

```text
36 runs, 419 assertions, 0 failures, 0 errors, 0 skips
Finished in 193.830601s
```

Alternate accepted flag value:

```bash
SKIP_HELD_KARP=true bin/rails test test/services/tsp_solver_test.rb
```

Output:

```text
12 runs, 15 assertions, 0 failures, 0 errors, 5 skips
```

### Runtime Comparison

The default full suite took about 193.8 seconds. The skip-flag suite took about 31.5 seconds, reducing this run by roughly 162.3 seconds while making the skipped exact-solver tests visible in Minitest output.
