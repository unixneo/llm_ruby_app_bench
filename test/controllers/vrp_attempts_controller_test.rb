require "test_helper"

class VrpAttemptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @challenge = Challenge.create!(name: "Vehicle Routing Problem")
    @attempt = Attempt.create!(
      prompt_id: "P0020",
      challenge: @challenge,
      fixture_name: "vrp_small_5",
      algorithm_version: "clarke-wright-savings-v1",
      reference_version: GemVrpSolver::REFERENCE_VERSION,
      candidate_result: JSON.pretty_generate(vrp_result("clarke-wright-savings")),
      reference_result: JSON.pretty_generate(vrp_result("or-tools")),
      status: "feasible",
      difference: 4.0
    )
  end

  test "shows vrp attempts index" do
    get vrp_attempts_url

    assert_response :success
    assert_includes response.body, "VRP Attempts"
    assert_includes response.body, "vrp_small_5"
    assert_includes response.body, "Distance Difference"
    assert_includes response.body, "Feasible"
  end

  test "shows vrp attempt routes" do
    get vrp_attempt_url(@attempt)

    assert_response :success
    assert_includes response.body, "Candidate Routes"
    assert_includes response.body, "Reference Routes"
    assert_includes response.body, "Vehicle 1:"
    assert_includes response.body, "clarke-wright-savings"
    assert_includes response.body, "or-tools"
  end

  private

  def vrp_result(source)
    {
      routes: [[0, 1, 2, 0], [0, 3, 0]],
      total_distance: 42.0,
      vehicle_loads: [12, 8],
      source: source,
      reference_version: GemVrpSolver::REFERENCE_VERSION
    }
  end
end
