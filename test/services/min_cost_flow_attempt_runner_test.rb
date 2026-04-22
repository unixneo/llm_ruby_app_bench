require "test_helper"

class MinCostFlowAttemptRunnerTest < ActiveSupport::TestCase
  test "creates exact min cost flow attempts for all fixtures" do
    attempts = MinCostFlowAttemptRunner.new.run_all

    assert_equal MinCostFlowFixtures.all.length, attempts.length
    assert_equal MinCostFlowFixtures.all.length, MinCostFlowProblem.count
    assert_equal MinCostFlowFixtures.all.length, Attempt.joins(:challenge).where(challenges: { name: "Minimum Cost Flow Problem" }).count

    attempts.each do |attempt|
      assert_equal "P0023", attempt.prompt_id
      assert_equal "Minimum Cost Flow Problem", attempt.challenge.name
      assert_equal "successive-shortest-path-v1", attempt.algorithm_version
      assert_equal GemMinCostFlowSolver::REFERENCE_VERSION, attempt.reference_version
      assert_equal "exact_match", attempt.status
      assert_in_delta 0.0, attempt.difference, 0.01
      assert attempt.candidate_result_data.fetch("flow_edges")
      assert attempt.reference_result_data.fetch("flow_edges")
      assert attempt.candidate_result_data.fetch("demand")
    end
  end

  test "rerunning preserves existing min cost flow attempts" do
    first_run = MinCostFlowAttemptRunner.new.run_all
    ids = first_run.map(&:id).sort

    second_run = MinCostFlowAttemptRunner.new.run_all

    assert_equal ids, second_run.map(&:id).sort
  end
end
