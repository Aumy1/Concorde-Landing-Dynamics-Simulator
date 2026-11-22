# Attribution and assistance

## Initial implementation

The project owner, [Aumy1](https://github.com/Aumy1), chose the civilian Concorde landing project and its scope, supplied the CAD and livery references for the local preview, and directed the replay refinements. OpenAI Codex authored the MATLAB implementation, tests, documentation and packaging, and ran the model and its verification suite in MATLAB. The recorded evidence is in `docs/VALIDATION.md` and `results/verification/`.

The public replay uses original procedural aircraft geometry. The user-supplied STEP, its converted mesh, and the reference images are excluded. Python and Gmsh were used for the optional local STEP conversion; the simulator is written in MATLAB.

## Reference material

- [The Museum of Flight — Concorde exhibit](https://www.museumofflight.org/Exhibits-and-Events/Aircraft/concorde): nominal wing area and aircraft context.
- [British Airways — Celebrating Concorde](https://www.britishairways.com/content/information/about-ba/history-and-heritage/celebrating-concorde): general landing-speed context.
- [British Airways — Concorde in the Landor livery](https://mediacentre.britishairways.com/image/details/47327): visual paint reference. Markings are simplified geometry drawn for this replay.
- [NASA Glenn — Lift equation](https://www1.grc.nasa.gov/beginners-guide-to-aeronautics/lift-equation/) and [drag equation](https://www1.grc.nasa.gov/beginners-guide-to-aeronautics/drag-equation/): standard force relationships.
- [MathWorks — ode45](https://www.mathworks.com/help/matlab/ref/ode45.html) and [ODE event location](https://www.mathworks.com/help/matlab/math/ode-event-location.html): numerical-solver interface and event behavior.
- [Official MATLAB Actions](https://github.com/matlab-actions): setup and batch execution in the included GitHub Actions workflow.

Pages were consulted November 21, 2026 (America/Toronto). See `docs/PARAMETERS.md` for the sourced-versus-estimated distinction. No reference photographs, official logo files, third-party source code, or proprietary performance tables are bundled. Charts are generated from this model. Product and organization names belong to their respective owners.
