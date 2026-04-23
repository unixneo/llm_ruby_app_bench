require "test_helper"

class SatAttemptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @challenge = Challenge.create!(name: "SAT Solver (Boolean Satisfiability)")
    @attempt = Attempt.create!(
      prompt_id: "P0028",
      challenge: @challenge,
      fixture_name: "sat_trivial_sat_2",
      algorithm_version: "dpll-v1",
      reference_version: GemSatSolver::REFERENCE_VERSION,
      candidate_result: JSON.pretty_generate(sat_result("dpll")),
      reference_result: JSON.pretty_generate(sat_result("ravensat")),
      status: "exact_match",
      difference: 0.0
    )
  end

  test "shows sat attempts index under scoped path" do
    get sat_attempts_url

    assert_response :success
    assert_includes response.body, "SAT Attempts"
    assert_includes response.body, "sat_trivial_sat_2"
    assert_includes response.body, "Satisfiable Difference"
    assert_includes response.body, "Boolean Logic"
    assert_includes response.body, "NP-complete decision problem"
  end

  test "shows sat attempt details under scoped path" do
    get sat_attempt_url(@attempt)

    assert_response :success
    assert_includes response.body, "Candidate Result"
    assert_includes response.body, "Reference Result"
    assert_includes response.body, "ravensat"
    assert_includes response.body, "/sat/attempts/#{@attempt.id}/interpretations"
  end

  private

  def sat_result(source)
    {
      num_vars: 2,
      clauses: [[1, 2], [-1, 2], [1, -2]],
      satisfiable: true,
      assignments: { 1 => true, 2 => true },
      decisions: 1,
      method: "dpll",
      source: source,
      expected_satisfiable: true,
      validation_errors: [],
      reference_version: GemSatSolver::REFERENCE_VERSION
    }
  end
end
