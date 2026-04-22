require "test_helper"

class GemMinCostFlowSolverTest < ActiveSupport::TestCase
  test "or tools simple min cost flow solves simple fixture" do
    fixture = MinCostFlowFixtures.simple_4
    result = GemMinCostFlowSolver.new(
      fixture.fetch(:nodes),
      fixture.fetch(:edges),
      fixture.fetch(:source),
      fixture.fetch(:sink),
      fixture.fetch(:demand)
    ).solve

    assert_equal "or-tools", result.source
    assert_equal GemMinCostFlowSolver::REFERENCE_VERSION, result.reference_version
    assert_equal 90, result.optimal_cost
    assert_equal fixture.fetch(:demand), result.total_flow
    assert result.demand_satisfied
    assert_equal fixture.fetch(:edges).length, result.flow_edges.length
  end
end
