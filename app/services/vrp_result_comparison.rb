class VrpResultComparison
  def initialize(problem)
    @problem = problem
  end

  def compare(candidate, reference)
    candidate_errors = VrpSolutionValidator.new(@problem).errors_for(candidate.routes)
    reference_errors = VrpSolutionValidator.new(@problem).errors_for(reference.routes)

    status = if candidate_errors.any? || reference_errors.any?
      "infeasible"
    else
      "feasible"
    end

    {
      status: status,
      difference: (candidate.total_distance - reference.total_distance).abs,
      candidate_errors: candidate_errors,
      reference_errors: reference_errors
    }
  end
end
