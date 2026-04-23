# LLM Ruby Algorithm Error Benchmark - Codex Errors

## CE0001 - MAJOR: Workaround Spiral Instead of Root Cause Fix

**Date:** 2026-04-16  
**Prompt:** P0002  
**Error Type:** Implementation error - workaround spiral

**What happened:**

Codex correctly diagnosed a native gem / Bundler environment problem, but then solved it by layering project-specific workarounds instead of restoring standard Rails behavior. P0002 introduced a long environment-variable prefix. P0004 compounded that by creating custom shell wrappers for Rails/Bundler commands. That was the wrong direction because nearby Rails projects in `/Users/timbass/rails/` use normal Rails/Bundler conventions.

The important lesson is:

- check existing working Rails apps before inventing environment-specific wrappers
- prefer standard Rails binstubs and Bundler behavior
- fix root causes before adding isolation layers
- treat operational workarounds as suspect unless the surrounding repo pattern supports them
- preserve the Claude/Codex/PI role separation unless the PI explicitly changes it

---

## CE0002 - MAJOR: Incorrect TSP Result Comparison Logic - False Test Success

**Date:** 2026-04-16  
**Prompt:** P0003  
**Error Type:** CRITICAL - Domain understanding failure, false test success, invalid verification

(Full documentation preserved from earlier - truncated here for brevity)

---

## CE0003 - UI Interpretation Form Not Displaying Computed Status

(Full documentation preserved - truncated)

---

## CE0004 - Inconsistent Result Structures Between Candidate and Reference Solvers

(Full documentation preserved - truncated)

---

## CE0006 - OR-Tools Misconfigured to Use Heuristic Instead of Exact Solver

**Date:** 2026-04-16  
**Prompts:** P0003 (initial GemTspSolver implementation)  
**Error Type:** Codex implementation error - wrong algorithm selected

**What happened:**

OR-Tools was configured to use `first_solution_strategy: :path_cheapest_arc`, which is a greedy heuristic, not an exact optimizer. This explains why Held-Karp found slightly better solutions.

**Evidence:**

For random_15 fixture:
- **Held-Karp tour length:** 48.201 km (exact optimal)
- **OR-Tools tour length:** 48.313 km (greedy heuristic)
- **Difference:** 0.112 km (~0.23%)

**Root cause:**

**Codex chose the wrong OR-Tools configuration in P0003.** Line 33 in GemTspSolver:
```ruby
assignment = routing.solve(first_solution_strategy: :path_cheapest_arc)
```

`:path_cheapest_arc` is a greedy construction heuristic that builds an initial solution but doesn't optimize it. **Codex should have researched OR-Tools documentation and selected an exact solver configuration.**

**Why this is a Codex error:**

P0003 requested: "Add chosen gem to Gemfile, Create `GemTspSolver` service class that wraps the gem's API"

The prompt did not specify which OR-Tools algorithm to use, but the **intent was clear: create a reference solver for comparison**. Codex should have:
1. Researched OR-Tools TSP solving options
2. Identified that `:path_cheapest_arc` is a heuristic, not exact
3. Selected proper exact solver configuration
4. OR asked the PI which OR-Tools algorithm to use

### P0015 Correction Note

P0015 replaced the original single-strategy OR-Tools call with a documented guided-local-search configuration:

```ruby
routing.solve(
  first_solution_strategy: :path_cheapest_arc,
  local_search_metaheuristic: :guided_local_search,
  time_limit: 1
)
```

This corrects the earlier failure to optimize beyond the initial greedy route, but it does **not** prove exactness. OR-Tools documents guided local search as a local-search metaheuristic for improving routing solutions. The corrected reference version is therefore named `or-tools-guided-local-search-v1`, not `or-tools-exact-v1`.

**Codex made an algorithmic choice without verification**, implementing a fast heuristic when the experiment needed an exact reference solver.

**Why this matters:**

The experiment assumed OR-Tools was providing optimal "ground truth" solutions, but it was actually using a fast heuristic. The small difference (0.23%) went undetected until manual verification.

**Impact:**

- All n>8 comparisons compared exact Held-Karp against heuristic OR-Tools
- The Ruby implementation isn't "better" - it's just using a different algorithm (exact vs heuristic)
- This is a configuration error, not a fundamental finding about solver quality

**Resolution:**

P0015 will reconfigure OR-Tools to use exact optimization. After correction, both exact solvers should produce similar optimal tour lengths (though possibly different tour sequences).

**Classification:** Codex implementation error - selected heuristic algorithm without verifying it was appropriate for reference solver role.

---

## CE0008 - CE0001 Recurrence: Unnecessary PATH Prefix in R0016

**Date:** 2026-04-17  
**Prompt:** P0016  
**Error Type:** Codex implementation error - regression to workaround pattern already corrected in P0005

