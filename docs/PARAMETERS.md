# Parameters, units and provenance

All values are defined in `+landing/defaultConfig.m`. Inputs are held constant for one run. Source pages were consulted November 21, 2026 (America/Toronto).

## Sourced aircraft context

The [Museum of Flight's Concorde exhibit record](https://www.museumofflight.org/Exhibits-and-Events/Aircraft/concorde) lists a wing area of 3,856 ft². Converting at 0.09290304 m²/ft² gives 358.233 m². The model uses 358.25 m² as a rounded nominal reference, about 0.005% different. This is the model's only sourced aircraft geometry parameter.

[British Airways' Concorde heritage page](https://www.britishairways.com/content/information/about-ba/history-and-heritage/celebrating-concorde) lists a landing speed of 300 km/h, equivalent to 83.333 m/s or about 162 kt. This provides order-of-magnitude context for the selected approach and flare speeds. It is not a condition-specific landing schedule, model calibration target, or touchdown acceptance criterion.

No proprietary aircraft aerodynamic tables, flight-control laws, or operational manuals are included. NASA force equations and MathWorks numerical-solver documentation support the implementation; they do not supply the estimated Concorde coefficients below.

## Aircraft and environment

| Field | Default | Units | Status / interpretation |
| --- | ---: | --- | --- |
| `aircraft.mass` | 105000 | kg | Selected landing scenario; constant, no fuel burn |
| `aircraft.wingArea` | 358.25 | m² | Sourced scale, rounded as described above |
| `aircraft.cd0` | 0.045 | — | Estimated fixed landing-configuration drag |
| `aircraft.inducedDrag` | 0.18 | — | Estimated parabolic polar coefficient |
| `aircraft.clMax` | 1.6 | — | Estimated ideal controller lift limit, not measured stall CL |
| `aircraft.maxThrust` | 300000 | N | Estimated total forward-thrust control authority |
| `environment.rho` | 1.225 | kg/m³ | Assumed fixed standard sea-level density |
| `environment.g` | 9.80665 | m/s² | Conventional standard gravity |
| `environment.wind` | 0 | m/s | Selected constant runway-axis wind, positive tailwind |

## Approach, flare and guidance

| Field | Default | Units | Status / interpretation |
| --- | ---: | --- | --- |
| `approach.initialHeight` | 150 | m | Selected effective gear clearance |
| `approach.thresholdHeight` | 15 | m | Sets initial x for the unflared path |
| `approach.glideAngle` | pi/60 | rad | Selected 3° descent magnitude |
| `approach.speed` | 86 | m/s TAS | Selected approach reference, approximately 167 kt |
| `flare.height` | 12 | m | Selected downward crossing for flare entry |
| `flare.speed` | 82 | m/s TAS | Reference requested at zero height, not achieved instantaneously |
| `flare.sinkTarget` | 0.7 | m/s down | Selected zero-height guidance target |
| `control.pathTimeConstant` | 0.65 | s | Estimated ideal path-response tuning |
| `control.speedTimeConstant` | 4 | s | Estimated ideal speed-response tuning |

## Ground and runway

| Field | Default | Units | Status / interpretation |
| --- | ---: | --- | --- |
| `ground.brakeMu` | 0.30 | — | Estimated effective wheel friction after full deployment |
| `ground.rollingMu` | 0.015 | — | Estimated rolling resistance |
| `ground.brakeDelay` | 1.5 | s | Selected delay after touchdown |
| `ground.brakeRamp` | 1 | s | Selected linear deployment duration |
| `ground.residualCL` | 0.15 | — | Estimated unloaded lift coefficient |
| `ground.liftDecayTime` | 1 | s | Selected exponential effective lift unloading |
| `ground.reverseForce` | 85000 | N | Estimated aggregate reverse authority |
| `ground.reverseDelay` | 1 | s | Selected reverse activation delay |
| `ground.reverseRamp` | 1.5 | s | Selected linear deployment duration |
| `ground.reverseFadeSpeed` | 25 | m/s ground | Selected fade region; reverse tends to zero at stop |
| `runway.length` | 3000 | m | Selected flat-runway geometry |

## Numerical settings

| Field | Default | Units | Interpretation |
| --- | ---: | --- | --- |
| `solver.relativeTolerance` | 1e-8 | — | Adaptive relative error tolerance |
| `solver.absoluteTolerance` | 1e-9 | mixed state units | Scalar absolute tolerance applied to each state |
| `solver.maxStep` | 0.1 | s | Maximum integration step |
| `solver.maxAirTime` | 180 | s | Total airborne time allowance from start |
| `solver.maxGroundTime` | 180 | s | Ground time allowance from touchdown |

## Accepted computational envelope

`validateConfig` enforces 80–120 t mass, 0.9–1.4 kg/m³ density, wind within ±15 m/s, 75–100 m/s approach speed, 70 m/s ≤ flare speed ≤ approach speed, and a 2–4° approach. Height order is `initialHeight > thresholdHeight > flare.height > 0`, with flare height ≤25 m. Sink target must be positive and below the entry sink rate. Effective braking is 0–0.6, rolling resistance is 0–0.1, and residual CL cannot exceed the imposed CL maximum.

Time constants, deployment ramps, core physical scales, runway length, and solver settings must be positive. Coefficients, delays and force magnitudes otherwise must be nonnegative; wind can have either sign. Relative tolerance is at most 1e-3; maximum step is at most 1 s. Every field must be a finite real numeric scalar, and field names must match the schema exactly.

These bounds help reject obvious input mistakes. They do not establish physical validity throughout the envelope or guarantee every accepted scenario will land and stop; runtime events and timeouts still apply. The lower-friction scenario uses coefficient 0.15 as a sensitivity example, without claiming it represents a particular runway surface or weather condition.
