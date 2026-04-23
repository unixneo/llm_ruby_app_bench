class JobShopResultComparison
  TOLERANCE = 0.01

  def self.compare(jobs, candidate_result, reference_result)
    new(jobs).compare(candidate_result, reference_result)
  end

  def initialize(jobs)
    @jobs = jobs
  end

  def compare(candidate_result, reference_result)
    candidate_validation = JobShopScheduleValidator.validate(@jobs, candidate_result.scheduled_tasks, candidate_result.optimal_makespan)
    reference_validation = JobShopScheduleValidator.validate(@jobs, reference_result.scheduled_tasks, reference_result.optimal_makespan)
    makespan_difference = candidate_result.optimal_makespan - reference_result.optimal_makespan

    {
      status: status(candidate_validation, reference_validation, makespan_difference),
      makespan_difference: makespan_difference,
      is_optimal: makespan_difference.abs <= TOLERANCE,
      candidate_makespan: candidate_result.optimal_makespan,
      reference_makespan: reference_result.optimal_makespan,
      candidate_errors: candidate_validation.fetch(:errors),
      reference_errors: reference_validation.fetch(:errors)
    }
  end

  private

  def status(candidate_validation, reference_validation, makespan_difference)
    return "infeasible" unless candidate_validation.fetch(:valid)
    return "reference_failed" unless reference_validation.fetch(:valid)

    makespan_difference.abs <= TOLERANCE ? "exact_match" : "length_mismatch"
  end
end
