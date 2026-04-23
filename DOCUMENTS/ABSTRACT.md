# Abstract

This paper investigates LLM-assisted software development as a governance problem, not merely a code-generation problem. The study does not argue that LLMs cannot code, nor that coding agents will replace human developers. Instead, it examines how LLM architects and coding agents can produce runnable, tested software while silently shifting architectural authority, validation responsibility, and research accountability away from the human principal investigator (PI).

The core claim is that organizations using LLMs or coding agents require human-in-the-loop (HITL) governance, not just HITL prompting. In this framing, the human role is not limited to writing clearer prompts or approving generated code. The human role is a constitutive accountability function that preserves research intent, distinguishes implementation details from research-design decisions, validates results beyond unit tests, and prevents local workarounds from becoming undocumented project methodology.

## Experimental Design

The case study uses a Ruby on Rails application with SQLite3 to evaluate LLM collaboration across a systematic series of algorithm implementation prompts. The three-role architecture assigns the PI (human) as research authority, Claude (Architect) as prompt designer, and Codex (Coder) as implementer. Twenty-eight numbered prompts have been completed across nine algorithm families:

- **Operations Research (OR-Tools):** TSP (P0001-P0019), VRP (P0020), Assignment Problem (P0021), Max Flow (P0022), Min Cost Flow (P0023), Job Shop Scheduling (P0024)
- **Astronomy:** Moon Phase Calculations (P0025-P0026, two algorithm versions)
- **Combinatorics:** N-Queens Problem (P0027, PI-authored reference gem)
- **Boolean Reasoning:** SAT Solver (P0028, completed)

The application records numbered prompts, implementation results, solver outputs, reference outputs, status classifications, PI interpretations, algorithm versions, and correction records. Role-specific error logs for the Architect (Claude) and Coder (Codex) allow failures to be attributed to prompt design, implementation, verification, architecture, or process governance. The project is publicly available at https://github.com/unixneo/llm_ruby_app_bench with a Zenodo DOI for reproducibility.


## Core Findings

**Finding 1: Passing tests are insufficient evidence of research correctness.**
Several failures produced plausible software artifacts while violating the intended research process. Examples include:

- **CLE0005:** Architect chose nearest-neighbor heuristic for n=20 without PI approval, changing the research question from "test exact solver" to "compare heuristic vs optimal"
- **CE0002/CLE0002:** Comparison logic checked tour length but not route sequence; tests passed while core requirement was violated
- **CE0006/CLE0007:** OR-Tools initially misconfigured with greedy heuristic; risk of presenting heuristic output as exact proof
- **CLE0011:** When asked for "all OR-Tools algorithms", Architect initially provided 7, only revealing 54 modules when challenged — not an honest mistake but misrepresentation
- **CE0010:** Max Flow implementation passed all tests but shipped a UI regression caught only by PI inspection
- **CLE0013:** Architect specified an infeasible fixture (demand exceeded source capacity) in the Min Cost Flow prompt; caught by Coder running the reference solver
- **CLE0015:** Architect mixed exact and heuristic candidate scope in the Job Shop Scheduling prompt without surfacing this as a research decision; Coder stopped and requested PI clarification
- **CLE0017:** Architect misdiagnosed the source of Moon Phase accuracy drift in the P0026 prompt; Coder identified the actual cause (missing TT-to-UTC conversion) through direct implementation verification

These failures demonstrate that LLM risk in software development extends beyond syntax errors and broken tests. The deeper risk is that an LLM can silently answer a different question than the organization intended to ask, or misrepresent the completeness and correctness of its work.

**Finding 2: Governance corrections demonstrably reduce error rates.**
After corrections C001-C009 were established, consecutive implementations proceeded with dramatically fewer errors:

- **VRP (P0020):** 0 implementation errors, single clean cycle
- **Assignment (P0021):** Hungarian algorithm, all 5 fixtures achieved exact optimal match, 0 implementation errors
- **Max Flow (P0022):** Edmonds-Karp, exact match on all 5 fixtures, 0 solver errors (UI regression caught by PI inspection led to C008)
- **Min Cost Flow (P0023):** Successive Shortest Path, exact match on all 5 corrected fixtures
- **Job Shop Scheduling (P0024):** Exact branch-and-bound, all 5 fixtures matched OR-Tools CP-SAT
- **Moon Phase (P0025-P0026):** Two algorithm versions; meeus-full-corrections-v1 eliminated systematic event-time drift
- **N-Queens (P0027):** Backtracking candidate matched PI-authored gem reference on all 5 fixtures exactly
- **SAT (P0028):** DPLL candidate matched ravensat reference on all 5 fixtures exactly

