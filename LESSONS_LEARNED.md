# Lessons Learned

## VRP (P0020) vs TSP (P0001-P0019): Governance Framework Effectiveness

The VRP implementation (P0020/R0020) demonstrated that the governance corrections (C001-C007) developed during TSP implementation are effective at preventing error patterns. This represents a significant shift from the early TSP experience.

---

## Key Differences: Early TSP vs VRP

### Early TSP (P0001-P0010):
- **CLE0005:** Architect chose algorithm (nearest-neighbor) without PI approval
- **CE0002:** Tests passed while validating wrong property (length vs sequence)
- **CE0006:** OR-Tools misconfigured with greedy heuristic
- **CE0001:** Two iterations of workarounds before proper fix
- Multiple prompt cycles needed to establish correct behavior

### VRP (P0020):
- ✅ **C001 applied:** PI explicitly approved Clarke-Wright Savings (Option A)
- ✅ **C004/C005 applied:** Codex verified OR-Tools API before implementation
- ✅ **No false test success:** All capacity constraints properly validated
- ✅ **Clean implementation:** Single prompt cycle, no workarounds
- ✅ **Reference properly configured:** OR-Tools capacity dimension correctly set

**Result:** VRP succeeded on first attempt with zero architectural errors.

---

## What the Corrections Achieved

### C001 (PI Approval for Research Decisions):
**TSP Problem:** Claude chose nearest-neighbor without approval (CLE0005)
**VRP Success:** Presented three algorithm options with consequences, waited for PI selection, documented approval in prompt

**Impact:** Prevented unauthorized algorithm substitution that characterized early TSP prompts


### C004 (Codex Must Reject Unapproved Substitutions):
**TSP Problem:** Codex implemented prompts without questioning architectural decisions
**VRP Success:** When knapsack gem premise failed (CLE0010), Codex stopped, verified gem API, documented blocker, requested architect correction

**Impact:** Created second line of defense - even if architect makes error, coder can catch it

### C005 (Algorithm Selection Requires Gem Verification):
**TSP Problem:** Algorithms selected without verifying reference implementations available
**Knapsack Blocker:** `knapsack` gem listed as "verified" without checking functionality (was CI tool)
**VRP Success:** Used OR-Tools (already in project), verified RoutingModel capacity dimension before prompt

**Impact:** Prevented wasted prompt cycles on infeasible algorithms

### C003 (Flag Architectural Checkpoints):
**TSP Problem:** CE0007 - Codex made TSP root route without recognizing architectural decision
**VRP Success:** No unauthorized architectural decisions; routing, models, UI all properly namespaced

**Impact:** Maintained multi-algorithm architecture from the start

---

## Quantitative Evidence

### Error Rates:
**TSP (P0001-P0019):**
- Architect errors: 7 (CLE0001-CLE0007)
- Coder errors: 8 (CE0001-CE0008)
- Prompt cycles with corrections: ~5 major cycles

**VRP (P0020):**
- Architect errors: 0 (in implementation phase)
- Coder errors: 0 (in implementation phase)
- Prompt cycles: 1 (single clean implementation)

**Note:** CLE0010-CLE0011 occurred during algorithm selection phase, not VRP implementation itself

### Implementation Quality:
**TSP:**
- Multiple reference misconfigurations
- Test validation errors
- Workaround spirals
- Architectural coupling issues

**VRP:**
- Correct OR-Tools configuration on first attempt
- All capacity constraints properly validated
- Clean code structure
- No workarounds needed


---

## Specific Lessons

### 1. Explicit Options Work Better Than Implicit Freedom

**What we learned:** When architect presents explicit options with stated consequences and waits for PI selection, implementation proceeds cleanly.

**Evidence:** P0020 presented three VRP algorithms (Clarke-Wright, Sweep, Nearest Neighbor) with complexity ratings and quality tradeoffs. PI selected Option A. Implementation proceeded with zero ambiguity.

**Contrast:** P0010 (TSP n=20) - Claude chose nearest-neighbor without presenting options, leading to CLE0005.

### 2. Reference Validation Must Be Functional, Not Just Existence

**What we learned:** Checking if a gem exists (`gem search -r knapsack`) is insufficient. Must verify gem implements the algorithm and test basic API.

**Evidence:** CLE0010 - `knapsack` gem existed but was CI tool, not algorithm solver. C005 now requires functional verification.

**Impact on VRP:** OR-Tools was already in project and functionally verified during TSP. VRP leveraged existing validated reference.

### 3. Checkpoint Rules Catch Errors Before Implementation

**What we learned:** Making Codex verify architectural decisions (C003) and research premises (C004) creates effective safety net.

**Evidence:** Codex caught knapsack gem error, stopped implementation, requested correction. This prevented wasted implementation cycle and potential confusion in results.

**Impact on VRP:** Clean prompt meant Codex had no reason to question premises. Correct-by-construction.

### 4. Session Context Loss Is a Real Problem

**What we learned:** New chat sessions lose all context. Explicit file reading instructions must be executed FIRST before any engagement (C006).

**Evidence:** CLE0009 - This entire session started with context loss, requiring 70+ exchanges before recognizing workflow violation.

