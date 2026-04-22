# Next Project Shortlist for Architect Review

## Date

2026-04-22

## Purpose

Provide a separate, reviewable shortlist of benchmark candidates that fit the core methodology of `llm_ruby_app_bench`:

- GenAI writes the native Ruby candidate implementation
- a mature Ruby gem provides the comparative reference
- outputs can be compared in a disciplined way
- benchmark results remain interpretable by the PI

This file is intended for Claude/Architect review before any new prompts are added to `DOCUMENTS/PROMPTS.md`.

---

## Selection Rule

Candidates should satisfy all of the following:

1. The problem is mathematically or algorithmically substantive.
2. A credible Ruby gem reference exists and has been functionally verified.
3. A native Ruby implementation is feasible without calling the reference gem.
4. Comparison can be expressed clearly in the Rails app.
5. The benchmark contributes a distinct LLM error surface.

---

## Ranked Shortlist

### 1. Min Cost Flow

**Reference:** OR-Tools  
**Status:** Strongest immediate fit  
**Why it fits:**
- Extends current max-flow work without changing benchmark architecture
- Adds cost accounting, residual-graph reasoning, and flow optimality checks
- Candidate/reference comparison remains objective

**Expected LLM failure modes:**
- capacity/flow conservation errors
- incorrect shortest-path or residual updates
- correct feasible flow but non-optimal cost
- confusion between max flow and min cost flow objectives

**Recommendation:** Highest priority next OR prompt

---

### 2. Job Shop Scheduling

**Reference:** OR-Tools  
**Status:** Strong fit  
**Why it fits:**
- Constraint-heavy benchmark with clear reference support
- Distinct from routing and flow despite staying in OR
- Good publication value for governance and specification drift

**Expected LLM failure modes:**
- precedence constraint violations
- machine overlap errors
- incorrect makespan calculation
- false completion claims on partially feasible schedules

**Recommendation:** Highest-value scheduling benchmark

---

### 3. CVRP / VRP with Time Windows

**Reference:** OR-Tools  
**Status:** Strong fit  
**Why it fits:**
- Natural extension of existing VRP lane
- Preserves current comparison model
- Adds time-window constraints and richer feasibility validation

**Expected LLM failure modes:**
- omitted time-window constraints
- route feasibility errors
- depot timing mistakes
- presenting heuristic output as fully compliant

**Recommendation:** Good if the project wants to deepen the routing family

---

### 4. Moon Phase / Lunar Event Calculations

**Reference:** `astronoby`  
**Status:** Best non-OR candidate  
**Why it fits:**
- Clear numeric/timestamp outputs
- Distinct scientific-computing error surface
- More modern maintenance signal than `orbit`

**Expected LLM failure modes:**
- UTC/local time confusion
- Julian date conversion errors
- event boundary mistakes near month transitions
- tolerance/rounding errors presented as exact results

**Recommendation:** Highest-priority astronomy benchmark

---

### 5. Equinox / Solstice Timing

**Reference:** `astronoby`  
**Status:** Strong non-OR candidate  
**Why it fits:**
- Similar strengths to Moon-phase calculations
- Good fit for time-system and numerical-tolerance analysis
- Outputs are easy to present in the Rails UI

**Expected LLM failure modes:**
- time-scale mismatch
- wrong epoch assumptions
- off-by-one-day or timezone presentation bugs
- incorrect conversion between civil time and astronomical time

**Recommendation:** Strong second astronomy benchmark

---

### 6. Satellite Look Angle from TLE

**Reference:** `orbit`  
**Status:** Good candidate, older reference gem  
**Why it fits:**
- Strong benchmark for units, coordinates, and time handling
- Tolerance-based comparison is straightforward
- Good scientific-computing complement to OR

**Expected LLM failure modes:**
- radians/degrees confusion
- latitude/longitude handling errors
- time parsing mistakes
- incorrect observer-frame transformation

**Caution:**
- `orbit` is useful but old, so the Architect should decide whether its maintenance age is acceptable for the paper narrative

**Recommendation:** Good celestial-mechanics candidate if older gem age is acceptable

---

### 7. Satellite Pass Prediction

**Reference:** `orbit`  
**Status:** Good candidate, more complex than single-time look angle  
**Why it fits:**
- Adds event detection over time rather than point evaluation
- Better UI potential than a single scalar calculation
- Exposes algorithmic drift in iteration and threshold logic

