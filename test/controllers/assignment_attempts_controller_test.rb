require "test_helper"

class AssignmentAttemptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @challenge = Challenge.create!(name: "Assignment Problem")
    @attempt = Attempt.create!(
      prompt_id: "P0021",
      challenge: @challenge,
      fixture_name: "assignment_tiny_3x3",
      algorithm_version: "hungarian-v1",
      reference_version: GemAssignmentSolver::REFERENCE_VERSION,
      candidate_result: JSON.pretty_generate(assignment_result("hungarian")),
      reference_result: JSON.pretty_generate(assignment_result("or-tools")),
      status: "exact_match",
      difference: 0.0
    )
  end

  test "shows assignment attempts index" do
    get assignment_attempts_url

    assert_response :success
    assert_includes response.body, "Assignment Attempts"
    assert_includes response.body, "assignment_tiny_3x3"
    assert_includes response.body, "Cost Difference"
    assert_includes response.body, "Exact match"
  end

  test "shows assignment attempt mapping" do
    get assignment_attempt_url(@attempt)

    assert_response :success
    assert_includes response.body, "Candidate Assignment"
    assert_includes response.body, "Reference Assignment"
    assert_includes response.body, "Worker 0 -&gt; Task 1"
    assert_includes response.body, "hungarian"
    assert_includes response.body, "or-tools"
  end

  private

  def assignment_result(source)
    {
      assignment: [1, 0, 2],
      cost: 9,
      source: source,
      reference_version: GemAssignmentSolver::REFERENCE_VERSION,
      workers: 3,
      tasks: 3,
      validation_errors: []
    }
  end
end
