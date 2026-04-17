class ChallengesController < ApplicationController
  def index
    @tsp_challenge = Challenge.find_by(name: "Traveling Salesman Problem")
    @tsp_stats = {
      fixture_count: TspFixtures.all.count,
      algorithm_count: Attempt.distinct.count(:algorithm_version),
      attempt_count: Attempt.count
    }
    @future_challenges = [
      {
        name: "Knapsack Problem",
        description: "Optimization under capacity constraints.",
        status: "Coming Soon"
      },
      {
        name: "Graph Coloring",
        description: "Constraint solving over graph structure.",
        status: "Coming Soon"
      },
      {
        name: "Shortest Path Algorithms",
        description: "Pathfinding and weighted graph comparisons.",
        status: "Coming Soon"
      }
    ]
  end

  def show
    challenge = Challenge.find(params[:id])

    if challenge.name == "Traveling Salesman Problem"
      redirect_to attempts_path
    else
      redirect_to challenges_path, alert: "No attempt index is available for this challenge yet."
    end
  end
end
