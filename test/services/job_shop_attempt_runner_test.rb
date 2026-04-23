require "test_helper"

class JobShopAttemptRunnerTest < ActiveSupport::TestCase
  test "creates exact job shop attempts for all fixtures" do
    attempts = JobShopAttemptRunner.new.run_all

    assert_equal JobShopFixtures.all.length, attempts.length
    assert_equal JobShopFixtures.all.length, JobShopProblem.count
    assert_equal JobShopFixtures.all.length, Attempt.joins(:challenge).where(challenges: { name: "Job Shop Scheduling Problem" }).count

    attempts.each do |attempt|
      assert_equal "P0024", attempt.prompt_id
      assert_equal "Job Shop Scheduling Problem", attempt.challenge.name
      assert_equal "branch-and-bound-v1", attempt.algorithm_version
      assert_equal GemJobShopScheduler::REFERENCE_VERSION, attempt.reference_version
      assert_equal "exact_match", attempt.status
      assert_in_delta 0.0, attempt.difference, 0.01
      assert attempt.candidate_result_data.fetch("scheduled_tasks")
      assert attempt.reference_result_data.fetch("scheduled_tasks")
    end
  end
end
