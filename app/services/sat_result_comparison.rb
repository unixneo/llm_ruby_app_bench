class SatResultComparison
  def self.compare(problem, candidate_result, reference_result)
    new(problem).compare(candidate_result, reference_result)
  end

  def initialize(problem)
    @problem = problem
  end

  def compare(candidate_result, reference_result)
    candidate_validation = SatSolutionValidator.validate(@problem, candidate_result)
    reference_validation = SatSolutionValidator.validate(@problem, reference_result)

    exact_match = candidate_result.satisfiable == reference_result.satisfiable &&
      candidate_result.satisfiable == @problem.satisfiable

    {
      status: status(candidate_validation, reference_validation, exact_match),
      satisfiable_difference: candidate_result.satisfiable == reference_result.satisfiable ? 0 : 1,
      candidate_satisfiable: candidate_result.satisfiable,
      reference_satisfiable: reference_result.satisfiable,
      expected_satisfiable: @problem.satisfiable,
      exact_match: exact_match,
      candidate_errors: candidate_validation.fetch(:errors),
      reference_errors: reference_validation.fetch(:errors)
    }
  end

  private

  def status(candidate_validation, reference_validation, exact_match)
    return "infeasible" unless candidate_validation.fetch(:valid)
    return "reference_failed" unless reference_validation.fetch(:valid)

    exact_match ? "exact_match" : "length_mismatch"
  end
end
