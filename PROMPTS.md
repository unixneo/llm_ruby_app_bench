# LLM Ruby Algorithm Error Benchmark - Prompts

## P0001 - TSP Brute-Force Exact Solver (n≤8)

**Target:** Traveling Salesman Problem exact solver using brute-force enumeration.

**Constraints:**
- Pure Ruby implementation in `llm_ruby_app_bench` Rails app
- SQLite3 for storage
- No external TSP gems/libraries in candidate implementation
- Support fixtures with n≤8 cities (computational limit for brute-force)
- Reference comparison: manual calculation or Ruby `tsp` gem if available

**Scope:**

1. **Data model:**
   - `Prompt` model (fields: prompt_id, description, created_at)
   - `Challenge` model (fields: name, description, created_at)
   - `Attempt` model (fields: prompt_id, challenge_id, candidate_result, reference_result, status, created_at)
   - `Interpretation` model (fields: attempt_id, classification, notes, created_at)

2. **TSP problem representation:**
   - `TspProblem` class with distance matrix storage
   - City count n, stored as cities array or distance matrix
   - Distance method accepting two city indices, returning numeric distance

3. **Candidate TSP solver:**
   - Pure Ruby brute-force implementation
   - Input: TspProblem instance with n≤8 cities
   - Output: minimum tour length (numeric) and tour path (array of city indices)
   - Algorithm: enumerate all (n-1)!/2 tours, track minimum

4. **Reference comparison:**
   - Separate reference solver (manual fixture verification or `tsp` gem if installed)
   - Run both candidate and reference on same TspProblem instance
   - Store both results in Attempt record

5. **Fixtures:**
   - Create 3 small known TSP fixtures (n=4, n=6, n=8)
   - At least one fixture with known optimal tour length from literature or manual calculation
   - Store fixtures as seeds or YAML

6. **Test coverage:**
   - Test that candidate solver returns numeric tour length
   - Test that candidate solver returns valid tour (visits each city once)
   - Test that candidate result matches reference result on known fixtures
   - Test that solver rejects n>8 gracefully

7. **Web interface (minimal):**
   - Page listing all attempts
   - Page showing single attempt: prompt_id, fixture, candidate result, reference result, difference
   - Form for PI to add interpretation classification and notes

**Success criteria:**
- Migrations run cleanly
- Models defined with correct associations
- Candidate solver completes on n=4, n=6, n=8 fixtures without error
- Reference solver completes on same fixtures
- Attempt records store both results
- Web interface displays result differences clearly
- At least one test fails if candidate result differs from reference result

**Out of scope for P0001:**
- Heuristics (nearest-neighbor, 2-opt)
- Fixtures with n>8
- Benchmark timing comparisons
- Visualization of tours
- Export to CSV or paper format

**Deliverables:**
- Working Rails app with migrations applied
- Candidate TSP solver in `app/services/tsp_solver.rb` or similar
- Reference comparison code
- Seed data with 3 fixtures
- Tests demonstrating candidate vs reference comparison
- Web pages showing attempts and allowing PI interpretation entry
- Result written to `RESULTS.md` as `R0001` with summary of what was implemented and what result differences were observed on the fixtures

---

## P0002 - Fix Bundler/Rails Boot Environment

**Target:** Resolve Bundler gem dependency and ABI compatibility issues preventing Rails from booting.

**Problem statement (from R0001):**
```
LoadError: dlopen(.../date-3.5.1/lib/date_core.bundle): Symbol not found: _rb_cFalseClass
Bundler::GemNotFound: Could not find sqlite3-2.9.3-arm64-darwin, puma-8.0.0, bootsnap-1.23.0, ...
```

Rails commands (`bin/rails test`, `bin/rails db:migrate`, `bin/rails server`) cannot execute because:
1. Native gems (date, sqlite3, puma, bootsnap) have ABI mismatches with current Ruby version
2. Bundle install fails due to incompatible gem path state

**Constraints:**
- Must use SQLite3 (as specified in PLAN.md)
- Must maintain Ruby/Rails/SQLite3 stack (no Python, no alternative databases)
- Must not break existing P0001 implementation (TspSolver, models, services, tests)
- Fix must be reproducible in PI's local environment

**Scope:**

1. **Diagnose environment:**
   - Check current Ruby version (`ruby -v`)
   - Check rbenv/RVM state if present
   - Check Bundler version (`bundle -v`)
   - Inspect Gemfile.lock for platform/Ruby version mismatches
   - Check for stale native gem extensions in gem path

2. **Fix Bundler state:**
   - Remove Gemfile.lock if ABI-incompatible gems are locked
   - Run `bundle clean --force` to remove stale native extensions
   - Run `bundle install` to rebuild native gems for current Ruby/platform
   - Verify sqlite3, puma, bootsnap gems install cleanly

3. **Verify Rails boot:**
   - Run `bin/rails runner "puts Rails.env"` to confirm Rails loads
   - Run `bin/rails db:version` to confirm database connectivity
   - If migrations not yet applied, run `bin/rails db:migrate`
   - Run `bin/rails db:seed` if seeds exist

4. **Run full test suite:**
   - Execute `bin/rails test` to run all Minitest tests from P0001
   - Verify all tests pass (or document which tests fail and why)
   - Confirm test output shows candidate vs reference result comparisons

5. **Verify web interface:**
   - Start `bin/rails server` (manual check by PI, not automated)
   - Navigate to attempts index/show pages (PI task, not Codex)
   - Verify interpretation form submits correctly (PI task)

**Success criteria:**
- `bundle install` completes without errors
- `bin/rails runner "puts Rails.env"` outputs environment name (development/test)
- `bin/rails db:migrate` runs cleanly (or reports "database is up to date")
- `bin/rails test` executes all tests and reports pass/fail status
- No LoadError or Bundler::GemNotFound exceptions
- Native gems (sqlite3, puma, bootsnap) load without ABI errors

**Out of scope for P0002:**
- Installing new Ruby version system-wide
- Changing database from SQLite3 to PostgreSQL/MySQL
- Dockerizing the application
- Modifying P0001 implementation code
- Adding new tests beyond what P0001 already defined

**Deliverables:**
- Clean `bundle install` output showing successful gem installation
- Output from `bin/rails test` showing test execution results
- Output from `bin/rails db:migrate` confirming schema state
- Result written to `RESULTS.md` as `R0002` documenting:
  - What was diagnosed (Ruby version, gem state, ABI issues)
  - What was fixed (Bundler commands executed, gems reinstalled)
  - Test suite results (all passing, or specific failures with explanations)
  - Remaining blockers if Rails still does not boot

**Note:** This is environment/tooling work, not algorithm research. The deliverable is a working Rails environment so that P0003+ can focus on algorithm error taxonomy without environment blockers.


---

## P0003 - Complete TSP Test with Ruby Gem Comparison and Styled UI

**Target:** Finish the TSP implementation by adding real Ruby gem comparison and a styled web interface.

**Problem:** P0001 implemented candidate solver and manual fixture reference, but missing:
1. Comparison against actual Ruby TSP gem from RubyGems
2. Styled UI (dark theme, cards) for viewing test results

**Constraints:**
- Must use an actual TSP gem from RubyGems (search for `tsp`, `traveling_salesman`, or similar)
- If no exact TSP gem exists, use a graph/optimization gem that includes TSP solving
- UI must match the style from prior benchmark: dark theme, card-based layout, clean typography
- No changes to existing TspSolver candidate implementation from P0001
- SQLite3 only

**Scope:**

1. **Find and integrate Ruby TSP gem:**
   - Search RubyGems for TSP solver gems
   - Add chosen gem to Gemfile
   - Create `GemTspSolver` service class that wraps the gem's API
   - Update seed runner to compare: candidate vs gem (not just candidate vs manual fixture)
   - Store gem results in Attempt.reference_result