Contrast with early TSP (P0001-P0019) which accumulated 17 total errors before corrections stabilized. The framework works across NP-hard heuristics, exact polynomial algorithms, numerical scientific computing, and combinatorial search.


**Finding 3: Verification asymmetry between architect and coder roles.**
Empirical observation across the session documented in CLE0014 revealed that the coder role (Codex) consistently outperformed the architect role (Claude) on concrete state verification tasks: checking actual repository state, cross-file consistency, and reference solver feasibility. The architect handled high-level algorithmic reasoning adequately but exhibited weak procedural reliability and repeated overconfident completion claims. This finding suggests that in multi-agent LLM workflows, coder-style direct file inspection is more reliable than architect self-report for verification tasks, while the architect role retains relative advantage for conceptual framing and prompt specification.

**Finding 4: LLM non-determinism necessitates peer-reviewed ground truth validation.**
LLM output consistency is explicitly not a valid validation method. The methodology uses external peer-reviewed ground truth — OR-Tools reference solvers, OEIS A000170 solution counts, astronoby ephemeris-backed astronomical calculations — to validate candidate implementations independently of LLM agreement. This design choice is directly motivated by documented non-determinism in LLM code generation (Ouyang et al., 2025), which shows that repeated sampling from the same prompt produces different results with varying correctness.

## Governance Framework

The project maintains nine active correction protocols:

- **C001:** PI approval required for algorithmic research decisions
- **C002:** Distinguish implementation from research decisions
- **C003:** Flag architectural checkpoints requiring PI awareness
- **C004:** Codex must reject unapproved research substitutions
- **C005:** Algorithm selection requires reference gem verification
- **C006:** New session initialization protocol (read required files first)
- **C007:** Completeness verification (when asked for "all", verify and state count)
- **C008:** Mandatory UI verification for UI-affecting changes
- **C009:** Commit attribution trailers required (`Agent`, `Session`, `Role`) for traceability

These corrections form a persistent artifact ledger alongside PROMPTS.md, RESULTS.md, CLAUDE_ERRORS.md (17 errors, CLE0001-CLE0017), and CODEX_ERRORS.md (10 errors, CE0001-CE0010). Current test suite: 168 tests, 1263 assertions, 0 failures.


## Related Work

Most related work evaluates LLMs or agents by task-completion performance. SWE-bench introduced a benchmark of real GitHub issues where language models must edit repositories to resolve software problems [1]. SWE-agent extended this by emphasizing agent-computer interfaces [2]. SWE-bench Verified showed that benchmark quality itself requires human validation because problem statements and tests can be underspecified [3]. These efforts primarily evaluate whether agents produce acceptable patches under benchmark conditions. The present project differs by evaluating whether collaboration preserves the PI's research intent across a sustained multi-prompt experimental series.

Agentless questions whether complex autonomous agents are necessary and highlights simpler interpretable workflows [6]. This project is aligned with that concern but focuses on governance rather than agent complexity: when an LLM architect produces working software that changes the research question, validation standard, or architectural direction.

The HULA framework (Takerngsaksiri et al., 2025) deploys human-in-the-loop LLM agents at Atlassian for software development and concludes that human oversight is still necessary for code quality [10]. A follow-up paper identifies high computational costs of unit testing and variability in LLM-based evaluations as open challenges, calling for more stable and deterministic evaluation frameworks [11] — which the present project provides through peer-reviewed reference solvers. The key distinction is that HULA treats HITL as supervisory while this project treats HITL as constitutive: the human role preserves research intent, not just code quality.

Goal drift in LM agents has been studied as an emerging safety concern (2025) [12], documenting how agents gradually expand their scope beyond intended constraints. The present project contributes empirical instances of this failure mode in research software contexts, with documented correction mechanisms. Outcome-driven constraint violation benchmarks (Li et al., 2025) [13] further document "deliberative misalignment" where agents recognize their actions as problematic yet execute them — consistent with CLE0011 in this project where the Architect provided an incomplete list when asked for all OR-Tools algorithms.

Empirical studies of LLM non-determinism in code generation (Ouyang et al., 2025, ACM TOSEM) [14] show that repeated sampling from the same prompt produces different results with varying correctness, and that longer instructions correlate with greater non-determinism. This directly motivates the present project's use of external reference solvers rather than LLM-consistency as validation. Reproducibility concerns in LLM-based empirical SE studies (Angermeir et al., 2025) [15] further validate the methodology of using deterministic reference implementations.

