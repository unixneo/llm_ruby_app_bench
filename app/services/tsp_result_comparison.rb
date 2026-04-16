class TspResultComparison
  LENGTH_TOLERANCE = 1e-9

  Result = Data.define(:status, :length_difference, :same_length, :same_tour)

  def self.compare(candidate_result, reference_result)
    new(candidate_result, reference_result).compare
  end

  def initialize(candidate_result, reference_result)
    @candidate_result = candidate_result
    @reference_result = reference_result
  end

  def compare
    length_difference = (@candidate_result.length - @reference_result.length).abs
    same_length = length_difference <= LENGTH_TOLERANCE
    same_tour = @candidate_result.tour == @reference_result.tour

    Result.new(
      status: status_for(same_length, same_tour),
      length_difference: length_difference,
      same_length: same_length,
      same_tour: same_tour
    )
  end

  private

  def status_for(same_length, same_tour)
    return "length_mismatch" unless same_length
    return "exact_match" if same_tour

    "different_optimal"
  end
end