**Expected LLM failure modes:**
- missed rise/set events
- wrong visibility threshold logic
- timestamp drift across iterations
- incorrect handling of edge cases near the horizon

**Recommendation:** Good follow-on if `orbit` is accepted

---

### 8. SAT Solver

**Reference:** `ravensat`  
**Status:** Strongest non-OR discrete candidate  
**Why it fits:**
- Preserves native Ruby vs gem-reference methodology
- Provides a hard reasoning benchmark outside routing/flow
- Good contrast with numeric scientific-computing lanes

**Expected LLM failure modes:**
- clause evaluation mistakes
- incorrect CNF handling
- unsound satisfiability claims
- returning assignments that do not satisfy all clauses

**Recommendation:** Best non-OR discrete benchmark if the project wants Boolean reasoning

---

### 9. Shortest Path

**Reference:** `rgl`  
**Status:** Valid but lower priority  
**Why it fits:**
- Mature graph library with functional support
- Easy to compare
- Useful as a control benchmark

**Limitations:**
- Lower complexity and weaker novelty than top-ranked items
- Less aligned with the current "hard benchmark" narrative

**Recommendation:** Use as a control or warm-up benchmark, not a flagship next step

---

### 10. Minimum Spanning Tree

**Reference:** `rgl`  
**Status:** Valid but lower priority  
**Why it fits:**
- Clear objective comparison
- Mature graph-library support
- Good for sanity-checking candidate/reference framework generalization

**Limitations:**
- Easier and less distinctive than OR scheduling, astronomy, or SAT

**Recommendation:** Lower-priority control benchmark

---

## Recommended Sequence

If the project wants the strongest near-term roadmap while preserving methodological clarity:

1. Min Cost Flow
2. Job Shop Scheduling
3. Moon Phase / Lunar Event Calculations
4. Satellite Look Angle from TLE
5. SAT Solver

This sequence keeps the benchmark grounded in:

- proven OR-Tools comparative analysis
- one astronomy lane with modern gem support
- one celestial-mechanics lane with explicit caution about gem age
- one non-OR discrete reasoning lane

---

## Do Not Select Without New Verification

- Knapsack
- Graph Coloring
- proof-style Olympiad tasks without gem references
- `ruby-minisat` unless native build and API are deliberately verified
- `2-SAT` as a flagship benchmark

---

## Questions for Architect Review

Claude/Architect should review and answer:

1. Which of the top five candidates best strengthens the paper narrative?
2. Is `orbit` sufficiently credible despite its age, or should astronomy via `astronoby` be prioritized first?
3. Should the next phase emphasize depth in OR-Tools or broader domain coverage?
4. Is SAT via `ravensat` strong enough to justify a new discrete-logic lane now, or should it wait until after one astronomy benchmark?
5. Which candidate should become `P0023`?

---

## Decision Boundary

This file is a review artifact only. It should not be treated as an approved roadmap until the PI and Architect choose the next prompt explicitly.

---

## Review Outcome

### Date

2026-04-22

### Status

Reviewed for Architect consideration. `PROMPTS.md` remains unchanged.

### Current Recommendation

Based on PI-side review of this shortlist:

1. `Min Cost Flow` is the preferred next benchmark candidate.
2. `Min Cost Flow` should be considered the leading candidate for `P0023`, subject to Architect authorship and approval workflow.
3. `astronoby` should be prioritized before `orbit` for the first non-OR expansion because it offers a stronger maintenance signal.
4. `SAT` via `ravensat` should wait until after at least one astronomy benchmark is established.
5. `rgl` graph algorithms remain valid but lower-priority control benchmarks rather than flagship next steps.

### Sequencing Guidance

The current preferred sequence is:

1. `Min Cost Flow`
2. `Job Shop Scheduling`
3. `Moon Phase / Lunar Event Calculations`
4. `Satellite Look Angle from TLE`
5. `SAT Solver`

### Reasoning Summary

- `Min Cost Flow` preserves the existing OR-Tools comparison infrastructure while adding genuine algorithmic complexity.
- Extending from `Max Flow` to `Min Cost Flow` creates a cleaner methodological progression than jumping immediately to a new domain.
- `astronoby` provides the strongest first non-OR breadth expansion because it is more current than `orbit`.
- `SAT` remains attractive, but should be deferred until one astronomy benchmark establishes cross-domain generalization first.

### Constraint Reminder

This recommendation does not authorize prompt creation. Under the project workflow, only Claude/Architect should write coding prompts into `DOCUMENTS/PROMPTS.md`.
