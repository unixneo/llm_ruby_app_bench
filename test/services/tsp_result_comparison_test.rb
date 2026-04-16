require "test_helper"

class TspResultComparisonTest < ActiveSupport::TestCase
  Result = Data.define(:tour, :length)

  test "detects exact match when length and tour sequence match" do
    candidate = Result.new(tour: [0, 1, 2, 0], length: 3.0)
    reference = Result.new(tour: [0, 1, 2, 0], length: 3.0)

    comparison = TspResultComparison.compare(candidate, reference)

    assert_equal "exact_match", comparison.status
    assert comparison.same_length
    assert comparison.same_tour
  end

  test "detects different optimal when length matches but tour sequence differs" do
    candidate = Result.new(tour: [0, 1, 2, 0], length: 3.0)
    reference = Result.new(tour: [0, 2, 1, 0], length: 3.0)

    comparison = TspResultComparison.compare(candidate, reference)

    assert_equal "different_optimal", comparison.status
    assert comparison.same_length
    refute comparison.same_tour
  end

  test "detects length mismatch even if tour sequence matches" do
    candidate = Result.new(tour: [0, 1, 2, 0], length: 3.0)
    reference = Result.new(tour: [0, 1, 2, 0], length: 4.0)

    comparison = TspResultComparison.compare(candidate, reference)

    assert_equal "length_mismatch", comparison.status
    refute comparison.same_length
    assert comparison.same_tour
  end
end
