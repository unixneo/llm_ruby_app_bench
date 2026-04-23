require "test_helper"

class SatResultComparisonTest < ActiveSupport::TestCase
  test "returns exact_match when candidate and reference agree with fixture satisfiability" do
    fixture = SatFixtures.sat_3sat_small_sat
    problem = SatProblem.new(
      name: fixture.fetch(:name),
      num_vars: fixture.fetch(:num_vars),
      clauses: fixture.fetch(:clauses),
      satisfiable: fixture.fetch(:satisfiable),
      description: fixture.fetch(:description)
    )
    candidate = SatSolver.new(problem.num_vars, problem.clauses).solve
    reference = GemSatSolver.new(problem.num_vars, problem.clauses).solve

    comparison = SatResultComparison.compare(problem, candidate, reference)

    assert_equal "exact_match", comparison.fetch(:status)
    assert_equal 0, comparison.fetch(:satisfiable_difference)
  end

  test "returns length_mismatch when satisfiable flags differ" do
    fixture = SatFixtures.sat_trivial_sat_2
    problem = SatProblem.new(
      name: fixture.fetch(:name),
      num_vars: fixture.fetch(:num_vars),
      clauses: fixture.fetch(:clauses),
      satisfiable: fixture.fetch(:satisfiable),
      description: fixture.fetch(:description)
    )
    candidate = SatSolver::Result.new(
      num_vars: 2,
      clauses: fixture.fetch(:clauses),
      satisfiable: false,
      assignments: nil,
      decisions: 1,
      method: :dpll,
      source: "dpll"
    )
    reference = GemSatSolver.new(problem.num_vars, problem.clauses).solve

    comparison = SatResultComparison.compare(problem, candidate, reference)

    assert_equal "length_mismatch", comparison.fetch(:status)
    assert_equal 1, comparison.fetch(:satisfiable_difference)
  end
end
