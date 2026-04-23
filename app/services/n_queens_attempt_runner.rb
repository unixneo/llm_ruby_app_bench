class NQueensAttemptRunner
  PROMPT_ID = "P0027"
  CHALLENGE_NAME = "N-Queens Problem"

  def initialize(candidate_solver_class: NQueensSolver, reference_solver_class: GemNQueensSolver)
    @candidate_solver_class = candidate_solver_class
    @reference_solver_class = reference_solver_class
  end

  def run_all
    NQueensFixtures.seed!

    challenge = Challenge.find_or_create_by!(name: CHALLENGE_NAME) do |record|
      record.description = "N-Queens benchmark with exact backtracking candidate and n_queens gem reference."
    end

    NQueensProblem.order(:n, :name).map do |problem|
      run_single(challenge, problem)
    end
  end

  def run_single(challenge, problem)
    candidate = @candidate_solver_class.new(problem.n).solve
    reference = @reference_solver_class.new(problem.n).solve
    comparison = NQueensResultComparison.compare(problem, candidate, reference)

    Attempt.find_or_create_by!(
      prompt_id: PROMPT_ID,
      challenge: challenge,
      fixture_name: problem.name,
      algorithm_version: Attempt.algorithm_version_for_source(candidate.source),
      reference_version: reference.reference_version
    ) do |attempt|
      attempt.candidate_result = JSON.pretty_generate(candidate.to_h.merge(problem_metadata(problem, comparison.fetch(:candidate_errors), comparison.fetch(:known_count))))
      attempt.reference_result = JSON.pretty_generate(reference.to_h.merge(problem_metadata(problem, comparison.fetch(:reference_errors), comparison.fetch(:known_count))))
      attempt.status = comparison.fetch(:status)
      attempt.difference = comparison.fetch(:count_difference)
    end
  end

  private

  def problem_metadata(problem, validation_errors, known_count)
    {
      n: problem.n,
      known_count: known_count,
      validation_errors: validation_errors
    }
  end
end