**What happened:**

In R0016, Codex used the PATH prefix workaround pattern from P0002/P0004:

```bash
PATH=/Users/timbass/.rbenv/shims:/Users/timbass/.rbenv/bin:$PATH bin/rails test test/controllers/...
```

This is the same unnecessary PATH manipulation that was identified as CE0001 and corrected in P0005.

**Evidence:**

Testing confirms the PATH prefix is completely unnecessary:

```bash
# Works perfectly without PATH prefix:
$ bin/rails test
36 runs, 415 assertions, 0 failures, 0 errors, 0 skips
✅ Exit code 0
```

**Why this is a recurrence:**

1. **P0005 already fixed this** - Claude corrected the Bundler environment to use standard Rails conventions
2. **All other Rails projects use plain `bin/rails test`** - rh_llm_benchmark, mkmu, etc.
3. **Rails binstubs handle rbenv automatically** - the PATH prefix adds no value
4. **This is the exact workaround pattern documented in CE0001**

**What Codex should have done:**

1. Review recent results (R0005 onwards) showing the correct pattern: plain `bin/rails test`
2. Use standard Rails binstub commands without PATH manipulation
3. Trust that P0005's correction resolved the underlying environment issue

**Root cause:**

Codex either:
- Didn't review recent results and copy-pasted from old results (R0002-R0004)
- Failed to recognize the pattern was already corrected
- Reverted to workaround habit without checking current project state

**Impact:**

- Perpetuates incorrect workaround pattern in documentation
- Suggests the P0005 fix didn't work (when it did)
- Creates confusion about correct Rails command usage
- Pollutes RESULTS.md with obsolete workaround syntax

**Classification:** Codex implementation error - regression to previously-corrected workaround pattern, failure to maintain project consistency across prompts.

---

## CE0007 - Unauthorized Root Route Design (TSP-Specific)

**Date:** 2026-04-16  
**Prompt:** P0001  
**Error Type:** Codex implementation error - unauthorized design decision violating multi-algorithm intent

**What happened:**

Codex set `root "attempts#index"` in `config/routes.rb`, hardcoding TSP attempts as the application root route. This creates tight coupling between the root route and TSP, making it harder to add other algorithm families later.

**Evidence:**

```ruby
# config/routes.rb
root "attempts#index"

resources :attempts, only: [:index, :show] do
  resources :interpretations, only: [:create]
end
```

**Why this is an error:**

PLAN.md clearly states this is a **multi-algorithm benchmark**:
- "The algorithms are the test cases" (line 11)
- Goal is to document "LLM errors while implementing difficult engineering/math algorithms" (plural)
- TSP is just the first case study, not the only one

**P0001 specification:**

```
7. Web interface (minimal):
   - Page listing all attempts
   - Page showing single attempt: prompt_id, fixture, candidate result, reference result, difference
   - Form for PI to add interpretation classification and notes
```

P0001 requested generic "pages" without specifying root routing or implying TSP should be the application root.

**What Codex should have done:**

1. Recognize from PLAN.md that this is multi-algorithm benchmark
2. Either:
   - Create generic root (e.g., `root "challenges#index"` listing all algorithm types)
   - Ask PI which route should be root
   - Leave root unset until PI specifies
3. Make TSP attempts accessible via namespaced route (e.g., `/tsp/attempts`)

**Impact:**

- **Architectural coupling:** Root route now hardcoded to TSP
- **Scalability problem:** Adding Knapsack, Graph Coloring, or other algorithms requires refactoring root route
- **Violates intent:** PLAN.md envisioned algorithm-agnostic framework, not TSP-specific app

**Classification:** Codex implementation error - made architectural design decision (which algorithm owns root route) without authorization, violating multi-algorithm intent from PLAN.md.

**Severity:** Major (not critical) - creates technical debt and tight coupling, but doesn't break functionality or produce wrong results.


---

## CE0009 - Unauthorized Vendor Bundle Configuration

**Date:** 2026-04-17  
**Commit:** d72a988 (Initial commit)  
**Phase:** Project initialization

**Error:**

Codex configured `.bundle/config` with `BUNDLE_PATH: "vendor/bundle"` in the initial commit without PI authorization or requirement.

**Impact:**

1. **Reboot fragility:** Native extensions compiled in vendor/bundle become incompatible after Mac reboot
2. **Diverges from project standards:** Other Rails projects in `/Users/timbass/rails/` use system gems
3. **Requires manual intervention:** Every reboot requires `rm -rf vendor/bundle && bundle install`
4. **Not requested:** PI never asked for gem isolation or vendor bundling

**Root Cause:**

Codex made an architectural decision (gem installation location) without PI approval. This is a C003 violation - should have flagged as architectural checkpoint requiring PI approval.

**Evidence:**

