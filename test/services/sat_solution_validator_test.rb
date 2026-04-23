require "test_helper"

class SatSolutionValidatorTest < ActiveSupport::TestCase
  test "accepts valid SAT result" do
    fixture = SatFixtures.sat_trivial_sat_2
    problem = SatProblem.new(
      name: fixture.fetch(:name),
      num_vars: fixture.fetch(:num_vars),
      clauses: fixture.fetch(:clauses),
      satisfiable: fixture.fetch(:satisfiable),
      description: fixture.fetch(:description)
    )
    result = SatSolver.new(problem.num_vars, problem.clauses).solve

    validation = SatSolutionValidator.validate(problem, result)

    assert validation.fetch(:valid)
    assert_empty validation.fetch(:errors)
  end

  test "rejects SAT result with invalid assignment" do
    fixture = SatFixtures.sat_trivial_sat_2
    problem = SatProblem.new(
      name: fixture.fetch(:name),
      num_vars: fixture.fetch(:num_vars),
      clauses: fixture.fetch(:clauses),
      satisfiable: fixture.fetch(:satisfiable),
      description: fixture.fetch(:description)
    )

    bad_result = SatSolver::Result.new(
      num_vars: 2,
      clauses: fixture.fetch(:clauses),
      satisfiable: true,
      assignments: { 1 => false, 2 => false },
      decisions: 0,
      method: :dpll,
      source: "dpll"
    )

    validation = SatSolutionValidator.validate(problem, bad_result)

    refute validation.fetch(:valid)
    assert_includes validation.fetch(:errors).join(" "), "does not satisfy all clauses"
  end
end
