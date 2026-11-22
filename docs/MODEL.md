# Model and numerical design

## Scope and coordinates

The vehicle is a two-dimensional longitudinal point mass over a flat runway. All calculations use SI units. Position `x = 0` is the runway threshold; positive x is along landing travel. Height h is an effective gear-contact clearance, not the actual centre-of-gravity altitude. Gamma is an **air-relative flight-path angle**, positive upward; it is not pitch attitude or angle of attack.

Wind w is constant and horizontal, positive for tailwind. There is no vertical wind, crosswind, wind shear, runway slope, or altitude-dependent density. The trajectory starts at 150 m effective clearance. Its initial x is chosen so the unflared approach would cross the threshold at 15 m, including the ground-speed effect of wind:

```text
gamma0 = -approach.glideAngle
sink0  = V0 sin(approach.glideAngle)
u0     = V0 cos(gamma0) + w
x0     = -(h0 - thresholdHeight) u0 / sink0
```

## Flight equations

State `y = [x, h, V, gamma]`, with V true airspeed. Mass m and gravity g are constant. Thrust T acts along the air-relative flight path; lift L is perpendicular to it; drag D opposes it:

```text
q         = rho V^2 / 2
L         = q S CL
CD        = CD0 + k CL^2
D         = q S CD
dx/dt     = V cos(gamma) + w
dh/dt     = V sin(gamma)
dV/dt     = (T - D)/m - g sin(gamma)
dgamma/dt = L/(m V) - g cos(gamma)/V
```

NASA's [lift equation](https://www1.grc.nasa.gov/beginners-guide-to-aeronautics/lift-equation/) and [drag equation](https://www1.grc.nasa.gov/beginners-guide-to-aeronautics/drag-equation/) provide the force relations. The chosen parabolic polar is an engineering approximation with estimated coefficients. It is not a fitted Concorde delta-wing aerodynamic database and does not resolve vortex lift, stall, Mach effects, or ground effect.

### Approach and flare guidance

Approach requests constant V and gamma. During flare, let `f = clamp(h / flare.height, 0, 1)`:

```text
sinkEntry = approach.speed sin(approach.glideAngle)
sinkRef   = sinkTarget + (sinkEntry - sinkTarget) f
gammaRef  = -asin(sinkRef / V)
Vref      = flare.speed + (approach.speed - flare.speed) f
```

The code bounds the asin argument defensively. Guidance follows a moving target, so the actual touchdown sink and speed do not equal their requested values. There is no feedforward cancellation to force a prescribed trajectory.

An ideal force controller requests:

```text
gammaDotRequest = (gammaRef - gamma) / pathTimeConstant
CLrequest       = m (V gammaDotRequest + g cos(gamma)) / (q S)
CL              = clamp(CLrequest, 0, clMax)
Trequest        = D + mg sin(gamma) + m (Vref - V) / speedTimeConstant
T               = clamp(Trequest, 0, maxThrust)
```

CL and T have no actuator states or rate limits. This is a reduced guidance/control demonstration, not a flight-control law for the real aircraft. Saturation is logged at saved output samples; the flag is not a continuous-time proof that no transient limit was reached.

## Hybrid phase transitions

1. **Approach:** integrate until h crosses flare height downward.
2. **Flare:** restart from that event state and integrate until h crosses zero downward.
3. **Touchdown:** record the pre-impact state and sink rate. Preserve x and horizontal ground velocity `u = V cos(gamma) + w`. Reset vertical velocity to zero with perfectly inelastic contact. No longitudinal contact impulse is applied.
4. **Ground roll:** integrate x and u until u reaches zero downward.

The vertical contact removes `m (V sin(gamma))^2 / 2` joules. This is an energy bookkeeping value, **not** a peak impact force or a landing-gear load prediction. No gear spring, pitch rotation, nose-wheel transition, bounce, or tire dynamics are resolved. The h datum intentionally collapses gear geometry.

## Ground equations