```bash
$ git show d72a988:.bundle/config
---
BUNDLE_PATH: "vendor/bundle"
```

Error manifests after reboot as:
```
Could not find puma-8.0.0 ... linked to incompatible 
/Users/timbass/.rbenv/versions/3.2.2/lib/libruby.3.2.dylib
```

**Correction Required:**

1. Remove `.bundle/config` from repository
2. Remove `vendor/bundle` directory
3. Add `.bundle/` to `.gitignore`
4. Reinstall gems using system-wide location (default rbenv behavior)
5. Document that project uses system gems like all other Rails projects

**Classification:** Major architectural error - unauthorized configuration decision with recurring operational impact

**Related:** Violates C003 (architectural checkpoints) - gem installation location is an architectural decision affecting project portability and maintenance

---

# CE0010: UI Layout Regression After Max Flow Implementation

**Date:** 2026-04-18  
**Prompt:** P0022/R0022 (Max Flow Problem)  
**Severity:** Medium (functional code, broken UI)

## Error Description

After implementing Max Flow Problem (P0022/R0022), the algorithm index page UI broke:
- 4 algorithm cards now present (TSP, VRP, Assignment, Max Flow)
- Grid layout using `repeat(auto-fit, minmax(320px, 1fr))` caused awkward wrapping
- Cards not aligned properly on wide screens
- Layout looked broken compared to previous clean 3-card display

**Root cause:** Codex added Max Flow card but did not:
1. Check the UI in browser after implementation
2. Test how 4 cards would lay out in the grid
3. Adjust CSS for the new card count

## Impact

- ✅ **Functionality:** All features work correctly
- ❌ **UI/UX:** Homepage looks broken, unprofessional
- ❌ **Verification:** LLM did not validate visual output

**This is a classic LLM failure mode:** Code works, tests pass, but human-facing UI is broken.

## Why This Happened

**Pattern:** LLMs don't naturally verify visual output after changes.

They will:
- ✅ Write correct Rails code
- ✅ Add proper routes and controllers  
- ✅ Make tests pass
- ❌ Actually look at the rendered UI
- ❌ Check responsive behavior
- ❌ Verify layout with new content

**Lesson:** UI verification requires explicit checkpoint, not implicit testing.


## Fix Applied

Updated `app/assets/stylesheets/application.css`:

**Before:**
```css
.algorithm-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: 1rem;
}
```

**After:**
```css
.algorithm-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1.5rem;
  align-items: start;
}

@media (min-width: 1400px) {
  .algorithm-grid {
    grid-template-columns: repeat(4, 1fr);
  }
}
```

**Changes:**
- Reduced minmax from 320px to 280px (allows 4 cards to fit better)
- Increased gap from 1rem to 1.5rem (better spacing)
- Added `align-items: start` (prevents cards from stretching)
- Added media query for wide screens (explicit 4-column layout)

## Correction Needed

**New correction C008:** UI verification checkpoint

**Problem:** Code can pass all tests while breaking user-facing UI.

**Required behavior:**
1. After implementing features that affect UI, Coder must:
   - Start Rails server
   - Actually visit affected pages in browser
   - Take screenshot or describe what they see
   - Report any layout issues to Architect
2. Architect must include UI verification in acceptance criteria
3. PI performs final UI inspection

**Applies to:** Any change affecting views, stylesheets, or user-facing pages

---

**Status:** Fixed by PI  
**Pattern:** LLMs don't naturally check visual output  
**Frequency:** Common (happened in P0022)

---

## CE0011 - Scoped Attempts Page Fell Back to TSP and Leaked All Attempts

**Date:** 2026-04-22  
**Prompt:** P0023/R0023 (Minimum Cost Flow Problem)  
**Severity:** Medium (feature implemented, scoped UI behavior wrong)

### Error Description

After implementing the `Minimum Cost Flow Problem` lane, visiting `/min_cost_flow/attempts` showed the wrong page behavior:

- page title fell back to `TSP Attempts`
- TSP problem profile text was shown
- all attempts across all challenges were listed
- minimum-cost-flow scoping did not hold when the `Challenge` row was absent

This made the new route look like a TSP page with mixed benchmark data instead of a scoped Minimum Cost Flow attempt index.

### Root Cause

Codex introduced two linked implementation bugs:

1. **Controller fallback bug**
   In `AttemptsController#index`, scoped requests only filtered by challenge if `Challenge.find_by(name: params[:challenge_name])` returned a row.

   If the scoped challenge row did not yet exist in the database, `@challenge` became `nil`, and `scoped_attempts` returned `Attempt.all` instead of no records.

2. **View fallback bug**
   `app/views/attempts/index.html.erb` was not updated to recognize `Minimum Cost Flow Problem`.

   This left:
   - page title fallback at `TSP Attempts`
   - scoped filter-link fallback at `attempts_path`
   - attempt-link helper logic missing the `min_cost_flow` branch

