class MoonPhaseCalculator
  SOURCE = "meeus"
  SYNODIC_MONTH = 29.530588861

  def initialize(date)
    @date = date
    @time = Time.utc(date.year, date.month, date.day, 12, 0, 0)
  end

  def illuminated_fraction
    ((1 + Math.cos(phase_angle_radians)) / 2.0).clamp(0.0, 1.0)
  end

  def phase_fraction
    (mean_elongation_degrees / 360.0) % 1.0
  end

  def phase_name
    fraction = phase_fraction

    if wrap_distance(fraction, 0.0) <= 0.03
      "new_moon"
    elsif fraction < 0.22
      "waxing_crescent"
    elsif wrap_distance(fraction, 0.25) <= 0.03
      "first_quarter"
    elsif fraction < 0.47
      "waxing_gibbous"
    elsif wrap_distance(fraction, 0.5) <= 0.03
      "full_moon"
    elsif fraction < 0.72
      "waning_gibbous"
    elsif wrap_distance(fraction, 0.75) <= 0.03
      "last_quarter"
    else
      "waning_crescent"
    end
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

  def wrap_distance(a, b)
    difference = (a - b).abs
    [difference, 1.0 - difference].min
  end

  def phase_angle_radians
    degrees = 180.0 -
      mean_elongation_degrees -
      6.289 * Math.sin(moon_mean_anomaly_radians) +
      2.1 * Math.sin(sun_mean_anomaly_radians) -
      1.274 * Math.sin((2 * mean_elongation_radians) - moon_mean_anomaly_radians) -
      0.658 * Math.sin(2 * mean_elongation_radians) -
      0.214 * Math.sin(2 * moon_mean_anomaly_radians) -
      0.11 * Math.sin(mean_elongation_radians)

    degrees * Math::PI / 180.0
  end

  def mean_elongation_radians
    mean_elongation_degrees * Math::PI / 180.0
  end

  def mean_elongation_degrees
    @mean_elongation_degrees ||= begin
      (
        297.8501921 +
        445267.1114034 * elapsed_centuries -
        0.0018819 * elapsed_centuries**2 +
        elapsed_centuries**3 / 545868.0 -
        elapsed_centuries**4 / 113065000.0
      ) % 360.0
    end
  end

  def sun_mean_anomaly_radians
    (
      357.5291092 +
      35999.0502909 * elapsed_centuries -
      0.0001536 * elapsed_centuries**2 +
      elapsed_centuries**3 / 24490000.0
    ) % 360.0 * Math::PI / 180.0
  end

  def moon_mean_anomaly_radians
    (
      134.9633964 +
      477198.8675055 * elapsed_centuries +
      0.0087414 * elapsed_centuries**2 +
      elapsed_centuries**3 / 69699.0 -
      elapsed_centuries**4 / 14712000.0
    ) % 360.0 * Math::PI / 180.0
  end

  def elapsed_centuries
    @elapsed_centuries ||= (julian_day - 2451545.0) / 36525.0
  end

  def julian_day
    @julian_day ||= begin
      year = @time.year
      month = @time.month

      if month <= 2
        year -= 1
        month += 12
      end

      a = (year / 100).floor
      b = 2 - a + (a / 4).floor
      day_fraction = (@time.hour + (@time.min / 60.0) + (@time.sec / 3600.0)) / 24.0

      (365.25 * (year + 4716)).floor +
        (30.6001 * (month + 1)).floor +
        @time.day +
        b -
        1524.5 +
        day_fraction
    end
  end
end
