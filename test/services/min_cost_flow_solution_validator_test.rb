require "test_helper"

class MinCostFlowSolutionValidatorTest < ActiveSupport::TestCase
  test "accepts valid flow" do
    edges = [[0, 1, 10, 2], [1, 2, 10, 3]]
    flow_edges = [[0, 1, 5], [1, 2, 5]]

    result = MinCostFlowSolutionValidator.validate(3, edges, 0, 2, 5, flow_edges, 25)

    assert result.fetch(:valid)
    assert_empty result.fetch(:errors)
    assert_equal 5, result.fetch(:source_outflow)
    assert_equal 5, result.fetch(:sink_inflow)
    assert_equal 25, result.fetch(:calculated_cost)
  end

  test "rejects demand mismatch" do
    edges = [[0, 1, 10, 2], [1, 2, 10, 3]]
    flow_edges = [[0, 1, 4], [1, 2, 4]]

    result = MinCostFlowSolutionValidator.validate(3, edges, 0, 2, 5, flow_edges, 20)

    refute result.fetch(:valid)
    assert_includes result.fetch(:errors), "Demand mismatch at source: expected=5, actual=4.0"
  end

  test "rejects reported cost mismatch" do
    edges = [[0, 1, 10, 2], [1, 2, 10, 3]]
    flow_edges = [[0, 1, 5], [1, 2, 5]]

    result = MinCostFlowSolutionValidator.validate(3, edges, 0, 2, 5, flow_edges, 26)

    refute result.fetch(:valid)
    assert_includes result.fetch(:errors), "Reported cost mismatch: reported=26, calculated=25.0"
  end
end
