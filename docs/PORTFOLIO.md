# Engineering walkthrough and portfolio use

## What this project can demonstrate

This artifact can support a GDMS Canada co-op portfolio through numerical modeling, modular MATLAB code, explicit requirements, failure handling, software tests, sensitivity analysis, and reproducible evidence. It has no affiliation with or endorsement from GDMS, British Airways, Airbus, or MathWorks.

An interview walkthrough can follow this sequence:

1. Run `run_demo` and explain why true airspeed and ground speed differ under wind.
2. Open `MODEL.md` and derive the tangential and normal point-mass equations from the force balance.
3. Show how event location avoids continuing flight below the runway, and explain why touchdown requires a state reset.
4. Show the analytical stopping-distance test. Explain what it validates independently of the complete model.
5. Compare the baseline with lower friction, headwind, tailwind, and no reverse. Explain the role of normal force in braking.
6. Open `VALIDATION.md` and distinguish numerical convergence, equation verification, and validation against actual aircraft data.
7. Identify the missing physics and explain which extension would reduce the most important uncertainty.

## Authorship and learning

Codex drafted the initial source, tests and documentation and exercised the MATLAB build at the user's request. The user selected the project and its civilian landing scope. This is a useful starting artifact, but it does not establish that the user independently wrote or understands every line. See `ATTRIBUTION.md`.

Before using the project as evidence of personal MATLAB skill, reproduce the build, explain each state and force term, trace one test manually, and make at least one understood change with a new justified test or experiment. Keep a clear record of those contributions in subsequent commits. Do not claim C++, Qt, 3D visualization, real-time execution, aircraft certification, or flight-data validation; those features are absent.

After that review and personal contribution, a contribution-specific résumé entry could mention numerical landing simulation, event-based integration, analytical verification and parameter sensitivity. Describe AI assistance honestly when asked and keep the checked-in provenance disclosure.

## GitHub preparation

The folder contains source, documentation, MIT license, ignore rules, issue/PR templates, a CI workflow, and checked-in demonstration outputs. Before publication, inspect the project and license, choose a repository name such as `concorde-landing-simulator`, and upload this directory as the repository root.

The GitHub Actions workflow uses official MathWorks actions and requests only base MATLAB. Hosted availability/licensing follows the [Setup MATLAB action's current requirements](https://github.com/matlab-actions/setup-matlab). Local execution does not prove that a future hosted run will succeed. No remote repository or public deployment is created by the local build.

## Sensible next milestone

The next useful step is understanding and improving the MATLAB model with a documented experiment, such as a drag-polar sensitivity sweep or a first-order thrust actuator. A C++ port or 3D viewer can follow once the MATLAB model serves as a stable numerical reference. Rendering changes should not substitute for improved physics or independent validation.
