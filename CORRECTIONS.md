# Process Corrections

This file records active safeguards that modify how the Architect (Claude) and Coder (Codex) should operate in future prompts. Each correction addresses a pattern of errors identified in `CLAUDE_ERRORS.md` or `CODEX_ERRORS.md`.

---

## C001 - PI Approval Required for Algorithmic Research Decisions

**Date:** 2026-04-16  
**Addresses:** CLE0005 (unauthorized nearest-neighbor choice for n=20)

**Problem:**

In P0010, Claude specified a nearest-neighbor heuristic for the n=20 fixture without explicit PI approval. This silently changed the research question from "test exact solver on 20-city problem" to "compare heuristic vs optimal solver." Codex implemented the prompt correctly, tests passed, but the workflow had drifted from the PI's intended research authority.

**Correction:**

When prompts involve consequential research-design choices, the Architect must:

1. **Identify the decision point** - Recognize when a choice affects research outcomes (exact vs heuristic, optimization vs approximation, speed vs accuracy, reference method selection)
2. **State available options** - List the alternatives (e.g., "Option A: brute-force up to n=8, fail gracefully beyond; Option B: implement heuristic for n>8; Option C: implement exact DP solver")
3. **State consequences** - Explain how each option affects the research question
4. **Wait for PI approval** - Do not proceed until PI selects an option
5. **Include approval note in prompt** - Document which option was approved and by whom

**Scope:**

This correction applies to decisions involving:
- Algorithm selection (exact vs heuristic, different algorithmic families)
- Validation criteria (what counts as "correct")
- Reference methods (which gem/library to use as ground truth)
- Speed-vs-accuracy tradeoffs
- Experimental interpretation

**Out of scope:**

Routine implementation details that do not affect research outcomes:
- Variable naming
- Code structure
- File organization (unless it affects architectural coupling)
- Test implementation (unless it affects what is validated)

---

## C002 - Distinguish Implementation from Research Decisions

**Date:** 2026-04-16  
**Addresses:** CLE0005, general pattern of LLM control-taking

**Problem:**

LLMs treat ambiguity as permission to choose. When a requirement is partially specified, LLMs make substitutions that seem "reasonable" but actually shift decision authority away from the PI.

**Correction:**

**Scope of LLM authority:**

LLMs MAY resolve:
- How to structure code to meet approved specifications
- Which data structures to use for approved algorithms
- How to name variables, functions, files
- How to organize tests for approved validation criteria

LLMs MAY NOT resolve:
- Which algorithm to implement when multiple options exist
- What validation criteria define "correctness"
- Which external library/gem counts as reference truth
- Whether to optimize for speed vs accuracy
- How to interpret ambiguous research requirements

**When in doubt:** The LLM should ask the PI rather than choosing.

---

## C003 - LLMs Must Flag Architectural Checkpoints

**Date:** 2026-04-17  
**Addresses:** CE0006 (OR-Tools misconfiguration), CE0007 (TSP root route), CE0008 (PATH regression), general pattern of LLM metacognitive blindness

**Problem:**

LLMs execute tasks toward goals without recognizing **significant decision moments** or **architectural implications**. They treat decision-making as routine implementation rather than governance checkpoints requiring PI awareness.

**Examples from this project:**

1. **CE0006:** Codex implemented `:path_cheapest_arc` without recognizing "this is the reference solver - which algorithm mode matters for ground truth validation?"
2. **CE0007:** Codex made TSP the root route without recognizing "this is an architectural decision about how the whole multi-algorithm app is structured"
3. **CE0008:** Codex reverted to PATH prefix without noticing "I'm doing something different from the pattern established in recent results"

**The pattern:** LLMs lack metacognitive awareness of when they're making decisions vs implementing decisions. They don't develop insight about the project trajectory, error patterns, or architectural implications.

**Correction:**

Both Architect and Coder must **explicitly flag checkpoint moments** in their outputs when they encounter:

**Architectural checkpoints:**
- Decisions affecting system structure, navigation, or coupling
- Choices that constrain future additions (root routes, tight coupling, global state)
- Patterns that become project standards (command syntax, file organization, error handling)

**Research checkpoints:**
- Algorithm selection (exact vs heuristic, optimization approaches)
- Reference/validation assumptions (what counts as "ground truth")
- Verification standards (what properties must be validated)

**Process checkpoints:**
- Deviations from established patterns (command syntax, result documentation)
- Workarounds that could leak into methodology
- Error patterns repeating across prompts

**How to flag:**

When implementing a prompt, if the LLM encounters a checkpoint moment, it **MUST**:

1. **STOP and state the checkpoint explicitly**
   - "CHECKPOINT: This implementation requires choosing between exact optimization (slow, n≤15) vs heuristic (fast, all n). This affects research validity."
   - "CHECKPOINT: Setting root route determines app architecture for all future algorithms."
   - "CHECKPOINT: This command pattern differs from recent results. Should this become the new standard?"

2. **Present options and implications**
   - List alternatives
   - State what each choice affects
   - Note if this sets a precedent

3. **WAIT for PI approval**
   - Do NOT proceed with implementation
   - Do NOT make assumptions about what the PI wants
   - Do NOT decide a checkpoint is "minor" and skip approval

**Rule:** If a choice affects research validity, architecture, project standards, or documented methodology, it is NOT minor. Flag it and wait for PI approval.

**Benefit:**

This enforces a **mechanical stop rule** that prevents LLMs from proceeding through consequential decision points without PI approval. It makes the system testable: either the LLM flagged the checkpoint and waited, or it didn't. No subjective judgment about what's "minor."

**Scope:**

This applies to:
- Both Claude (Architect) and Codex (Coder)
- All prompts going forward
- Any moment where a choice affects architecture, research validity, or project patterns

**Out of scope:**

- Routine coding choices already within C002 scope
- Obvious implementation details with no architectural implications


---

## C004 - Codex Must Reject Unapproved Research Substitutions

**Date:** 2026-04-17  
**Addresses:** General pattern where Architect (Claude) makes unauthorized choices that Coder (Codex) implements without question

**Problem:**

When Codex receives a prompt from Claude containing research-design decisions not explicitly approved by the PI, Codex may implement them without recognizing the substitution. This creates a failure where both LLMs bypass PI authority.

**Correction:**

When Codex receives a prompt that specifies an algorithm, validation method, reference choice, or architectural decision, Codex MUST:

1. **Check for PI approval** - Look in the conversation history for explicit PI approval of this specific choice
2. **Recognize substitutions** - Identify when the prompt specifies choices that weren't in PLAN.md or approved by PI
3. **Flag and STOP** - Report: "This prompt specifies [X], but I don't see PI approval for this choice in the conversation history"
4. **WAIT for confirmation** - Do not implement until PI confirms the choice was intentional

**Important:** Prompts can DOCUMENT PI approval (e.g., "PI approved Option C: exact DP solver"), but prompts cannot MANUFACTURE PI approval. The approval must exist in the conversation history, not just be claimed in the prompt.

This creates a second line of defense: even if Claude makes an unauthorized choice, Codex can catch it before implementation.

---

## Additional Governance Rules

**PLAN.md Governance:**

PLAN.md remains the frozen research charter. It defines:
- Multi-algorithm scope (not TSP-specific)
- Three-role separation (PI/Architect/Coder)
- Research goals and hard constraints
- What the paper-worthy result is (LLM error patterns, not algorithm performance)

Neither Claude nor Codex may modify PLAN.md. Changes to research direction, scope, or methodology require PI approval documented in the conversation, not in prompts or code.

If a prompt or implementation appears to contradict PLAN.md, the LLM must flag the contradiction and wait for PI clarification.
