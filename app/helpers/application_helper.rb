module ApplicationHelper
  def app_version
    Rails.root.join("VERSION").read.strip
  end

  def problem_profile_for(challenge_name)
    case challenge_name
    when "Traveling Salesman Problem"
      {
        domain: "Operations Research",
        complexity: "NP-hard optimization problem; the decision version is NP-complete.",
        relevance: "Models sequencing, routing, dispatch, and tour planning where search space grows factorially."
      }
    when "Vehicle Routing Problem"
      {
        domain: "Operations Research",
        complexity: "NP-hard; generalizes TSP by adding vehicles, capacity, and assignment-to-route decisions.",
        relevance: "Central to logistics, delivery, service fleets, warehouse dispatch, and transportation cost control."
      }
    when "Assignment Problem"
      {
        domain: "Operations Research",
        complexity: "Polynomial-time linear assignment problem; Hungarian algorithm runs in O(n^3).",
        relevance: "Models worker-task matching, resource allocation, scheduling, and minimum-cost pairing decisions."
      }
    when "Job Shop Scheduling Problem"
      {
        domain: "Operations Research",
        complexity: "NP-hard scheduling problem with precedence and resource constraints.",
        relevance: "Models production planning, manufacturing sequencing, resource contention, and time-constrained operations."
      }
    when "Moon Phase Calculations"
      {
        domain: "Astronomy",
        complexity: "Numerical astronomy problem using trigonometric approximation and time conversion.",
        relevance: "Models lunar phase estimation, event timing, ephemeris-backed reference checks, and UTC-sensitive scientific computation."
      }
    when "N-Queens Problem"
      {
        domain: "Combinatorics",
        complexity: "NP-complete decision variant; exact counting requires exhaustive search with pruning.",
        relevance: "Models exact combinatorial search, constraint pruning quality, and correctness-sensitive counting."
      }
    when "Minimum Cost Flow Problem"
      {
        domain: "Operations Research",
        complexity: "Polynomial-time network optimization problem with capacities, costs, and fixed demand.",
        relevance: "Models cost-aware routing, logistics planning, and flow allocation under capacity constraints."
      }
    when "Max Flow Problem"
      {
        domain: "Operations Research",
        complexity: "Polynomial-time network flow problem; Edmonds-Karp runs in O(VE^2).",
        relevance: "Models throughput, bottlenecks, routing capacity, infrastructure planning, and supply networks."
      }
    end
  end
end
