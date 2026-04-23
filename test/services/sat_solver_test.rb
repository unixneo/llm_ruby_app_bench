require "test_helper"

class SatSolverTest < ActiveSupport::TestCase
  test "solves satisfiable fixture and returns valid assignment" do
    fixture = SatFixtures.sat_trivial_sat_2
    solver = SatSolver.new(fixture.fetch(:num_vars), fixture.fetch(:clauses))
    result = solver.solve

    assert_equal true, result.satisfiable
    assert_equal :dpll, result.method
    assert_equal "dpll", result.source
    assert result.assignments.is_a?(Hash)
    assert solver.valid_assignment?(result.assignments, fixture.fetch(:clauses))
  end

  test "solves unsatisfiable fixture" do
    fixture = SatFixtures.sat_trivial_unsat_2
    result = SatSolver.new(fixture.fetch(:num_vars), fixture.fetch(:clauses)).solve

    assert_equal false, result.satisfiable
    assert_nil result.assignments
  end

  test "valid_assignment returns false for unsatisfying assignment" do
    clauses = [[1], [2]]
    solver = SatSolver.new(2, clauses)

    refute solver.valid_assignment?({ 1 => true, 2 => false }, clauses)
  end
end
