require "astronoby"

class GemMoonPhaseSolver
  REFERENCE_VERSION = "astronoby-v0.9.0"
  EPHEMERIS_PATH = "tmp/de421.bsp"

  def initialize(problem)
    @problem = problem
  end

  def solve
    if @problem.daily_fixture?
      solve_daily_fixture
    else
      solve_event_fixture
    end
  end

  private

  def solve_daily_fixture
    ensure_ephemeris!

    instant = Astronoby::Instant.from_time(Time.utc(@problem.observation_date.year, @problem.observation_date.month, @problem.observation_date.day, 12, 0, 0))
    moon = Astronoby::Moon.new(ephem: Astronoby::Ephem.load(EPHEMERIS_PATH), instant: instant)

    MoonPhaseResult.new(
      fixture_type: "daily",
      illuminated_fraction: moon.illuminated_fraction.round(6),
      phase_fraction: moon.current_phase_fraction.round(6),
      phase_name: MoonPhaseCalculator.new(@problem.observation_date).phase_name,
      major_events: [],
      source: "astronoby",
      reference_version: REFERENCE_VERSION,
      ephemeris_required: true
    )
  end

  def solve_event_fixture
    phases = Astronoby::Events::MoonPhases.phases_for(year: @problem.year, month: @problem.month)

    MoonPhaseResult.new(
      fixture_type: "events",
      illuminated_fraction: nil,
      phase_fraction: nil,
      phase_name: nil,
      major_events: phases.map { |phase| { phase: phase.phase, time: phase.time.utc } },
      source: "astronoby",
      reference_version: REFERENCE_VERSION,
      ephemeris_required: false
    )
  end

  def ensure_ephemeris!
    return if File.exist?(EPHEMERIS_PATH)

    Astronoby::Ephem.download(name: "de421.bsp", target: EPHEMERIS_PATH)
  end
end