Studies of LLM-generated code quality show that a substantial fraction of generated programs produce wrong outputs even when syntactically correct [16], and that existing benchmarks over-approximate functional correctness by using inadequate test suites [17]. The present project extends these findings by showing that correctness failures occur not only at the implementation level but at the research-design level, where an LLM silently substitutes a different algorithmic objective.

Multi-agent LLM systems for software engineering have been surveyed systematically (He et al., ACM TOSEM, 2025) [18], identifying role specialization and inter-agent coordination as key design dimensions. The present project's three-role PI/Architect/Coder architecture fits within this taxonomy and contributes empirical evidence about where coordination failures occur across 28 prompts. Design pattern research for LLM-based multi-agent systems (2025) [19] notes that MAS failures arise from both LLM limitations and system design — consistent with the finding that both architect and coder errors contributed to project failures at different rates.

In the Software Quality Journal specifically, Haldar and Capretz (2026) empirically evaluate LLMs for automated test plan generation and conclude that human validation remains necessary [20]. The present paper is complementary: where Haldar and Capretz assess output quality of individual LLM-generated test plans, this project documents the governance mechanisms required to maintain research integrity and goal preservation across a sustained multi-agent workflow.

LLM applications to software testing more broadly (Augusto et al., 2025; Sherifi et al., 2026) [21, 22] establish that LLMs can assist with test generation and reporting, but do not address the governance failures that arise when the testing or implementation objective itself is silently substituted.


## Contributions

This study differs from existing benchmarks and empirical studies in seven ways:

1. **Role-specific error attribution:** Separates PI, Architect, and Coder responsibilities with dedicated error logs enabling pattern analysis by role
2. **Persistent artifacts as data:** Prompt, result, error, and correction ledgers are first-class research data, not administrative records
3. **Goal preservation evaluation:** Assesses whether collaboration maintains PI research intent, not only functional correctness
4. **Beyond passing tests:** Treats passing unit tests as insufficient when the underlying prompt has substituted an unauthorized research question
5. **Decision authority boundaries:** Distinguishes routine implementation ambiguity from consequential research-design choices requiring PI approval
6. **Reference validation:** Treats external libraries as assumptions requiring verification (C005), not automatic ground truth
7. **Correction effectiveness measurement:** Documents quantitative reduction in error rates across consecutive implementations after corrections established

Additionally, the project introduces a PI-authored reference gem (`n_queens` v1.0.0, published to RubyGems.org) as a methodologically stronger reference implementation than third-party libraries, and documents a verification asymmetry finding showing that coder-style direct file inspection is more reliable than architect self-report for state verification tasks.

## Keywords

LLM agents; AI-assisted software engineering; coding agents; human-in-the-loop governance; accountability; validation beyond unit testing; prompt traceability; result traceability; goal drift; research governance; Ruby; Rails; algorithm benchmarking; TSP; VRP; Assignment Problem; Max Flow; Min Cost Flow; Job Shop Scheduling; Moon Phase; N-Queens; SAT; OR-Tools; astronoby; reference validation; correction frameworks; multi-agent systems; non-determinism; reproducibility


## References

1. Jimenez, C.E., Yang, J., Wettig, A., Yao, S., Pei, K., Press, O., Narasimhan, K. (2023). SWE-bench: Can Language Models Resolve Real-World GitHub Issues? arXiv:2310.06770. https://arxiv.org/abs/2310.06770

2. Yang, J., Jimenez, C.E., Wettig, A., Lieret, K., Yao, S., Narasimhan, K., Press, O. (2024). SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering. arXiv:2405.15793. https://arxiv.org/abs/2405.15793

3. Chowdhury, N., et al. (2024). Introducing SWE-bench Verified. OpenAI. https://openai.com/index/introducing-swe-bench-verified/

4. Liu, X., et al. (2023). AgentBench: Evaluating LLMs as Agents. arXiv:2308.03688. https://arxiv.org/abs/2308.03688

5. Merrill, M.A., et al. (2026). Terminal-Bench: Benchmarking Agents on Hard, Realistic Tasks in Command Line Interfaces. arXiv:2601.11868. https://arxiv.org/abs/2601.11868

6. Xia, C.S., Deng, Y., Dunn, S., Zhang, L. (2024). Agentless: Demystifying LLM-based Software Engineering Agents. arXiv:2407.01489. https://arxiv.org/abs/2407.01489

7. Chen, J., Xu, X., Wei, H., Chen, C., Zhao, B. (2026). SWE-CI: Evaluating Agent Capabilities in Maintaining Codebases via Continuous Integration. arXiv:2603.03823. https://arxiv.org/abs/2603.03823

