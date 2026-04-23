require "test_helper"

class MoonPhaseAttemptRunnerTest < ActiveSupport::TestCase
  test "creates moon phase attempts for all fixtures" do
    MoonPhaseProblem.delete_all
    Attempt.delete_all
    Challenge.where(name: "Moon Phase Calculations").delete_all

    attempts = MoonPhaseAttemptRunner.new.run_all

    assert_equal MoonPhaseFixtures.all.length, attempts.length
    assert_equal MoonPhaseFixtures.all.length, Attempt.joins(:challenge).where(challenges: { name: "Moon Phase Calculations" }).count
    assert attempts.all? { |attempt| attempt.reference_version == "astronoby-v0.9.0" }
  end
end
