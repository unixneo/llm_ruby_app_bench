require "test_helper"

class MoonPhaseFullAttemptRunnerTest < ActiveSupport::TestCase
  test "creates moon phase full-correction attempts for all fixtures" do
    MoonPhaseProblem.delete_all
    Attempt.delete_all
    Challenge.where(name: "Moon Phase Calculations").delete_all

    attempts = MoonPhaseFullAttemptRunner.new.run_all

    assert_equal MoonPhaseFixtures.all.length, attempts.length
    assert_equal MoonPhaseFixtures.all.length, Attempt.joins(:challenge).where(
      challenges: { name: "Moon Phase Calculations" },
      algorithm_version: "meeus-full-corrections-v1"
    ).count
    assert attempts.all? { |attempt| attempt.reference_version == "astronoby-v0.9.0" }
  end
end
