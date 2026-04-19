# LLM Ruby Algorithm Error Benchmark

## Goal

Build a small Rails research app for documenting LLM errors while implementing difficult engineering/math algorithms in Ruby.

The main research target is LLM behavior:

- mathematical mistakes
- wrong algorithms
- constraint violations
- goal drift
- weak tests
- false claims of success

The algorithms are the test cases. The paper-worthy result is the documented pattern of LLM errors.

## Hard Constraints

- Ruby only for candidate algorithm implementations.
- Rails for the app.
- SQLite3 only for the database.
- No Python.
- Reference Ruby gems may be used for comparison, but candidate code must not call them unless a prompt explicitly allows it.
- Every coding attempt must trace back to a numbered prompt.

## Roles

### PI Human

Sets the research direction and interprets the differences between Codex-written Ruby results and established Ruby gem/reference results.

The PI should not need to read every line of generated code to evaluate an attempt. The app should surface result differences clearly enough for the PI to judge whether they indicate LLM error, acceptable approximation, missing scope, or an interesting research finding.

### Claude

Reads this `PLAN.md` and writes numbered prompts into `PROMPTS.md`.

Claude is the prompt architect, not the coder.

### Codex

Reads the selected numbered prompt from `PROMPTS.md`, writes the Rails/Ruby code, runs tests, and reports results.

Codex is the coder and implementation architect.

## Prompt Workflow

Prompts are stored in `PROMPTS.md`.

Prompt IDs use this format:

```text
P0001
P0002
P0003
```

Each implementation attempt should be tied to one prompt ID.

Basic loop:

1. PI updates research direction if needed.
2. Claude appends a numbered prompt to `PROMPTS.md`.
3. PI tells Codex the prompt has been updated.
4. Codex reads the selected prompt and implements only that scope.
5. Codex runs the Codex-written implementation and the Ruby gem/reference comparison.
6. PI reviews the reported result differences and records interpretation.

## Research Files

Use a small set of markdown files as the human-readable experiment trail:

- `PLAN.md`: project direction and workflow
- `PROMPTS.md`: Claude-authored numbered prompts
- `RESULTS.md`: Codex-authored results after each completed prompt
- `CLAUDE_ERRORS.md`: architect errors, prompt drift, missing constraints, overreach, or task framing mistakes
- `CODEX_ERRORS.md`: coder errors, implementation mistakes, result mismatches, weak tests, or incorrect completion claims

Suggested IDs:

```text
P0001    prompt
R0001    result
CLE0001  Claude/Architect error
CE0001   Codex/Coder error
```

Based on prior experience, the main expected source of goal drift is the architect/prompt layer. `CLAUDE_ERRORS.md` should therefore capture prompt-level drift separately from Codex implementation errors.

## App Scope

The app should support the research loop, not become a large product.

Initial scope:

- track prompts by ID
- track algorithm challenges
- track implementation attempts
- run candidate Ruby code and Ruby gem/reference code on the same inputs
- compare candidate output to gem/reference output
- show the PI clear result differences
- record PI interpretation of differences
- export useful data for paper writing

Out of scope for now:

- user accounts
- cloud deployment
- automated LLM orchestration
- large multi-agent workflows
- broad algorithm coverage before one workflow works

## First Experiment Direction

Start with the Traveling Salesman Problem because it is difficult, visual, and easy to compare.

Possible first implementation scope:

- pure Ruby TSP problem representation
- small known fixtures
- brute-force exact solver for small cases
- nearest-neighbor heuristic
- tests that expose common LLM mistakes
- records linking results to prompt ID `P0001`

Later experiments can add Held-Karp, 2-opt, simulated annealing, knapsack, graph coloring, SAT, scheduling, DSP, or coding theory.

## PI Result Interpretation Focus

The PI's main testing role is to interpret result differences.

For each attempt, the app should present:

- the prompt ID
- the input fixture
- the Codex-written Ruby result
- the Ruby gem/reference result
- the difference between the two
- runtime or benchmark differences when useful
- any notes Codex reported about implementation or verification

The PI then classifies the difference, for example:

- correct match
- acceptable approximation
- mathematical or algorithmic error
- possible goal drift
- reference/gem limitation
- needs another fixture
- inconclusive

For TSP, the app should help surface differences such as:

- Codex route length differs from gem/reference route length
- Codex returns a path length while the reference returns a cycle length
- Codex heuristic result is presented as if it were exact
- Codex result changes across repeated runs without a stated random seed
- Codex handles small fixtures differently than the reference

## Immediate Next Step

Claude reads this file and creates `PROMPTS.md` with `P0001`.

Then Codex reads `PROMPTS.md` and implements the requested first scope.
