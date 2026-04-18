require "test_helper"

class MaxFlowAttemptRunnerTest < ActiveSupport::TestCase
  test "creates exact max flow attempts for all fixtures" do
    attempts = MaxFlowAttemptRunner.new.run_all

    assert_equal MaxFlowFixtures.all.length, attempts.length
    assert_equal MaxFlowFixtures.all.length, MaxFlowProblem.count
    assert_equal MaxFlowFixtures.all.length, Attempt.joins(:challenge).where(challenges: { name: "Max Flow Problem" }).count

    attempts.each do |attempt|
      assert_equal "P0022", attempt.prompt_id
      assert_equal "Max Flow Problem", attempt.challenge.name
      assert_equal "edmonds-karp-v1", attempt.algorithm_version
      assert_equal GemMaxFlowSolver::REFERENCE_VERSION, attempt.reference_version
      assert_equal "exact_match", attempt.status
      assert_in_delta 0.0, attempt.difference, 0.01
      assert attempt.candidate_result_data.fetch("flow_edges")
      assert attempt.reference_result_data.fetch("flow_edges")
    end
  end

  test "rerunning preserves existing max flow attempts" do
    first_run = MaxFlowAttemptRunner.new.run_all
    ids = first_run.map(&:id).sort

    second_run = MaxFlowAttemptRunner.new.run_all

    assert_equal ids, second_run.map(&:id).sort
  end
end
