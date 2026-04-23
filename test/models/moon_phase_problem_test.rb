require "test_helper"

class MoonPhaseProblemTest < ActiveSupport::TestCase
  test "validates daily fixtures" do
    problem = MoonPhaseProblem.new(
      name: "moon_phase_new_moon_2024_01",
      fixture_type: "daily",
      observation_date: Date.new(2024, 1, 11),
      expected_illuminated_fraction: 0.001911,
      expected_phase_fraction: 0.010761,
      expected_phase_name: "new_moon"
    )

    assert problem.valid?
  end

  test "validates event fixtures" do
    problem = MoonPhaseProblem.new(
      name: "moon_phase_events_2024_05",
      fixture_type: "events",
      year: 2024,
      month: 5,
      expected_events: [{ phase: "full_moon", time: "2024-05-23T13:53:12Z" }]
    )

    assert problem.valid?
  end

  test "requires daily fields for daily fixtures" do
    problem = MoonPhaseProblem.new(name: "broken", fixture_type: "daily")

    refute problem.valid?
    assert_includes problem.errors[:observation_date], "must be present for daily fixtures"
  end
end
