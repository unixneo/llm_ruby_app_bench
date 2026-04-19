# Algorithm Complexity Analysis - Beyond OR-Tools

## Purpose
Before committing to OR-Tools-only approach, evaluate what exists at TSP/VRP complexity level (NP-hard/NP-complete) outside operations research domain.

## Complexity Baseline (Current Implementation)

**TSP:** 
- Complexity: NP-hard
- Search space: Exponential O(n!)
- Verification: Tour length calculation
- Implementation difficulty: 8/10

**VRP:**
- Complexity: NP-hard  
- Search space: O(n! × m^n) for m vehicles
- Verification: Capacity constraints + tour length
- Implementation difficulty: 10/10

**Target:** Match or exceed this complexity outside OR domain

---

## Survey Results Summary

### NP-Hard/NP-Complete Outside OR: ❌ NO MATURE RUBY GEMS FOUND
See RUBYGEMS_NP_COMPLETE_SURVEY.md for full details.

### Physics/Scientific Computing: ✅ TWO STRONG CANDIDATES FOUND
See PHYSICS_DOMAIN_SURVEY.md for full details.

**Best candidates:**
1. **`orbit` gem** - Satellite propagation from TLEs (celestial mechanics)
2. **`astronoby` gem** - Astronomical events, Moon phases, ephemerides

---

## DECISION: Option A - Diverse Multi-Domain Approach

**Approved by PI:** 2026-04-17

### Algorithm Mix:
- **60% OR-Tools** (routing, flow, assignment, scheduling)
- **30% Celestial Mechanics** (`orbit` - satellite tracking)
- **10% Astronomy** (`astronoby` - Moon phases, ephemerides)

### Target: 40-50 prompts across three distinct algorithm families


---

## Rationale for Option A

### Three Distinct Error Surfaces:

**1. OR-Tools (Combinatorial Optimization):**
- Error surface: Algorithm selection, constraint modeling, search configuration
- Complexity: NP-hard discrete optimization
- LLM risks: Constraint misspecification, infeasible solutions, reference misconfiguration

**2. Celestial Mechanics (Numerical Physics):**
- Error surface: Coordinate transforms, time systems, unit conversions, orbital mechanics
- Complexity: Numerical integration, multi-frame calculations
- LLM risks: Radians/degrees confusion, reference frame errors, time scale mistakes

**3. Astronomy (Scientific Computing):**
- Error surface: Ephemeris handling, time scales, celestial coordinates
- Complexity: Multi-body dynamics, coordinate system conversions
- LLM risks: Julian date errors, coordinate precision, ephemeris interpolation

### Benefits:

1. ✅ **Demonstrates framework generalizability** - Works across optimization AND physics
2. ✅ **Different verification strategies** - Optimization (feasibility), Physics (tolerances)
3. ✅ **Diverse LLM challenges** - Discrete vs continuous, constraints vs coordinates
4. ✅ **Mature reference gems** - All verified functional (C005 compliance)
5. ✅ **Strong paper narrative** - "Governance across algorithm domains"

### Implementation Strategy:

**Phase 1: Strengthen OR-Tools base (2-3 algorithms)**
- Assignment Problem (Linear Sum Assignment)
- Max Flow / Min Cost Flow
- Solidify OR-Tools governance patterns

**Phase 2: Add Celestial Mechanics (2-3 algorithms)**
- Satellite propagation from TLEs (`orbit`)
- Look angle calculations
- Pass predictions

**Phase 3: Add Astronomy (1-2 algorithms)**
- Moon phase calculations (`astronoby`)
- Equinox/solstice timing
- Coordinate transforms

**Timeline:** 3-4 weeks to 40-50 prompts (if corrections continue working like VRP)


---

## Paper Scope Impact

### Title (proposed):
"Governance Framework for LLM-Assisted Algorithm Implementation: Evidence from Operations Research and Scientific Computing"

### Abstract themes:
- Multi-domain validation (optimization + physics)
- Role-specific error attribution (architect vs coder)
- Correction framework effectiveness (before/after comparison)
- Empirical evidence across 40-50 prompts

### Methodological strength:
- Not limited to single tool (OR-Tools) or single domain
- Shows framework works for discrete optimization AND continuous physics
- Different verification strategies (feasibility vs numerical tolerance)
- Broader generalizability claim

### Target journals:
- IEEE Transactions on Software Engineering
- ACM Transactions on Software Engineering and Methodology  
- Empirical Software Engineering (Springer)
- Journal of Systems and Software (Elsevier)

---

## Next Steps

1. ✅ **Decision made:** Option A (multi-domain)
2. **Next algorithm:** Assignment Problem or Max Flow (OR-Tools)
3. **Gem installation:** Install `orbit` and `astronoby` when ready for physics phase
4. **Continue testing corrections:** Validate C001-C007 across new domains

**Document Status:** Decision recorded, Option A approved
**Date:** 2026-04-17
