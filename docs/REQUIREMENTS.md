# Requirements and verification traceability

This project is an educational software portfolio artifact. IDs below identify implemented behavior, not aircraft certification requirements.

| ID | Requirement | Implementation | Automated verification / evidence |
| --- | --- | --- | --- |
| LD-01 | Integrate longitudinal flight with lift, drag, thrust and gravity in SI units | `aero`, `airborneRhs` | `testLiftDragAgainstHandCalculation`, `testSteadyApproachForceBalance`, `testNoWindAirborneEnergyBalance` |
| LD-02 | Model approach, flare, touchdown and ground roll as explicit phases | `simulate` | `testOrderedExactEvents`, event CSV |
| LD-03 | Distinguish air-relative velocity from ground-relative velocity | `airborneRhs`, `groundRhs`, `telemetry` | `testWindOnlyChangesHorizontalKinematics`, `testTailwindAndHeadwindTrend` |
| LD-04 | Preserve horizontal velocity through an inelastic vertical contact reset | `simulate`, `metrics` | `testTouchdownResetPreservesHorizontalVelocity` |
| LD-05 | Use normal-force-dependent wheel braking with delayed ramps and reverse fade | `groundRhs` | `testAnalyticalConstantDecelerationStop`, `testGroundWorkEnergyBalance`, `testReverseAndBrakesCannotActBeforeDelay` |
| LD-06 | Terminate on zero ground speed and report runway margin | `simulate`, `metrics` | `testBaselinePhysicalInvariants`, `testShortRunwayIsReported` |
| LD-07 | Bound requested lift/thrust and identify sampled saturation | `airborneRhs`, `telemetry` | `testControlAuthorityIsLimited`, `testBaselinePhysicalInvariants` |
| LD-08 | Reject malformed inputs and never report timeout as success | `validateConfig`, `simulate` | `testInvalidInputs`, `testAirTimeoutCannotReportSuccess`, `testGroundTimeoutCannotReportSuccess` |
| LD-09 | Produce repeatable results and show integration refinement stability | `simulate` | `testDeterministicRepeat`, `testSolverConvergence`, `VALIDATION.md` |
| LD-10 | Show interpretable friction, wind, mass and reverse sensitivities | `run_scenarios` | Friction/wind/reverse trend tests, `results/scenarios/comparison.csv` and PNG |
| LD-11 | Export inspectable configuration, telemetry, metrics, events and full state | `exportResults` | `testExportRoundTrip`, baseline CSV/JSON/MAT outputs |
| LD-12 | Provide performance and force plots and a simple control panel | `plotResults`, `landing_app` | Local visual review of generated plots; GUI smoke check recorded separately |
| LD-13 | Separate measured aircraft context from estimates and model choices | `defaultConfig`, documentation | Manual source and assumption review in `PARAMETERS.md` |

`testLanding` uses MATLAB's function-based unit-test framework. The 21 test functions include multiple assertions; do not present the assertion count as the test count. `run_tests` writes machine-readable JUnit XML and a per-test CSV, then calls `assertSuccess` so failures stop a batch/CI run.

The analytical stopping check bypasses scenario validation intentionally to create a limiting case with zero aerodynamic density and already deployed brakes. It exercises `groundRhs` directly and compares event time and distance to `u0/a` and `u0²/(2a)`. The production scenario API does not accept zero density.

The energy checks use trapezoidal quadrature over the saved adaptive mesh with a relative residual allowance of 2e-4. The convergence check halves MaxStep and tightens both tolerances by 100, requiring touchdown time and sink differences below 0.002 s and 0.002 m/s, and ground-roll difference below 0.1 m.

## Remaining validation work

- Obtain an independent, condition-matched aircraft performance dataset before claiming Concorde performance accuracy.
- Add pitching moment, attitude and actuator/engine dynamics before claiming a flight-control or pilot-in-the-loop simulation.
- Add compliant landing gear and wheel/antiskid dynamics before evaluating impact loads or brake-system behavior.
- Execute cross-release MATLAB checks if broader compatibility is needed; only the recorded release has local execution evidence.
- A GitHub-hosted CI run becomes evidence only after the repository is published and that workflow succeeds.
