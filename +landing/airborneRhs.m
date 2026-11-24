function [dy, f] = airborneRhs(~, y, p, phase)
%AIRBORNERHS Point-mass longitudinal equations; y = [x; h; Vair; gamma].
% Gamma is positive upward, thrust is aligned with air-relative velocity.
% Guidance requests gamma and V; ideal force control is bounded by CL/T.
if exist('flight_mex','file') == 3
    [dy,f] = flight_mex('air',y,p,0,double(strcmp(phase,'flare')));
    f.saturated = logical(f.saturated);
    return;
end
v = max(y(3), 1); gamma = y(4);
if strcmp(phase, 'approach')
    gammaRef = -p.approach.glideAngle;
    speedRef = p.approach.speed;
else
    fraction = min(max(y(2) / p.flare.height, 0), 1);
    entrySink = p.approach.speed * sin(p.approach.glideAngle);
    sinkRef = p.flare.sinkTarget + (entrySink-p.flare.sinkTarget)*fraction;
    gammaRef = -asin(min(sinkRef / v, 0.9));
    speedRef = p.flare.speed + (p.approach.speed-p.flare.speed)*fraction;
end
gammaRateRequest = (gammaRef - gamma) / p.control.pathTimeConstant;
qS = 0.5*p.environment.rho*v^2*p.aircraft.wingArea;
clRequest = p.aircraft.mass * (v*gammaRateRequest + ...
    p.environment.g*cos(gamma)) / qS;
f.cl = min(max(clRequest, 0), p.aircraft.clMax);
af = landing.aero(v, f.cl, p);
f.lift = af.lift; f.drag = af.drag;
thrustRequest = f.drag + p.aircraft.mass*p.environment.g*sin(gamma) + ...
    p.aircraft.mass*(speedRef-v)/p.control.speedTimeConstant;
f.thrust = min(max(thrustRequest, 0), p.aircraft.maxThrust);
f.saturated = abs(clRequest-f.cl) > 1e-10 || ...
    abs(thrustRequest-f.thrust) > 1e-6;
f.speedRef = speedRef; f.gammaRef = gammaRef;
dy = [v*cos(gamma) + p.environment.wind; v*sin(gamma); ...
    (f.thrust-f.drag)/p.aircraft.mass - p.environment.g*sin(gamma); ...
    f.lift/(p.aircraft.mass*v) - p.environment.g*cos(gamma)/v];
end