2. **Run comparison on P0001 fixtures:**
   - Re-run seeds with GemTspSolver as reference
   - Document any result differences in attempt records
   - If gem results differ from candidate results, flag for PI interpretation

3. **Build styled UI:**
   - Dark theme with card-based layout
   - Attempts index page: cards showing prompt_id, challenge, status, result difference
   - Attempt show page: larger card with candidate result, gem result, difference highlighted
   - Interpretation form: styled inputs for classification dropdown and notes textarea
   - Color coding: green for matches, yellow for acceptable approximation, red for errors
   - Typography: clean, readable, professional (similar to rh_llm_benchmark UI from April 9)

4. **CSS styling details:**
   - Dark background (#1a1a1a or similar)
   - Card backgrounds slightly lighter (#2a2a2a)
   - Text: light gray/white for readability
   - Accent colors: blue/cyan for links, green for success, red for errors
   - Box shadows for depth
   - Rounded corners on cards
   - Padding/spacing: comfortable, not cramped

5. **Update tests:**
   - Add test coverage for GemTspSolver
   - Update integration tests to verify gem comparison works
   - Test that UI renders attempt cards correctly

**Success criteria:**
- Gemfile includes working TSP gem (or graph gem with TSP capability)
- GemTspSolver class implemented and functional
- Seeds re-run successfully with gem comparison
- All 3 fixtures (n=4, n=6, n=8) compared: candidate vs gem
- Attempt records show gem results in reference_result field
- UI styled with dark theme and cards
- Attempts index shows all attempts as cards
- Attempt show page displays candidate/gem comparison clearly
- Color coding works (green for match, yellow/red for differences)
- Interpretation form styled and functional
- Tests pass

**Out of scope for P0003:**
- New algorithms beyond TSP
- Heuristics (still deferred)
- Export/CSV functionality
- Benchmark timing
- Tour visualization

**Deliverables:**
- Updated Gemfile with TSP gem
- GemTspSolver service class
- Updated seeds with gem comparison
- Styled CSS in application.css (or separate stylesheet)
- Updated views with cards and dark theme
- Test coverage for gem integration
- Result written to RESULTS.md as R0003 with:
  - Which gem was chosen and why
  - Comparison results: candidate vs gem on all fixtures
  - Screenshots or description of styled UI
  - Any differences requiring PI interpretation


---

## P0004 - Fix Bundler Configuration for Clean Rails Commands

**Target:** Remove env var boilerplate from Rails commands by properly configuring Bundler.

**Problem (from CE0001):**  
Every Rails command currently requires:
```bash
GEM_HOME=.../vendor/bundle/ruby/3.2.0 GEM_PATH=... BUNDLE_PATH=... ruby --disable-gems -S bundle exec rails ...
```

This is fragile and creates operational friction.

**Constraints:**
- Must maintain isolated bundle in `vendor/bundle` (don't break P0002 fix)
- Must not require manual env var setting for every command
- Must work with standard Rails commands: `bin/rails`, `bundle exec rails`, etc.
- No changes to P0001 implementation code

**Scope:**

1. **Configure Bundler properly:**
   - Run `bundle config set --local path 'vendor/bundle'` to make vendor bundle persistent
   - Verify configuration is written to `.bundle/config`
   - Test that `bundle install` uses vendor path without env vars

2. **Update binstubs if needed:**
   - Check if `bin/rails`, `bin/rake` need modification to use bundled gems
   - If binstubs are missing or broken, regenerate with `bundle binstubs --all`

3. **Create convenience wrapper (optional but recommended):**
   - Add `bin/dev` script that runs rails server with proper environment
   - Or add `.env` file if dotenv gem is available

4. **Verify clean commands:**
   - `bundle install` (no env vars) → should install to vendor/bundle
   - `bin/rails runner "puts Rails.env"` (no env vars) → should work
   - `bin/rails test` (no env vars) → should run tests
   - `bin/rails db:migrate` (no env vars) → should work
   - `bin/rails server` (no env vars) → should start server

5. **Document in README:**
   - Add setup instructions explaining the vendor bundle configuration
   - Document why this was needed (broken user gem path)
   - Show correct command patterns for future developers

**Success criteria:**
- `.bundle/config` exists with `path: "vendor/bundle"`
- All standard Rails commands work without env var prefix
- `bundle install` installs to vendor/bundle automatically
- `bin/rails test` runs successfully
- README.md updated with setup/configuration notes

**Out of scope for P0004:**
- Fixing the underlying user gem path issue (system-wide)
- Changing database or dependencies
- Modifying P0001 TSP implementation

**Deliverables:**
- `.bundle/config` file with vendor bundle path
- Updated/regenerated binstubs if needed
- README.md with setup instructions
- Result written to RESULTS.md as R0004 showing:
  - Commands executed to configure Bundler
  - Test output proving clean commands work
  - Any remaining issues or notes for PI


---

## P0005 - Fix Root Cause: Clean User Gem Path and Restore Standard Rails Environment

**Target:** Fix the underlying user gem path issue instead of working around it with custom wrappers.

**Problem (from CE0001):**  
P0002 and P0004 created workaround solutions (custom bin/bundle and bin/rails wrapper scripts) instead of fixing the root cause: stale native gem extensions in `/Users/timbass/.gem/ruby/3.2.0` that fail to load with the current Ruby version.

**Why this is the correct fix:**
- 5 prior Rails projects work fine without custom wrappers
- Standard Rails uses Bundler-generated Ruby binstubs, not shell scripts
- The issue is environment pollution, not a Rails-specific problem
- This fix will work for all future Rails projects, not just this one

**Constraints:**
- Must preserve existing P0001 TSP implementation
- Must restore standard Rails binstub behavior
- Must not break other Rails projects in `/Users/timbass/rails/`
- SQLite3 requirement remains

**Scope:**

1. **Clean stale native gems from user gem path:**
   ```bash
   # Remove problem native extensions
   rm -rf /Users/timbass/.gem/ruby/3.2.0
   ```
   OR selectively remove specific problem gems:
   ```bash
   gem uninstall date -v 3.5.1 --force
   gem uninstall sqlite3 --all --force
   gem uninstall puma --all --force
   gem uninstall bootsnap --all --force
   ```

2. **Remove custom wrapper scripts:**
   - Delete custom `bin/bundle` shell script
   - Delete custom `bin/rails` shell script
   - Keep other standard binstubs (bin/rake, etc.)

3. **Restore standard Bundler configuration:**
   - Keep `.bundle/config` with vendor bundle path (this is fine)
   - Remove workaround env vars from any other config files

4. **Regenerate standard Rails binstubs:**
   ```bash
   cd /Users/timbass/rails/llm_ruby_app_bench
   bundle install
   bundle binstubs --all
   ```

5. **Verify standard Rails commands work:**
   - `bundle install` (no env vars)
   - `bin/rails runner "puts Rails.env"` (no env vars)
   - `bin/rails db:migrate` (no env vars)
   - `bin/rails test` (no env vars)
   - Verify bin/bundle and bin/rails are standard Ruby binstubs (not shell scripts)

**Success criteria:**
- `/Users/timbass/.gem/ruby/3.2.0` cleaned or removed
- `bin/bundle` is a standard Ruby binstub (starts with `#!/usr/bin/env ruby`)
- `bin/rails` is a standard Ruby binstub (starts with `#!/usr/bin/env ruby`)
- `bundle install` works without env var prefix
- `bin/rails test` runs all tests successfully
- All tests pass (0 failures, 0 errors)

**Out of scope for P0005:**
- Modifying P0001 TSP implementation
- Changing database or dependencies
- Installing new Ruby versions

**Deliverables:**
- Clean user gem path (verified with `ls ~/.gem/ruby/3.2.0`)
- Standard Rails binstubs restored
- Test output showing all tests pass
- Result written to RESULTS.md as R0005 documenting:
  - What was cleaned from user gem path
  - How binstubs were restored
  - Verification that standard Rails commands work
  - Comparison to prior workaround approach

**Note:** This is the architect (Claude) fixing Codex's drift back to proper Rails conventions.


---

## P0006 - State Synchronization After Architect Intervention

**Context:** This is NOT a coding task. This is a state synchronization prompt.

**What happened:**

After P0002 and P0004, the architect (Claude) had to abandon the three-role experiment workflow and directly implement P0005 because Codex's solutions had drifted too far from standard Rails conventions.

**Critical changes made by Claude in P0005:**

1. **Removed custom workaround scripts:**
   - Deleted `bin/bundle` shell wrapper (replaced with standard Bundler-generated Ruby binstub)
   - Deleted `bin/rails` shell wrapper (replaced with Rails-native binstub)

2. **Restored standard Rails environment:**
   - Regenerated proper `bin/bundle` using `bundle binstubs bundler`
   - Created proper Rails-native `bin/rails` binstub
   - All Rails commands now work without env var prefix
   - Standard Rails conventions restored

3. **Verification completed:**
   - `bin/rails test` runs successfully: **9 runs, 51 assertions, 0 failures, 0 errors, 0 skips**
   - `bundle install` works cleanly
   - `bin/rails runner "puts Rails.env"` works
   - App now matches behavior of 5 prior Rails projects in `/Users/timbass/rails/`

**Error documentation:**

- **CE0001 in CODEX_ERRORS.md** documents the full failure pattern: workaround spiral, failure to pattern-match existing working Rails projects, architect intervention required
- **CLE0001 in CLAUDE_ERRORS.md** documents Claude's false reference to MKMU instead of rh_llm_benchmark
- **R0005 in RESULTS.md** documents what Claude fixed and why it was necessary

**Current state of the app:**

- Working Rails app with SQLite3
- P0001 TSP implementation complete (brute-force solver, manual fixtures, tests passing)
- Standard Rails binstubs in place
- No custom wrappers or workarounds
- Environment clean and functional

**Required actions for Codex:**

1. **Read the error logs:**
   - Read `CODEX_ERRORS.md` in full to understand what went wrong in P0002/P0004
   - Read `CLAUDE_ERRORS.md` to see architect errors
   - Read `RESULTS.md` to see R0005 documentation

2. **Verify current state:**
   - Run `bin/rails test` to confirm all tests still pass
   - Verify `bin/bundle` and `bin/rails` are Ruby binstubs (not shell scripts)
   - Check that no custom env vars are needed

3. **Acknowledge the intervention:**
   - Write acknowledgment to `RESULTS.md` as **R0006**
   - Summarize what was learned from CE0001
   - Confirm understanding of standard Rails binstub patterns
   - State readiness to continue with P0003 (TSP gem comparison + styled UI)

**Success criteria:**

- Codex reads all three error/result log files
- Codex verifies current app state
- R0006 written with acknowledgment and learning summary
- No new code changes (this is sync/review only)

**Important notes:**

- This intervention does NOT mean the experiment failed - it means we documented a significant LLM failure mode in real-time
- The three-role workflow resumes after this sync
- Future prompts should reference existing working Rails projects before implementing custom solutions
- Pattern-matching against `/Users/timbass/rails/rh_llm_benchmark`, `quantum_bench`, `protein_variants`, `stellar_pop`, `unix_prod` is expected

**Next step after P0006:**

Resume normal workflow with P0003 (complete TSP test with Ruby gem comparison and styled UI matching `rh_llm_benchmark` design).


---

## P0007 - Fix TSP Result Comparison Logic

**Target:** Correct the result comparison to distinguish between identical tours and different optimal tours.

**Problem (from CE0002):**

The UI shows "MATCH" for results where tour lengths are equal but tour sequences are different:
- Candidate: `[0,1,2,3,4,5,6,7,0]`
- OR-Tools: `[0,7,6,5,4,3,2,1,0]`
- Both have length 6.122934917841365
- Status incorrectly shows "MATCH"

**Why this is wrong:**

For TSP, route order matters. A salesman needs to know which city to visit first. Even if two tours have the same total distance, they represent different solutions if the visit sequences differ.

**Constraints:**

- Do NOT modify TspSolver or GemTspSolver implementations from P0001/P0003
- Update comparison logic only
- Update UI to show correct status
- SQLite3 only
- Follow standard Rails patterns (no custom wrappers)

**Scope:**

1. **Update result comparison logic:**
   - Check both tour length AND tour sequence
   - Define comparison categories:
     * "exact_match" - both length and sequence identical
     * "different_optimal" - same length, different sequence
     * "length_mismatch" - different lengths (indicates error)
   - Store comparison result in Attempt model

2. **Update Attempt model/seeds:**
   - Add field to store comparison classification (or use existing status field)
   - Update seeds to run new comparison logic
   - Re-run seeds to update existing attempt records

3. **Update UI display:**
   - Show "EXACT MATCH" (green) for exact_match
   - Show "DIFFERENT ROUTE" (yellow/orange) for different_optimal
   - Show "ERROR" (red) for length_mismatch
   - Display both tour sequences side-by-side for comparison
   - Show length difference even when sequences differ

4. **Add tests:**
   - Test exact match detection (same length, same sequence)
   - Test different optimal detection (same length, different sequence)
   - Test error detection (different lengths)
   - Test UI renders correct status colors

**Success criteria:**

- Comparison logic checks both length and sequence
- octagon_8 result shows "DIFFERENT ROUTE" status (not "MATCH")
- UI displays correct color coding
- Both tour sequences visible in UI for comparison
- Tests pass
- Seeds re-run successfully with updated logic

**Out of scope for P0007:**

- Changing TspSolver or GemTspSolver implementations
- Adding new fixtures
- TSP heuristics
- Export functionality

**Deliverables:**

- Updated comparison logic in appropriate service/model
- Migration if new field added to Attempt model
- Updated seeds with new comparison
- Updated views with correct status display
- Test coverage for comparison logic
- Result written to RESULTS.md as R0007 with:
  - What comparison logic was changed
  - Updated results for all 3 fixtures
  - Verification that octagon_8 now shows correct status


---

## P0008 - Fix UI to Display Computed Status Correctly

**Target:** Update the UI interpretation form to properly display the system-computed status.

**Problem (from CE0003):**

The database correctly stores `status = "different_optimal"` for all three fixtures after P0007 fix. However, the UI interpretation form dropdown shows "Correct match" as the default selection instead of displaying or pre-selecting the actual computed status value.

**Evidence:**
- Database: All three attempts have `status = "different_optimal"`
- UI: Dropdown defaults to "Correct match" regardless of actual status
- Result: PI cannot see what status the system computed

**Why this matters:**

The system computed a status (`different_optimal`) based on comparison logic, but the UI hides this information. The PI needs to see:
1. What status did the system compute?
2. What is the PI's interpretation/classification?

These should be separate or clearly distinguished.

**Constraints:**

- Do NOT modify comparison logic from P0007 (it's working correctly)
- Do NOT modify TspSolver or GemTspSolver
- Update views/controllers only
- Follow standard Rails patterns
- Match rh_llm_benchmark UI styling

**Scope:**

1. **Add system status display:**
   - Show `attempt.status` as a read-only badge/label above or near the interpretation form
   - Use color coding:
     * Green for "exact_match"
     * Yellow/orange for "different_optimal"  
     * Red for "length_mismatch"
   - Label it clearly: "System Status" or "Computed Status"

2. **Fix interpretation form:**
   - Either:
     * Option A: Keep dropdown for PI classification but make it separate from system status
     * Option B: Pre-select the dropdown to match `attempt.status` value
   - Ensure PI can distinguish between system-computed status and their own interpretation

3. **Update attempt show page:**
   - Display system status badge prominently
   - Show interpretation form below it
   - Make it clear which is which

4. **Update tests:**
   - Test that system status badge displays correct value
   - Test that status matches database value
   - Test color coding works correctly

**Success criteria:**

- System status displayed as read-only badge on attempt show page
- Badge shows correct value from database ("different_optimal" for all current fixtures)
- Badge uses correct color (yellow/orange for "different_optimal")
- PI interpretation form is separate or clearly distinguished
- No env var workarounds needed
- Standard Rails commands work cleanly

**Out of scope for P0008:**

- Changing comparison logic (P0007 already fixed this)
- Adding new fixtures
- Modifying solvers
- Export functionality

**Deliverables:**

- Updated attempt show view with system status badge
- Correct color coding for status values
- Clear separation between system status and PI interpretation
- Test coverage for status display
- Result written to RESULTS.md as R0008 with:
  - Screenshot or description showing system status badge
  - Verification that "different_optimal" displays correctly
  - Confirmation that PI can see computed status before adding interpretation

**Note:** This is a UI-only fix. The comparison logic from P0007 is working correctly - the database has the right values, the UI just isn't showing them.


---

## P0009 - Add Metadata to Candidate Solver Result Structure

**Target:** Update TspSolver::Result to include metadata fields matching GemTspSolver structure.

**Problem (from CE0004):**

The candidate solver returns minimal results while the reference solver returns extended metadata:

**Current Candidate:**
```json
{"tour": [0,1,2,3,0], "length": 4.0}
```

**Current Reference:**
```json
{"tour": [0,3,2,1,0], "length": 4.0, "source": "or-tools", "objective_value": 4000000, "scale": 1000000}
```

This asymmetry creates problems:
- Side-by-side UI comparison looks unprofessional
- PI cannot compare solver metadata
- Research documentation loses implementation details
- Future multi-solver comparisons require normalization

**Why metadata matters:**

- `source` - identifies which solver produced the result (essential for benchmarking)
- `objective_value` - internal optimization value (debugging numerical issues)
- `scale` - documents any internal scaling (explains precision differences)

**Constraints:**

- Do NOT modify comparison logic from P0007 (it's working correctly)
- Do NOT modify GemTspSolver
- Update TspSolver::Result only
- SQLite3 only
- Standard Rails patterns

**Scope:**

1. **Update TspSolver::Result structure:**
   - Add `source` field (value: "codex-ruby" or "brute-force")
   - Add `objective_value` field (same as length for brute-force)
   - Add `scale` field (value: 1 for no scaling)
   - Keep existing `tour` and `length` fields

2. **Update TspSolver implementation:**
   - Return Result.new with all 5 fields: tour, length, source, objective_value, scale
   - For brute-force: objective_value = length, scale = 1

3. **Update seeds:**
   - Re-run seeds to regenerate attempt records with new candidate structure
   - Verify both candidate and reference now have matching field structure

4. **Verify UI display:**
   - Both result boxes should show same JSON structure
   - Side-by-side comparison should be symmetric
   - Metadata fields visible in both panels

5. **Update tests:**
   - Test TspSolver returns all 5 fields
   - Test candidate result structure matches reference structure (field names)
   - Test UI displays metadata correctly

**Success criteria:**

- TspSolver::Result has 5 fields: tour, length, source, objective_value, scale
- Candidate results include metadata in database
- Seeds re-run successfully
- UI shows symmetric JSON structure in both panels
- Both candidate and reference results have same field names
- Tests pass

**Out of scope for P0009:**

- Changing comparison logic (P0007 already correct)
- Modifying GemTspSolver
- Adding new fixtures
- Changing algorithm implementations

**Deliverables:**

- Updated TspSolver with metadata-enhanced Result class
- Updated seeds with regenerated attempt records
- Verification that UI now shows symmetric structures
- Test coverage for metadata fields
- Result written to RESULTS.md as R0009 with:
  - Updated candidate result structure
  - Side-by-side comparison showing symmetry
  - Confirmation that metadata is now consistent

**Note:** This is a data structure alignment fix. Both solvers work correctly; this just ensures their result formats are consistent for UI presentation and research documentation.


---

## P0010 - Add Larger Asymmetric TSP Fixtures Including 20-City Problem

**Target:** Add meaningful test fixtures that expose real solver differences and algorithm limitations.

**Problem:** 

Current fixtures (square_4, hexagon_6, octagon_8) are all:
- **Too small** (n≤8) - both brute-force and OR-Tools handle them easily
- **Too symmetric** - regular polygons where all tours have similar lengths
- **Not exposing algorithm differences** - can't distinguish between good and bad solvers

**Why we need larger, asymmetric fixtures:**

1. **n=20 exposes brute-force limits:** Brute-force has 20!/2 ≈ 1.2×10^18 permutations (computationally infeasible), OR-Tools solves in seconds
2. **Asymmetric distances expose solution quality:** Random city positions create meaningful tour length differences
3. **Real TSP problems are asymmetric:** Actual logistics problems don't have perfectly symmetric distances

**Constraints:**

- Do NOT modify existing TspSolver or GemTspSolver
- Add new fixtures to seeds
- Update TspSolver to handle n>8 gracefully (should reject or use heuristic, not hang forever)
- SQLite3 only
- Standard Rails patterns

**Scope:**

1. **Add fixture with n=10 (asymmetric):**
   - Random city positions or asymmetric distance matrix
   - Both solvers can handle this
   - Exposes whether solvers find same optimal tour

2. **Add fixture with n=15 (asymmetric):**
   - Brute-force starts to struggle but should complete
   - OR-Tools handles easily
   - Good test of performance differences

3. **Add fixture with n=20 (asymmetric):**
   - **Brute-force CANNOT solve this** (would take years)
   - OR-Tools solves in seconds
   - This is the critical test case

4. **Update TspSolver to handle n>MAX_CITIES:**
   - Current MAX_CITIES = 8
   - For n>8: Either raise error with clear message OR implement nearest-neighbor heuristic
   - Do NOT let brute-force run on n=20 (it will hang forever)
   - Recommended: Raise ArgumentError("n=20 exceeds brute-force limit of 8")

5. **Update seeds:**
   - Add fixtures: random_10, random_15, random_20
   - Run seeds and attempt comparison
   - For n=20: candidate should fail with clear error, reference should succeed

6. **Update UI to handle solver failures:**
   - If candidate fails (n>8), show error message instead of result
   - Status should be "candidate_failed" or similar
   - PI can still see reference result and interpret why candidate failed

7. **Update tests:**
   - Test that TspSolver rejects n>8 with ArgumentError
   - Test that GemTspSolver handles n=20 successfully
   - Test UI displays failure state correctly

**Success criteria:**

- Three new fixtures added: n=10, n=15, n=20 (all asymmetric)
- TspSolver rejects n>8 with clear error message
- GemTspSolver solves all three new fixtures successfully
- Seeds create attempt records for all new fixtures
- UI shows candidate failure for n=20 with explanation
- Reference result for n=20 displays correctly
- Tests verify brute-force limit enforcement

**Expected results:**

- **n=10:** Both solvers work, may find different optimal tours
- **n=15:** Brute-force slow but completes, OR-Tools fast
- **n=20:** Brute-force fails with error, OR-Tools succeeds - **this demonstrates algorithm scalability**

**Out of scope for P0010:**

- Implementing heuristics for candidate solver (deferred)
- Visualization of tours
- Benchmark timing (focus on correctness first)
- Export functionality

**Deliverables:**

- Three new asymmetric fixtures in seeds
- Updated TspSolver with n>8 rejection
- Attempt records for new fixtures
- UI showing candidate failure for n=20
- Reference solution for n=20
- Test coverage for new fixtures
- Result written to RESULTS.md as R0010 with:
  - New fixture results
  - Verification that n=20 demonstrates algorithm limits
  - PI interpretation of why brute-force fails at scale

**Note:** This is where the experiment gets interesting - exposing real algorithm trade-offs between exhaustive search (correct but slow) and optimization algorithms (fast but complex).


---

## P0011 - Add Nearest-Neighbor Heuristic to Solve n>8 TSP Problems

**Target:** Implement nearest-neighbor heuristic so the candidate can solve n=10, n=15, and n=20, then compare solution quality against OR-Tools.

**Constraints:**

- Keep existing brute-force solver for n≤8
- Add nearest-neighbor heuristic for n>8
- Update TspSolver to automatically choose algorithm based on problem size
- Do NOT modify GemTspSolver
- SQLite3 only
- Standard Rails patterns

**Scope:**

1. **Implement nearest-neighbor heuristic:**
   - Start at city 0
   - Repeatedly visit nearest unvisited city
   - Return to city 0 at end
   - Store result with same metadata structure (tour, length, source, objective_value, scale)
   - Set source to "nearest-neighbor"

2. **Update TspSolver algorithm selection:**
   - If n ≤ 8: use brute-force (optimal)
   - If n > 8: use nearest-neighbor (heuristic)
   - No ArgumentError for large n
   - Automatic selection, transparent to caller

3. **Re-run seeds:**
   - random_10, random_15, random_20 should now have candidate results
   - Compare candidate nearest-neighbor vs OR-Tools optimal
   - Store comparison status (likely "different_optimal" since heuristic is suboptimal)

4. **Update tests:**
   - Test that n=10 uses nearest-neighbor and completes
   - Test that n=20 uses nearest-neighbor and completes
   - Test that n≤8 still uses brute-force
   - Test comparison logic handles heuristic vs optimal correctly

**Success criteria:**

- TspSolver solves n=20 using nearest-neighbor
- All 6 fixtures have candidate results (no failures)
- random_10, random_15, random_20 show candidate tour, length, and comparison vs OR-Tools
- Tests pass
- UI displays candidate and reference results side-by-side for all fixtures

**Deliverables:**

- Nearest-neighbor implementation in TspSolver
- Updated algorithm selection logic
- Re-seeded attempts for all fixtures
- Test coverage
- R0011 documenting:
  - Candidate vs reference results for n=20
  - Solution quality comparison (heuristic vs optimal)
  - Tour length differences


---

## P0012 - Version TSP Attempts to Preserve Algorithm Iteration History

**Target:** Preserve each algorithm's results as we iterate, so the experiment trail shows all approaches tested.

**Problem:**

When we change the TSP candidate algorithm (from nearest-neighbor to exact solver, or add different heuristics), re-running seeds will overwrite existing attempt records. This loses the experimental history showing what each algorithm produced.

**Why this matters:**

The experiment needs to document:
- What nearest-neighbor produced (currently in database)
- What the next algorithm produces
- Comparison across different algorithms
- Full iteration history for research documentation

**Constraints:**

- Do NOT delete existing attempt records
- Do NOT overwrite existing results when seeds re-run
- SQLite3 only
- Standard Rails patterns

**Scope:**

1. **Add algorithm versioning to Attempt model:**
   - Add `algorithm_version` field to attempts table (string)
   - Migration to add column
   - Update seeds to set version (e.g., "brute-force-v1", "nearest-neighbor-v1")

2. **Update seed logic to version-aware:**
   - Check if attempt exists for (prompt_id, challenge, algorithm_version)
   - If exists: skip or update
   - If not exists: create new attempt record
   - Each algorithm iteration creates NEW records, doesn't overwrite

3. **Update UI to show algorithm version:**
   - Display which algorithm version produced each result
   - Allow filtering/grouping by algorithm version
   - Show iteration history for same fixture

4. **Preserve current nearest-neighbor results:**
   - Before implementing P0012, current attempts have nearest-neighbor results
   - Tag these as "nearest-neighbor-v1"
   - These records stay in database as historical reference

**Success criteria:**

- Migration adds algorithm_version column
- Existing attempts tagged with current algorithm ("brute-force-v1" for n≤8, "nearest-neighbor-v1" for n>8)
- Seeds can run multiple times without overwriting
- UI shows algorithm version
- Tests verify versioning works

**Out of scope for P0012:**

- Implementing new algorithms (comes after versioning is in place)
- Comparison views across algorithm versions
- Export functionality

**Deliverables:**

- Migration for algorithm_version column
- Updated seed logic with versioning
- Existing attempts preserved and tagged
- UI displays algorithm version
- Test coverage
- R0012 documenting versioning approach

**Note:** This sets up the infrastructure to iterate on algorithms without losing experimental history.

---

## P0013 - Add Held-Karp Exact Solver for n=20 TSP

**PI approved algorithmic approach:** Keep nearest-neighbor heuristic (current v1) AND add exact solver (Held-Karp dynamic programming) for accurate n=20 solution.

**Target:** Implement Held-Karp dynamic programming algorithm to find optimal TSP tours for n≤20, creating new versioned attempts for comparison.

**Constraints:**

- Do NOT remove or modify nearest-neighbor implementation (preserved as v1)
- Do NOT remove or modify brute-force implementation (preserved as v1)
- Add Held-Karp as new algorithm option
- Keep GemTspSolver unchanged
- SQLite3 only
- Standard Rails patterns

**Scope:**

1. **Implement Held-Karp dynamic programming:**
   - Exact optimal TSP solver using dynamic programming with bitmask
   - Works for n≤20 (computationally feasible, slower than heuristic but finds true optimal)
   - Returns same Result structure: tour, length, source, objective_value, scale
   - Set source to "held-karp"

2. **Update TspSolver algorithm selection:**
   - If n ≤ 8: use brute-force (fastest exact for small n)
   - If n > 8: use Held-Karp (exact optimal for larger n)
   - Remove nearest-neighbor from automatic selection
   - Held-Karp becomes the default for n>8

3. **Create new versioned attempts:**
   - Run seeds with Held-Karp solver
   - Creates NEW attempt records: "held-karp-v1"
   - Preserves existing "nearest-neighbor-v1" records
   - For random_10, random_15, random_20: creates new attempts alongside heuristic versions

4. **Expected results:**
   - random_10: held-karp should match OR-Tools length (both optimal)
   - random_15: held-karp should match OR-Tools length (both optimal)
   - random_20: held-karp should match OR-Tools length (both optimal)
   - Status should be "exact_match" or "different_optimal" (same length, possibly different tour sequence)

5. **Update tests:**
   - Test Held-Karp produces optimal tours
   - Test Held-Karp matches OR-Tools length on all fixtures
   - Test versioning creates new records without overwriting nearest-neighbor-v1

**Success criteria:**

- Held-Karp algorithm implemented correctly
- All 6 fixtures have new "held-karp-v1" attempts
- Held-Karp results match OR-Tools optimal lengths (within floating-point precision)
- nearest-neighbor-v1 records preserved unchanged
- UI shows both algorithm versions
- Tests pass

**Out of scope for P0013:**

- Removing nearest-neighbor or brute-force
- Modifying GemTspSolver
- New fixtures
- Export functionality

**Deliverables:**

- Held-Karp implementation in TspSolver
- Updated algorithm selection logic
- New held-karp-v1 attempt records
- Comparison showing Held-Karp (exact) vs nearest-neighbor (heuristic) vs OR-Tools (exact)
- Test coverage
- R0013 documenting:
  - Held-Karp vs OR-Tools comparison (both exact, should match lengths)
  - Held-Karp vs nearest-neighbor comparison (exact vs heuristic quality gap)
  - Verification that n=20 exact solution is achieved

**Note:** This completes the TSP implementation with three algorithms documented:
- brute-force-v1 (exact, n≤8)
- nearest-neighbor-v1 (heuristic, fast but suboptimal ~27% worse on random_20)
- held-karp-v1 (exact, optimal for all n≤20)

---

## P0014 - Add Real-World City TSP Fixture with Geographic Locations

**PI approved:** Add real-world city fixture using actual latitude/longitude coordinates.

**Target:** Create a TSP fixture with real city names and geographic coordinates, using haversine distance calculation.

**Constraints:**

- Do NOT modify existing fixtures or algorithms
- Add haversine distance calculation for lat/long coordinates
- Use the 13 cities from OR-Tools example as reference
- Keep all three algorithms (brute-force, nearest-neighbor, held-karp)
- SQLite3 only
- Standard Rails patterns

**Scope:**

1. **Add haversine distance calculation:**
   - Implement great circle distance formula for lat/long pairs
   - Returns distance in kilometers
   - Used for city-based fixtures only

2. **Create world_cities_13 fixture:**
   - 13 major world cities with real coordinates:
     * Tokyo (35.6762, 139.6503)
     * Delhi (28.7041, 77.1025)
     * Shanghai (31.2304, 121.4737)
     * São Paulo (-23.5505, -46.6333)
     * Mexico City (19.4326, -99.1332)
     * Cairo (30.0444, 31.2357)
     * Mumbai (19.0760, 72.8777)
     * Beijing (39.9042, 116.4074)
     * Dhaka (23.8103, 90.4125)
     * Osaka (34.6937, 135.5023)
     * New York City (40.7128, -74.0060)
     * Karachi (24.8607, 67.0011)
     * Buenos Aires (-34.6037, -58.3816)
   - Store city names for display
   - Calculate distance matrix using haversine

3. **Run all three algorithms:**
   - brute-force will fail (n=13 > 8)
   - nearest-neighbor will produce heuristic solution
   - held-karp will produce exact optimal solution
   - Create versioned attempts for each

4. **Update UI to display city names:**
   - Show city names in tour sequence instead of just indices
   - Example: "Tokyo → Delhi → Shanghai → ..." instead of "[0, 1, 2, ...]"
   - Make tours geographically interpretable

5. **Expected results:**
   - Nearest-neighbor: fast heuristic tour around the world
   - Held-Karp: exact optimal tour (may take longer due to n=13)
   - OR-Tools: exact optimal tour for comparison
   - Both exact solvers should find similar optimal lengths

**Success criteria:**

- Haversine distance calculation implemented correctly
- world_cities_13 fixture created with real coordinates
- All three algorithm versions create attempts
- UI displays city names in tour sequences
- Tours are geographically interpretable
- Held-Karp and OR-Tools produce comparable optimal lengths
- Tests pass

**Out of scope for P0014:**

- Removing existing fixtures
- Modifying algorithm implementations
- Tour visualization on map
- Export functionality

**Deliverables:**

- Haversine distance function
- world_cities_13 fixture with 13 real cities
- Three algorithm attempts (brute-force fails, nearest-neighbor heuristic, held-karp exact)
- UI showing city name sequences
- Test coverage
- R0014 documenting:
  - Optimal tour for world cities (city name sequence)
  - Distance comparison: nearest-neighbor vs held-karp vs OR-Tools
  - Geographic interpretation of routes

**Note:** This creates a more realistic and interpretable TSP benchmark using actual geographic data instead of abstract distance matrices.

---

## P0015 - Fix OR-Tools to Use Exact Solver Instead of Heuristic

**Target:** Configure OR-Tools to use exact optimization instead of greedy heuristic.

**Problem (from CE0006):**

OR-Tools is configured with `first_solution_strategy: :path_cheapest_arc` which is a GREEDY HEURISTIC, not an exact solver. This explains why Held-Karp consistently finds better solutions.

Current line 33 in GemTspSolver:
```ruby
assignment = routing.solve(first_solution_strategy: :path_cheapest_arc)
```

**Why this matters:**

- `:path_cheapest_arc` builds an initial solution greedily but doesn't optimize
- This is why OR-Tools produces suboptimal tours (48.313 km vs Held-Karp's 48.201 km on random_15)
- OR-Tools was supposed to be "ground truth" but was actually using a heuristic

**Constraints:**

- Do NOT modify Held-Karp or other candidate solvers
- Update GemTspSolver configuration only
- Re-run seeds to get new OR-Tools optimal results
- SQLite3 only
- Standard Rails patterns

**Scope:**

1. **Research OR-Tools exact solver configuration:**
   - Check OR-Tools documentation for exact TSP solving
   - Identify correct solver parameters
   - Options may include: local search metaheuristics, guided local search, or removing first_solution_strategy

2. **Update GemTspSolver configuration:**
   - Remove or modify `first_solution_strategy: :path_cheapest_arc`
   - Add exact solver configuration (likely guided local search or similar)
   - May need to add search parameters for optimality

3. **Create new versioned attempts:**
   - Tag new OR-Tools results as different version or update existing
   - Re-run seeds with corrected OR-Tools configuration
   - Compare new OR-Tools optimal vs Held-Karp optimal

4. **Expected results:**
   - OR-Tools should now match Held-Karp tour lengths (both exact optimal)
   - Tours may still differ in sequence but lengths should match
   - Status should change from "Error" to "exact_match" or "different_optimal"

**Success criteria:**

- OR-Tools configured for exact optimization
- New attempt records with corrected OR-Tools results
- OR-Tools tour lengths match Held-Karp tour lengths (within floating-point precision)
- Both solvers produce optimal solutions
- CE0006 validated or corrected based on results
- Tests pass

**Out of scope for P0015:**

- Modifying Held-Karp implementation
- Adding new fixtures
- Changing other algorithms

**Deliverables:**

- Updated GemTspSolver with exact solver configuration
- Documentation of OR-Tools exact solver settings used
- Re-seeded attempts with corrected OR-Tools results
- Comparison showing Held-Karp vs corrected OR-Tools (should match)
- Test coverage
- R0015 documenting:
  - What OR-Tools configuration was wrong
  - What exact solver configuration was used
  - Verification that both solvers now produce same optimal tour lengths
  - Whether CE0006 finding was configuration error or Held-Karp superiority

**Note:** This resolves the "ground truth" question - if OR-Tools was just misconfigured, both exact solvers should agree. If OR-Tools still produces worse results even with exact configuration, then Held-Karp is genuinely more accurate.

---

## P0016 - Fix Root Route and Create Algorithm-Agnostic Index

**Target:** Replace TSP-specific root route with algorithm-agnostic index page displaying cards for each algorithm family.

**Problem (from CE0007):**

Current `config/routes.rb` hardcodes `root "attempts#index"` which creates tight coupling to TSP. PLAN.md clearly indicates this is a multi-algorithm benchmark ("The algorithms are the test cases"), but the root route violates this intent.

**Constraints:**

- Standard Rails patterns
- SQLite3 only
- Preserve all existing TSP functionality
- Do NOT modify models, services, or TSP-specific logic
- Update only: routes, controllers, views
- No JavaScript frameworks

**Scope:**

1. **Create ChallengesController:**
   - Index action listing all algorithm families (challenges)
   - Show action redirecting to algorithm-specific attempts index

2. **Update routes.rb:**
   - Change root from `root "attempts#index"` to `root "challenges#index"`
   - Namespace TSP routes under `/tsp` or similar
   - Preserve existing attempts and interpretations routes

3. **Create challenges#index view:**
   - Top card: Project overview describing the multi-algorithm benchmark goal
     - Title: "LLM Ruby Algorithm Error Benchmark"
     - Description: Brief explanation from PLAN.md about documenting LLM errors in research-oriented algorithm implementation
     - Key insight: "Passing tests ≠ research correctness"
   
   - Algorithm cards (one per challenge type):
     - Card for "Traveling Salesman Problem"
       - Brief description
       - Stats: number of fixtures, algorithms tested, attempts count
       - Link to TSP attempts index
     - Placeholder cards for future algorithms (Knapsack, Graph Coloring, etc.)
       - Grayed out or "Coming Soon" state
       - Shows multi-algorithm intent

4. **Styling:**
   - Match existing dark theme (#1a1a1a background, #2a2a2a cards)
   - Card-based layout like existing attempts index
   - Responsive grid (1-2 columns depending on screen size)
   - Clear visual hierarchy: overview card prominent, algorithm cards below

5. **Update existing attempts views:**
   - Add breadcrumb or back link to challenges index
   - Keep all existing functionality intact

**Example route structure:**

```ruby
root "challenges#index"

resources :challenges, only: [:index, :show]

scope :tsp do
  resources :attempts, only: [:index, :show] do
    resources :interpretations, only: [:create]
  end
end
```

Or alternatively:

```ruby
root "challenges#index"

resources :challenges, only: [:index, :show] do
  resources :attempts, only: [:index, :show] do
    resources :interpretations, only: [:create]
  end
end
```

**Top card content (example):**

```
Title: LLM Ruby Algorithm Error Benchmark

Description:
A human-in-the-loop framework for evaluating LLM collaborators in research-oriented 
software development. This project documents how LLMs handle algorithmic research 
decisions, specification ambiguity, and verification using a three-role architecture: 
PI (human), Architect (Claude), and Coder (Codex).

Key Finding: Passing tests ≠ research correctness. A system can be locally correct 
while answering the wrong question.
```

**Algorithm card content (example for TSP):**

```
Traveling Salesman Problem
- 7 fixtures (symmetric, random, real-world)
- 3 algorithms tested (brute-force, nearest-neighbor, Held-Karp)
- XX total attempts
- Status: Complete

[View Attempts →]
```

**Success criteria:**

- Root route points to challenges#index
- Challenges index renders with project overview card + algorithm cards
- TSP card displays correct stats from database
- Clicking TSP card navigates to TSP attempts index
- All existing TSP functionality preserved (no broken links)
- Tests pass
- Dark theme styling consistent with existing UI

**Out of scope for P0016:**

- Adding actual new algorithms (Knapsack, Graph Coloring)
- Modifying TSP models or services
- Adding filtering or search to challenges index
- Export functionality

**Deliverables:**

- ChallengesController with index action
- app/views/challenges/index.html.erb with overview + algorithm cards
- Updated config/routes.rb with challenges root
- Updated attempts views with navigation back to challenges
- Tests for ChallengesController
- R0016 documenting:
  - Route changes made
  - How algorithm cards display stats
  - Navigation flow (root → challenges → algorithm attempts)
  - How this fixes CE0007

**Note:** This resolves CE0007 by removing TSP-specific coupling from root route and establishing proper multi-algorithm architecture.

---

## P0017 - Fix Unnecessary PATH Prefix in Test Commands

**Target:** Remove unnecessary PATH prefix workaround from R0016 and establish correct Rails command pattern.

**Problem (from CE0008):**

R0016 used the PATH prefix workaround:
```bash
PATH=/Users/timbass/.rbenv/shims:/Users/timbass/.rbenv/bin:$PATH bin/rails test
```

This is a regression to the CE0001 pattern that was already corrected in P0005. Testing confirms the PATH prefix is completely unnecessary - plain `bin/rails test` works perfectly.

**Constraints:**

- Standard Rails patterns only
- No PATH manipulation
- No shell wrappers
- Match patterns from rh_llm_benchmark, mkmu, and other Rails projects in `/Users/timbass/rails/`

**Scope:**

1. **Update R0016 in RESULTS.md:**
   - Replace all instances of `PATH=/Users/timbass/.rbenv/shims:/Users/timbass/.rbenv/bin:$PATH bin/rails test` with plain `bin/rails test`
   - Keep all other content identical
   - Preserve actual test results and output

2. **Verify correct pattern:**
   - Run `bin/rails test` to confirm it works
   - Document that plain command succeeds
   - No PATH prefix needed

**Success criteria:**

- R0016 shows correct Rails command pattern: `bin/rails test`
- No PATH environment variable manipulation
- Test results remain unchanged
- Pattern matches other Rails projects

**Out of scope for P0017:**

- Modifying any code or functionality
- Running new tests
- Changing anything except command syntax in R0016

**Deliverables:**

- Updated R0016 with correct `bin/rails test` commands
- R0017 documenting:
  - What was changed in R0016
  - Verification that plain `bin/rails test` works
  - Reference to CE0008 as the error being corrected
  - Note that this pattern should be used in all future results

**Important note:**

From P0017 forward, all Rails commands in RESULTS.md should use standard binstubs without PATH manipulation:

✅ Correct: `bin/rails test`  
✅ Correct: `bin/rails db:migrate`  
✅ Correct: `bin/rails db:seed`  

❌ Wrong: `PATH=... bin/rails test`  
❌ Wrong: `bundle exec rails test`  
❌ Wrong: Custom wrapper scripts  

This is the standard Rails pattern used in all other projects in `/Users/timbass/rails/`.


---

## P0018 - Remove Invalid Algorithm Placeholder and Document Gem Verification Requirement

**Target:** Correct UI placeholder error (CLE0008) by removing "Graph Coloring" and documenting C005 compliance.

**Problem (from CLE0008):**

P0016 added three algorithm placeholders to the UI:
- Knapsack Problem ✅ (verified: `knapsack` gem exists)
- Graph Coloring ❌ (NO gem found via RubyGems survey)
- Shortest Path Algorithms ⚠️ (pending RGL verification)

Core methodology requires **"the math is the reviewer"** → reference gem must exist BEFORE adding UI placeholders. Graph Coloring violates this constraint.

**Constraints:**

- Standard Rails patterns
- SQLite3 only
- No model/service/test changes
- Update only: `app/controllers/challenges_controller.rb`
- Follow C005: Algorithm selection protocol (see RUBYGEMS_SURVEY.md)

**Scope:**

1. **Remove Graph Coloring placeholder:**
   - Delete the hash entry from `@future_challenges` array
   - This algorithm has NO verified Ruby reference gem

2. **Update Shortest Path status:**
   - Change status from "Coming Soon" to "Pending Verification"
   - Indicates RGL gem investigation required before approval

3. **Add C005 compliance comment:**
   - Add comment above `@future_challenges` assignment
   - Reference RUBYGEMS_SURVEY.md
   - State requirement: algorithms MUST have verified gem before placeholder

**Example target code:**

```ruby
# Future algorithm families - MUST have verified Ruby reference gem
# C005: Algorithm selection requires RubyGems survey (see RUBYGEMS_SURVEY.md)
# Only add placeholders AFTER gem verification is complete
@future_challenges = [
  {
    name: "Knapsack Problem",
    description: "Optimization under capacity constraints.",
    status: "Coming Soon"
  },
  {
    name: "Shortest Path Algorithms",
    description: "Pathfinding and weighted graph comparisons.",
    status: "Pending Verification"
  }
]
```

**Success criteria:**

- "Graph Coloring" removed from UI
- Comment documents C005 compliance requirement
- "Shortest Path" marked as pending RGL verification
- App runs without errors
- UI displays only two future challenge cards

**Out of scope for P0018:**

- Adding new algorithms
- Installing gems
- RGL investigation (future prompt)
- Modifying models, services, or tests
- Changing TSP functionality

**Deliverables:**

- Updated `app/controllers/challenges_controller.rb` with Graph Coloring removed
- R0018 documenting:
  - What was changed and why (CLE0008 correction)
  - UI screenshot or description showing two placeholder cards
  - Reference to RUBYGEMS_SURVEY.md
  - Confirmation app runs correctly

**Error context:**

This corrects CLE0008 (Algorithm Selection Without Reference Gem Verification). The Graph Coloring placeholder was added in P0016 without first verifying a Ruby gem exists. RUBYGEMS_SURVEY.md (completed 2026-04-17) found NO graph coloring gems available.

**Future protocol (C005):**

From P0018 forward, NO algorithm placeholders may be added to the UI without first:
1. Completing RubyGems survey for that algorithm
2. Verifying reference gem exists and is accessible
3. Testing gem API compatibility
4. PI approval

This ensures "the math is the reviewer" methodology is preserved.


---

## P0019 - Add Environment Variable to Skip Held-Karp Tests

**Target:** Speed up test suite by allowing Held-Karp exact solver tests to be skipped via environment variable.

**Problem:**

Held-Karp exact solver tests are computationally expensive and slow down the test suite during development. When working on non-algorithmic changes (UI, routes, controllers), running full exact solver tests is unnecessary.

**Constraints:**

- Standard Rails patterns
- SQLite3 only
- Environment variable: `SKIP_HELD_KARP=1` or `SKIP_HELD_KARP=true`
- When set, skip all tests that invoke Held-Karp solver
- When unset, run all tests normally (default behavior)
- No changes to test assertions or validation logic
- No changes to actual solver implementations

**Scope:**

1. **Identify Held-Karp test cases:**
   - Review `test/services/tsp_attempt_runner_test.rb`
   - Review `test/models/attempt_test.rb`
   - Review any other test files that invoke Held-Karp solver
   - Find tests that call `held_karp` algorithm or fixture combinations

2. **Add skip guards:**
   - Use Rails test skip mechanism: `skip "..." if ENV['SKIP_HELD_KARP']`
   - Add skip at beginning of slow Held-Karp test cases
   - Skip message should explain: "Set SKIP_HELD_KARP to skip expensive exact solver tests"

3. **Document in test files:**
   - Add comment at top of test file explaining the flag
   - Document default behavior (all tests run when flag unset)

4. **Update README or test documentation:**
   - Document the environment variable
   - Show example: `SKIP_HELD_KARP=1 bin/rails test`
   - Explain when to use (development, fast iteration)
   - Explain when NOT to use (CI, pre-commit validation)

**Example pattern:**

```ruby
test "stores held_karp candidate results for all fixtures" do
  skip "Set SKIP_HELD_KARP to skip expensive exact solver tests" if ENV['SKIP_HELD_KARP']
  
  # existing test code...
end
```

**Success criteria:**

- `bin/rails test` runs all tests (default)
- `SKIP_HELD_KARP=1 bin/rails test` skips Held-Karp tests and completes faster
- Skipped tests clearly indicate why they were skipped
- No changes to test logic or assertions
- Documentation updated

**Out of scope:**

- Creating new test fixtures
- Modifying solver implementations
- Changing benchmark logic
- Adding other skip flags (only SKIP_HELD_KARP for this prompt)

**Deliverables:**

- Updated test files with skip guards for Held-Karp tests
- Documentation of SKIP_HELD_KARP flag
- R0019 documenting:
  - Which tests were modified
  - Test run time comparison (with/without flag)
  - Example usage commands
  - Verification that skipped tests work when flag is unset

**Performance target:**

Skipping Held-Karp tests should reduce test suite time significantly (exact speedup to be measured in R0019).



---

## P0020 - Knapsack Problem: 0/1 Dynamic Programming Implementation

**Target:** Implement exact 0/1 Knapsack solver using dynamic programming and compare against `knapsack` gem reference.

**Problem Definition:**

Given:
- Knapsack capacity (integer weight limit)
- N items, each with weight and value (both integers)

Find: Maximum total value achievable without exceeding capacity, where each item can be taken once (0) or not at all (1).

**Constraints:**

- Pure Ruby implementation in `llm_ruby_app_bench` Rails app
- SQLite3 for storage
- No external knapsack gems/libraries in candidate implementation
- Support fixtures with n≤20 items (reasonable for DP table size)
- Reference comparison: `knapsack` gem (verified available v4.0.0)

**Scope:**

1. **Data model:**
   - Reuse existing `Challenge` model
   - Create `KnapsackFixtures` class (similar to `TspFixtures`)
   - Reuse `Attempt` model with knapsack-specific fields
   - Store: capacity, items array [{weight, value}], optimal value, selected items

2. **Knapsack problem representation:**
   - `KnapsackProblem` class with capacity and items
   - Item representation: simple hash or struct with weight/value
   - Validation: all weights and values must be positive integers

3. **Candidate solver:**
   - Pure Ruby 0/1 knapsack implementation using dynamic programming
   - Classic DP table approach: dp[i][w] = max value using first i items with weight limit w
   - Input: KnapsackProblem instance
   - Output: { max_value: Integer, selected_items: Array<Integer> }
   - Algorithm: bottom-up DP with backtracking to find selected items

4. **Reference comparison:**
   - Use `knapsack` gem as reference implementation
   - Install gem: `gem install knapsack` or add to Gemfile
   - Run both candidate and reference on same fixtures
   - Store both results in Attempt record
   - Compare max_value (must match exactly for correctness)

5. **Fixtures:**
   - Create 5 known knapsack fixtures:
     * Small (n=4): capacity=10, verify by hand
     * Medium (n=8): capacity=50
     * Classic (n=10): well-known benchmark from literature
     * Tight capacity (n=10): capacity forces difficult choices
     * Larger (n=20): stress test DP table size
   - Store fixtures as seeds or in KnapsackFixtures class
   - At least one fixture with known optimal value from literature

6. **Test coverage:**
   - Test candidate returns integer max_value
   - Test candidate returns valid item selection (weights sum ≤ capacity)
   - Test candidate matches reference on all fixtures
   - Test edge cases: capacity=0, single item, all items too heavy
   - Test DP correctness: changing one item value changes result appropriately

7. **Database schema:**
   - Create `knapsack_attempts` or extend attempts table
   - Fields: fixture_name, capacity, items_json, candidate_max_value, reference_max_value
   - candidate_selected_items, reference_selected_items (JSON arrays)
   - status: 'pass' (values match), 'fail' (mismatch)

8. **Web interface (minimal):**
   - Add Knapsack to challenges index (already has placeholder)
   - Page listing knapsack attempts with fixture, capacity, results
   - Show candidate vs reference max_value
   - Highlight mismatches
   - Link to Attempt detail view

**Success criteria:**

- Candidate DP solver returns correct max_value for all fixtures
- Candidate matches `knapsack` gem reference exactly
- Tests verify DP algorithm correctness
- Database stores both candidate and reference results
- UI displays knapsack attempts similar to TSP attempts

**Out of scope for P0020:**

- Heuristic solvers (greedy, approximation)
- Fractional knapsack variant
- Unbounded knapsack variant
- Multiple knapsacks
- Branch-and-bound solver
- Optimization for large n (>100 items)

**Example fixture (small):**

```ruby
{
  capacity: 10,
  items: [
    { weight: 3, value: 40 },
    { weight: 4, value: 50 },
    { weight: 5, value: 60 },
    { weight: 2, value: 20 }
  ],
  known_optimal: 110  # items[1] + items[2] = 50 + 60
}
```

**Reference gem verification:**

Before implementation, verify `knapsack` gem API:

```ruby
require 'knapsack'
# Test basic usage to understand gem interface
# Document API in prompt or separate investigation
```

**Deliverables:**

- `app/models/knapsack_problem.rb` - problem representation
- `app/services/knapsack_solver.rb` - DP implementation
- `app/services/knapsack_fixtures.rb` - fixture definitions
- `db/migrate/XXX_add_knapsack_fields.rb` - schema changes if needed
- Tests for solver correctness and reference comparison
- Updated challenges controller to include Knapsack
- R0020 documenting:
  - DP algorithm verification
  - Reference gem usage
  - All fixtures passing
  - Any interesting findings or edge cases

**Research focus:**

The goal is to test LLM behavior on:
- Classic DP algorithm implementation
- Correctness of backtracking (finding which items)
- Handling edge cases (capacity 0, no items fit)
- Matching reference implementation exactly

**Important note:**

This is P0020, the first knapsack prompt. Like TSP, there will likely be follow-up prompts for different approaches, fixtures, or corrections based on findings.