8. Thai, M.V.T., Le, T., Nguyen Manh, D., Phan Nhat, H., Bui, N.D.Q. (2025). SWE-EVO: Benchmarking Coding Agents in Long-Horizon Software Evolution Scenarios. arXiv:2512.18470. https://arxiv.org/abs/2512.18470

9. Haldar, S., Capretz, L.F. (2026). Automated test plan generation using large language models. Software Quality Journal, 34, Article 8. https://doi.org/10.1007/s11219-026-09744-9

10. Takerngsaksiri, W., Pasuksmit, J., Thongtanunam, P., Tantithamthavorn, C., et al. (2025). Human-In-the-Loop Software Development Agents. ICSE 2025 SEIP. arXiv:2411.12924. https://arxiv.org/abs/2411.12924

11. Pasuksmit, J., et al. (2025). Human-In-The-Loop Software Development Agents: Challenges and Future Directions. arXiv:2506.11009. https://arxiv.org/abs/2506.11009

12. (2025). Technical Report: Evaluating Goal Drift in Language Model Agents. arXiv:2505.02709. https://arxiv.org/abs/2505.02709

13. Li, et al. (2025). A Benchmark for Evaluating Outcome-Driven Constraint Violations in Autonomous AI Agents. arXiv:2512.20798. https://arxiv.org/abs/2512.20798

14. Ouyang, S., Zhang, J.M., Harman, M., Wang, M. (2025). An Empirical Study of the Non-Determinism of ChatGPT in Code Generation. ACM Transactions on Software Engineering and Methodology, 34(2), Article 42. https://doi.org/10.1145/3697010

15. Angermeir, F., et al. (2025). Reflections on the Reproducibility of Commercial LLM Performance in Empirical Software Engineering Studies. arXiv:2510.25506. https://arxiv.org/abs/2510.25506

16. Liu, Z., et al. (2024). Refining ChatGPT-Generated Code: Characterizing and Mitigating Code Quality Issues. ACM Transactions on Software Engineering and Methodology. https://doi.org/10.1145/3643674

17. Liu, J., Xia, C.S., Wang, Y., Zhang, L. (2024). Is Your Code Generated by ChatGPT Really Correct? Rigorous Evaluation of Large Language Models for Code Generation. NeurIPS 2024. arXiv:2305.01210. https://arxiv.org/abs/2305.01210

18. He, J., et al. (2025). LLM-Based Multi-Agent Systems for Software Engineering: Literature Review, Vision and the Road Ahead. ACM Transactions on Software Engineering and Methodology. https://doi.org/10.1145/3712003

19. (2025). Designing LLM-based Multi-Agent Systems for Software Engineering Tasks: Quality Attributes, Design Patterns and Rationale. arXiv:2511.08475. https://arxiv.org/abs/2511.08475

20. Haldar, S., Capretz, L.F. (2026). Automated test plan generation using large language models. Software Quality Journal, 34, Article 8. https://doi.org/10.1007/s11219-026-09744-9

21. Augusto, C., Morán, J., Bertolino, A., de la Riva, C., Tuya, J. (2025). Software System Testing Assisted by Large Language Models: An Exploratory Study. In: Testing Software and Systems. ICTSS 2024. LNCS vol 15383. Springer. https://doi.org/10.1007/978-3-031-80889-0_17

22. Sherifi, B., Slhoub, K., Nembhard, F. (2026). The Potential of Large Language Models in Automating Software Testing: From Generation to Reporting. In: Software and Data Engineering. SEDE 2025. CCIS vol 2720. Springer. https://doi.org/10.1007/978-3-032-08649-5_13


## Working Status

This document reflects the state of the project at P0028 (SAT Solver, completed).

**Current metrics:**
- 28 prompts completed (P0001-P0028)
- 9 algorithm families implemented
- 17 Claude/Architect errors documented (CLE0001-CLE0017)
- 10 Codex/Coder errors documented (CE0001-CE0010)
- 9 active governance corrections (C001-C009)
- 168 tests, 1263 assertions, 0 failures
- PI-authored reference gem published: `n_queens` v1.0.0 (https://rubygems.org/gems/n_queens)
- Public repository: https://github.com/unixneo/llm_ruby_app_bench
- Zenodo DOI: https://doi.org/10.5281/zenodo.19650593

**Target journal:** Software Quality Journal (Springer, IF 2.3)
https://link.springer.com/journal/11219

**Submission to first decision (median):** 12 days
