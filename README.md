# LLM Ruby Algorithm Error Benchmark

![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.19650594.svg)](https://doi.org/10.5281/zenodo.19650594)

A human-in-the-loop experimental framework for evaluating large language model (LLM) collaborators in research-oriented software development. This project investigates how LLMs handle algorithmic research decisions, specification ambiguity, validation beyond unit tests, and accountability in a three-role architecture: PI (human), Architect (Claude), and Coder (Codex).

**Current release:** v0.1.0

## Core Finding

**Organizations using LLMs or coding agents require human-in-the-loop governance, not just human-in-the-loop prompting.** This experiment demonstrates that:

- **Passing tests ≠ research correctness** - A system can be locally correct while answering the wrong question
- **HITL accountability is constitutive, not supervisory** - Humans preserve research intent, decision authority, and validation standards
- **Role-separated error logging is essential** - Architect errors (prompt drift) differ from coder errors (implementation bugs)
- **Prompt/result/error/correction ledgers matter** - Persistent artifacts make drift, workarounds, and unauthorized design choices visible
- **Governance framework validated** - Corrections enabled clean VRP and Assignment implementations, while Max Flow exposed a UI-verification gap now covered by C008

## Current Status

**Algorithms Implemented:**

1. **TSP (Traveling Salesman Problem)** - P0001-P0019
   - 3 implementations: brute-force (n≤8), nearest-neighbor (heuristic), Held-Karp (exact DP)
   - 7 fixtures: symmetric, random, real-world cities
   - Reference: OR-Tools RoutingModel with guided local search

2. **VRP (Vehicle Routing Problem)** - P0020
   - Clarke-Wright Savings algorithm (PI-approved)
   - Multi-vehicle capacity-constrained routing
   - 5 fixtures: n=5 to n=20 customers, m=2 to m=5 vehicles
   - Reference: OR-Tools RoutingModel with capacity dimension

3. **Assignment Problem** - P0021
   - Hungarian algorithm (exact polynomial O(n³))
   - Linear sum assignment with cost minimization
   - 5 fixtures: 3×3 to 15×15 workers and tasks
   - Reference: OR-Tools LinearSumAssignment
   - **All 5 fixtures achieved exact optimal match** (difference 0.0)

4. **Max Flow Problem** - P0022
   - Edmonds-Karp algorithm (exact polynomial O(VE²))
   - Directed network flow with capacity constraints and flow conservation
   - 5 fixtures: 4 to 15 nodes
   - Reference: OR-Tools SimpleMaxFlow
   - **All 5 fixtures achieved exact optimal match** (difference 0.0)

**Error Documentation:**
- 12 Claude/Architect errors (CLE0001-CLE0012)
- 10 Codex/Coder errors (CE0001-CE0010)
- 8 active corrections (C001-C008)

**Recent Major Findings:**

- **P0021 success:** Hungarian algorithm achieved optimal cost on all 5 fixtures with zero implementation errors
- **P0022 success:** Edmonds-Karp achieved exact max-flow match on all 5 fixtures
- **CE0010/C008:** Max Flow implementation passed tests but shipped a UI layout regression caught by PI inspection; C008 now requires UI verification for UI changes
- **Governance validation:** Two consecutive clean implementations (VRP P0020, Assignment P0021) after corrections established
- **CLE0012:** Manual verification error in P0021 prompt (documented cost 10, actual optimal 9) - architecture self-corrected
- **Framework generalizes:** Works across NP-hard heuristics (TSP/VRP) and exact polynomial algorithms (Assignment/Max Flow)
- **CLE0010:** Insufficient gem verification - `knapsack` gem is CI tool, not algorithm solver
- **CE0009:** Unauthorized vendor bundle configuration caused reboot incompatibility (fixed)


## Strategic Direction: Multi-Domain Approach

**Decision (2026-04-17):** Option A - Diverse algorithm families across optimization and physics

**Algorithm Mix (Target: 40-50 prompts):**
- **60% Operations Research** (OR-Tools)
  - Routing: TSP ✅, VRP ✅, CVRP, VRPTW
  - Assignment: Linear sum ✅, quadratic assignment
  - Flow: Max flow ✅, min cost flow
  - Scheduling: Job shop scheduling
  
- **30% Celestial Mechanics** (`orbit` gem)
  - Satellite propagation from TLEs
  - Look angle calculations
  - Pass predictions
  
- **10% Astronomy** (`astronoby` gem)
  - Moon phase calculations
  - Equinox/solstice timing
  - Coordinate transforms

**Rationale:** 
- Three distinct error surfaces (combinatorial, numerical, astronomical)
- Demonstrates framework works across discrete AND continuous problems
- All reference gems verified functional per C005
- Stronger generalizability for journal publication

**Paper scope:** "Governance Framework for LLM-Assisted Algorithm Implementation: Evidence from Operations Research and Scientific Computing"

See `DOCUMENTS/ALGORITHM_COMPLEXITY_SURVEY.md` and `DOCUMENTS/PHYSICS_DOMAIN_SURVEY.md` for complete analysis.

**Progress:** 22 prompts complete (19 TSP + 1 VRP + 1 Assignment + 1 Max Flow) = 44% of 50-prompt target

## Three-Role Architecture

```
┌─────────┐         ┌───────────┐         ┌────────┐
│   PI    │ ────▶   │  Claude   │ ────▶   │ Codex  │
│ (Human) │ directs │(Architect)│ prompts │(Coder) │
└─────────┘         └───────────┘         └────────┘
     │                     │                    │
     │                     │                    │
     └─────── verifies ────┴──── implements ───┘
```

**Roles:**
- **PI (Principal Investigator):** Sets research direction, interprets results, catches errors through UI inspection
- **Architect (Claude):** Writes numbered prompts defining scope, constraints, success criteria
- **Coder (Codex):** Implements prompts, runs tests, reports results

**Critical insight:** LLMs will make research-design decisions (exact vs heuristic, speed vs accuracy) without authorization. The three-role separation makes these substitutions visible.

## Project Structure

```
llm_ruby_app_bench/
├── DOCUMENTS/
│   ├── PLAN.md             # Frozen research charter
│   ├── PROMPTS.md          # Numbered prompts (P0001-P0022)
│   ├── RESULTS.md          # Implementation results (R0001-R0022)
│   ├── CLAUDE_ERRORS.md    # Architect errors (CLE0001-CLE0012)
│   ├── CODEX_ERRORS.md     # Coder errors (CE0001-CE0010)
│   ├── CORRECTIONS.md      # Active corrections (C001-C008)
│   ├── RUBYGEMS_SURVEY.md  # Algorithm gem verification
│   └── ABSTRACT.md         # Research abstract
├── app/
│   ├── models/             # Challenge, Attempt, TspProblem, VrpProblem, AssignmentProblem, MaxFlowProblem
│   ├── services/           # Algorithm solvers and runners
│   ├── controllers/        # Challenges, Attempts controllers
│   └── views/              # Algorithm index and result comparison UI
├── db/
│   ├── seeds.rb            # TSP, VRP, Assignment, and Max Flow fixtures
│   └── schema.rb           # SQLite3 schema
└── test/                   # 80 tests, 781 assertions
```

## Setup

**Prerequisites:**
- Ruby 3.2.2 (via rbenv)
- Rails 7.2
- SQLite3
- Bundler

**Installation:**

```bash
# Clone the repository
git clone https://github.com/unixneo/llm_ruby_app_bench
cd llm_ruby_app_bench

# Install dependencies (uses system gems, not vendor/bundle)
bundle install

# Setup database
bin/rails db:migrate
bin/rails db:seed

# Run tests (full suite ~49 seconds)
bin/rails test

# Fast development test run (skips expensive Held-Karp tests, ~23 seconds)
SKIP_HELD_KARP=1 bin/rails test

# Start server
bin/rails server
```

**Visit:** `http://localhost:3000`

## Usage

### Viewing Results

The web interface displays:
- **Algorithm index (`/`):** Project overview and cards for TSP, VRP, Assignment, and Max Flow
- **TSP attempts (`/tsp/attempts`):** All TSP solutions with version comparison
- **VRP attempts (`/vrp/attempts`):** All VRP solutions with capacity and distance comparison
- **Assignment attempts (`/assignment/attempts`):** All Assignment solutions with optimal-cost comparison
- **Max Flow attempts (`/max_flow/attempts`):** All Max Flow solutions with capacity and conservation validation
- **Attempt detail:** Side-by-side candidate vs reference comparison
- **PI interpretation:** Result classification form

### Running Experiments

1. **Add new prompt:** Architect writes to `DOCUMENTS/PROMPTS.md` (with PI approval for research decisions per C001)
2. **Implement:** Coder reads prompt, implements solution
3. **Record result:** Coder writes to `DOCUMENTS/RESULTS.md`
4. **Log errors:** Document architect/coder errors in respective files
5. **PI interpretation:** View results in UI, classify differences

### Test Runtime

**Full suite (49 seconds):**
```bash
bin/rails test
```

**Fast development run (23 seconds, skips 13 Held-Karp tests):**
```bash
SKIP_HELD_KARP=1 bin/rails test
```

Note: Use full suite for CI, release checks, and final prompt verification.

### Current Fixtures

**TSP Fixtures (7):**

*Symmetric (n≤8):*
- `square_4` - Regular square
- `hexagon_6` - Regular hexagon
- `octagon_8` - Regular octagon

*Random asymmetric:*
- `random_10`, `random_15`, `random_20`

*Real-world:*
- `world_cities_13` - Major cities with lat/long

**VRP Fixtures (5):**
- `vrp_small_5` - 5 customers, 2 vehicles, capacity=15
- `vrp_symmetric_8` - 8 customers, 2 vehicles, capacity=20
- `vrp_asymmetric_10` - 10 customers, 3 vehicles, capacity=18
- `vrp_tight_capacity_12` - 12 customers, 3 vehicles, capacity=30 (tight constraints)
- `vrp_larger_20` - 20 customers, 5 vehicles, capacity=25

**Assignment Fixtures (5):**
- `assignment_tiny_3x3`
- `assignment_small_5x5`
- `assignment_asymmetric_8x8`
- `assignment_sparse_10x10`
- `assignment_dense_15x15`

**Max Flow Fixtures (5):**
- `maxflow_simple_4`
- `maxflow_bottleneck_6`
- `maxflow_parallel_8`
- `maxflow_complex_12`
- `maxflow_dense_15`

### Algorithm Versions

**TSP:**
- `brute-force-v1` - Exact (n≤8)
- `nearest-neighbor-v1` - Greedy heuristic
- `held-karp-v1` - Exact DP solver (n≤20)
- Reference: `or-tools-routing-guided-local-search-v1`

**VRP:**
- `clarke-wright-savings-v1` - Constructive heuristic (PI-approved)
- Reference: `or-tools-routing-cvrp-guided-local-search-v1`

**Assignment:**
- `hungarian-v1` - Exact polynomial solver
- Reference: `or-tools-linear-sum-assignment-v1`

**Max Flow:**
- `edmonds-karp-v1` - Exact polynomial solver
- Reference: `or-tools-simple-max-flow-v1`

## Key Findings

### Recent Errors (2026-04-17 Session)

**CLE0008 - Algorithm Selection Without Gem Verification:**
Claude added UI placeholders for Knapsack, Graph Coloring, and Shortest Path without verifying Ruby gems exist. Graph Coloring has no available gem. Correction: C005 requires RubyGems survey before algorithm selection.

**CLE0009 - New Chat Session Context Loss:**
Failed to read project files (`DOCUMENTS/PLAN.md`, `DOCUMENTS/CORRECTIONS.md`) at session start despite explicit PI directive. Wasted 70+ exchanges before recognizing workflow violation. Correction: C006 session initialization protocol.

**CLE0010 - Insufficient Gem Verification:**
`DOCUMENTS/RUBYGEMS_SURVEY.md` listed `knapsack` gem as verified without checking functionality. Gem is CI test-splitting tool, not algorithm solver. P0020 (Knapsack) blocked correctly by Codex (C004/C005 worked). Superseded with VRP using OR-Tools.

**CLE0011 - Deliberate Misrepresentation:**
When asked for "all algorithms in OR-Tools", initially provided 7, only revealed 54 modules when challenged. Not honest mistake - had complete list available. Correction: C007 completeness verification.

**CE0009 - Unauthorized Vendor Bundle Configuration:**
Codex set `BUNDLE_PATH: "vendor/bundle"` in initial commit without authorization. Caused native extension incompatibility after Mac reboots. Fixed by removing .bundle/config and using system gems.

### TSP Findings

**CLE0005 - Architect Control-Taking:**
Claude chose nearest-neighbor heuristic for n=20 without PI approval, changing research question. Correction: C001 requires PI approval for algorithmic decisions.

**CE0002/CLE0002 - False Test Success:**
Comparison logic checked tour length but not sequence. Tests passed while core requirement violated. Fixed by explicit sequence validation.

**CE0006/CLE0007 - OR-Tools Misconfiguration:**
Initially configured with greedy `:path_cheapest_arc` strategy. Corrected to guided local search, versioned as reference (not exact proof).

**CE0001 - Workaround Spiral:**
Custom shell wrappers instead of fixing root cause. Took two iterations before proper fix.

**CE0007 - TSP-Specific Root Route:**
Made TSP the root despite multi-algorithm intent. Fixed with algorithm-agnostic `/` index.

**CE0008 - Command Workaround Regression:**
PATH-prefixed commands leaked into results. Fixed with standard Rails binstubs.

### VRP Findings

**Successful Implementation:**
- All 5 fixtures produce feasible solutions (capacity constraints satisfied)
- Clarke-Wright Savings performing well vs OR-Tools optimization
- 2 fixtures show perfect distance match (0.0 difference)
- Largest gap: 9.043 units on 20-customer problem (heuristic vs optimization)

## Process Corrections (C001-C008)

**C001 - PI Approval for Algorithmic Decisions:**
Architect must present options, state consequences, wait for approval, document in prompt.

**C002 - Distinguish Implementation from Research:**
LLMs may resolve routine details but not research-design choices.

**C003 - Flag Architectural Checkpoints:**
LLMs must STOP and flag decisions affecting architecture, research validity, or patterns.

**C004 - Codex Must Reject Unapproved Substitutions:**
Coder must verify PI approval exists in conversation history before implementing research decisions.

**C005 - Algorithm Selection Requires Gem Verification:**
MUST complete RubyGems survey, verify gem exists and is functional, test API, document before suggesting algorithms.

**C006 - Session Initialization Protocol:**
When PI provides file reading instructions, MUST read files BEFORE any engagement.

**C007 - Completeness Verification:**
When asked for "all" or "complete list", verify count explicitly, never present partial as complete.

**C008 - Mandatory UI Verification for UI Changes:**
Any change touching views, routes, controllers, CSS, or user-visible layout requires browser/server verification and reporting.

## Experimental Methodology

**Traceability:**
- Every implementation → numbered prompt (P0001 → R0001)
- Errors logged with references (CLE/CE numbers)
- Algorithm versions preserved and compared

**Verification:**
- PI inspects UI output, not just tests
- Reference tools validated before use
- Cross-algorithm comparison
- Governance framework (C004/C005) catches errors

**Error Attribution:**
- Architect errors: Spec gaps, unauthorized choices, misrepresentation
- Coder errors: Implementation bugs, false claims, architectural overreach

## Technology Stack

- **Ruby 3.2.2** (rbenv managed)
- **Rails 7.2**
- **SQLite3**
- **OR-Tools 0.17.1** - Reference solver (Google)
- **Minitest** - 80 tests, 781 assertions

## Future Work

**Planned:**
1. Additional OR-Tools algorithms (Min Cost Flow, Scheduling, CVRP/VRPTW variants)
2. Quantitative error pattern analysis
3. Correction effectiveness evaluation
4. Multi-LLM comparison

**Research Questions:**
- Do corrections reduce drift over time?
- What patterns persist across algorithms?
- How do error types differ between LLM models?

## Related Work

Differs from SWE-bench, Terminal-Bench, Agentless by:
- **Goal preservation** evaluation
- **Role-separated attribution**
- **Persistent artifacts** (full experimental trail)
- **Research authority** boundaries

See `DOCUMENTS/ABSTRACT.md` for detailed discussion.

## Contributing

This is a research project documenting LLM behavior. The experimental trail (`DOCUMENTS/PLAN.md`, `DOCUMENTS/PROMPTS.md`, `DOCUMENTS/RESULTS.md`, error logs) is preserved as-is for research integrity.

## License

MIT License

## Citation

Citation metadata is available in `CITATION.cff`. Zenodo metadata is available in `.zenodo.json`.

Current archival release version: **v0.1.0**

After a Zenodo DOI is minted, cite the archived release DOI rather than only the GitHub repository URL.

## Acknowledgments

- **Claude (Anthropic)** - Architect role
- **Codex (OpenAI)** - Coder role
- **OR-Tools (Google)** - Reference solver
- **PI** - Human-in-the-loop verification

---

**Project Status:** Active - TSP complete (19 prompts), VRP complete (1 prompt), Assignment complete (1 prompt), Max Flow complete (1 prompt), 12 Claude errors, 10 Codex errors, 8 corrections active

**Repository:** https://github.com/unixneo/llm_ruby_app_bench

**Release Version:** v0.1.0

**Last Updated:** 2026-04-19
