require "test_helper"

class VrpAttemptRunnerTest < ActiveSupport::TestCase
  test "creates feasible vrp attempts for all fixtures" do
    attempts = VrpAttemptRunner.new.run_all

    assert_equal VrpFixtures.all.length, attempts.length
    assert_equal VrpFixtures.all.length, Attempt.joins(:challenge).where(challenges: { name: "Vehicle Routing Problem" }).count

    attempts.each do |attempt|
      assert_equal "P0020", attempt.prompt_id
      assert_equal "Vehicle Routing Problem", attempt.challenge.name
      assert_equal "clarke-wright-savings-v1", attempt.algorithm_version
      assert_equal GemVrpSolver::REFERENCE_VERSION, attempt.reference_version
      assert_equal "feasible", attempt.status
      assert attempt.candidate_result_data.fetch("routes")
      assert attempt.reference_result_data.fetch("routes")
      assert attempt.difference >= 0
    end
  end

  test "rerunning preserves existing vrp attempts" do
    first_run = VrpAttemptRunner.new.run_all
    ids = first_run.map(&:id).sort

    second_run = VrpAttemptRunner.new.run_all

    assert_equal ids, second_run.map(&:id).sort
  end
end
