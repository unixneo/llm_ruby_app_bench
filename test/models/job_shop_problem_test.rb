require "test_helper"

class JobShopProblemTest < ActiveSupport::TestCase
  test "validates job structure" do
    problem = JobShopProblem.new(
      name: "bad_jobs",
      jobs: [[[0, 3], [1]], "oops"]
    )

    refute problem.valid?
    assert_includes problem.errors[:jobs], "must be an array of jobs, each containing [machine_id, duration] integer pairs"
  end

  test "reports derived counts" do
    problem = JobShopProblem.new(
      name: "counts",
      jobs: [[[0, 3], [1, 2]], [[1, 4]]]
    )

    assert_equal 2, problem.job_count
    assert_equal 3, problem.task_count
    assert_equal 2, problem.machine_count
  end
end