### Why This Is a Codex Error

The implementation added:

- `min_cost_flow` routes
- challenge index card
- `Attempt#route_path_name` support

But Codex failed to complete the end-to-end wiring for the shared attempts index. This is a classic partial-integration bug:

- routing added
- backend model support added
- one shared UI surface not fully updated
- bad nil fallback exposed unrelated records

This was also a direct failure to follow an existing instruction already written for Codex:

```text
C008 - UI Verification Checkpoint
```

`C008` already required UI verification for user-facing changes. The scoped attempts page was a user-facing page, and Codex did not verify it adequately before treating the implementation as complete.

### Impact

- ✅ `P0023` solver/reference/validator/runner implementation worked
- ✅ `/min_cost_flow/attempts` route existed
- ❌ page rendered the wrong benchmark identity
- ❌ scoped route leaked all attempts when challenge record was missing
- ❌ user-facing behavior was misleading enough to look like the feature had not been implemented correctly

### Fix Applied

Two corrections were made:

1. **Controller fix**
   `AttemptsController#scoped_attempts` now returns `Attempt.none` for scoped routes when `challenge_name` is present but the corresponding `Challenge` row is missing.

2. **View fix**
   `app/views/attempts/index.html.erb` now includes a `Minimum Cost Flow Problem` branch for:
   - page title
   - scoped filter path
   - problem profile selection
   - attempt detail links

### Verification Added

Focused controller coverage was added for:

- minimum-cost-flow scoped attempts page renders `Min Cost Flow Attempts`
- scoped page shows min-cost-flow attempts rather than TSP attempts
- missing scoped challenge row renders `No attempts recorded` instead of leaking all attempts

Verification command:

```bash
bin/rails test test/controllers/attempts_controller_test.rb test/controllers/challenges_controller_test.rb
```

Output:

```text
19 runs, 161 assertions, 0 failures, 0 errors, 0 skips
```

### Compliance Failure

This error does **not** indicate a missing correction.

It indicates that Codex failed to comply with the correction already in force:

- `C008` should have caught the wrong page title
- `C008` should have caught the wrong problem profile text
- `C008` should have caught the leaked all-attempts dataset
- `C008` should have caught the broken scoped page identity

The failure was execution against existing instructions, not absence of instructions.

### Lesson

When extending a shared multi-algorithm UI, Codex must verify all of these together:

- route scope exists
- challenge lookup works with and without seeded records
- shared page titles/labels include the new challenge
- nil fallback does not silently widen scope to all records

This was not a solver bug. It was a shared-UI integration bug caused by incomplete propagation of a new challenge type through the generic attempts page.

---

## CE0012 - Results Ledger Left Out of Numeric Order

**Date:** 2026-04-23  
**Prompt:** P0024/R0024 and P0025/R0025 follow-up documentation  
**Severity:** Medium (research ledger integrity/documentation quality failure)

### Error Description

After documenting `R0024` and `R0025`, `DOCUMENTS/RESULTS.md` was left structurally disordered:

- `R0025` appeared before `R0024`
- `R0021` and `R0022` appeared after `R0024`
- the tail of the file no longer read in clean numeric sequence

This made the results ledger harder to trust and review, even though the underlying implementation content was present.

### Root Cause

Codex appended new result sections opportunistically where work was already in progress instead of normalizing the full tail of the results ledger.

The failure was not about missing content. It was about failing to maintain the repository's numbered research artifact in a clean ordered state after multiple incremental updates.

### Why This Is a Codex Error

`RESULTS.md` is a core experimental ledger, not incidental documentation. Ordered numbering is part of the project’s traceability model.

Codex should have treated the file as a numbered registry and verified:

- new result sections were inserted in numeric order
- prior result sections still appeared in numeric order after edits
- follow-up documentation notes did not leave the ledger structurally confusing

Instead, Codex left the file in a state where a reviewer could reasonably conclude the results trail was sloppy or unreliable.

### Impact

- ✅ implementation summaries themselves were present
- ✅ result content for `R0021` through `R0025` was preserved
- ❌ the numbered ledger was out of order
- ❌ repository-state review became unnecessarily confusing
- ❌ Claude correctly caught a real documentation-ordering problem

### Fix Applied

The tail of `DOCUMENTS/RESULTS.md` was reordered so the later result sections now appear in numeric sequence:

```text
R0021
R0022
R0023
R0024
R0025
```

### Lesson

For numbered research ledgers, “content exists” is not enough. Codex must also preserve ordering and registry hygiene.

When updating `PROMPTS.md`, `RESULTS.md`, or error ledgers:

- verify the new entry number
- verify surrounding entries remain in order
- treat the ledger like a journal index, not a scratchpad
