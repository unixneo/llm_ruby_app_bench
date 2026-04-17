# Physics, Quantum, Astrophysics, and Celestial Mechanics Survey

## Date

2026-04-17

## Purpose

Evaluate whether physics-adjacent algorithm families are suitable next benchmark domains for the Rails research app.

This survey applies C005: a domain is not ready for prompt selection unless a Ruby reference gem exists, loads, and can be exercised with a basic API call.

Temporary test gems were installed under `/tmp/codex_physics_gems`; the Rails app `Gemfile` and bundle were not modified.

---

## Summary

| Domain | Candidate gem | Functional status | Complexity fit | Recommendation |
| --- | --- | --- | --- | --- |
| Celestial mechanics / satellite propagation | `orbit` | Loads and computes satellite look angle from TLE | Strong numerical/physics fit | Best physics-domain candidate |
| Astrometry / astronomy | `astronoby` | Loads and computes Moon phases | Strong numerical/astronomy fit | Strong candidate, especially for ephemeris/time calculations |
| Quantum computing | `quantum_ruby` | Loads, but README-level measurement path failed locally | Interesting algorithmic fit | Reject until API issue is resolved |
| Newtonian n-body simulation | `orbiter` | Loads and creates bodies | Toy/reference-limited | Possible teaching benchmark, weak reference |
| Newtonian mechanics | `newtonian` | Installs, but normal require did not expose core classes from project cwd | Broken packaging/API issue | Reject |
| Classical/quantum formulas | `physics`, `physics_calculator` | Load successfully | Mostly formula evaluation, not algorithmically deep | Useful only for small formula-validation prompts |
| Astrophysics simulation wrappers | `gs2crmod`, `mesa_cli` | Not tested as reference libraries | External-code workflow, not pure Ruby benchmark | Reject for current workflow |

Best candidates from this pass:

1. `orbit` for satellite propagation from TLEs.
2. `astronoby` for astronomical events, ephemerides, Moon phases, coordinate/time calculations.

These are not NP-hard/NP-complete like TSP, VRP, or SAT. They are better framed as numerical scientific-computing benchmarks where LLM failures would involve units, coordinate transforms, time systems, floating-point tolerances, and physics formulas.

---

## Celestial Mechanics: `orbit`

RubyGems metadata:

```text
name: orbit
version: 0.8.0
info: A ruby gem for calculating satellite positional data and look angles, etc.
```

Library files include:

```text
orbit/norad_sgp4.rb
orbit/norad_sdp4.rb
orbit/satellite.rb
orbit/site.rb
orbit/tle.rb
orbit/julian.rb
```

Functional smoke test:

```bash
GEM_HOME=/tmp/codex_physics_gems GEM_PATH=/tmp/codex_physics_gems ruby -e 'require "orbit"; tle="EYESAT-1 (AO-27)\n1 22825U 93061C   12265.90994989  .00000070  00000-0  44528-4 0  2022\n2 22825  98.5823 207.2528 0008444   2.3056 357.8161 14.29486540990291"; s=Orbit::Satellite.new(tle); site=Orbit::Site.new(33.5,-95.3,23); tc=site.view_angle_to_satellite_at_time(s, Time.utc(2012,9,21,22,0,0)); puts [Orbit::OrbitGlobals.rad_to_deg(tc.elevation).round(4), Orbit::OrbitGlobals.rad_to_deg(tc.azimuth).round(4)].join(" ")'
```

Output:

```text
-1.2911 281.463
```

Candidate benchmark ideas:

- Parse a TLE.
- Propagate satellite position at requested times.
- Compute observer azimuth/elevation from latitude, longitude, altitude, and timestamp.
- Compare candidate Ruby output against `orbit` within explicit tolerances.

Research value:

- Strong risk of LLM errors in coordinate frames, radians/degrees, time handling, and orbital element interpretation.
- Good UI potential: observer site, Earth view, pass table, azimuth/elevation chart.
- Reference gem is pure Ruby and works in a smoke test.

Risk:

- Need determine whether `orbit` precision and maintenance are acceptable for this research app.
- Validation must use tolerances, not exact equality.

Verdict: **best physics-domain candidate**.

---

## Astrometry / Astronomy: `astronoby`

RubyGems metadata:

```text
name: astronoby
version: 0.9.0
info: Astronomy and astrometry Ruby library for astronomical data and events.
```

The README states that algorithms are based on astronomy/astrometry sources including Jean Meeus and that Solar System positions use IMCCE or NASA/JPL ephemerides.

Functional smoke test:

```bash
GEM_HOME=/tmp/codex_physics_gems GEM_PATH=/tmp/codex_physics_gems ruby -e 'require "astronoby"; phases=Astronoby::Events::MoonPhases.phases_for(year: 2024, month: 5); puts phases.map { |p| "#{p.phase}:#{p.time.utc.strftime("%Y-%m-%d %H:%M:%S")}" }.join("|")'
```

Output:

```text
last_quarter:2024-05-01 11:27:15|new_moon:2024-05-08 03:21:56|first_quarter:2024-05-15 11:48:02|full_moon:2024-05-23 13:53:12|last_quarter:2024-05-30 17:12:42
```

Candidate benchmark ideas:

