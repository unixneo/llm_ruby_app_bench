require "test_helper"

class MaxFlowSolutionValidatorTest < ActiveSupport::TestCase
  test "accepts valid flow" do
    edges = [[0, 1, 10], [0, 2, 5], [1, 3, 15], [2, 3, 10]]
    flow_edges = [[0, 1, 10], [0, 2, 5], [1, 3, 10], [2, 3, 5]]

    result = MaxFlowSolutionValidator.validate(4, edges, 0, 3, flow_edges, 15)

    assert result.fetch(:valid)
    assert_empty result.fetch(:errors)
    assert_equal 15, result.fetch(:source_outflow)
    assert_equal 15, result.fetch(:sink_inflow)
  end

  test "rejects capacity violation" do
    edges = [[0, 1, 10], [1, 2, 5]]
    flow_edges = [[0, 1, 11], [1, 2, 11]]

    result = MaxFlowSolutionValidator.validate(3, edges, 0, 2, flow_edges, 11)

    refute result.fetch(:valid)
    assert_includes result.fetch(:errors), "Flow exceeds capacity on edge 0 (0, 1): 11 > 10"
  end

  test "rejects flow conservation violation" do
    edges = [[0, 1, 10], [1, 2, 10]]
    flow_edges = [[0, 1, 10], [1, 2, 5]]

    result = MaxFlowSolutionValidator.validate(3, edges, 0, 2, flow_edges, 10)

    refute result.fetch(:valid)
    assert_includes result.fetch(:errors), "Flow conservation violated at node 1: net=5.0"
  end
end
