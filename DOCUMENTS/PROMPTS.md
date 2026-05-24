# LLM Ruby Algorithm Error Benchmark - Prompts

This file is the canonical index for all numbered prompts in the experiment.
Prompts are split across two files for manageability:

- **[PROMPTS_01_21.md](PROMPTS_01_21.md)** — P0001 through P0021 (TSP, VRP, Assignment)
- **[PROMPTS_22_28.md](PROMPTS_22_28.md)** — P0022 through P0028 (Max Flow, Min Cost Flow, Job Shop, Moon Phase, N-Queens, SAT)

## Prompt Index

| Prompt | Algorithm | File |
|--------|-----------|------|
| P0001 | TSP — Brute-force baseline | PROMPTS_01_21.md |
| P0002 | TSP — Rails environment fix | PROMPTS_01_21.md |
| P0003 | TSP — GemTspSolver + comparison logic | PROMPTS_01_21.md |
| P0004 | TSP — Environment workaround (superseded) | PROMPTS_01_21.md |
| P0005 | TSP — Architect environment correction | PROMPTS_01_21.md |
| P0006 | TSP — State synchronization | PROMPTS_01_21.md |
| P0007 | TSP — Fix comparison logic (CE0002) | PROMPTS_01_21.md |
| P0008 | TSP — Fix UI status display | PROMPTS_01_21.md |
| P0009 | TSP — Add candidate result metadata | PROMPTS_01_21.md |
| P0010 | TSP — Add larger fixtures (n=10,15,20) | PROMPTS_01_21.md |
| P0011 | TSP — Nearest-neighbor heuristic for n>8 | PROMPTS_01_21.md |
| P0012 | TSP — Algorithm versioning | PROMPTS_01_21.md |
| P0013 | TSP — Held-Karp exact solver | PROMPTS_01_21.md |
| P0014 | TSP — Real-world city fixture | PROMPTS_01_21.md |
| P0015 | TSP — OR-Tools guided local search reference | PROMPTS_01_21.md |
| P0016 | TSP — Algorithm-agnostic root page | PROMPTS_01_21.md |
| P0017 | TSP — Correct Rails command pattern | PROMPTS_01_21.md |
| P0018 | TSP — Remove invalid algorithm placeholder | PROMPTS_01_21.md |
| P0019 | TSP — SKIP_HELD_KARP test flag | PROMPTS_01_21.md |
| P0020 | VRP — Clarke-Wright Savings | PROMPTS_01_21.md |
| P0021 | Assignment — Hungarian algorithm | PROMPTS_01_21.md |
| P0022 | Max Flow — Edmonds-Karp | PROMPTS_22_28.md |
| P0023 | Min Cost Flow — Successive Shortest Path | PROMPTS_22_28.md |
| P0024 | Job Shop Scheduling — Branch-and-bound | PROMPTS_22_28.md |
| P0025 | Moon Phase — meeus-v1 | PROMPTS_22_28.md |
| P0026 | Moon Phase — meeus-full-corrections-v1 | PROMPTS_22_28.md |
| P0027 | N-Queens — Backtracking | PROMPTS_22_28.md |
| P0028 | SAT — DPLL | PROMPTS_22_28.md |

## Notes

- All prompts follow the naming convention P####
- Each prompt has a corresponding result in RESULTS.md (R####)
- Architect errors traceable to prompts are in CLAUDE_ERRORS.md (CLE####)
- Coder errors traceable to prompts are in CODEX_ERRORS.md (CE####)
- Active governance corrections referenced by prompts are in CORRECTIONS.md (C001-C009)
