function r = simulate(p)
%SIMULATE Approach -> flare -> contact reset -> ground roll -> stopped.
% Terminal ODE events locate phase boundaries independently of output steps.
% Failures throw named errors; an incomplete run never reports a stop.
if nargin == 0, p = landing.defaultConfig(); end
landing.validateConfig(p);
opts = odeset('RelTol',p.solver.relativeTolerance, ...
    'AbsTol',p.solver.absoluteTolerance,'MaxStep',p.solver.maxStep);
gamma0 = -p.approach.glideAngle;
% For wind, adjust the initial x to preserve the chosen threshold height
% along the unflared steady descent in ground coordinates.
sink0 = p.approach.speed*sin(p.approach.glideAngle);
ground0 = p.approach.speed*cos(gamma0)+p.environment.wind;
x0 = -(p.approach.initialHeight-p.approach.thresholdHeight)*ground0/sink0;
y0 = [x0; p.approach.initialHeight; p.approach.speed; gamma0];
[ta, ya, te, ye, ie] = ode45(@(t,y) landing.airborneRhs(t,y,p,'approach'), ...
    [0 p.solver.maxAirTime], y0, ...
    odeset(opts,'Events',@(t,y) airEvent(t,y,p.flare.height)));
checkAirEvent(te, ie, 'Flare entry');
r.events.flareTime = te(end);
[tf, yf, te, ye, ie] = ode45(@(t,y) landing.airborneRhs(t,y,p,'flare'), ...
    [te(end) p.solver.maxAirTime], ye(end,:)', ...
    odeset(opts,'Events',@(t,y) airEvent(t,y,0)));
checkAirEvent(te, ie, 'Touchdown');
r.events.touchdownTime = te(end);
td = ye(end,:)'; td(2) = 0;
[~, ftd] = landing.airborneRhs(te(end),td,p,'flare');
r.events.touchdownState = td;
r.events.touchdownCL = ftd.cl;
% Perfectly inelastic vertical contact, no longitudinal impulse or bounce.
% Constant wind converts true air velocity to horizontal ground velocity.
groundInitial = [td(1); td(3)*cos(td(4))+p.environment.wind];
[tg, yg, te, ~] = ode45(@(t,y) landing.groundRhs(t,y,p,ftd.cl), ...
    [0 p.solver.maxGroundTime], groundInitial, ...
    odeset(opts,'Events',@stopEvent));
assert(~isempty(te), 'landing:NoStop', ...
    'Ground roll exceeded maxGroundTime without reaching zero speed.');
yg(end,2) = 0; % remove root-finding roundoff, not a speed threshold
r.events.stopTime = r.events.touchdownTime+te(end);
r.config = p;
r.air.time = [ta; tf(2:end)];
r.air.state = [ya; yf(2:end,:)]; r.air.state(end,2) = 0;
r.ground.time = tg+r.events.touchdownTime;
r.ground.elapsed = tg; r.ground.state = yg;
r.history = landing.telemetry(r);
r.metrics = landing.metrics(r);
end

function [value, terminal, direction] = airEvent(~, y, targetHeight)
% Second root stops integration outside the low-speed model domain.
value = [y(2)-targetHeight; y(3)-55];
terminal = [1;1]; direction = [-1;-1];
end

function [value, terminal, direction] = stopEvent(~, y)
value = y(2); terminal = 1; direction = -1;
end

function checkAirEvent(te, ie, name)
assert(~isempty(te), 'landing:NoTouchdown', ...
    '%s event was not reached before maxAirTime.', name);
assert(ie(end) == 1, 'landing:FlightEnvelope', ...
    'Airspeed fell below the model floor before %s.', name);
end
