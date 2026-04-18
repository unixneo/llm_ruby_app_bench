require "test_helper"

class GemMaxFlowSolverTest < ActiveSupport::TestCase
  test "or tools simple max flow solves simple fixture" do
    fixture = MaxFlowFixtures.simple_4
    result = GemMaxFlowSolver.new(
      fixture.fetch(:nodes),
      fixture.fetch(:edges),
      fixture.fetch(:source),
      fixture.fetch(:sink)
    ).solve

    assert_equal "or-tools", result.source
    assert_equal GemMaxFlowSolver::REFERENCE_VERSION, result.reference_version
    assert_equal 15, result.max_flow
    assert_equal fixture.fetch(:edges).length, result.flow_edges.length
  end
end
