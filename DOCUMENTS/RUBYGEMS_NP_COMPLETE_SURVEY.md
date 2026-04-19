# RubyGems Survey: NP-Hard/NP-Complete Algorithms (Non-OR)

## Date

2026-04-17

## Constraint

Find working Ruby reference implementations for high-complexity, non-OR algorithm families. Survey conclusions must satisfy C005 functional verification:

- gem exists
- gem implements the target algorithm family
- gem can load in Ruby
- basic API can be exercised, or the failure mode is documented

Temporary test gems were installed under `/tmp/codex_np_gems`; the Rails app `Gemfile` and bundle were not modified.

---

## Summary

| Domain | Candidate gem | Functional status | Complexity fit | Recommendation |
| --- | --- | --- | --- | --- |
| SAT | `ravensat` | Loads and solves a basic SAT formula | NP-complete | Strongest non-OR candidate |
| SAT | `ruby-minisat` | Real MiniSat binding, but native build failed locally | NP-complete | Promising but blocked by native dependency |
| SAT | `dpll_solver` | Installs but fails to load | NP-complete | Reject unless fixed |
| 2-SAT | `ac-library-rb` | Loads and solves 2-SAT | Polynomial | Useful reference, not hard enough |
| Graph algorithms | `rgl` | Loads and runs Dijkstra | Mostly polynomial | Reject for NP-hard benchmark |
| Sudoku/CSP | `sudoku-solver` and others | Not functionally verified; one tested gem failed | NP-complete as generalized problem | Not ready |
| N-Queens | none verified | No suitable solver found | NP-complete decision variant | Reject for now |
| Graph Coloring | none verified | No suitable solver found | NP-complete | Reject |

Final survey recommendation: **Ravensat/SAT is the best verified non-OR direction** if the project needs a domain outside routing/operations research.

---

## SAT Solvers

### Search Evidence

The original `gem search -r "sat|minisat|z3|smt"` workflow was unreliable in this shell because it returned RubyGems warnings and no visible rows. Codex therefore used the RubyGems HTTP API.

RubyGems API query:

```bash
curl -s 'https://rubygems.org/api/v1/search.json?query=sat'
```

Relevant candidates found:

- `ravensat` - "An interface to the SAT solver for Ruby"
- `ruby-minisat` - "ruby binding for MiniSat, an open-source SAT solver"
- `dpll_solver` - "small SAT solving tool"
- `ac-library-rb` - includes 2-SAT, plus max flow/min cost flow and other AtCoder algorithms

### `ravensat`

Metadata:

```text
name: ravensat
version: 1.1.1
info: An interface to the SAT solver for Ruby
homepage: https://github.com/matsuda0528/ravensat
```

Functional smoke test:

```bash
GEM_HOME=/tmp/codex_np_gems GEM_PATH=/tmp/codex_np_gems ruby -e 'require "ravensat"; a=Ravensat::VarNode.new; b=Ravensat::VarNode.new; logic=(a | b) & (~a | b) & (a | ~b); result=Ravensat::Solver.new.solve(logic); puts "sat=#{result}"; puts "a=#{a.result} b=#{b.result}"'
```

Output:

```text
sat=true
a=true b=true
```

Assessment:

- Implements SAT interface in Ruby.
- Can use bundled simple solver when no external SAT solver is installed.
- Basic formula solve works.
- Suitable as a reference candidate for a future SAT prompt.

Verdict: **verified candidate**.

### `ruby-minisat`

Metadata:

```text
name: ruby-minisat
version: 2.2.0.3
info: ruby binding for MiniSat, an open-source SAT solver
homepage: http://github.com/mame/ruby-minisat
```

Install attempt:

```bash
gem install --install-dir /tmp/codex_np_gems --no-document ruby-minisat
```

Result:

