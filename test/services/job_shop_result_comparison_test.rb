require "test_helper"

class JobShopResultComparisonTest < ActiveSupport::TestCase
  test "marks optimal valid candidate as exact match" do
    jobs = [[[0, 3], [1, 2]]]
    scheduled_tasks = [
      {job_id: 0, task_id: 0, machine_id: 0, duration: 3, start_time: 0, end_time: 3},
      {job_id: 0, task_id: 1, machine_id: 1, duration: 2, start_time: 3, end_time: 5}
    ]
    candidate = JobShopScheduler::Result.new(optimal_makespan: 5, scheduled_tasks: scheduled_tasks, source: "branch-and-bound", iterations: 1)
    reference = GemJobShopScheduler::Result.new(
      optimal_makespan: 5,
      scheduled_tasks: scheduled_tasks,
      source: "or-tools",
      reference_version: GemJobShopScheduler::REFERENCE_VERSION
    )

    comparison = JobShopResultComparison.compare(jobs, candidate, reference)

    assert_equal "exact_match", comparison.fetch(:status)
    assert comparison.fetch(:is_optimal)
    assert_equal 0, comparison.fetch(:makespan_difference)
  end
end
