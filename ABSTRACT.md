# Abstract

This project investigates a human-in-the-loop workflow for evaluating large language model (LLM) collaborators in research-oriented software development. The goal is not to argue that LLMs cannot code, nor to argue that coding agents will replace human developers. The central claim is that LLM-assisted software development changes the structure of governance, authority, and accountability. Unlike coding-agent benchmarks that primarily score whether an agent resolves a task, this study treats the full collaboration trail as the object of analysis: PI intent, architect prompts, Codex implementations, test results, UI interpretation, documented LLM errors, and process corrections.

The current case study uses a Ruby on Rails application and SQLite3 database to compare Ruby implementations of algorithmic problems against established Ruby gem or library references. The initial problem domain is the Traveling Salesman Problem (TSP), where candidate Ruby solvers are compared against an OR-Tools-based reference. The app records prompts, attempts, solver outputs, reference outputs, status classifications, PI interpretations, and algorithm versions.

The most significant finding so far is not merely a code defect. It is an architect-level research-design failure. In response to the PI's request to test a 20-city TSP problem, the architect model first produced contradictory requirements that preserved a brute-force limit while expecting larger instances to run, then later specified a nearest-neighbor heuristic without explicit PI approval. This silently changed the research question from an open 20-city TSP design question into a speed-oriented heuristic-vs-reference comparison. Codex implemented the prompt correctly, tests passed, and the app produced plausible results, but the workflow had already drifted from the PI's intended research authority.

This motivates a central claim: passing tests and functional code are insufficient evidence of research correctness in LLM-assisted software projects. A system can be locally correct while answering the wrong question. The highest-risk failures may occur before code generation, when an architect agent transforms a human research goal into a concrete technical choice without authorization. These failures are difficult to detect precisely because the resulting software can appear coherent, tested, and useful.

This study also rejects a simplistic "the human did not write a detailed enough prompt" explanation. Clearer prompts help, but real software and research workflows always contain partially specified requirements. The critical distinction is between routine implementation details and consequential research-design choices. LLMs may resolve ordinary programming details needed to execute an approved design. They may not silently resolve open choices involving algorithms, validation criteria, reference methods, speed-vs-accuracy tradeoffs, or experimental interpretation. When such choices remain open, the system must preserve the decision for the PI rather than treating ambiguity as permission to substitute its own design.

Therefore, LLM-assisted research software requires explicit governance artifacts that separate errors from corrections. This project preserves `PLAN.md` as the frozen starting plan, uses `PROMPTS.md` and `RESULTS.md` as trace logs, records role-specific failures in `CLAUDE_ERRORS.md` and `CODEX_ERRORS.md`, and introduces `CORRECTIONS.md` to define active safeguards such as requiring PI approval for algorithmic research-design choices and distinguishing routine implementation judgment from research-design authority.

The emerging contribution is a traceable methodology for studying LLM goal drift, unauthorized design substitution, prompt-code mismatch, and correction loops in multi-role AI-assisted software development. The current evidence is best understood as a preliminary case study rather than a complete journal-ready evaluation. Future work should extend the method across additional algorithm families, compare corrected and uncorrected workflows, and test whether explicit correction rules reduce architect and coder drift over subsequent iterations.

## Keywords

LLM agents; AI-assisted software engineering; coding agents; goal drift; research governance; accountability; human-in-the-loop evaluation; prompt traceability; Ruby; Rails; algorithm benchmarking; Traveling Salesman Problem.

## Related Work

Most related work evaluates LLMs or agents by task-completion performance. SWE-bench introduced a benchmark of real GitHub issues where language models must edit repositories to resolve software problems. SWE-agent extended this line by emphasizing agent-computer interfaces for automated software engineering. SWE-bench Verified later showed that benchmark quality itself requires human validation because problem statements and tests can be underspecified or unfair. These efforts are directly relevant, but they primarily evaluate whether agents produce acceptable patches under benchmark conditions.

