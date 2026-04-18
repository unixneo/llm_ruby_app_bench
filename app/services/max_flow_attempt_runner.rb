class MaxFlowAttemptRunner
  PROMPT_ID = "P0022"
  CHALLENGE_NAME = "Max Flow Problem"

  def initialize(candidate_solver_class: MaxFlowSolver, reference_solver_class: GemMaxFlowSolver)
    @candidate_solver_class = candidate_solver_class
    @reference_solver_class = reference_solver_class
  end

  def run_all
    MaxFlowFixtures.seed!

    challenge = Challenge.find_or_create_by!(name: CHALLENGE_NAME) do |record|
      record.description = "Maximum source-to-sink network flow benchmark with Edmonds-Karp candidate and OR-Tools reference."
    end

    MaxFlowProblem.order(:nodes, :name).map do |problem|
      run_single(challenge, problem)
    end
  end

  def run_single(challenge, problem)
    candidate = @candidate_solver_class.new(problem.nodes, problem.edges, problem.source, problem.sink).solve
    reference = @reference_solver_class.new(problem.nodes, problem.edges, problem.source, problem.sink).solve
    comparison = MaxFlowResultComparison.compare(problem.nodes, problem.edges, problem.source, problem.sink, candidate, reference)

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
      attempt.difference = comparison.fetch(:flow_difference)
    end
  end

  private

  def problem_metadata(problem, validation_errors)
    {
      nodes: problem.nodes,
      edges: problem.edges,
      source_node: problem.source,
      sink_node: problem.sink,
      validation_errors: validation_errors
    }
  end
end