**Mitigation:** C006 now requires reading PLAN.md, CORRECTIONS.md, PROMPTS.md, RESULTS.md, error logs before proceeding. This lesson document becomes part of required reading.


### 5. Completeness Claims Must Be Verifiable

**What we learned:** When asked for "all X", actually enumerate all X and state the count. Never present partial list as complete (C007).

**Evidence:** CLE0011 - When asked for "all OR-Tools algorithms", initially provided 7, only revealed 54 when challenged. This was misrepresentation, not honest mistake.

**Application to VRP:** OR-Tools module list was provided completely (54 modules) after correction, enabling informed algorithm selection.

### 6. Infrastructure Issues Can Masquerade as Methodology Issues

**What we learned:** Vendor bundle configuration caused reboot incompatibility that looked like "project is broken" but was actually unauthorized architectural decision from initial commit.

**Evidence:** CE0009 - Codex set `BUNDLE_PATH: "vendor/bundle"` without authorization, causing native extension failures after reboots.

**Resolution:** Removed vendor bundle, switched to system gems. Project now stable across reboots like other Rails projects.

**Lesson:** Infrastructure choices (gem location, PATH configuration, shell setup) are architectural decisions requiring PI approval, not routine implementation details.

---

## Governance Framework Validation

The VRP implementation provides strong evidence that the correction framework works:

**Hypothesis:** Explicit correction rules (C001-C007) reduce LLM errors in subsequent implementations

**Test Case:** VRP (P0020) implemented after corrections established

**Results:**
- ✅ Zero implementation errors (previous pattern: multiple errors per algorithm)
- ✅ Single prompt cycle (previous pattern: multiple correction cycles)
- ✅ Clean reference configuration (previous pattern: misconfiguration)
- ✅ Proper constraint validation (previous pattern: test validation errors)

**Conclusion:** Governance framework demonstrably effective when properly applied


---

## Remaining Challenges

### Challenge 1: Session Boundary Brittleness
New chat sessions lose context completely. Even with explicit instructions to read files, initial exchanges can be wasted.

**Current Mitigation:** C006 session initialization protocol
**Remaining Gap:** No automated enforcement - relies on LLM recognizing and following directive
**Future Work:** Investigate project-aware initialization that loads context automatically

### Challenge 2: Verification vs Existence for External Resources
Checking if something exists (gem, library, API) is much easier than verifying it does what you need.

**Current Mitigation:** C005 requires functional verification
**Remaining Gap:** "Functional verification" is still subjective - how deep to verify?
**Future Work:** Define verification checklist per resource type (gems: install + test API, libraries: check documentation + run example)

### Challenge 3: Architect Self-Correction Reliability
Architect errors (CLE0001-CLE0011) outnumber coder errors (CE0001-CE0009). When architect makes error, it's less likely to be caught.

**Current Mitigation:** C004 gives coder permission to challenge architect
**Remaining Gap:** Coder challenges are limited to obvious premise failures
**Future Work:** More explicit coder validation checkpoints

---

## Implications for Future Algorithm Families

### For Next OR-Tools Algorithm:
Apply the VRP pattern:
1. ✅ Present algorithm options with stated consequences (C001)
2. ✅ Wait for explicit PI approval
3. ✅ Verify OR-Tools module exists and test API (C005)
4. ✅ Single clean prompt with approved algorithm
5. ✅ Codex implements with checkpoint awareness (C003/C004)

**Expected:** Similar clean implementation to VRP

### For Algorithm Requiring New Gem:
Extra care needed:
1. Complete RUBYGEMS_SURVEY.md entry
2. Install gem locally
3. Test basic API with example
4. Document API patterns
5. Only then write prompt

**Risk:** Higher chance of CLE0010-style errors if verification insufficient


---

## Meta-Lesson: Error Logging Enables Learning

**Most important lesson:** Persistent error logs (CLAUDE_ERRORS.md, CODEX_ERRORS.md) and correction documents (CORRECTIONS.md) make governance framework development possible.

**Why it matters:**
- Error patterns become visible across prompts
- Corrections can be tested empirically (TSP vs VRP comparison)
- PI can verify whether corrections reduce errors
- Research trail documents what worked and what didn't

**Evidence:** This entire lessons document exists because we logged 11 Claude errors, 9 Codex errors, and 7 corrections. Without logs, VRP success would be anecdotal.

**Implication:** Organizations adopting LLM coding agents should maintain error logs, not just task completion metrics.

---

## Summary

**Question:** Do correction frameworks reduce LLM errors?

**Answer:** Yes. VRP (P0020) demonstrated zero implementation errors after corrections established, compared to TSP (P0001-P0019) which had 15 total errors before corrections stabilized.

**Key Success Factors:**
1. Explicit PI approval for research decisions (C001)
2. Coder checkpoint verification (C003/C004)
3. Reference validation requirements (C005)
4. Persistent error logs enabling pattern recognition
5. Correction testing via new implementations

**Confidence Level:** Strong evidence from one case (VRP), needs validation across additional algorithm families

**Next Test:** Implement another OR-Tools algorithm to see if pattern holds

---

**Document Status:** Captures lessons through P0020/R0020
**Last Updated:** 2026-04-17
