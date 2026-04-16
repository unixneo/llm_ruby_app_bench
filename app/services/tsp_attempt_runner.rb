class TspAttemptRunner
  PROMPT_ID = "P0001"

  def initialize(candidate_solvers: nil, reference_solver: GemTspSolver.new)
    @candidate_solvers = candidate_solvers
    @reference_solver = reference_solver
  end

  def run_all
    prompt = Prompt.find_or_create_by!(prompt_id: PROMPT_ID) do |record|
      record.description = "TSP brute-force exact solver for n<=8"
    end

    challenge = Challenge.find_or_create_by!(name: "Traveling Salesman Problem") do |record|
      record.description = "Compare Codex-written pure Ruby TSP results with manual fixture references."
    end

    TspFixtures.all.flat_map do |fixture|
      problem = TspFixtures.problem_for(fixture)
      reference = @reference_solver.solve(problem, fixture)
      reference_version = reference.reference_version

      candidate_solvers_for(fixture).map do |candidate_solver|
        candidate = solve_candidate(candidate_solver, problem)
        comparison = compare_results(candidate, reference)
        algorithm_version = Attempt.algorithm_version_for_source(candidate.source)

        existing_attempt = Attempt.find_by(
          prompt_id: prompt.prompt_id,
          fixture_name: fixture.fetch(:name),
          algorithm_version: algorithm_version,
          reference_version: reference_version
        )
        next existing_attempt if existing_attempt

        Attempt.create!(
          prompt_id: prompt.prompt_id,
          challenge: challenge,
          fixture_name: fixture.fetch(:name),
          algorithm_version: algorithm_version,
          reference_version: reference_version,
          candidate_result: JSON.pretty_generate(candidate.to_h),
          reference_result: JSON.pretty_generate(reference.to_h),
          difference: comparison.length_difference,
          status: comparison.status
        )
      end
    end.uniq
  end

  private

  Failure = Data.define(:source, :error_class, :error_message) do
    def to_h
      {
        tour: nil,
        length: nil,
        source: source,
        objective_value: nil,
        scale: 1,
        error: {
          class: error_class,
          message: error_message
        }
      }
    end
  end

  FailureComparison = Data.define(:status, :length_difference)

  def candidate_solvers_for(fixture)
    return @candidate_solvers if @candidate_solvers
    return world_city_solvers if fixture.fetch(:name) == "world_cities_13"

    [TspSolver.new, TspSolver.new(algorithm: :held_karp)]
  end

  def world_city_solvers
    [
      TspSolver.new(algorithm: :brute_force),
      TspSolver.new(algorithm: :nearest_neighbor),
      TspSolver.new(algorithm: :held_karp)
    ]
  end

  def solve_candidate(candidate_solver, problem)
    candidate_solver.solve(problem)
  rescue ArgumentError => error
    Failure.new(
      source: "brute-force",
      error_class: error.class.name,
      error_message: error.message
    )
  end

  def compare_results(candidate, reference)
    return FailureComparison.new(status: "candidate_failed", length_difference: 0.0) if candidate.is_a?(Failure)

    TspResultComparison.compare(candidate, reference)
  end
end
