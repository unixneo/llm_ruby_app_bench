require "test_helper"

class NQueensAttemptRunnerTest < ActiveSupport::TestCase
  test "creates n-queens attempts for all fixtures" do
    NQueensProblem.delete_all
    Attempt.delete_all
    Challenge.where(name: "N-Queens Problem").delete_all

    attempts = NQueensAttemptRunner.new.run_all

    assert_equal NQueensFixtures.all.length, attempts.length
    assert_equal NQueensFixtures.all.length, NQueensProblem.count
    assert_equal NQueensFixtures.all.length, Attempt.joins(:challenge).where(challenges: { name: "N-Queens Problem" }).count
    assert attempts.all? { |attempt| attempt.status == "exact_match" }
    assert attempts.all? { |attempt| attempt.reference_version == GemNQueensSolver::REFERENCE_VERSION }
  end
end

