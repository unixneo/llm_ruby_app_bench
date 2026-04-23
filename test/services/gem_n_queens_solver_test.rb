require "test_helper"

class GemNQueensSolverTest < ActiveSupport::TestCase
  test "matches known count for n=8" do
    result = GemNQueensSolver.new(8).solve

    assert_equal 92, result.count
    assert_equal 8, result.n
    assert_equal GemNQueensSolver::REFERENCE_VERSION, result.reference_version
    assert_equal "n_queens", result.source
  end

  test "drops large solution array payload for n>10" do
    result = GemNQueensSolver.new(12).solve

    assert_equal 14200, result.count
    assert_nil result.solutions
  end
end

