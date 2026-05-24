# Introduction (Draft Replacement)

Large-language-model (LLM) software agents are increasingly evaluated by task completion metrics (for example, issue resolution, patch acceptance, and test pass rates). These metrics are useful, but they can overstate reliability when the generated artifact passes tests while the development process violates higher-level project intent. In research and quality-critical settings, this creates a distinct failure mode: the system appears successful at the code level while silently changing the problem definition, validation standard, or architectural decision path.

This paper studies that failure mode as a governance and traceability problem in multi-agent software development. The setting is a three-role workflow with a human principal investigator (PI), an LLM Architect, and an LLM Coder. The PI defines research intent and approval boundaries; the Architect translates intent into implementation prompts; the Coder executes and verifies repository-level changes. We analyze how process failures emerge across this interaction, and which governance controls reduce their frequency.

The paper makes a scoped empirical contribution rather than a universal causal claim. Specifically, we provide a longitudinal case study over 28 prompt-driven implementation cycles in one reproducible Rails benchmark environment. The contribution is a role-attributed, artifact-linked process dataset and an operational governance protocol (C001-C009) that can be reused and independently stress-tested by future studies.

## Research Questions

RQ1. What categories of process-governance failure occur in a PI-Architect-Coder workflow, even when software artifacts are runnable and tests pass?

RQ2. How are failures distributed across roles (Architect vs Coder) when attribution is performed with explicit coding rules and evidence links?

RQ3. Under this case-study setting, how do observed failure rates differ between pre-correction and post-correction phases after governance controls C001-C009 are introduced?

RQ4. Which governance controls are associated with reductions in specific failure categories (for example, unauthorized objective substitution, incomplete verification claims, or reference-selection errors)?

## Claimed Scope

We claim descriptive and analytical findings for this case-study environment. We do not claim universal causal effects across all models, tasks, or organizations. Any statements about reduction effects are reported as phase-associated differences within this longitudinal trace, with explicit threats to validity.

## Novelty Relative to Prior Work

Compared with benchmark-centric agent evaluations, this study contributes four elements not typically combined in prior work:

1. Role-separated process attribution at the failure-event level.
2. Persistent governance artifacts (prompts, results, error logs, corrections) treated as primary data.
3. Evaluation target of intent preservation, not only functional correctness.
4. Explicit approval-boundary protocol for research-design decisions inside agent workflows.

# Method (Draft Replacement)

## Study Design

This is a single-project longitudinal case study with sequential intervention phases.

- Environment: Ruby on Rails 7.2, Ruby 3.2.2, SQLite3.
- Workflow roles: PI (human), Architect (LLM), Coder (LLM).
- Observation window: P0001-P0028 (28 prompt cycles).
- Intervention: governance corrections C001-C009, introduced incrementally and then maintained.

Unit of analysis: a **failure event**, defined as a documented deviation from approved intent, verification protocol, or implementation correctness, with an evidence link to repository artifacts.

## Case and Task Selection Criteria

Tasks were included only when all four criteria were met:

1. Implementable in the benchmark application without external proprietary infrastructure.
2. Verifiable against a deterministic or peer-reviewed external reference implementation.
3. Loggable through the prompt-result ledger with reproducible artifacts.
4. Representative of a distinct algorithmic surface (OR, combinatorial search, numerical astronomy, SAT reasoning).

Reference tools (for example, OR-Tools, astronoby, ravensat, and PI-authored `n_queens`) were selected using a pre-check protocol: availability, executable API path, and fixture-level functional verification before use.

## Data Sources

Primary data artifacts:

1. Prompt ledger (`PROMPTS_01_21.md`, `PROMPTS_22_28.md`).
2. Result ledger (`RESULTS.md`).
3. Role-specific error ledgers (`CLAUDE_ERRORS.md`, `CODEX_ERRORS.md`).
4. Governance ledger (`CORRECTIONS.md`).
5. Executable codebase, tests, and fixtures in the public repository/DOI archive.

Each failure event record includes: event ID, phase, role attribution, category label, affected artifact(s), detection pathway, and correction linkage where applicable.

## Failure Taxonomy and Coding Protocol

### Taxonomy

Failure events are coded into five top-level categories:

1. **Objective/Authority Violations**: unapproved changes to research objective, algorithm class, or decision authority.
2. **Verification Failures**: incomplete, incorrect, or overstated validation claims.
3. **Specification/Prompt Defects**: ambiguous, infeasible, or internally inconsistent prompt requirements.
4. **Implementation Defects**: coding errors that affect correctness, comparability, or user-visible behavior.
5. **Process Compliance Violations**: breaches of explicit governance rules (C001-C009).

### Coding Steps

1. Extract candidate events from ledgers and linked commits/results.
2. Assign preliminary category and responsible role using event definitions.
3. Verify category-role assignment against evidence artifacts.
4. Resolve ambiguous cases using PI adjudication with recorded rationale.
5. Freeze coded table for phase analysis.

This protocol is designed to make attribution decisions inspectable and reproducible.

## Phase Definition and Analysis Plan

Two analysis phases are reported:

1. **Pre-correction phase**: cycles before governance protocol stabilization.
2. **Post-correction phase**: cycles after C001-C009 adoption.

Primary descriptive metrics:

1. Failure count and rate per cycle by phase.
2. Failure category distribution by phase.
3. Role-attributed failure distribution by phase.
4. Detection-source distribution (tests, reference solver checks, PI review, coder verification).

We report phase-associated differences as descriptive effects; we do not infer causal treatment effects.

## Reproducibility Protocol

The analysis is reproducible via:

1. Public repository snapshot and DOI archive.
2. Stable event IDs (P/R/CLE/CE/C labels).
3. Open fixtures and test suite.
4. Explicit mapping from manuscript claims to artifact records.

## Threats to Validity

### Internal Validity

- Learning effects across time may reduce later errors independently of corrections.
- Task heterogeneity across algorithm families may confound phase comparisons.
- Model/session drift may affect behavior independently of governance rules.

Mitigation: report phase effects descriptively, include transparent event ledger, avoid causal wording.

### Construct Validity

- “Governance failure” can be interpreted broadly.

Mitigation: fixed taxonomy, explicit inclusion rules, artifact-backed event coding.

### External Validity

- Single project, single workflow architecture, limited number of tasks.

Mitigation: bound claims to this setting and release artifacts for independent replication.

### Conclusion Validity

- Small sample limits inferential statistics.

Mitigation: emphasize effect magnitudes and trace transparency, not hypothesis-test significance.

## Ethics and Accountability

All agent-attributed findings are limited to observed artifacts and workflow behavior in this environment. The analysis targets process reliability and governance design, not anthropomorphic intent claims.
