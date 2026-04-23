require "test_helper"

class MoonPhaseFullCalculatorTest < ActiveSupport::TestCase
  test "computes daily moon phase values within tighter prompt tolerances" do
    fixture = MoonPhaseFixtures.first_quarter_2024_05
    calculator = MoonPhaseFullCalculator.new(fixture.fetch(:observation_date))

    assert_in_delta fixture.fetch(:expected_illuminated_fraction), calculator.illuminated_fraction, 0.005
    assert_in_delta fixture.fetch(:expected_phase_fraction), calculator.phase_fraction, 0.005
    assert_equal "first_quarter", calculator.phase_name
  end

  test "labels full moon correctly" do
    calculator = MoonPhaseFullCalculator.new(Date.new(2024, 1, 25))

    assert_equal "full_moon", calculator.phase_name
  end
end
