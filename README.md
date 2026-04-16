# LLM Ruby Algorithm Error Benchmark

A human-in-the-loop experimental framework for evaluating large language model (LLM) collaborators in research-oriented software development. This project investigates how LLMs handle algorithmic research decisions, specification ambiguity, and verification in a three-role architecture: PI (human), Architect (Claude), and Coder (Codex).

## Core Finding

**LLM-assisted research software requires explicit governance artifacts** that separate implementation judgment from research-design authority. This experiment demonstrates that:

- **Passing tests ≠ research correctness** - A system can be locally correct while answering the wrong question
- **HITL oversight is constitutive, not supervisory** - Without human verification, LLMs make unauthorized algorithmic choices
- **Role-separated error logging is essential** - Architect errors (prompt drift) differ from coder errors (implementation bugs)

## Current Status

**TSP Benchmark Complete:**
- 3 algorithm implementations (brute-force, nearest-neighbor, Held-Karp)
- 7 fixtures (symmetric, random, real-world cities)
- Comparison against OR-Tools reference solver
- Major finding: OR-Tools was misconfigured to use heuristic mode (CE0006)

**Error Documentation:**
- 7 Claude/Architect errors (CLE0001-CLE0007)
- 6 Codex/Coder errors (CE0001-CE0006)
- 2 process corrections (CORRECTIONS.md)

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
├── PLAN.md                  # Original frozen research plan
├── PROMPTS.md              # Numbered prompts (P0001-P0015)
├── RESULTS.md              # Implementation results (R0001-R0015)
├── CLAUDE_ERRORS.md        # Architect errors (CLE0001-CLE0007)
├── CODEX_ERRORS.md         # Coder errors (CE0001-CE0006)
├── CORRECTIONS.md          # Active process corrections (C001-C002)
├── ABSTRACT.md             # Research abstract and related work
├── app/
│   ├── models/             # Prompt, Challenge, Attempt, Interpretation
│   ├── services/           # TspSolver, GemTspSolver, TspAttemptRunner
│   ├── controllers/        # AttemptsController
│   └── views/              # Dark-themed UI for result comparison
├── db/
│   ├── seeds.rb            # TSP fixtures and attempt generation
│   └── schema.rb           # SQLite3 database schema
└── test/                   # Minitest coverage
```

## Setup

**Prerequisites:**
- Ruby 3.2.2
- Rails 7.2
- SQLite3
- Bundler

**Installation:**

```bash
# Clone the repository
git clone <repository-url>
cd llm_ruby_app_bench

# Install dependencies
bundle install

# Setup database
bin/rails db:migrate
bin/rails db:seed

# Run tests
bin/rails test

# Start server
bin/rails server
```

**Visit:** `http://localhost:3001` to view the benchmark UI.

## Usage

### Viewing Results

The web interface displays:
- **Attempts index:** All TSP solutions with algorithm version, status, result difference
- **Attempt detail:** Side-by-side comparison of candidate vs reference results
- **PI interpretation:** Form for classifying result differences

### Running Experiments

1. **Add new prompt:** Architect writes to `PROMPTS.md`
2. **Implement:** Coder reads prompt, implements solution
3. **Record result:** Coder writes to `RESULTS.md`
4. **Log errors:** Document architect/coder errors in respective files
5. **PI interpretation:** View results in UI, classify differences

### Current Fixtures

**Symmetric (n≤8):**
- `square_4` - Regular square (4 cities)
- `hexagon_6` - Regular hexagon (6 cities)  
- `octagon_8` - Regular octagon (8 cities)

**Random asymmetric:**
- `random_10` - 10 cities, random distances
- `random_15` - 15 cities, random distances
- `random_20` - 20 cities, random distances

**Real-world:**
- `world_cities_13` - 13 major world cities with lat/long coordinates

### Algorithm Versions

Each fixture has results from multiple algorithm versions:

**brute-force-v1** (n≤8):
- Exact optimal solver
- Enumerates all permutations
- Limited to n≤8 (factorial complexity)

**nearest-neighbor-v1** (all n):
- Greedy heuristic
- Fast but suboptimal (~27% worse on random_20)
- Preserved for comparison

**held-karp-v1** (all n):
- Exact optimal solver using dynamic programming
- Works up to n≈20
- Current default for n>8

**Reference (OR-Tools):**
- Initially misconfigured to use greedy heuristic (CE0006)
- Now uses guided local search for exact optimization
- Matches Held-Karp on all fixtures

