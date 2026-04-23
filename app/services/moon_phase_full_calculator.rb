class MoonPhaseFullCalculator
  SOURCE = "meeus-full-corrections"
  PHASE_FRACTIONS = {
    new_moon: 0.0,
    first_quarter: 0.25,
    full_moon: 0.5,
    last_quarter: 0.75
  }.freeze

  def self.phase_name_for_fraction(fraction)
    wrapped = fraction % 1.0

    if wrap_distance(wrapped, 0.0) <= 0.03
      "new_moon"
    elsif wrapped < 0.22
      "waxing_crescent"
    elsif wrap_distance(wrapped, 0.25) <= 0.03
      "first_quarter"
    elsif wrapped < 0.47
      "waxing_gibbous"
    elsif wrap_distance(wrapped, 0.5) <= 0.03
      "full_moon"
    elsif wrapped < 0.72
      "waning_gibbous"
    elsif wrap_distance(wrapped, 0.75) <= 0.03
      "last_quarter"
    else
      "waning_crescent"
    end
  end

  def self.wrap_distance(a, b)
    difference = (a - b).abs
    [difference, 1.0 - difference].min
  end

  def initialize(date)
    @date = date
    @time = Time.utc(date.year, date.month, date.day, 12, 0, 0)
  end

  def illuminated_fraction
    base_calculator.illuminated_fraction
  end

  def phase_fraction
    base_calculator.phase_fraction
  end

  def phase_name
    self.class.phase_name_for_fraction(phase_fraction)
  end

  def solve
    MoonPhaseResult.new(
      fixture_type: "daily",
      illuminated_fraction: illuminated_fraction.round(6),
      phase_fraction: phase_fraction.round(6),
      phase_name: phase_name,
      major_events: [],
      source: SOURCE,
      reference_version: nil,
      ephemeris_required: false
    )
  end

  private

  def base_calculator
    @base_calculator ||= MoonPhaseCalculator.new(@date)
  end
end