AgentBench evaluates LLMs as agents across multiple interactive environments, emphasizing reasoning and decision-making in multi-turn settings. Terminal-Bench similarly evaluates agents in command-line environments with realistic tasks and test-based verification. Long-horizon benchmarks such as SWE-CI and SWE-EVO further shift attention from one-shot repair toward maintaining codebases or evolving software over time.

Agentless is especially relevant because it questions whether complex autonomous software agents are necessary and highlights simpler, more interpretable workflows. This project is aligned with that concern but moves the focus from agent complexity to research-governance failure: when an LLM architect or coder produces working software that changes the PI's research question.

The present project differs from these benchmarks in five ways:

1. It treats role-specific error attribution as primary data, separating PI, architect, and coder responsibilities.
2. It records prompt, result, error, and correction artifacts as persistent files rather than only final task outcomes.
3. It evaluates goal preservation and research-design authority, not only functional correctness.
4. It treats passing tests as insufficient when the underlying prompt has substituted an unauthorized research question.
5. It distinguishes routine implementation ambiguity from consequential decision authority, rejecting the idea that imperfect human prompts justify silent agent control over research design.

## References

1. Carlos E. Jimenez, John Yang, Alexander Wettig, Shunyu Yao, Kexin Pei, Ofir Press, and Karthik Narasimhan. "SWE-bench: Can Language Models Resolve Real-World GitHub Issues?" arXiv:2310.06770, 2023.  
   https://arxiv.org/abs/2310.06770

2. John Yang, Carlos E. Jimenez, Alexander Wettig, Kilian Lieret, Shunyu Yao, Karthik Narasimhan, and Ofir Press. "SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering." arXiv:2405.15793, 2024.  
   https://arxiv.org/abs/2405.15793

3. Neil Chowdhury, James Aung, Chan Jun Shern, Oliver Jaffe, Dane Sherburn, Giulio Starace, Evan Mays, Rachel Dias, Marwan Aljubeh, Mia Glaese, Carlos E. Jimenez, John Yang, Leyton Ho, Tejal Patwardhan, Kevin Liu, and Aleksander Madry. "Introducing SWE-bench Verified." OpenAI, 2024.  
   https://openai.com/index/introducing-swe-bench-verified/

4. OpenAI. "Why SWE-bench Verified no longer measures frontier coding capabilities." OpenAI, 2026.  
   https://openai.com/index/why-we-no-longer-evaluate-swe-bench-verified/

5. Xiao Liu, Hao Yu, Hanchen Zhang, Yifan Xu, Xuanyu Lei, Hanyu Lai, Yu Gu, Hangliang Ding, Kaiwen Men, Kejuan Yang, Shudan Zhang, Xiang Deng, Aohan Zeng, Zhengxiao Du, Chenhui Zhang, Sheng Shen, Tianjun Zhang, Yu Su, Huan Sun, Minlie Huang, Yuxiao Dong, and Jie Tang. "AgentBench: Evaluating LLMs as Agents." arXiv:2308.03688, 2023.  
   https://arxiv.org/abs/2308.03688

6. Chunqiu Steven Xia, Yinlin Deng, Soren Dunn, and Lingming Zhang. "Agentless: Demystifying LLM-based Software Engineering Agents." arXiv:2407.01489, 2024.  
   https://arxiv.org/abs/2407.01489

7. Mike A. Merrill, Alexander G. Shaw, Nicholas Carlini, Boxuan Li, Harsh Raj, Ivan Bercovich, Lin Shi, Jeong Yeon Shin, Thomas Walshe, E. Kelly Buchanan, Junhong Shen, Guanghao Ye, Haowei Lin, Jason Poulos, Maoyu Wang, Marianna Nezhurina, Jenia Jitsev, Di Lu, Orfeas Menis Mastromichalakis, Zhiwei Xu, Zizhao Chen, Yue Liu, et al. "Terminal-Bench: Benchmarking Agents on Hard, Realistic Tasks in Command Line Interfaces." arXiv:2601.11868, 2026.  
   https://arxiv.org/abs/2601.11868

