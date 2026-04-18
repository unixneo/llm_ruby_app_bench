require "test_helper"

class MaxFlowAttemptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @challenge = Challenge.create!(name: "Max Flow Problem")
    @attempt = Attempt.create!(
      prompt_id: "P0022",
      challenge: @challenge,
      fixture_name: "maxflow_simple_4",
      algorithm_version: "edmonds-karp-v1",
      reference_version: GemMaxFlowSolver::REFERENCE_VERSION,
      candidate_result: JSON.pretty_generate(max_flow_result("edmonds-karp")),
      reference_result: JSON.pretty_generate(max_flow_result("or-tools")),
      status: "exact_match",
      difference: 0.0
    )
  end

  test "shows max flow attempts index" do
    get max_flow_attempts_url

    assert_response :success
    assert_includes response.body, "Max Flow Attempts"
    assert_includes response.body, "maxflow_simple_4"
    assert_includes response.body, "Flow Difference"
    assert_includes response.body, "Exact match"
  end

  test "shows max flow attempt mapping" do
    get max_flow_attempt_url(@attempt)

    assert_response :success
    assert_includes response.body, "Candidate Flow"
    assert_includes response.body, "Reference Flow"
    assert_includes response.body, "0 -&gt; 1: 10"
    assert_includes response.body, "edmonds-karp"
    assert_includes response.body, "or-tools"
  end

  private

  def max_flow_result(source)
    {
      max_flow: 15,
      flow_edges: [[0, 1, 10], [0, 2, 5], [1, 3, 10], [2, 3, 5]],
      source: source,
      reference_version: GemMaxFlowSolver::REFERENCE_VERSION,
      nodes: 4,
      validation_errors: []
    }
  end
end