```text
ERROR: Failed to build gem native extension.
checking for -lminisat... no
extconf.rb:20:in `<main>': undefined method `+' for nil:NilClass (NoMethodError)
```

Source inspection confirms it is a real MiniSat binding and ships examples, but local installation failed because MiniSat library/header detection failed.

Assessment:

- Strong algorithmic fit.
- Not currently usable without native dependency work.
- Installing it in this Rails app would risk repeating Bundler/native-extension failure patterns.

Verdict: **promising but blocked**.

### `dpll_solver`

Metadata:

```text
name: dpll_solver
version: 0.0.1
info: small SAT solving tool for DIMACS or boolean expressions
```

Load test:

```bash
GEM_HOME=/tmp/codex_np_gems GEM_PATH=/tmp/codex_np_gems ruby -e 'require "dpll_solver"'
```

Result:

```text
NameError: uninitialized constant DpllSolver::Formulas::BinaryFormula
```

Assessment:

- Claims to implement DPLL.
- Fails to load on current Ruby when required normally.

Verdict: **reject unless fixed**.

### `ac-library-rb` TwoSAT

Metadata:

```text
name: ac-library-rb
version: 1.2.0
info: Ruby port of AtCoder Library; includes 2-SAT, SCC, max flow, min cost flow, etc.
```

Functional smoke test:

```bash
GEM_HOME=/tmp/codex_np_gems GEM_PATH=/tmp/codex_np_gems ruby -I/tmp/codex_np_gems/gems/ac-library-rb-1.2.0/lib -e 'require "two_sat"; ts=TwoSAT.new(2); ts.add_clause(0,true,1,false); puts "sat=#{ts.satisfiable?}"; p ts.answer; ts2=TwoSAT.new(1); ts2.add_clause(0,true,0,true); ts2.add_clause(0,false,0,false); puts "unsat=#{ts2.satisfiable?}"'
```

Output:

```text
sat=true
[false, false]
unsat=false
```

Assessment:

- API works.
- 2-SAT is solvable in polynomial time, so it does not match TSP/VRP difficulty.
- Could be useful for validating implication-graph algorithms, but not for the NP-hard/NP-complete benchmark target.

Verdict: **working but too easy for this phase**.

---

## Constraint Satisfaction / Sudoku

The prior draft claimed all Sudoku gems were immature/broken based on one tested gem. That was too broad.

Current verified evidence:

- `sudoku-solver` v0.1.1 was reportedly installed and failed to load via `require 'sudoku-solver'`.
- Other Sudoku gems were not functionally tested in this pass.

Generalized Sudoku is NP-complete, but many Sudoku gems solve fixed 9x9 puzzles and may be small scripts rather than mature reference libraries. This category remains possible but not verified.

Verdict: **inconclusive; do not use for prompt selection yet**.

---

## N-Queens

RubyGems API query:

```bash
curl -s 'https://rubygems.org/api/v1/search.json?query=nqueens'
```

Output:

```text
[]
```

Prior broader search found `queenshop`, which is unrelated to the N-Queens problem.

Verdict: **no verified N-Queens reference gem**.

---

## Graph Coloring

No graph-coloring solver gem has been functionally verified. Prior searches did not find a suitable algorithm gem.

RGL provides graph data structures and polynomial graph algorithms, but no graph coloring solver was found in its library files.

Verdict: **no verified graph-coloring reference gem**.

---

## RGL Detailed Investigation

Metadata:

```text
name: rgl
version: 0.6.6
info: RGL is a framework for graph data structures and algorithms
```

Functional smoke test:

```bash
GEM_HOME=/tmp/codex_np_gems GEM_PATH=/tmp/codex_np_gems ruby -e 'require "rgl/adjacency"; require "rgl/dijkstra"; g=RGL::DirectedAdjacencyGraph[1,2,2,3,1,3]; weights={ [1,2]=>1, [2,3]=>2, [1,3]=>5 }; p g.dijkstra_shortest_path(weights,1,3); puts "rgl_ok"'
```

Output:

```text
[1, 2, 3]
rgl_ok
```

Library files inspected:

```text
rgl/bellman_ford.rb
rgl/bipartite.rb
rgl/connected_components.rb
rgl/dijkstra.rb
rgl/edmonds_karp.rb
rgl/prim.rb
rgl/topsort.rb
```

No graph coloring, Hamiltonian path, clique, or vertex cover solver was found in `lib`.

Assessment:

- RGL is mature and usable for graph data structures and polynomial graph algorithms.
- It does not satisfy the current need for an NP-hard/NP-complete reference solver.

Verdict: **not suitable for next high-complexity benchmark**.

---

## Recommendation

If the project needs a non-OR algorithm family at comparable theoretical difficulty to TSP/VRP, the best current candidate is:

```text
SAT with Ravensat as the reference
```

Recommended next prompt path:

1. Create a SAT benchmark prompt.
2. Candidate implementation: pure Ruby DPLL or CDCL-lite, depending on PI-approved scope.
3. Reference implementation: Ravensat.
4. Fixtures: satisfiable and unsatisfiable CNF formulas, including DIMACS-style cases and small hand-verifiable formulas.
5. Validation: assignment satisfies every clause, unsat cases match reference result.

Do not select RGL graph algorithms, Sudoku, N-Queens, Graph Coloring, `ruby-minisat`, or `dpll_solver` without additional functional verification or PI-approved environment work.

---

## Survey Status

Completed enough to support next algorithm-family selection.

Primary verified option:

```text
SAT via ravensat
```

Residual risk:

- Ravensat's bundled solver should be tested on larger CNF fixtures before being treated as a robust ground-truth reference.
- If the PI wants an industrial SAT reference, native MiniSat integration would require deliberate environment work and should be its own prompt because `ruby-minisat` failed local native build.

## Out-of-Scope Addendum: Physics Domains

The follow-up survey for physics, quantum physics, astrophysics, and celestial mechanics is recorded in `PHYSICS_DOMAIN_SURVEY.md`.

Those domains are outside the NP-hard/NP-complete target of this file. The strongest verified candidates from that pass were:

- `orbit`: satellite propagation and observer look-angle calculations from TLE data.
- `astronoby`: astronomy and astrometry calculations such as Moon phases and ephemeris-backed Solar System positions.

These are promising scientific-computing benchmarks, but they should not be mixed into the NP-complete survey without changing the comparison frame. Their validation model requires numeric tolerances, unit discipline, coordinate-frame checks, and time-system checks rather than exact combinatorial optimality.
