function p = defaultConfig()
%DEFAULTCONFIG SI configuration for the educational civilian landing model.
% See docs/PARAMETERS.md for provenance. Except wing area, these are scenario
% choices or engineering estimates, not a certified Concorde data set.
p.aircraft.mass = 105000;              % kg, constant landing mass
p.aircraft.wingArea = 358.25;          % m^2, rounded Museum of Flight value
p.aircraft.cd0 = 0.045;                % gear-down parasitic drag estimate
p.aircraft.inducedDrag = 0.18;         % parabolic polar factor, estimated
p.aircraft.clMax = 1.6;                % imposed model authority limit
p.aircraft.maxThrust = 300000;         % N, aggregate approach authority
p.environment.rho = 1.225;            % kg/m^3, fixed sea-level density
p.environment.g = 9.80665;            % m/s^2
p.environment.wind = 0;               % m/s, positive = tailwind along runway
p.approach.initialHeight = 150;        % m above effective gear-contact datum
p.approach.thresholdHeight = 15;       % m, defines initial position
p.approach.glideAngle = deg2rad(3);    % positive descent angle magnitude
p.approach.speed = 86;                 % m/s true airspeed
p.flare.height = 12;                  % m, downward crossing starts flare
p.flare.speed = 82;                   % m/s, commanded at h = 0
p.flare.sinkTarget = 0.7;              % m/s down, target rather than outcome
p.control.pathTimeConstant = 0.65;     % s, ideal flight-path response
p.control.speedTimeConstant = 4;       % s, ideal thrust speed controller
p.ground.brakeMu = 0.30;              % dimensionless effective wheel braking
p.ground.rollingMu = 0.015;           % dimensionless rolling resistance
p.ground.brakeDelay = 1.5;            % s after touchdown
p.ground.brakeRamp = 1;               % s, linear application
p.ground.residualCL = 0.15;           % lift coefficient after unloading
p.ground.liftDecayTime = 1;           % s, effective pitch/lift unloading
p.ground.reverseForce = 85000;        % N, aggregate reverse estimate
p.ground.reverseDelay = 1;            % s after touchdown
p.ground.reverseRamp = 1.5;           % s, linear application
p.ground.reverseFadeSpeed = 25;       % m/s ground speed, fades to zero
p.runway.length = 3000;               % m, threshold x = 0, flat runway
p.solver.relativeTolerance = 1e-8;
p.solver.absoluteTolerance = 1e-9;
p.solver.maxStep = 0.1;                % s, bounds event/integration steps
p.solver.maxAirTime = 180;             % s, explicit failure if not landed
p.solver.maxGroundTime = 180;          % s, explicit failure if not stopped
end
