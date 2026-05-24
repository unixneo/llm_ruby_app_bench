# When LLMs Pass Tests but Fail the Process: A Governance and Traceability Case Study of Multi-Agent LLM Software Development

## Abstract

LLM-based software agents are commonly evaluated by artifact-level outcomes such as patch acceptance and test pass rates. These outcomes are useful but incomplete in research and quality-critical contexts, where software may pass tests while the development process violates project intent, validation boundaries, or decision authority. This paper studies that gap as a governance and traceability problem in multi-agent LLM software development.

We present a longitudinal case study of a three-role workflow: PI (human research authority), Architect (LLM prompt designer), and Coder (LLM implementer/verifier). The study covers 28 prompt-driven implementation cycles (P0001-P0028) across nine algorithm families in a Ruby on Rails benchmark environment. We analyze role-attributed failure events using persistent artifacts: prompt/result ledgers, role-specific error logs, and governance-correction records.

The study contributes: (1) a role-separated failure taxonomy and coding protocol, (2) artifact-linked governance controls (C001-C009), and (3) phase-based descriptive analysis comparing pre-correction and post-correction behavior. Findings show that process-level failures can occur despite runnable software and passing tests, including unauthorized objective substitution, incomplete verification claims, and reference-selection errors. Later cycles show substantially fewer documented failures after governance controls are established; however, we report these as phase-associated differences within a single-case longitudinal design, not universal causal effects.

The repository and archival DOI are publicly available for replication and re-analysis.

## 1. Introduction

Large-language-model (LLM) software agents are increasingly evaluated by task completion metrics. These metrics can overstate reliability when a generated artifact appears correct while the process that produced it diverges from approved intent. In research workflows, this divergence can change the problem being solved, the validation standard being applied, or the boundary of who is authorized to make research-design decisions.

This paper examines that divergence in a multi-agent setting with explicit role separation: PI (human), Architect (LLM), and Coder (LLM). The PI defines research intent and approval boundaries; the Architect translates intent into prompts and specifications; the Coder executes repository changes and verification. Our focus is not whether LLMs can generate code, but whether collaboration preserves intent and accountability over a sustained sequence of implementation cycles.

Most prior work in LLM software engineering emphasizes output quality (for example, benchmark task success). We instead treat governance artifacts themselves as first-class data and evaluate process integrity using event-level traceability.

### 1.1 Research Questions

RQ1. What categories of process-governance failure occur in PI-Architect-Coder workflows, including cases where software artifacts pass tests?

RQ2. How are failures distributed across roles when attribution follows explicit, evidence-backed coding rules?

RQ3. Within this case-study setting, how do observed failure rates differ between pre-correction and post-correction phases after governance controls are introduced?

RQ4. Which governance controls are associated with reductions in specific failure categories?

### 1.2 Claimed Scope

This paper reports descriptive and analytical findings for one reproducible case-study environment. We do not claim universal causal effects across all LLMs, organizations, or software tasks.

## 2. Method

### 2.1 Study Design

This is a longitudinal single-case study with sequential intervention phases.

- Environment: Ruby 3.2.2, Rails 7.2, SQLite3.
- Workflow roles: PI (human), Architect (Claude), Coder (Codex).
- Observation window: 28 prompt cycles (P0001-P0028).
- Interventions: governance corrections C001-C009 introduced incrementally and maintained.

Unit of analysis: a **failure event**, defined as a documented deviation from approved intent, verification protocol, implementation correctness, or governance compliance, backed by artifact evidence.

### 2.2 Task and Reference Selection Criteria

A task is included only if all criteria are satisfied:

1. Implementable in the benchmark application without proprietary infrastructure.
2. Verifiable against deterministic or peer-reviewed external references.
3. Fully traceable through prompt/result/event artifacts.
4. Representative of a distinct algorithmic surface.

Algorithm families covered:

- **Operations Research (OR-Tools):** TSP (P0001-P0019), VRP (P0020), Assignment (P0021), Max Flow (P0022), Min Cost Flow (P0023), Job Shop Scheduling (P0024)
- **Astronomy:** Moon Phase Calculations (P0025-P0026; two algorithm versions)
- **Combinatorics:** N-Queens (P0027)
- **Boolean Reasoning:** SAT (P0028)

Reference solvers were admitted only after explicit availability and functional checks at fixture level.

### 2.3 Data Sources

Primary artifacts:

1. Prompt ledgers (`PROMPTS_01_21.md`, `PROMPTS_22_28.md`)
2. Result ledger (`RESULTS.md`)
3. Architect error ledger (`CLAUDE_ERRORS.md`)
4. Coder error ledger (`CODEX_ERRORS.md`)
5. Governance ledger (`CORRECTIONS.md`)
6. Executable code, fixtures, and tests in the public repository/DOI archive

### 2.4 Failure Taxonomy and Coding Protocol

Top-level failure categories:

1. Objective/Authority Violations
2. Verification Failures
3. Specification/Prompt Defects
4. Implementation Defects
5. Process Compliance Violations

Coding protocol:

1. Extract candidate events from ledgers and linked artifacts.
2. Assign provisional category and role.
3. Verify against repository evidence.
4. Resolve ambiguous cases with PI adjudication and rationale logging.
5. Freeze coded table for phase analysis.

### 2.5 Phase Analysis Plan

We report two phases:

1. **Pre-correction phase:** cycles before governance stabilization.
2. **Post-correction phase:** cycles after C001-C009 adoption.

Descriptive metrics:

1. Failure count and rate per cycle
2. Failure category distribution by phase
3. Role-attributed failure distribution
4. Detection-source distribution (tests, reference checks, PI review, coder verification)

We report phase-associated differences descriptively and avoid causal treatment claims.

### 2.6 Threats to Validity

- **Internal validity:** learning effects, task heterogeneity, and model/session drift may confound phase differences.
- **Construct validity:** governance failure definitions can be broad.
- **External validity:** single project and architecture limit generalization.
- **Conclusion validity:** sample size limits inferential statistics.

Mitigation: fixed taxonomy, explicit coding rules, artifact traceability, bounded claims.

## 3. Findings

### 3.1 Finding 1: Passing Tests Are Insufficient for Process Correctness

We observed multiple cases where software artifacts were runnable and often test-passing, yet process integrity was violated:

- **CLE0005:** Unapproved shift from exact n=20 objective to heuristic framing
- **CE0002/CLE0002:** Comparison logic validated tour length but not required route sequence
- **CE0006/CLE0007:** Initial OR-Tools exactness misconfiguration risk
- **CLE0013:** Infeasible Min Cost Flow fixture specification
- **CE0010:** Max Flow implementation with UI regression detected through PI review
- **CLE0015/CLE0017:** Prompt-scope ambiguity and root-cause misdiagnosis in moon-phase workflow

These events indicate that artifact-level success can mask governance-level failure.

### 3.2 Finding 2: Phase-Associated Reduction in Documented Failures

Early TSP cycles (P0001-P0019) accumulated substantially more documented failures than later cycles. After governance controls were established, later implementations across VRP, Assignment, Max Flow, Min Cost Flow, Job Shop, Moon Phase, N-Queens, and SAT showed fewer documented failures per cycle.

This is reported as a longitudinal phase association in this environment, not as a universal causal effect.

### 3.3 Finding 3: Verification Asymmetry by Role

In this dataset, the Coder role more consistently identified repository-state and feasibility mismatches, while the Architect role showed stronger high-level framing but weaker procedural verification reliability in several episodes. This role asymmetry is an empirical observation bounded to this workflow.

### 3.4 Finding 4: External Ground Truth Is Necessary Under LLM Non-Determinism

Validation relied on external references (for example, OR-Tools, astronoby, `n_queens`, `ravensat`) rather than LLM self-consistency. This design aligns with published findings on LLM code-generation non-determinism and reproducibility concerns.

## 4. Governance Framework (C001-C009)

