class ChallengesController < ApplicationController
  def index
    @tsp_challenge = Challenge.find_by(name: "Traveling Salesman Problem")
    @tsp_stats = {
      fixture_count: TspFixtures.all.count,
      algorithm_count: @tsp_challenge ? Attempt.where(challenge: @tsp_challenge).distinct.count(:algorithm_version) : 0,
      attempt_count: @tsp_challenge ? Attempt.where(challenge: @tsp_challenge).count : 0
    }
    @vrp_challenge = Challenge.find_by(name: "Vehicle Routing Problem")
    @vrp_stats = {
      fixture_count: VrpFixtures.all.count,
      algorithm_count: @vrp_challenge ? Attempt.where(challenge: @vrp_challenge).distinct.count(:algorithm_version) : 0,
      attempt_count: @vrp_challenge ? Attempt.where(challenge: @vrp_challenge).count : 0
    }
    @assignment_challenge = Challenge.find_by(name: "Assignment Problem")
    @assignment_stats = {
      fixture_count: AssignmentFixtures.all.count,
      algorithm_count: @assignment_challenge ? Attempt.where(challenge: @assignment_challenge).distinct.count(:algorithm_version) : 0,
      attempt_count: @assignment_challenge ? Attempt.where(challenge: @assignment_challenge).count : 0
    }
    @max_flow_challenge = Challenge.find_by(name: "Max Flow Problem")
    @max_flow_stats = {
      fixture_count: MaxFlowFixtures.all.count,
      algorithm_count: @max_flow_challenge ? Attempt.where(challenge: @max_flow_challenge).distinct.count(:algorithm_version) : 0,
      attempt_count: @max_flow_challenge ? Attempt.where(challenge: @max_flow_challenge).count : 0
    }
    # Future algorithm families must have verified Ruby reference gems.
    # C005: Algorithm selection requires RubyGems survey (see RUBYGEMS_SURVEY.md).
    # Only add placeholders after gem verification is complete.
    @future_challenges = [
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
    elsif challenge.name == "Vehicle Routing Problem"
      redirect_to vrp_attempts_path
    elsif challenge.name == "Assignment Problem"
      redirect_to assignment_attempts_path
    elsif challenge.name == "Max Flow Problem"
      redirect_to max_flow_attempts_path
    else
      redirect_to challenges_path, alert: "No attempt index is available for this challenge yet."
    end
  end
end
