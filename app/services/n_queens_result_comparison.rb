class NQueensResultComparison
  def self.compare(problem, candidate_result, reference_result)
    new(problem).compare(candidate_result, reference_result)
  end

  def initialize(problem)
    @problem = problem
  end

  def compare(candidate_result, reference_result)
    candidate_validation = NQueensSolutionValidator.validate(@problem, candidate_result)
    reference_validation = NQueensSolutionValidator.validate(@problem, reference_result)
    known_count = NQueens::KNOWN_COUNTS.fetch(@problem.n)

    count_difference = candidate_result.count - reference_result.count
    exact = candidate_result.count == reference_result.count && candidate_result.count == known_count

    {
      status: status(candidate_validation, reference_validation, exact),
      count_difference: count_difference,
      candidate_count: candidate_result.count,
      reference_count: reference_result.count,
      known_count: known_count,
      exact_match: exact,
      candidate_errors: candidate_validation.fetch(:errors),
      reference_errors: reference_validation.fetch(:errors)
    }
  end

  private

  def status(candidate_validation, reference_validation, exact)
    return "infeasible" unless candidate_validation.fetch(:valid)
    return "reference_failed" unless reference_validation.fetch(:valid)

    exact ? "exact_match" : "length_mismatch"
  end
end

