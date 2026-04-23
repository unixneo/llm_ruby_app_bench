class MoonPhaseEventFinder
  PHASE_INCREMENTS = {
    new_moon: 0.0,
    first_quarter: 0.25,
    full_moon: 0.5,
    last_quarter: 0.75
  }.freeze

  def initialize(year, month)
    @year = year
    @month = month
  end

  def major_events
    [
      build_event(:first_quarter, -0.75),
      build_event(:full_moon, -0.5),
      build_event(:last_quarter, -0.25),
      build_event(:new_moon, 0.0),
      build_event(:first_quarter, 0.25),
      build_event(:full_moon, 0.5),
      build_event(:last_quarter, 0.75),
      build_event(:new_moon, 1.0),
      build_event(:first_quarter, 1.25)
    ].select { |event| event.fetch(:time).month == @month }
  end

  private

  def build_event(phase, phase_increment)
    {
      phase: phase,
      time: julian_day_to_time(
        julian_ephemeris_day(phase_increment) +
          periodic_terms(phase, phase_increment) +
          additional_corrections(phase_increment)
      )
    }
  end

  def periodic_terms(phase, phase_increment)
    values = orbital_values(phase_increment)
    ecc = values.fetch(:eccentricity_correction)
    mma = values.fetch(:moon_mean_anomaly_radians)
    sma = values.fetch(:sun_mean_anomaly_radians)
    maol = values.fetch(:moon_argument_of_latitude_radians)
    lotan = values.fetch(:longitude_of_the_ascending_node_radians)

    case phase
    when :new_moon
      [
        [-0.40720, mma],
        [0.17241 * ecc, sma],
        [0.01608, 2 * mma],
        [0.01039, 2 * maol],
        [0.00739 * ecc, mma - sma],
        [-0.00514 * ecc, mma + sma],
        [0.00208 * ecc * ecc, 2 * sma],
        [-0.00111, mma - 2 * maol],
        [-0.00057, mma + 2 * maol],
        [0.00056 * ecc, 2 * mma + sma],
        [-0.00042, 3 * mma],
        [0.00042 * ecc, sma + 2 * maol],
        [0.00038 * ecc, sma - 2 * maol],
        [-0.00024 * ecc, 2 * mma - sma],
        [-0.00017, lotan],
        [-0.00007, mma + 2 * sma],
        [0.00004, 2 * mma - 2 * maol],
        [0.00004, 3 * sma],
        [0.00003, mma + sma - 2 * maol],
        [0.00003, 2 * mma + 2 * maol],
        [-0.00003, mma + sma + 2 * maol],
        [0.00003, mma - sma + 2 * maol],
        [-0.00002, mma - sma - 2 * maol],
        [-0.00002, 3 * mma + sma],
        [0.00002, 4 * mma]
      ].sum { |coefficient, angle| coefficient * Math.sin(angle) }
    when :full_moon
      [
        [-0.40614, mma],
        [0.17302 * ecc, sma],
        [0.01614, 2 * mma],
        [0.01043, 2 * maol],
        [0.00734 * ecc, mma - sma],
        [-0.00515 * ecc, mma + sma],
        [0.00209 * ecc * ecc, 2 * sma],
        [-0.00111, mma - 2 * maol],
        [-0.00057, mma + 2 * maol],
        [0.00056 * ecc, 2 * mma + sma],
        [-0.00042, 3 * mma],
        [0.00042 * ecc, sma + 2 * maol],
        [0.00038 * ecc, sma - 2 * maol],
        [-0.00024 * ecc, 2 * mma - sma],
        [-0.00017, lotan],
        [-0.00007, mma + 2 * sma],
        [0.00004, 2 * mma - 2 * maol],
        [0.00004, 3 * sma],
        [0.00003, mma + sma - 2 * maol],
        [0.00003, 2 * mma + 2 * maol],
        [-0.00003, mma + sma + 2 * maol],
        [0.00003, mma - sma + 2 * maol],
        [-0.00002, mma - sma - 2 * maol],
        [-0.00002, 3 * mma + sma],
        [0.00002, 4 * mma]
      ].sum { |coefficient, angle| coefficient * Math.sin(angle) }
    else
      first_and_last_quarter_correction(values) +
        (phase == :first_quarter ? first_and_last_quarter_final_correction(values) : -first_and_last_quarter_final_correction(values))
    end
  end

  def additional_corrections(phase_increment)
    time = approximate_time(phase_increment)
    century = julian_centuries(phase_increment)

    [
      [0.000325, angle_radians(299.77 + 0.107408 * time - 0.009173 * century**2)],
      [0.000165, angle_radians(251.88 + 0.016321 * time)],
      [0.000164, angle_radians(251.83 + 26.651886 * time)],
      [0.000126, angle_radians(349.42 + 36.412478 * time)],
      [0.000110, angle_radians(84.66 + 18.206239 * time)],
      [0.000062, angle_radians(141.74 + 53.303771 * time)],
      [0.000060, angle_radians(207.14 + 2.453732 * time)],
      [0.000056, angle_radians(154.84 + 7.306860 * time)],
      [0.000047, angle_radians(34.52 + 27.261239 * time)],
      [0.000042, angle_radians(207.19 + 0.121824 * time)],
      [0.000040, angle_radians(291.34 + 1.844379 * time)],
      [0.000037, angle_radians(161.72 + 24.198154 * time)],
      [0.000035, angle_radians(239.56 + 25.513099 * time)],
      [0.000023, angle_radians(331.55 + 3.592518 * time)]
    ].sum { |coefficient, angle| coefficient * Math.sin(angle) }
  end

  def first_and_last_quarter_correction(values)
    ecc = values.fetch(:eccentricity_correction)
    mma = values.fetch(:moon_mean_anomaly_radians)
    sma = values.fetch(:sun_mean_anomaly_radians)
    maol = values.fetch(:moon_argument_of_latitude_radians)
    lotan = values.fetch(:longitude_of_the_ascending_node_radians)

    [
      [-0.62801, mma],
      [0.17172 * ecc, sma],
      [-0.01183, mma + sma],
      [0.00862, 2 * mma],
      [0.00804, 2 * maol],
      [0.00454 * ecc, mma - sma],
      [0.00204 * ecc**2, 2 * sma],
      [-0.00180, mma - 2 * maol],
      [-0.00070, mma + 2 * maol],
      [-0.00040, 3 * mma],
      [-0.00034 * ecc, 2 * mma - sma],
      [0.00032 * ecc, sma + 2 * maol],
      [0.00032, sma - 2 * maol],
      [-0.00028 * ecc**2, mma + 2 * sma],
      [0.00027 * ecc, 2 * mma + sma],
      [-0.00017, lotan],
      [-0.00005, mma - sma - 2 * maol],
      [0.00004, 2 * mma + 2 * maol],
      [-0.00004, mma + sma + 2 * maol],
      [0.00004, mma - 2 * sma],
      [0.00003, mma + sma - 2 * maol],
      [0.00003, 3 * sma],
      [0.00002, 2 * mma - 2 * maol],
      [0.00002, mma - sma + 2 * maol],
      [-0.00002, 3 * mma + sma]
    ].sum { |coefficient, angle| coefficient * Math.sin(angle) }
  end

  def first_and_last_quarter_final_correction(values)
    ecc = values.fetch(:eccentricity_correction)
    sma = values.fetch(:sun_mean_anomaly_radians)
    mma = values.fetch(:moon_mean_anomaly_radians)
    maol = values.fetch(:moon_argument_of_latitude_radians)

    0.00306 -
      0.00038 * ecc * Math.cos(sma) +
      0.00026 * Math.cos(mma) -
      0.00002 * Math.cos(mma - sma) +
      0.00002 * Math.cos(mma + sma) +
      0.00002 * Math.cos(2 * maol)
  end

  def orbital_values(phase_increment)
    centuries = julian_centuries(phase_increment)
    time = approximate_time(phase_increment)

    {
      eccentricity_correction: 1 - 0.002516 * centuries - 0.0000074 * centuries**2,
      moon_mean_anomaly_radians: angle_radians(
        201.5643 +
        385.81693528 * time +
        0.0107582 * centuries**2 +
        0.00001238 * centuries**3 -
        0.000000058 * centuries**4
      ),
      sun_mean_anomaly_radians: angle_radians(
        2.5534 +
        29.10535670 * time -
        0.0000014 * centuries**2 -
        0.00000011 * centuries**3
      ),
      moon_argument_of_latitude_radians: angle_radians(
        160.7108 +
        390.67050284 * time -
        0.0016118 * centuries**2 -
        0.00000227 * centuries**3 +
        0.000000011 * centuries**4
      ),
      longitude_of_the_ascending_node_radians: angle_radians(
        124.7746 -
        1.56375588 * time +
        0.0020672 * centuries**2 +
        0.00000215 * centuries**3
      )
    }
  end

  def approximate_time(phase_increment)
    ((@year + portion_of_year - 2000.0) * 12.3685).floor + phase_increment
  end

  def julian_centuries(phase_increment)
    approximate_time(phase_increment) / 1236.85
  end

  def julian_ephemeris_day(phase_increment)
    centuries = julian_centuries(phase_increment)
    time = approximate_time(phase_increment)

    2451550.09766 +
      29.530588861 * time +
      0.00015437 * centuries**2 -
      0.000000150 * centuries**3 +
      0.00000000073 * centuries**4
  end

  def portion_of_year
    days_in_year = Date.new(@year, 12, 31) - Date.new(@year, 1, 1)
    mid_month = Date.new(@year, @month, 15)
    mid_month.yday / days_in_year.to_f
  end

  def angle_radians(degrees)
    (degrees % 360.0) * Math::PI / 180.0
  end

  def julian_day_to_time(julian_day)
    adjusted = julian_day + 0.5
    z = adjusted.floor
    f = adjusted - z

    if z < 2299161
      a = z
    else
      alpha = ((z - 1867216.25) / 36524.25).floor
      a = z + 1 + alpha - (alpha / 4).floor
    end

    b = a + 1524
    c = ((b - 122.1) / 365.25).floor
    d = (365.25 * c).floor
    e = ((b - d) / 30.6001).floor
    day = b - d - (30.6001 * e).floor + f
    month = e < 14 ? e - 1 : e - 13
    year = month > 2 ? c - 4716 : c - 4715

    day_integer = day.floor
    day_fraction = day - day_integer
    total_seconds = (day_fraction * 86_400).round
    hours = total_seconds / 3600
    minutes = (total_seconds % 3600) / 60
    seconds = total_seconds % 60

    Time.utc(year, month, day_integer, hours, minutes, seconds)
  end
end
