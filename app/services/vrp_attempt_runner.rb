class VrpAttemptRunner
  PROMPT_ID = "P0020"
  CHALLENGE_NAME = "Vehicle Routing Problem"

  def initialize(candidate_solver: VrpSolver.new, reference_solver: GemVrpSolver.new)
    @candidate_solver = candidate_solver
    @reference_solver = reference_solver
  end

  def run_all
    challenge = Challenge.find_or_create_by!(name: CHALLENGE_NAME) do |record|
      record.description = "Multi-vehicle capacity-constrained routing benchmark."
    end

    VrpFixtures.all.map do |fixture|
      problem = VrpFixtures.problem_for(fixture)
      candidate = @candidate_solver.solve(problem)
      reference = @reference_solver.solve(problem, fixture)
      comparison = VrpResultComparison.new(problem).compare(candidate, reference)

      Attempt.find_or_create_by!(
        prompt_id: PROMPT_ID,
        challenge: challenge,
        fixture_name: fixture.fetch(:name),
        algorithm_version: Attempt.algorithm_version_for_source(candidate.source),
        reference_version: reference.reference_version
      ) do |attempt|
        attempt.candidate_result = JSON.pretty_generate(candidate.to_h.merge(problem_metadata(fixture, comparison.fetch(:candidate_errors))))
        attempt.reference_result = JSON.pretty_generate(reference.to_h.merge(problem_metadata(fixture, comparison.fetch(:reference_errors))))
        attempt.status = comparison.fetch(:status)
        attempt.difference = comparison.fetch(:difference)
      end
    end
  end

  private

  def problem_metadata(fixture, validation_errors)
    {
      num_vehicles: fixture.fetch(:num_vehicles),
      vehicle_capacity: fixture.fetch(:vehicle_capacity),
      demands: fixture.fetch(:demands),
      validation_errors: validation_errors
    }
  end
end
