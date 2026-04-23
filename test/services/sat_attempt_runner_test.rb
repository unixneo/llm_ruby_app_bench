require "test_helper"

class SatAttemptRunnerTest < ActiveSupport::TestCase
  test "creates SAT attempts for all fixtures" do
    SatProblem.delete_all
    Attempt.delete_all
    Challenge.where(name: "SAT Solver (Boolean Satisfiability)").delete_all

    attempts = SatAttemptRunner.new.run_all

    assert_equal SatFixtures.all.length, attempts.length
    assert_equal SatFixtures.all.length, SatProblem.count
    assert_equal SatFixtures.all.length, Attempt.joins(:challenge).where(challenges: { name: "SAT Solver (Boolean Satisfiability)" }).count
    assert attempts.all? { |attempt| attempt.reference_version == GemSatSolver::REFERENCE_VERSION }
  end
end
