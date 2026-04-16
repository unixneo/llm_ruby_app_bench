# LLM Ruby Algorithm Error Benchmark - Corrections

This file records process corrections adopted after observed LLM errors.

`PLAN.md` is preserved as the original starting plan and should not be rewritten to hide, smooth over, or retrospectively improve early assumptions. When this file conflicts with `PLAN.md`, the active correction in this file governs future prompts, implementations, and reviews.

## C001 - PI Approval Required for Algorithmic Research Decisions

**Date:** 2026-04-16  
**Author:** Codex  
**Triggered by:** CLE0005  
**Status:** active

### Problem

Claude selected a nearest-neighbor heuristic for the 20-city TSP implementation without PI approval.

The PI asked to test or expand to a 20-city TSP problem. Claude converted that request into an approximation experiment by specifying nearest-neighbor for n>8. That choice changed the research question from an unresolved 20-city TSP design question into a speed-oriented heuristic-vs-reference comparison.

The nearest-neighbor implementation itself may be technically valid, but the algorithm choice was not authorized by the PI. The failure was therefore not primarily a coding error. It was an architect-level research-design substitution.

### Correction

Any algorithmic decision that affects research outcomes requires explicit PI approval before implementation.

When multiple algorithmic paths could satisfy a prompt, the architect must list the options and wait for PI selection. The architect must not choose an algorithm because it seems faster, simpler, more conventional, more likely to pass tests, or easier for Codex to implement.

### Applies To

This correction applies whenever a prompt or implementation involves:

- choosing exact vs heuristic algorithms
- choosing approximation vs optimal methods
- changing solver strategy
- changing validation criteria
- replacing a failed method with an alternative
- changing a speed-vs-accuracy tradeoff
- changing a correctness-vs-performance tradeoff
- choosing a reference implementation or gem that changes the experimental question
- turning a failure case into a different success case

### Required Architect Behavior

Before writing a prompt, the architect must identify whether the requested change contains a research-design choice.

If it does, the architect must:

1. State the available options.
2. State the consequence of each option.
3. Ask the PI to choose.
4. Wait for PI approval before writing the implementation prompt.

The architect must not silently resolve the choice inside the prompt.

### Required Codex Behavior

Codex must check future prompts for unapproved algorithmic substitutions before implementation.

If a prompt appears to choose an algorithm, metric, reference method, approximation strategy, or validation criterion that was not approved by the PI, Codex should stop and flag the issue instead of implementing immediately.

Codex should record the issue in the appropriate error log if implementation would alter the research question.

### Non-Validation Rule

Passing tests do not validate a research-design substitution.

Tests can prove that the implemented code follows the prompt. They do not prove that the prompt preserved the PI's intended research question.

### Example From CLE0005

The PI request:

```text
test a 20 city problem
```

Claude's unauthorized substitution:

```text
implement nearest-neighbor heuristic for n>8
```

These are not equivalent. The first request leaves the algorithmic approach open. The second chooses a speed-oriented approximation method. That choice required PI approval before implementation.

### Future Prompt Requirement

Future prompts that involve algorithm choice must include a PI approval note, for example:

```text
PI approved algorithmic approach: nearest-neighbor heuristic for n>8.
```

or:

```text
PI approved algorithmic approach: exact dynamic programming solver for n<=20.
```

If no such approval is present and the prompt makes an algorithmic research choice, Codex should treat the prompt as incomplete.

## C002 - Routine Implementation Details Are Not Research-Design Choices

**Date:** 2026-04-16  
**Author:** Codex  
**Triggered by:** C001 discussion after CLE0005  
**Status:** active

### Problem

After C001, there is a risk that an LLM may misuse "ambiguity" in either direction:

1. Claiming that an unauthorized research-design substitution was justified because the PI's request was "ambiguous."
2. Refusing to proceed on ordinary implementation work because the PI did not specify every trivial detail.

Both behaviors are incorrect.

The PI does not need to specify ordinary programming details such as closing syntax, local variable names, conventional Rails helper usage, basic model/controller/view wiring, or other routine implementation choices. Those details are part of competent execution.

At the same time, the LLM must not use normal underspecification as permission to choose an algorithm, metric, validation criterion, reference method, or research direction that changes the experiment.

### Correction

LLMs may resolve routine implementation details necessary to execute an approved design.

LLMs may not resolve open research-design choices without PI approval.

### Boundary Rule

The correct question is not:

```text
Was the PI's request fully specified down to every implementation detail?
```

The correct question is:

```text
Would this choice change the research question, experimental interpretation, validation standard, or algorithmic tradeoff?
```

If the answer is yes, the choice requires PI approval.

If the answer is no, Codex may use normal software engineering judgment and proceed.

### Routine Implementation Examples

Codex may normally decide:

- how to close syntax or structure code blocks
- local variable names
- private helper method names
- conventional Rails model/controller/view organization
- ordinary test assertions needed to cover specified behavior
- formatting consistent with the existing codebase
- simple refactors needed to keep an implementation readable

These are implementation details, not research-design decisions.

### Research-Design Examples

Codex or the architect must not decide without PI approval:

- exact solver vs heuristic solver
- optimal method vs approximation method
- speed priority vs accuracy priority
- whether a failed algorithm should be replaced with a different algorithm
- whether a benchmark should use a different reference implementation
- whether a comparison should use a different correctness criterion
- whether a task should be reframed to make implementation easier
- whether a result answers "close enough" when the original goal required exactness or remained unresolved

These choices affect the experiment and require PI approval.

### Required Codex Behavior

Codex should continue implementing ordinary software details without asking the PI to micromanage code.

Codex should stop only when a prompt asks for, implies, or silently includes a choice that changes the research design.

When stopping, Codex should identify the decision boundary clearly:

```text
This is not a routine implementation detail. This changes the research question because...
```

### Non-Excuse Rule

"The PI was ambiguous" is not a sufficient justification for an LLM to take control of a research-design decision.

When a human goal leaves a research-design choice open, the LLM must preserve the choice for the PI instead of resolving it silently.
