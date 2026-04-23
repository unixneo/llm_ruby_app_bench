require "test_helper"

class MoonPhaseSolutionValidatorTest < ActiveSupport::TestCase
  test "validates daily result structure" do
    problem = MoonPhaseFixtures.seed!
    fixture = MoonPhaseProblem.find_by!(name: "moon_phase_first_quarter_2024_05")
    result = MoonPhaseCalculator.new(fixture.observation_date).solve

    validation = MoonPhaseSolutionValidator.validate(fixture, result)

    assert validation.fetch(:valid)
  end

  test "rejects non chronological events" do
    fixture = MoonPhaseProblem.new(
      name: "moon_phase_events_2024_05",
      fixture_type: "events",
      year: 2024,
      month: 5,
      expected_events: MoonPhaseFixtures.events_2024_05.fetch(:expected_events)
    )
    result = MoonPhaseResult.new(
      fixture_type: "events",
      illuminated_fraction: nil,
      phase_fraction: nil,
      phase_name: nil,
      major_events: [
        { phase: :full_moon, time: Time.utc(2024, 5, 23, 13, 53, 12) },
        { phase: :new_moon, time: Time.utc(2024, 5, 8, 3, 21, 56) }
      ],
      source: "meeus",
      reference_version: nil,
      ephemeris_required: false
    )

    validation = MoonPhaseSolutionValidator.validate(fixture, result)

    refute validation.fetch(:valid)
    assert_includes validation.fetch(:errors), "Event count mismatch"
  end
end
