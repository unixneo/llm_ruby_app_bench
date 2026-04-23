require "test_helper"

class JobShopScheduleValidatorTest < ActiveSupport::TestCase
  test "accepts valid schedule" do
    jobs = [
      [[0, 3], [1, 2]],
      [[1, 2]]
    ]
    scheduled_tasks = [
      {job_id: 0, task_id: 0, machine_id: 0, duration: 3, start_time: 0, end_time: 3},
      {job_id: 1, task_id: 0, machine_id: 1, duration: 2, start_time: 0, end_time: 2},
      {job_id: 0, task_id: 1, machine_id: 1, duration: 2, start_time: 3, end_time: 5}
    ]

    result = JobShopScheduleValidator.validate(jobs, scheduled_tasks, 5)

    assert result.fetch(:valid)
    assert_empty result.fetch(:errors)
    assert_equal 5, result.fetch(:calculated_makespan)
  end

  test "rejects precedence violation" do
    jobs = [[[0, 3], [1, 2]]]
    scheduled_tasks = [
      {job_id: 0, task_id: 0, machine_id: 0, duration: 3, start_time: 2, end_time: 5},
      {job_id: 0, task_id: 1, machine_id: 1, duration: 2, start_time: 0, end_time: 2}
    ]

    result = JobShopScheduleValidator.validate(jobs, scheduled_tasks, 5)

    refute result.fetch(:valid)
    assert_includes result.fetch(:errors), "Precedence violated for job 0 task 1"
  end
end