- **C001:** PI approval required for algorithmic research decisions
- **C002:** Distinguish implementation from research decisions
- **C003:** Flag architectural checkpoints requiring PI awareness
- **C004:** Coder must reject unapproved research substitutions
- **C005:** Algorithm selection requires reference verification
- **C006:** New-session initialization protocol
- **C007:** Completeness verification for “all/complete” claims
- **C008:** Mandatory UI verification for UI-affecting changes
- **C009:** Commit attribution trailers (`Agent`, `Role`) for traceability

These controls were maintained alongside persistent ledgers and test artifacts.

## 5. Contributions

Relative to benchmark-centric evaluations, this study contributes:

1. Role-separated failure attribution in a sustained multi-agent workflow
2. Artifact-first process dataset (prompt/result/error/correction ledgers)
3. Intent-preservation as an evaluation target beyond functional correctness
4. Operational governance protocol (C001-C009) with reusable control definitions
5. A reproducible case-study package (code, fixtures, logs, DOI archive)

## 6. Limitations and Future Work

Limitations include single-case scope, non-random task ordering, and potential temporal confounds. Future work should replicate this protocol across additional model pairs, task suites, and independent coding teams, and should evaluate inter-rater reliability for failure coding.

## 7. Reproducibility and Artifact Availability

- Public repository: https://github.com/unixneo/llm_ruby_app_bench
- DOI archive: https://doi.org/10.5281/zenodo.19650593
- Current project status snapshot: P0028 completed; 28 prompt cycles; 9 algorithm families; 9 governance controls.

## Keywords

LLM agents; multi-agent software engineering; software quality; human-in-the-loop governance; process traceability; intent preservation; role attribution; verification; reproducibility; case study

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

12. Technical Report (2025). Evaluating Goal Drift in Language Model Agents. arXiv:2505.02709. https://arxiv.org/abs/2505.02709

13. Li, et al. (2025). A Benchmark for Evaluating Outcome-Driven Constraint Violations in Autonomous AI Agents. arXiv:2512.20798. https://arxiv.org/abs/2512.20798

14. Ouyang, S., Zhang, J.M., Harman, M., Wang, M. (2025). An Empirical Study of the Non-Determinism of ChatGPT in Code Generation. ACM Transactions on Software Engineering and Methodology, 34(2), Article 42. https://doi.org/10.1145/3697010

15. Angermeir, F., et al. (2025). Reflections on the Reproducibility of Commercial LLM Performance in Empirical Software Engineering Studies. arXiv:2510.25506. https://arxiv.org/abs/2510.25506

16. Liu, Z., et al. (2024). Refining ChatGPT-Generated Code: Characterizing and Mitigating Code Quality Issues. ACM Transactions on Software Engineering and Methodology. https://doi.org/10.1145/3643674

17. Liu, J., Xia, C.S., Wang, Y., Zhang, L. (2024). Is Your Code Generated by ChatGPT Really Correct? Rigorous Evaluation of Large Language Models for Code Generation. NeurIPS 2024. arXiv:2305.01210. https://arxiv.org/abs/2305.01210

18. He, J., et al. (2025). LLM-Based Multi-Agent Systems for Software Engineering: Literature Review, Vision and the Road Ahead. ACM Transactions on Software Engineering and Methodology. https://doi.org/10.1145/3712003

19. Designing LLM-based Multi-Agent Systems for Software Engineering Tasks (2025): Quality Attributes, Design Patterns and Rationale. arXiv:2511.08475. https://arxiv.org/abs/2511.08475

20. Augusto, C., Morán, J., Bertolino, A., de la Riva, C., Tuya, J. (2025). Software System Testing Assisted by Large Language Models: An Exploratory Study. In: Testing Software and Systems. ICTSS 2024. LNCS vol 15383. Springer. https://doi.org/10.1007/978-3-031-80889-0_17

21. Sherifi, B., Slhoub, K., Nembhard, F. (2026). The Potential of Large Language Models in Automating Software Testing: From Generation to Reporting. In: Software and Data Engineering. SEDE 2025. CCIS vol 2720. Springer. https://doi.org/10.1007/978-3-032-08649-5_13
