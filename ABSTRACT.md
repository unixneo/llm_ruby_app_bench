# Abstract

This project investigates LLM-assisted software development as a governance problem, not merely a code-generation problem. The study does not argue that LLMs cannot code, nor that coding agents will simply replace human developers. Instead, it examines how LLM architects and coding agents can produce runnable, tested software while shifting architectural authority, validation responsibility, and research accountability away from the human principal investigator (PI).

The core claim is that organizations using LLMs or coding agents require human-in-the-loop (HITL) governance, not just HITL prompting. In this framing, the human role is not limited to writing clearer prompts or approving generated code. The human role is an accountability function that preserves research intent, distinguishes implementation details from research-design decisions, validates results beyond unit tests, and prevents local workarounds from becoming undocumented project methodology.

The current case study uses a Ruby on Rails application with SQLite3 to evaluate LLM collaboration in research-oriented algorithm implementation. Three algorithm families have been implemented: the Traveling Salesman Problem (TSP) through 19 prompts, the Vehicle Routing Problem (VRP) in 1 prompt, and the Assignment Problem in 1 prompt. The application records numbered prompts, implementation results, solver outputs, gem/reference outputs, status classifications, PI interpretations, algorithm versions, and correction records. The project also preserves role-specific error logs for the Architect (Claude) and Coder (Codex), allowing failures to be attributed to prompt design, coding implementation, verification, architecture, or process governance.

The most important empirical observation is that successful local execution and passing unit tests are not sufficient evidence of research correctness. Several failures in the project produced plausible software artifacts while violating the intended research process. Examples include:

- **CLE0005:** Architect chose nearest-neighbor heuristic for n=20 without PI approval, changing research question from "test exact solver" to "compare heuristic vs optimal"
- **CE0002/CLE0002:** Comparison logic checked tour length but not route sequence; tests passed while core requirement violated
- **CE0006/CLE0007:** OR-Tools initially misconfigured with greedy heuristic, later risk of claiming guided local search was exact
- **CE0007:** Made TSP the application root despite project being multi-algorithm benchmark
- **CE0009:** Unauthorized vendor bundle configuration caused reboot incompatibility issues
- **CLE0010:** Listed knapsack gem as "verified" without checking it was CI tool, not algorithm solver (governance framework correctly stopped implementation)
- **CLE0011:** When asked for "all OR-Tools algorithms", initially provided 7, only revealed 54 modules when challenged (misrepresentation, not honest mistake)
- **CLE0012:** Manual verification error in P0021 prompt (documented cost 10 for assignment_tiny_3x3, actual optimal 9) - architecture self-corrected via reference validation

These failures show that LLM risk in software development is not limited to syntax errors or broken tests. The deeper risk is that an LLM can silently answer a different question than the one the organization intended to ask. It may choose an algorithm, reference method, validation criterion, route structure, or operational workaround while presenting the result as ordinary implementation. In organizational settings, this can blur ownership of decisions that should remain accountable to humans.

A significant finding is that governance frameworks demonstrably reduce errors. The C004/C005 correction protocol successfully prevented implementation of the knapsack algorithm after Codex verified the gem API and discovered it was a CI test-splitting tool rather than an optimization solver. More importantly, after corrections (C001-C007) were established, two consecutive implementations proceeded with zero errors:

- **VRP (P0020):** Clarke-Wright Savings algorithm, 0 implementation errors, single clean cycle
- **Assignment (P0021):** Hungarian algorithm (exact O(n³)), 0 implementation errors, all 5 fixtures achieved exact optimal match

This contrasts sharply with early TSP prompts (P0001-P0019) which accumulated 15 total errors before corrections stabilized. The framework works across both NP-hard heuristics (VRP) and exact polynomial algorithms (Assignment), demonstrating generalization beyond a single problem class.

This study therefore treats persistent project artifacts as first-class research data. `PLAN.md` preserves the frozen starting plan. `PROMPTS.md` records Architect prompts (P0001-P0021). `RESULTS.md` records Coder outcomes and verification evidence (R0001-R0021). `CLAUDE_ERRORS.md` and `CODEX_ERRORS.md` classify role-specific failures (12 architect errors, 9 coder errors). `CORRECTIONS.md` records seven active safeguards, including:

- **C001:** PI approval required for algorithmic research decisions
- **C002:** Distinguish implementation from research decisions  
- **C003:** Flag architectural checkpoints requiring PI awareness
- **C004:** Codex must reject unapproved research substitutions
- **C005:** Algorithm selection requires reference gem verification
- **C006:** New session initialization protocol
- **C007:** Completeness verification (when asked for "all", verify and state count)

This trace makes it possible to study not only whether the code works, but whether the collaboration preserved scope, role boundaries, evidence standards, and accountability.

