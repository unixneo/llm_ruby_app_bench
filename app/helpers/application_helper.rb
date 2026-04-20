module ApplicationHelper
  def app_version
    Rails.root.join("VERSION").read.strip
  end

  def problem_profile_for(challenge_name)
    case challenge_name
    when "Traveling Salesman Problem"
      {
        complexity: "NP-hard optimization problem; the decision version is NP-complete.",
        relevance: "Models sequencing, routing, dispatch, and tour planning where search space grows factorially."
      }
    when "Vehicle Routing Problem"
      {
        complexity: "NP-hard; generalizes TSP by adding vehicles, capacity, and assignment-to-route decisions.",
        relevance: "Central to logistics, delivery, service fleets, warehouse dispatch, and transportation cost control."
      }
    when "Assignment Problem"
      {
        complexity: "Polynomial-time linear assignment problem; Hungarian algorithm runs in O(n^3).",
        relevance: "Models worker-task matching, resource allocation, scheduling, and minimum-cost pairing decisions."
      }
    when "Max Flow Problem"
      {
        complexity: "Polynomial-time network flow problem; Edmonds-Karp runs in O(VE^2).",
        relevance: "Models throughput, bottlenecks, routing capacity, infrastructure planning, and supply networks."
      }
    end
  end
end