8. Jialong Chen, Xander Xu, Hu Wei, Chuan Chen, and Bing Zhao. "SWE-CI: Evaluating Agent Capabilities in Maintaining Codebases via Continuous Integration." arXiv:2603.03823, 2026.  
   https://arxiv.org/abs/2603.03823

9. Minh V. T. Thai, Tue Le, Dung Nguyen Manh, Huy Phan Nhat, and Nghi D. Q. Bui. "SWE-EVO: Benchmarking Coding Agents in Long-Horizon Software Evolution Scenarios." arXiv:2512.18470, 2025.  
   https://arxiv.org/abs/2512.18470

## Working Position

This draft should be treated as a preliminary abstract and related-work sketch, not a final paper abstract. It captures the current research direction as of P0012/R0012 and should be revised after additional algorithm families and correction-loop tests are completed.
## Conclusion

This project demonstrates that **LLM-assisted research software requires explicit governance boundaries** separating routine implementation from research-design authority. The three-role architecture (PI/Architect/Coder) with persistent error logs makes unauthorized design substitutions visible and traceable.

**Key empirical findings:**

1. **Passing tests ≠ research correctness** - CE0002 shows both LLMs claimed success while validating the wrong property (tour length without sequence). Tests passed but core requirement violated.

2. **LLMs make research decisions without authorization** - CLE0005 demonstrates the architect chose nearest-neighbor heuristic for n=20 without PI approval, silently changing the research question from "test 20-city problem" to "compare heuristic vs optimal."

3. **Reference solvers require verification** - CE0006 reveals OR-Tools was misconfigured to use greedy heuristic instead of exact solver, producing suboptimal results accepted as "ground truth" until manual verification.

4. **HITL oversight is constitutive, not supervisory** - PI caught all three major errors (CE0002, CLE0005, CE0006) through UI inspection and manual calculation. Without human verification, LLMs would have reported success while answering wrong questions.

**Process corrections validated:**

- **C001:** Explicit PI approval now required for algorithmic choices affecting research outcomes
- **C002:** Clear distinction between implementation details (LLM-resolvable) and research-design authority (PI-reserved)

**Methodological contribution:**

Unlike task-completion benchmarks (SWE-bench, Terminal-Bench), this framework evaluates **goal preservation** and **decision-boundary respect** in multi-role LLM collaboration. The persistent artifact trail (PLAN.md, PROMPTS.md, RESULTS.md, error logs, corrections) enables analysis of where and how LLM drift occurs, not just whether tasks complete.

**Current limitations:**

- Single algorithm domain (TSP only) - pattern generalization unverified
- Small sample size (15 prompts, 7 architect errors, 6 coder errors)
- No quantitative correction effectiveness analysis
- Single-model assessment (Claude architect, Codex coder)

**Future work priorities:**

1. **Additional algorithm families** (Knapsack, Graph Coloring) to test whether error patterns persist across domains
2. **Correction effectiveness evaluation** - Compare workflows before/after C001/C002 to measure drift reduction
3. **Multi-model comparison** - Test whether error types differ across LLM architectures
4. **Quantitative pattern analysis** - Statistical characterization of architect vs coder error frequencies and impacts

This work provides a traceable methodology for studying LLM goal drift, unauthorized design choices, and correction loops in research-oriented software development. The evidence supports the claim that governance artifacts and decision-boundary enforcement are essential for maintaining research integrity in LLM-assisted workflows.

## Working Position

This draft represents the state of the project as of P0015/R0015 (TSP benchmark complete with corrected OR-Tools solver). It should be treated as a preliminary research artifact, not a final publication. Additional algorithm families and correction-loop analysis remain pending before journal submission.
