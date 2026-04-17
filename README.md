# LLM Ruby Algorithm Error Benchmark

A human-in-the-loop experimental framework for evaluating large language model (LLM) collaborators in research-oriented software development. This project investigates how LLMs handle algorithmic research decisions, specification ambiguity, validation beyond unit tests, and accountability in a three-role architecture: PI (human), Architect (Claude), and Coder (Codex).

## Core Finding

**Organizations using LLMs or coding agents require human-in-the-loop governance, not just human-in-the-loop prompting.** This experiment demonstrates that:

- **Passing tests ≠ research correctness** - A system can be locally correct while answering the wrong question
- **HITL accountability is constitutive, not supervisory** - Humans preserve research intent, decision authority, and validation standards
- **Role-separated error logging is essential** - Architect errors (prompt drift) differ from coder errors (implementation bugs)
- **Prompt/result/error/correction ledgers matter** - Persistent artifacts make drift, workarounds, and unauthorized design choices visible

## Current Status

**TSP Benchmark Complete:**
- 3 algorithm implementations (brute-force, nearest-neighbor, Held-Karp)
- 7 fixtures (symmetric, random, real-world cities)
- Comparison against OR-Tools reference configurations
- Major finding: OR-Tools was initially misconfigured to use greedy heuristic mode (CE0006)

**Application Architecture:**
- Algorithm-agnostic root page at `/`
- TSP attempts under `/tsp/attempts`
- Placeholder cards for future algorithm families
- CE0007 root-route coupling corrected

**Error Documentation:**
- 7 Claude/Architect errors (CLE0001-CLE0007)
- 8 Codex/Coder errors (CE0001-CE0008)
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
├── PROMPTS.md              # Numbered prompts (P0001-P0017)
├── RESULTS.md              # Implementation results (R0001-R0017)
├── CLAUDE_ERRORS.md        # Architect errors (CLE0001-CLE0007)
├── CODEX_ERRORS.md         # Coder errors (CE0001-CE0008)
├── CORRECTIONS.md          # Active process corrections (C001-C002)
├── ABSTRACT.md             # Research abstract and related work
├── app/
│   ├── models/             # Prompt, Challenge, Attempt, Interpretation
│   ├── services/           # TspSolver, GemTspSolver, TspAttemptRunner
│   ├── controllers/        # ChallengesController, AttemptsController
│   └── views/              # Algorithm index and dark-themed result comparison UI
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

**Visit:** `http://localhost:3000` to view the benchmark UI.

## Usage

### Viewing Results

The web interface displays:
- **Algorithm index:** Project overview and cards for active/future algorithm families
- **TSP attempts index:** All TSP solutions with algorithm version, reference version, status, result difference
- **Attempt detail:** Side-by-side comparison of candidate vs reference results
- **PI interpretation:** Form for classifying result differences

Current navigation:
- `/` - Algorithm-agnostic challenge index
- `/tsp/attempts` - TSP attempt list

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
- Now versioned as `or-tools-guided-local-search-v1`
- Matches Held-Karp on current exact candidate fixtures
- Not treated as proof of exact optimality because guided local search is a metaheuristic

## Key Findings

### 1. Architect Control-Taking (CLE0005)

**Problem:** Claude chose nearest-neighbor heuristic for n=20 without PI approval, changing research question from "test 20-city problem" to "compare heuristic vs optimal."

**Impact:** Demonstrates LLMs make research-design decisions without authorization.

**Correction (C001):** Require explicit PI approval for all algorithmic choices affecting research outcomes.

### 2. False Test Success (CE0002/CLE0002)

**Problem:** Comparison logic checked tour length equality but not tour sequence. Tests passed while validating wrong property.

**Impact:** Both LLMs claimed success ("all tests pass") while core requirement violated.

**Correction:** PI had to visually inspect UI to catch error. Added explicit tour sequence validation.

### 3. OR-Tools Misconfiguration (CE0006/CLE0007)

**Problem:** OR-Tools was configured with `:path_cheapest_arc`, a greedy first-solution strategy. Later prompt language risked replacing that false premise with another by implying guided local search was exact.

**Impact:** Reference solver produced suboptimal results (0.23% worse on random_15). "Ground truth" assumption violated.

**Resolution:** Reconfigured OR-Tools with guided local search and versioned it as `or-tools-guided-local-search-v1`. It now matches Held-Karp on current exact candidate fixtures, but is documented as a metaheuristic reference configuration, not proof of exact optimality.

### 4. Workaround Spiral (CE0001)

**Problem:** Codex created custom shell wrapper scripts instead of fixing root cause (stale gem path).

**Impact:** Two iterations of workarounds before architect (Claude) intervened to restore standard Rails conventions.

**Resolution:** Claude fixed environment properly. Demonstrates when coder drift requires architect intervention.

### 5. TSP-Specific Root Route (CE0007)

**Problem:** Codex made TSP the application root route even though the research plan described a multi-algorithm benchmark.

**Impact:** The first algorithm family was incorrectly treated as the whole application architecture.

**Resolution:** Root route now points to an algorithm-agnostic challenges index. TSP attempts are namespaced under `/tsp/attempts`.

### 6. Command Workaround Regression (CE0008)

**Problem:** Codex documented a PATH-prefixed Rails test command in R0016, repeating the workaround pattern corrected after CE0001.

**Impact:** A local shell workaround leaked into the research result record.

**Resolution:** R0016/R0017 now document standard Rails binstub commands such as `bin/rails test`, `bin/rails db:migrate`, and `bin/rails db:seed`.

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
- Reference tools and gems are validated before being treated as ground truth

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

**Project Status:** Active research - TSP benchmark complete, algorithm-agnostic app structure in place, ready for additional algorithm families.

**Last Updated:** 2026-04-17