- Compute Moon phases for a civil month.
- Convert time to Julian date.
- Compute equinox/solstice times.
- Compute rise/transit/set or twilight events for an observer.
- With approved ephemeris fixture files, compute apparent positions of Solar System bodies.

Research value:

- Good for exposing time-scale, date boundary, coordinate, unit, and numerical-tolerance mistakes.
- Clear user-facing interpretation possible: event times, sky positions, phase names.
- Stronger maintained-library signal than most physics search results.

Risk:

- Some use cases require ephemeris files. Downloading and pinning those files should be its own PI-approved prompt.
- This is numerical scientific computing, not NP-hard search.

Verdict: **strong candidate**.

---

## Quantum Computing: `quantum_ruby`

RubyGems metadata:

```text
name: quantum_ruby
version: 0.9.0
info: A Quantum Computer Simulator written in Ruby.
```

Functional smoke test:

```bash
GEM_HOME=/tmp/codex_physics_gems GEM_PATH=/tmp/codex_physics_gems ruby -e 'require "quantum_ruby"; q=Qubit.new(1,0); s=H_GATE*q; puts "quantum_ok=#{s.respond_to?(:measure)}"; puts "x_zero=#{(X_GATE*Qubit.new(1,0)).measure}"'
```

Output:

```text
quantum_ok=true
TypeError: no implicit conversion from nil to integer
```

Assessment:

- The gem loads.
- Gate/state objects exist.
- A basic measurement path failed locally.
- This is not ready as a reference implementation without further investigation.

Candidate benchmark idea if fixed:

- Build a pure Ruby state-vector simulator.
- Validate gates, tensor products, Bell states, and simple deterministic circuits.
- Avoid probabilistic measurements unless seeded or validated statistically.

Verdict: **interesting but blocked**.

---

## Newtonian / N-Body Simulation

### `orbiter`

RubyGems metadata:

```text
name: orbiter
version: 0.0.2
info: For tracking the orbits of n free bodies in a 2D space
```

Functional smoke test:

```bash
GEM_HOME=/tmp/codex_physics_gems GEM_PATH=/tmp/codex_physics_gems ruby -e 'require "orbiter"; b=Orbiter::Free_body.new(mass: 10, x: 100, y: 100, vel_x: -5, vel_y: -1); puts "orbiter_ok=#{b.class}"'
```

Output:

```text
orbiter_ok=Orbiter::Free_body
```

Assessment:

- Loads and exposes a small 2D body/orbit updater.
- Uses normalized constants (`G_CONSTANT = 1`, `TIME_CONSTANT = 1`).
- Better suited as a toy simulation reference than a scientific reference.

Verdict: **possible but weak**.

### `newtonian`

RubyGems metadata:

```text
name: newtonian
version: 0.2.1
info: Newtonian physics gives a way to predict the future state of a system of massive objects in a Euclidean space.
```

Functional smoke test:

```bash
GEM_HOME=/tmp/codex_physics_gems GEM_PATH=/tmp/codex_physics_gems ruby -e 'require "newtonian"; puts "newtonian_loaded"; p defined?(Universe); p defined?(Body)'
```

Output:

```text
newtonian_loaded
nil
nil
```

Assessment:

- The gem loads, but the expected core classes were not exposed from the project working directory.
- Source inspection suggests the gem uses relative requires tied to its own directory layout.

Verdict: **reject**.

---

## Formula Libraries

### `physics`

RubyGems metadata:

```text
name: physics
version: 0.0.3
info: Physics formulae covering classical mechanics, general relativity, fundamental constants, and more.
```

Relevant files:

```text
physics/celestial_mechanics.rb
physics/classical_mechanics.rb
physics/fundamental_constants.rb
physics/general_relativity.rb
```

Assessment:

- Loads successfully.
- Includes simple formulas such as orbital period of a body in an elliptic orbit.
- Too shallow for the main benchmark unless the prompt explicitly focuses on formula correctness and units.

Verdict: **useful only for small formula checks**.

### `physics_calculator`

RubyGems metadata:

```text
name: physics_calculator
version: 0.0.2
info: Gem that contains many useful methods using physics formulas.
```

Assessment:

- Loads successfully.
- Includes vector helpers, constants, classical mechanics formulas, and several quantum formulas such as de Broglie wavelength, quantum harmonic oscillator energy, infinite-well energy, and Rydberg wavelength.
- Most methods are direct formulas, not complex algorithms.

Verdict: **useful only for small formula checks**.

---

## Domain Recommendation

Best physics-adjacent path:

```text
Celestial mechanics / satellite propagation with orbit as reference
```

Alternative strong path:

```text
Astronomy / astrometry event calculations with astronoby as reference
```

Recommended prompt framing:

1. Choose one of these domains with PI approval.
2. Treat it as numerical scientific computing, not NP-hard optimization.
3. Define exact fixtures before coding: TLEs, observer sites, timestamps, or Moon-phase months.
4. Define numeric tolerances before coding.
5. Require candidate Ruby code to avoid calling the reference gem.
6. Compare candidate output against the reference gem and present differences for PI interpretation.

Do not select quantum simulation, n-body simulation, or generic physics formulas as the next main benchmark without additional verification.
