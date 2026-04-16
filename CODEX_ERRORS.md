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
