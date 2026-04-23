require "test_helper"

class NQueensSolverTest < ActiveSupport::TestCase
  test "solves n=8 with exact count" do
    result = NQueensSolver.new(8).solve

    assert_equal 8, result.n
    assert_equal 92, result.count
    assert_equal :backtracking, result.method
    assert_equal "backtracking", result.source
    assert_equal 92, result.solutions.length
  end

  test "does not retain large solution arrays for n>10" do
    result = NQueensSolver.new(12).solve

    assert_equal 14200, result.count
    assert_nil result.solutions
  end
end

