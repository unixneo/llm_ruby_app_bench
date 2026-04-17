class ChallengesController < ApplicationController
  def index
    @tsp_challenge = Challenge.find_by(name: "Traveling Salesman Problem")
    @tsp_stats = {
      fixture_count: TspFixtures.all.count,
      algorithm_count: Attempt.distinct.count(:algorithm_version),
      attempt_count: Attempt.count
    }
    # Future algorithm families must have verified Ruby reference gems.
    # C005: Algorithm selection requires RubyGems survey (see RUBYGEMS_SURVEY.md).
    # Only add placeholders after gem verification is complete.
    @future_challenges = [
      {
        name: "Knapsack Problem",
        description: "Optimization under capacity constraints.",
        status: "Coming Soon"
      },
      {
        name: "Shortest Path Algorithms",
        description: "Pathfinding and weighted graph comparisons.",
        status: "Pending Verification"
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