Let tau be elapsed time after touchdown. Wind affects aerodynamic speed separately from ground speed:

```text
Vair       = max(u - w, 0)
CLground   = residualCL + (CLtouchdown - residualCL) exp(-tau/liftDecayTime)
L, D       = aero(Vair, CLground)
N          = max(mg - L, 0)
brakeFrac  = clamp((tau - brakeDelay)/brakeRamp, 0, 1)
reverseFrac= clamp((tau - reverseDelay)/reverseRamp, 0, 1)
B          = brakeMu brakeFrac N
Rrolling   = rollingMu N
Rreverse   = reverseForce reverseFrac min(max(u,0)/reverseFadeSpeed, 1)
dx/dt      = max(u,0)
du/dt      = -(D + B + Rrolling + Rreverse)/m
```

Lift unloading represents an imposed reduction of effective lift, not a simulated Concorde spoiler system. Reverse thrust uses aggregate constant-force authority with timed deployment and a smooth low-speed fade; engine dynamics are absent. Brake friction is an effective parameter and does not include antiskid, wheel rotation, brake temperature, hydroplaning, or a runway-condition standard.

The stopped state is a terminal event. The ODE is not used as a static-friction model after zero speed. Negative air-relative flow in a tailwind at low ground speed is ignored by the `max` approximation. The ground constraint can supply reaction without simulating re-liftoff.

## Numerics, output and errors

`ode45` uses an adaptive Dormand–Prince method, with terminal directional events. Baseline settings are `RelTol=1e-8`, `AbsTol=1e-9`, and `MaxStep=0.1 s`. Output is on the adaptive solver mesh, not a uniform fixed-rate log. Contact and stop use the event state, not the next displayed output sample. See MathWorks' [ode45 documentation](https://www.mathworks.com/help/matlab/ref/ode45.html) and [event-location notes](https://www.mathworks.com/help/matlab/math/ode-event-location.html).

The approach and flare share one maximum airborne time measured from simulation start. Ground roll has its own maximum elapsed time. Both phase boundaries are restarts so a flight ODE is never continued through runway penetration. The 55 m/s airborne speed event is a computational floor; it is not a claimed Concorde stall speed.

| Error identifier | Meaning |
| --- | --- |
| `landing:InvalidConfig` | Missing/extra fields, invalid scalar, or unsupported configuration |
| `landing:NoTouchdown` | Approach/flare event not reached within airborne time allowance |
| `landing:FlightEnvelope` | Airspeed floor reached before the required height event |
| `landing:NoStop` | Ground speed never reached zero within the ground time allowance |
| `landing:FileWrite` | A requested report or JSON output could not be opened |

`result.air` retains pre-contact flight states. `result.ground` includes the exact post-reset touchdown state. The combined telemetry has unique increasing times: its touchdown row retains pre-impact values, followed by ground samples strictly after touchdown. Consequently it intentionally does not show both sides of the vertical velocity discontinuity at the same time. The stopped telemetry row includes forces just before stopping; they should not be interpreted as post-stop forces.

Ground roll is `xStop - xTouchdown`. Threshold-to-stop distance is `xStop`, since threshold x is zero. Neither is the total simulated trajectory distance from the initial approach position, and neither is a regulated landing-distance calculation. `stoppedWithinRunway` also requires touchdown at or beyond the threshold. A negative margin is reported without simulating any subsequent event outside the runway.

## Validation limits

An analytical constant-deceleration case tests the ground solver independently of the full landing. Energy checks compare integrated work against kinetic/potential energy changes, with separate air and ground accounting across the inelastic reset. The airborne energy test uses no wind; otherwise the air-relative kinetic-energy form requires care with the chosen frame. Tolerance refinement tests sensitivity to discretization. One-at-a-time scenarios test qualitative trends.

Agreement with these checks establishes implementation consistency. Real Concorde performance validation would require independent aerodynamic, landing-configuration, thrust, runway, and flight-test records with matched conditions. Those data are not supplied by this project.
