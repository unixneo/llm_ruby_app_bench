require "test_helper"

class JobShopAttemptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @challenge = Challenge.create!(name: "Job Shop Scheduling Problem")
    @attempt = Attempt.create!(
      prompt_id: "P0024",
      challenge: @challenge,
      fixture_name: "jobshop_tiny_3x3",
      algorithm_version: "branch-and-bound-v1",
      reference_version: GemJobShopScheduler::REFERENCE_VERSION,
      candidate_result: JSON.pretty_generate(job_shop_result("branch-and-bound")),
      reference_result: JSON.pretty_generate(job_shop_result("or-tools")),
      status: "exact_match",
      difference: 0.0
    )
  end

  test "shows job shop attempts index" do
    get job_shop_attempts_url

    assert_response :success
    assert_includes response.body, "Job Shop Attempts"
    assert_includes response.body, "Problem Profile"
    assert_includes response.body, "NP-hard scheduling problem"
    assert_includes response.body, "production planning, manufacturing sequencing"
    assert_includes response.body, "jobshop_tiny_3x3"
    assert_includes response.body, "Makespan Difference"
    assert_includes response.body, "Exact match"
  end

  test "shows job shop attempt mapping" do
    get job_shop_attempt_url(@attempt)

    assert_response :success
    assert_includes response.body, "Candidate Schedule"
    assert_includes response.body, "Reference Schedule"
    assert_includes response.body, "J0T0 M0 @ 0-3"
    assert_includes response.body, "branch-and-bound"
    assert_includes response.body, "or-tools"
    assert_includes response.body, "/job_shop/attempts/#{@attempt.id}/interpretations"
  end

  private

  def job_shop_result(source)
    {
      optimal_makespan: 11,
      scheduled_tasks: [
        {job_id: 0, task_id: 0, machine_id: 0, duration: 3, start_time: 0, end_time: 3},
        {job_id: 1, task_id: 0, machine_id: 0, duration: 2, start_time: 3, end_time: 5},
        {job_id: 2, task_id: 0, machine_id: 1, duration: 4, start_time: 0, end_time: 4}
      ],
      source: source,
      reference_version: GemJobShopScheduler::REFERENCE_VERSION,
      validation_errors: []
    }
  end
end
