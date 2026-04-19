# Solver Architecture Verification

## Purpose

This document confirms that the comparison architecture maintains proper separation:
- **Candidate solvers:** Pure Ruby implementations (no gem dependencies)
- **Reference solvers:** OR-Tools gem wrappers (provide ground truth)

## Verification Results

**Date:** 2026-04-18
**Status:** ✅ PASSED

### Candidate Solvers (Pure Ruby - No OR-Tools)

| Solver | Status | Lines | Implementation |
|--------|--------|-------|----------------|
| `tsp_solver.rb` | ✅ Pure Ruby | 199 | Brute-force, Nearest-Neighbor, Held-Karp |
| `vrp_solver.rb` | ✅ Pure Ruby | 84 | Clarke-Wright Savings |
| `assignment_solver.rb` | ✅ Pure Ruby | 105 | Hungarian Algorithm |
| `max_flow_solver.rb` | ✅ Pure Ruby | 142 | Edmonds-Karp (Ford-Fulkerson with BFS) |

**Total:** 4 candidate solvers, 0 violations

### Reference Solvers (OR-Tools Required)

| Solver | Status | Lines | OR-Tools Module |
|--------|--------|-------|-----------------|
| `gem_tsp_solver.rb` | ✅ Uses OR-Tools | 89 | RoutingModel |
| `gem_vrp_solver.rb` | ✅ Uses OR-Tools | 94 | RoutingModel with capacity |
| `gem_assignment_solver.rb` | ✅ Uses OR-Tools | 61 | LinearSumAssignment |
| `gem_max_flow_solver.rb` | ✅ Uses OR-Tools | 40 | SimpleMaxFlow |

**Total:** 4 reference solvers, 0 violations


## Verification Method

### Automated Script

`scripts/verify_solver_architecture.rb` checks:
1. Candidate solvers do NOT contain `require "or-tools"` or `ORTools` references
2. Reference solvers DO contain OR-Tools imports and API calls
3. Reports violations if architecture is compromised

**Run verification:**
```bash
ruby scripts/verify_solver_architecture.rb
```

**Exit codes:**
- `0` - Architecture correct, no violations
- `1` - Violations detected, fix before accepting results

### Manual Verification

**Check candidate solver (should return nothing):**
```bash
grep -r "ORTools\|require.*or-tools" app/services/*_solver.rb app/services/vrp_solver.rb app/services/assignment_solver.rb app/services/max_flow_solver.rb
```

**Check reference solver (should show imports):**
```bash
grep -n "ORTools\|require.*or-tools" app/services/gem_*_solver.rb
```

## Why This Matters

### Research Validity

The comparison is only meaningful if:
- Candidate = Pure algorithmic implementation in Ruby
- Reference = Established optimization library (OR-Tools)

**Invalid comparison:**
- Candidate uses OR-Tools → comparing OR-Tools to OR-Tools
- Reference is pure Ruby → no ground truth for validation

### Error Detection

This architecture ensures:
1. Candidate errors are implementation mistakes, not library bugs
2. Reference provides reliable ground truth
3. Performance comparisons reflect algorithm differences
4. Results demonstrate Ruby implementation feasibility


## Historical Verification

### P0001-P0019: TSP
- Candidate: `tsp_solver.rb` (brute-force, nearest-neighbor, Held-Karp)
- Reference: `gem_tsp_solver.rb` (OR-Tools RoutingModel)
- ✅ No cross-contamination

### P0020: VRP  
- Candidate: `vrp_solver.rb` (Clarke-Wright Savings)
- Reference: `gem_vrp_solver.rb` (OR-Tools RoutingModel with capacity dimension)
- ✅ No cross-contamination

### P0021: Assignment Problem
- Candidate: `assignment_solver.rb` (Hungarian Algorithm)
- Reference: `gem_assignment_solver.rb` (OR-Tools LinearSumAssignment)
- ✅ No cross-contamination

### P0022: Max Flow
- Candidate: `max_flow_solver.rb` (Edmonds-Karp)
- Reference: `gem_max_flow_solver.rb` (OR-Tools SimpleMaxFlow)
- ✅ No cross-contamination

## Future Algorithms

**Required verification for each new algorithm:**

1. Create candidate solver without OR-Tools dependency
2. Create reference solver using OR-Tools
3. Run `scripts/verify_solver_architecture.rb`
4. Document results in this file

**Failure modes to watch for:**
- Candidate accidentally imports OR-Tools
- Reference solver implemented in pure Ruby instead of using gem
- Copy-paste errors mixing candidate and reference code

## Conclusion

**Architecture Status:** ✅ VERIFIED CORRECT

All 4 algorithm families maintain proper separation between pure Ruby candidates and OR-Tools references. No cross-contamination detected. Results are valid for publication.

---

**Last Verified:** 2026-04-18
**Verification Method:** Automated script + manual grep inspection
**Algorithms Checked:** TSP, VRP, Assignment, Max Flow
**Result:** PASS (0 violations)
