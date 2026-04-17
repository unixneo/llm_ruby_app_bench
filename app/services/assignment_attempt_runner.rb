class AssignmentAttemptRunner
  PROMPT_ID = "P0021"
  CHALLENGE_NAME = "Assignment Problem"

  def initialize(candidate_solver_class: AssignmentSolver, reference_solver_class: GemAssignmentSolver)
    @candidate_solver_class = candidate_solver_class
    @reference_solver_class = reference_solver_class
  end

  def run_all
    AssignmentFixtures.seed!

    challenge = Challenge.find_or_create_by!(name: CHALLENGE_NAME) do |record|
      record.description = "Linear sum assignment benchmark with exact Hungarian candidate and OR-Tools reference."
    end

    AssignmentProblem.order(:workers, :name).map do |problem|
      run_single(challenge, problem)
    end
  end

  def run_single(challenge, problem)
    candidate = @candidate_solver_class.new(problem.cost_matrix).solve
    reference = @reference_solver_class.new(problem.cost_matrix).solve
    comparison = AssignmentResultComparison.compare(problem.cost_matrix, candidate, reference)

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
      attempt.difference = comparison.fetch(:cost_difference)
    end
  end

  private

  def problem_metadata(problem, validation_errors)
    {
      workers: problem.workers,
      tasks: problem.tasks,
      cost_matrix: problem.cost_matrix,
      validation_errors: validation_errors
    }
  end
end
