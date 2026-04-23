class SatAttemptRunner
  PROMPT_ID = "P0028"
  CHALLENGE_NAME = "SAT Solver (Boolean Satisfiability)"

  def initialize(candidate_solver_class: SatSolver, reference_solver_class: GemSatSolver)
    @candidate_solver_class = candidate_solver_class
    @reference_solver_class = reference_solver_class
  end

  def run_all
    SatFixtures.seed!

    challenge = Challenge.find_or_create_by!(name: CHALLENGE_NAME) do |record|
      record.description = "Native DPLL SAT candidate compared with ravensat gem reference."
    end

    SatProblem.order(:num_vars, :name).map do |problem|
      run_single(challenge, problem)
    end
  end

  def run_single(challenge, problem)
    candidate = @candidate_solver_class.new(problem.num_vars, problem.clauses).solve
    reference = @reference_solver_class.new(problem.num_vars, problem.clauses).solve
    comparison = SatResultComparison.compare(problem, candidate, reference)

    Attempt.find_or_create_by!(
      prompt_id: PROMPT_ID,
      challenge: challenge,
      fixture_name: problem.name,
      algorithm_version: Attempt.algorithm_version_for_source(candidate.source),
      reference_version: reference.reference_version
    ) do |attempt|
      attempt.candidate_result = JSON.pretty_generate(candidate.to_h.merge(problem_metadata(problem, comparison.fetch(:candidate_errors))))
      attempt.reference_result = JSON.pretty_generate(reference.to_h.merge(problem_metadata(problem, comparison.fetch(:reference_errors))))
      attempt.status = comparison.fetch(:status)
      attempt.difference = comparison.fetch(:satisfiable_difference)
    end
  end

  private

  def problem_metadata(problem, validation_errors)
    {
      expected_satisfiable: problem.satisfiable,
      validation_errors: validation_errors
    }
  end
end