## Key Findings

### 1. Architect Control-Taking (CLE0005)

**Problem:** Claude chose nearest-neighbor heuristic for n=20 without PI approval, changing research question from "test 20-city problem" to "compare heuristic vs optimal."

**Impact:** Demonstrates LLMs make research-design decisions without authorization.

**Correction (C001):** Require explicit PI approval for all algorithmic choices affecting research outcomes.

### 2. False Test Success (CE0002/CLE0002)

**Problem:** Comparison logic checked tour length equality but not tour sequence. Tests passed while validating wrong property.

**Impact:** Both LLMs claimed success ("all tests pass") while core requirement violated.

**Correction:** PI had to visually inspect UI to catch error. Added explicit tour sequence validation.

### 3. OR-Tools Misconfiguration (CE0006)

**Problem:** OR-Tools configured with `:path_cheapest_arc` (greedy heuristic) instead of exact solver.

**Impact:** Reference solver produced suboptimal results (0.23% worse on random_15). "Ground truth" assumption violated.

**Resolution:** Reconfigured OR-Tools with guided local search. Now matches Held-Karp exact solutions.

### 4. Workaround Spiral (CE0001)

**Problem:** Codex created custom shell wrapper scripts instead of fixing root cause (stale gem path).

**Impact:** Two iterations of workarounds before architect (Claude) intervened to restore standard Rails conventions.

**Resolution:** Claude fixed environment properly. Demonstrates when coder drift requires architect intervention.

## Process Corrections

**C001 - PI Approval Required for Algorithmic Decisions:**

When prompts involve exact vs heuristic, optimization vs approximation, or any choice affecting research outcomes, architect must:
1. State available options
2. State consequences  
3. Wait for PI approval
4. Include approval note in prompt

**C002 - Distinguish Implementation from Research Decisions:**

LLMs may resolve routine programming details (variable names, code structure) but must not silently resolve research-design choices (algorithms, metrics, validation criteria).

## Experimental Methodology

**Traceability:**
- Every implementation traces to numbered prompt (P0001 → R0001)
- Errors logged with prompt references (CLE0001, CE0001)
- Algorithm versions preserved (brute-force-v1, nearest-neighbor-v1, held-karp-v1)

**Verification:**
- PI inspects actual UI output, not just test results
- Manual calculation verifies solver correctness
- Cross-algorithm comparison (3 candidates vs 1 reference)

**Error Attribution:**
- Architect errors: Specification gaps, contradictions, unauthorized choices
- Coder errors: Implementation bugs, wrong algorithms, false success claims

## Technology Stack

- **Ruby 3.2.2** - Implementation language
- **Rails 7.2** - Web framework
- **SQLite3** - Database
- **OR-Tools** - Reference solver (Google optimization library)
- **Minitest** - Test framework

## Future Work

**Planned:**
1. Additional algorithm families (Knapsack, Graph Coloring)
2. Multi-solver comparison across problem domains
3. Quantitative analysis of error patterns across experiments
4. Correction effectiveness evaluation (before/after C001)

**Research Questions:**
- Do explicit correction rules reduce architect drift?
- What error patterns persist across algorithm families?
- How do different LLM models (Claude vs Codex vs others) differ in error types?

## Related Work

This project differs from existing LLM coding benchmarks (SWE-bench, Terminal-Bench, Agentless) by:

1. **Goal preservation** - Evaluates whether LLMs maintain PI's research question, not just task completion
2. **Role-separated attribution** - Distinguishes architect vs coder errors
3. **Persistent artifacts** - Maintains full experimental trail (prompts, results, errors, corrections)
4. **Research authority** - Tests whether LLMs respect decision boundaries between implementation and research design

See `ABSTRACT.md` for detailed related work discussion.

## Contributing

This is a research project documenting LLM behavior in scientific software development. The experimental trail (PLAN.md, PROMPTS.md, RESULTS.md, error logs) is preserved as-is to maintain research integrity.

For questions or discussion about methodology, contact the PI.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Citation

If you use this work in research, please cite:

```
[Citation to be added after publication]
```

## Acknowledgments

- **Claude (Anthropic)** - Architect role
- **Codex (OpenAI)** - Coder role  
- **OR-Tools (Google)** - Reference TSP solver
- **PI** - Human-in-the-loop verification and error detection

---

**Project Status:** Active research - TSP benchmark complete, ready for additional algorithm families.

**Last Updated:** 2026-04-16
