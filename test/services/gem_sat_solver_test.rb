require "test_helper"

class GemSatSolverTest < ActiveSupport::TestCase
  test "matches satisfiable fixture and exposes reference version" do
    fixture = SatFixtures.sat_trivial_sat_2
    result = GemSatSolver.new(fixture.fetch(:num_vars), fixture.fetch(:clauses)).solve

    assert_equal true, result.satisfiable
    assert_equal "ravensat", result.source
    assert_equal GemSatSolver::REFERENCE_VERSION, result.reference_version
    assert result.assignments.is_a?(Hash)
  end

  test "returns unsat for contradictory unit clauses" do
    fixture = SatFixtures.sat_trivial_unsat_2
    result = GemSatSolver.new(fixture.fetch(:num_vars), fixture.fetch(:clauses)).solve

    assert_equal false, result.satisfiable
    assert_nil result.assignments
  end
end
