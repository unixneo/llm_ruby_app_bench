# Abstract

This project investigates LLM-assisted software development as a governance problem, not merely a code-generation problem. The study does not argue that LLMs cannot code, nor that coding agents will simply replace human developers. Instead, it examines how LLM architects and coding agents can produce runnable, tested software while shifting architectural authority, validation responsibility, and research accountability away from the human principal investigator (PI).

The core claim is that organizations using LLMs or coding agents require human-in-the-loop (HITL) governance, not just HITL prompting. In this framing, the human role is not limited to writing clearer prompts or approving generated code. The human role is an accountability function that preserves research intent, distinguishes implementation details from research-design decisions, validates results beyond unit tests, and prevents local workarounds from becoming undocumented project methodology.

The current case study uses a Ruby on Rails application with SQLite3 to evaluate LLM collaboration in research-oriented algorithm implementation. The initial algorithm family is the Traveling Salesman Problem (TSP). The application records numbered prompts, implementation results, solver outputs, gem/reference outputs, status classifications, PI interpretations, algorithm versions, and correction records. The project also preserves role-specific error logs for the Architect and Coder, allowing failures to be attributed to prompt design, coding implementation, verification, architecture, or process governance.

The most important empirical observation is that successful local execution and passing unit tests are not sufficient evidence of research correctness. Several failures in the project produced plausible software artifacts while violating the intended research process. Examples include comparing TSP results by tour length while missing route-sequence correctness, treating an OR-Tools heuristic configuration as a reference truth, making TSP the application root despite the project being a multi-algorithm benchmark, and documenting command-line workarounds that were artifacts of a local shell session rather than the project standard.

These failures show that LLM risk in software development is not limited to syntax errors or broken tests. The deeper risk is that an LLM can silently answer a different question than the one the organization intended to ask. It may choose an algorithm, reference method, validation criterion, route structure, or operational workaround while presenting the result as ordinary implementation. In organizational settings, this can blur ownership of decisions that should remain accountable to humans.

This study therefore treats persistent project artifacts as first-class research data. `PLAN.md` preserves the frozen starting plan. `PROMPTS.md` records Architect prompts. `RESULTS.md` records Coder outcomes and verification evidence. `CLAUDE_ERRORS.md` and `CODEX_ERRORS.md` classify role-specific failures. `CORRECTIONS.md` records active safeguards, including the requirement that algorithmic research-design choices receive explicit PI approval. This trace makes it possible to study not only whether the code works, but whether the collaboration preserved scope, role boundaries, evidence standards, and accountability.

The emerging contribution is a methodology for studying LLM coding agents in long-running research software projects where governance matters as much as code generation. The project suggests that effective LLM adoption in software organizations requires prompt/result ledgers, error/correction ledgers, reference-validation procedures, architecture approval gates, domain validation beyond unit tests, and explicit rules preventing workaround contamination. These controls do not replace software testing; they address a different risk class: tested software that is locally functional but organizationally or scientifically misaligned.

The current evidence remains a preliminary case study. The next step is to extend the method across additional algorithm families, compare corrected and uncorrected workflows, and measure whether documented correction rules reduce repeated drift by Architect and Coder agents.

## Keywords

LLM agents; AI-assisted software engineering; coding agents; human-in-the-loop governance; accountability; validation beyond unit testing; prompt traceability; result traceability; goal drift; research governance; Ruby; Rails; algorithm benchmarking; Traveling Salesman Problem.

## Related Work

Most related work evaluates LLMs or agents by task-completion performance. SWE-bench introduced a benchmark of real GitHub issues where language models must edit repositories to resolve software problems. SWE-agent extended this line by emphasizing agent-computer interfaces for automated software engineering. SWE-bench Verified later showed that benchmark quality itself requires human validation because problem statements and tests can be underspecified or unfair. These efforts are directly relevant, but they primarily evaluate whether agents produce acceptable patches under benchmark conditions.

AgentBench evaluates LLMs as agents across multiple interactive environments, emphasizing reasoning and decision-making in multi-turn settings. Terminal-Bench similarly evaluates agents in command-line environments with realistic tasks and test-based verification. Long-horizon benchmarks such as SWE-CI and SWE-EVO further shift attention from one-shot repair toward maintaining codebases or evolving software over time.

Agentless is especially relevant because it questions whether complex autonomous software agents are necessary and highlights simpler, more interpretable workflows. This project is aligned with that concern but moves the focus from agent complexity to software-development governance: when an LLM architect or coder produces working software that changes the user's research question, validation standard, or architectural direction.

The present project differs from these benchmarks in seven ways:

1. It treats role-specific error attribution as primary data, separating PI, Architect, and Coder responsibilities.
2. It records prompt, result, error, and correction artifacts as persistent files rather than only final task outcomes.
3. It evaluates goal preservation and research-design authority, not only functional correctness.
4. It treats passing tests as insufficient when the underlying prompt has substituted an unauthorized research question.
5. It distinguishes routine implementation ambiguity from consequential decision authority.
6. It treats external libraries and benchmark references as assumptions requiring validation, not automatic ground truth.
7. It studies workaround contamination, where local execution fixes can leak into project methodology or research records.

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

This draft represents the state of the project as of P0017/R0017. It should be treated as a preliminary research artifact, not a final publication abstract. The current evidence supports the governance framing, but additional algorithm families, correction-loop analysis, and quantitative role-specific error analysis remain pending before journal submission.
