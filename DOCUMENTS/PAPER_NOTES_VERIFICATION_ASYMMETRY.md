# Paper Notes - Verification Asymmetry Between Architect and Coder Roles

## Purpose

Capture a future paper subsection on the observed asymmetry between the Architect role's self-reports and the Coder role's direct repository verification.

This note is intentionally narrower than a general claim about model capability. It records an empirical pattern observed in this repository and provides a defensible way to discuss it later in the paper draft.

---

## Candidate Claim

In this project, the Coder role was more reliable than the Architect role at concrete repository-state verification tasks such as:

- checking whether a file was actually updated
- confirming whether numbering was sequential across documents
- identifying cross-file documentation inconsistencies
- detecting prompt-to-implementation feasibility mismatches through direct execution

This finding should be stated as **task-specific**, not as a general claim that the Coder role is superior overall.

---

## Scope Boundary

The evidence currently supports a narrow claim:

- **Supported:** coder-style direct inspection was more reliable for concrete verification and repo-state checking
- **Not yet supported:** coder roles are generally better than architect roles across all task types
- **Not yet supported:** workflow hierarchy should be inverted globally

The paper should distinguish:

- research framing and prompt design
- implementation and execution
- verification of actual repository state

The asymmetry appears strongest in the third category.

---

## Evidence Cases

### Case 1 - Prompt Fixture Infeasibility

**Architect error:** `CLE0013`  
**Prompt:** `P0023`  
**Observed pattern:** Architect specified an infeasible minimum-cost-flow fixture with demand greater than source outgoing capacity.  
**Detection mode:** Coder implementation plus OR-Tools verification.  
**Implication:** Architect-side prompt reasoning was not sufficient to ensure mathematical feasibility; execution-time verification was necessary.

### Case 2 - Documentation Numbering and Cross-File Consistency Failure

**Architect error:** `CLE0014`  
**Observed pattern:** Architect introduced non-sequential numbering, then duplicate numbering, then incomplete README cleanup, and repeatedly claimed consistency before it existed.  
**Detection mode:** Coder direct file inspection and cross-file verification.  
**Implication:** Architect self-report about repository state was unreliable without independent checking.

### Case 3 - Counterexample: Coder UI Integration Failure

**Coder error:** `CE0011`  
**Observed pattern:** Coder implemented the new minimum-cost-flow lane but failed to verify the shared UI surface correctly, causing scoped-page fallback and incorrect TSP labeling.  
**Implication:** The asymmetry is not absolute. The coder role also fails when end-to-end verification discipline is weak.

---

## Provisional Interpretation

One plausible interpretation is that the Architect role handled high-level conceptual work competently but was weaker at low-level procedural verification and self-audit. The Coder role performed better on questions of the form:

- "What is actually in the file right now?"
- "Does this route render the intended scoped page?"
- "Did this renumbering update every relevant reference?"
- "Does the reference solver accept this fixture as feasible?"

This suggests that in multi-agent LLM workflows, self-reports from design-oriented roles should not be trusted as final verification of concrete state.

---

## Candidate Table for Paper

| Case | Architect Claim or Output | Verification Method | Who Detected Problem | Outcome |
| --- | --- | --- | --- | --- |
| CLE0013 | P0023 fixture feasible as written | OR-Tools execution during implementation | Coder | Prompt corrected before completion |
| CLE0014 | Documentation numbering cleanup complete | Direct inspection of `CLAUDE_ERRORS.md` and `README.md` | Coder | Multiple correction cycles required |
| CE0011 | Minimum-cost-flow UI integration complete | User-visible route inspection and controller tests | PI, then Coder | Shared UI fallback fixed |

This table should be refined later with exact wording and dates from source documents.

---

## Candidate Results Paragraph

An asymmetry emerged between the Architect and Coder roles on verification tasks. In multiple cases, the Architect produced plausible but incorrect claims about repository state or prompt correctness, while the Coder identified discrepancies through direct file inspection or execution against a reference solver. This pattern was visible in the detection of an infeasible P0023 minimum-cost-flow fixture (`CLE0013`) and in repeated Architect documentation-numbering inconsistencies (`CLE0014`). However, the asymmetry was task-specific rather than absolute: the Coder also failed on end-to-end UI verification in `CE0011`. These results suggest that design-oriented LLM outputs should not be treated as self-verifying, and that independent repository inspection remains necessary even when higher-level reasoning appears sound.

---

## Candidate Discussion Point

The governance implication is not that coder roles should replace architect roles. The stronger conclusion is narrower: architect self-reports are unreliable enough on concrete state-verification tasks that an independent verification layer is required. In this project, the coder role often served that function effectively, but coder outputs still required PI oversight for user-visible correctness and methodological compliance.

---

## Threats to Validity

- This pattern comes from a single repository and a limited set of prompts.
- The observed asymmetry may be role-assignment specific rather than model-intrinsic.
- Verification task performance may depend more on task concreteness than on role hierarchy.
- Some verification gains may come from tool usage style rather than underlying reasoning ability.

---

## Recommended Placement in Paper

- **Results:** short subsection on verification asymmetry with 2-3 documented cases
- **Discussion:** governance implication about independent verification
- **Threats to Validity:** caution against overgeneralizing the role asymmetry

---

## Next Step

When the paper draft is updated, pull exact quotations, dates, and IDs from:

- `DOCUMENTS/CLAUDE_ERRORS.md`
- `DOCUMENTS/CODEX_ERRORS.md`
- `DOCUMENTS/RESULTS.md`
- relevant commit history where needed
