class AssignmentResultComparison
  TOLERANCE = 0.01

  def self.compare(cost_matrix, candidate_result, reference_result)
    new(cost_matrix).compare(candidate_result, reference_result)
  end

  def initialize(cost_matrix)
    @cost_matrix = cost_matrix
  end

  def compare(candidate_result, reference_result)
    candidate_validation = AssignmentSolutionValidator.validate(
      @cost_matrix,
      candidate_result.assignment,
      candidate_result.cost
    )
    reference_validation = AssignmentSolutionValidator.validate(
      @cost_matrix,
      reference_result.assignment,
      reference_result.cost
    )
    cost_difference = candidate_result.cost - reference_result.cost

    {
      status: status(candidate_validation, reference_validation, cost_difference),
      cost_difference: cost_difference,
      cost_ratio: candidate_result.cost.to_f / reference_result.cost,
      is_optimal: cost_difference.abs <= TOLERANCE,
      assignment_matches: candidate_result.assignment == reference_result.assignment,
      candidate_assignment: candidate_result.assignment,
      reference_assignment: reference_result.assignment,
      candidate_cost: candidate_result.cost,
      reference_cost: reference_result.cost,
      candidate_errors: candidate_validation.fetch(:errors),
      reference_errors: reference_validation.fetch(:errors)
    }
  end

  private

  def status(candidate_validation, reference_validation, cost_difference)
    return "infeasible" unless candidate_validation.fetch(:valid)
    return "reference_failed" unless reference_validation.fetch(:valid)

    cost_difference.abs <= TOLERANCE ? "exact_match" : "length_mismatch"
  end
end
