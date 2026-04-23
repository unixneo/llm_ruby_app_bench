class JobShopAttemptRunner
  PROMPT_ID = "P0024"
  CHALLENGE_NAME = "Job Shop Scheduling Problem"

  def initialize(candidate_solver_class: JobShopScheduler, reference_solver_class: GemJobShopScheduler)
    @candidate_solver_class = candidate_solver_class
    @reference_solver_class = reference_solver_class
  end

  def run_all
    JobShopFixtures.seed!

    challenge = Challenge.find_or_create_by!(name: CHALLENGE_NAME) do |record|
      record.description = "Job shop scheduling benchmark with exact Ruby branch-and-bound candidate and OR-Tools CP-SAT reference."
    end

    JobShopProblem.order(:name).map do |problem|
      run_single(challenge, problem)
    end
  end

  def run_single(challenge, problem)
    candidate = @candidate_solver_class.new(problem.jobs).solve
    reference = @reference_solver_class.new(problem.jobs).solve
    comparison = JobShopResultComparison.compare(problem.jobs, candidate, reference)

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
      attempt.difference = comparison.fetch(:makespan_difference)
    end
  end

  private

  def problem_metadata(problem, validation_errors)
    {
      jobs: problem.jobs,
      job_count: problem.job_count,
      machine_count: problem.machine_count,
      task_count: problem.task_count,
      validation_errors: validation_errors
    }
  end
end