The emerging contribution is a methodology for studying LLM coding agents in long-running research software projects where governance matters as much as code generation. The project suggests that effective LLM adoption in software organizations requires prompt/result ledgers, error/correction ledgers, reference-validation procedures, architecture approval gates, domain validation beyond unit tests, and explicit rules preventing workaround contamination. These controls do not replace software testing; they address a different risk class: tested software that is locally functional but organizationally or scientifically misaligned.

Current evidence demonstrates both the problem and viable solutions. Two consecutive implementations validated the correction framework:

**VRP (P0020):** Clarke-Wright Savings algorithm selected with explicit PI approval (C001), OR-Tools reference properly configured, all five fixtures produced feasible solutions respecting capacity constraints.

**Assignment (P0021):** Hungarian algorithm (exact polynomial) achieved optimal cost on all 5 fixtures (3×3 to 15×15), with zero implementation errors. The only error (CLE0012) was a manual verification mistake in the prompt itself, which the architecture self-corrected through reference validation - demonstrating that the three-role separation provides defense in depth.

Quantitative evidence: TSP (P0001-P0019) had 15 total errors before corrections stabilized. Post-corrections, VRP and Assignment had 0 implementation errors each, showing the governance framework prevents error patterns that characterized early work.

The next step is to extend the method across additional algorithm families from the OR-Tools suite, compare corrected and uncorrected workflows quantitatively, and measure whether documented correction rules reduce repeated drift by Architect and Coder agents over multiple algorithm implementations.

## Keywords

LLM agents; AI-assisted software engineering; coding agents; human-in-the-loop governance; accountability; validation beyond unit testing; prompt traceability; result traceability; goal drift; research governance; Ruby; Rails; algorithm benchmarking; Traveling Salesman Problem; Vehicle Routing Problem; OR-Tools; reference validation; correction frameworks.

## Related Work

Most related work evaluates LLMs or agents by task-completion performance. SWE-bench introduced a benchmark of real GitHub issues where language models must edit repositories to resolve software problems. SWE-agent extended this line by emphasizing agent-computer interfaces for automated software engineering. SWE-bench Verified later showed that benchmark quality itself requires human validation because problem statements and tests can be underspecified or unfair. These efforts are directly relevant, but they primarily evaluate whether agents produce acceptable patches under benchmark conditions.

AgentBench evaluates LLMs as agents across multiple interactive environments, emphasizing reasoning and decision-making in multi-turn settings. Terminal-Bench similarly evaluates agents in command-line environments with realistic tasks and test-based verification. Long-horizon benchmarks such as SWE-CI and SWE-EVO further shift attention from one-shot repair toward maintaining codebases or evolving software over time.

Agentless is especially relevant because it questions whether complex autonomous software agents are necessary and highlights simpler, more interpretable workflows. This project is aligned with that concern but moves the focus from agent complexity to software-development governance: when an LLM architect or coder produces working software that changes the user's research question, validation standard, or architectural direction.

The present project differs from these benchmarks in seven ways:

1. **Role-specific error attribution:** Separates PI, Architect (Claude), and Coder (Codex) responsibilities with dedicated error logs
2. **Persistent artifacts as data:** Records prompt, result, error, and correction ledgers as first-class research data
3. **Goal preservation evaluation:** Assesses whether collaboration maintains PI's research intent, not only functional correctness
4. **Beyond passing tests:** Treats passing unit tests as insufficient when underlying prompt has substituted unauthorized research question
5. **Decision authority boundaries:** Distinguishes routine implementation ambiguity from consequential research-design choices requiring PI approval
6. **Reference validation:** Treats external libraries and benchmark references as assumptions requiring verification (C005), not automatic ground truth
7. **Workaround contamination:** Studies how local execution fixes can leak into project methodology or research records

Additionally, this project demonstrates that governance frameworks can work: C004/C005 successfully stopped implementation when reference gem premise failed (CLE0010), and VRP implementation (P0020) successfully applied correction protocols that prevented error patterns from earlier TSP prompts.

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

This draft represents the state of the project as of P0021/R0021. It should be treated as a preliminary research artifact, not a final publication abstract. The current evidence supports the governance framing and demonstrates that correction frameworks can prevent error patterns. Additional algorithm families from the OR-Tools suite, quantitative correction-loop analysis, and multi-algorithm error pattern analysis remain pending before journal submission.

**Current Status:**
- 21 prompts completed (19 TSP, 1 VRP, 1 Assignment)
- 12 Claude/Architect errors documented and corrected
- 9 Codex/Coder errors documented and corrected
- Strong governance validation: 2 consecutive zero-error implementations after corrections established
- Framework validated across NP-hard heuristics and exact polynomial algorithms
- 9 Codex/Coder errors documented
- 7 active correction protocols (C001-C007)
- Governance framework demonstrated effective (C004/C005 stopped faulty implementation)
- 47 tests, 556 assertions, all passing
