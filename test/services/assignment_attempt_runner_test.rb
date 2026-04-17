require "test_helper"

class AssignmentAttemptRunnerTest < ActiveSupport::TestCase
  test "creates exact assignment attempts for all fixtures" do
    AssignmentFixtures.seed!
    attempts = AssignmentAttemptRunner.new.run_all

    assert_equal AssignmentFixtures.all.length, attempts.length
    assert_equal AssignmentFixtures.all.length, AssignmentProblem.count
    assert_equal AssignmentFixtures.all.length, Attempt.joins(:challenge).where(challenges: { name: "Assignment Problem" }).count

    attempts.each do |attempt|
      assert_equal "P0021", attempt.prompt_id
      assert_equal "Assignment Problem", attempt.challenge.name
      assert_equal "hungarian-v1", attempt.algorithm_version
      assert_equal GemAssignmentSolver::REFERENCE_VERSION, attempt.reference_version
      assert_equal "exact_match", attempt.status
      assert_in_delta 0.0, attempt.difference, 0.01
      assert attempt.candidate_result_data.fetch("assignment")
      assert attempt.reference_result_data.fetch("assignment")
    end
  end

  test "rerunning preserves existing assignment attempts" do
    AssignmentFixtures.seed!
    first_run = AssignmentAttemptRunner.new.run_all
    ids = first_run.map(&:id).sort

    second_run = AssignmentAttemptRunner.new.run_all

    assert_equal ids, second_run.map(&:id).sort
  end
end
