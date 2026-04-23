require "test_helper"

class MoonPhaseCalculatorTest < ActiveSupport::TestCase
  test "computes daily moon phase values within prompt tolerances" do
    calculator = MoonPhaseCalculator.new(Date.new(2024, 5, 15))

    assert_in_delta 0.502129, calculator.illuminated_fraction, 0.02
    assert_in_delta 0.24366, calculator.phase_fraction, 0.02
    assert_equal "first_quarter", calculator.phase_name
  end

  test "labels new moon correctly" do
    calculator = MoonPhaseCalculator.new(Date.new(2024, 1, 11))

    assert_equal "new_moon", calculator.phase_name
  end
end
