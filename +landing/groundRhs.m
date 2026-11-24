function [dy, f] = groundRhs(elapsed, y, p, touchdownCL)
%GROUNDRHS Flat-runway roll; y = [x; ground speed], time since touchdown.
% N = max(mg-L,0). Resistance always opposes forward travel. An event
% terminates at zero speed, so wheel forces are not a static-friction model.
if exist('flight_mex','file') == 3
    [dy,f] = flight_mex('ground',y,p,elapsed,touchdownCL);
    return;
end
u = max(y(2), 0);
vAir = max(u - p.environment.wind, 0); % no reverse-flow aero at taxi speed
f.cl = p.ground.residualCL + (touchdownCL-p.ground.residualCL) * ...
    exp(-max(elapsed, 0)/p.ground.liftDecayTime);
af = landing.aero(vAir, f.cl, p);
f.lift = af.lift; f.drag = af.drag;
f.normal = max(p.aircraft.mass*p.environment.g-f.lift, 0);
brakeFraction = min(max((elapsed-p.ground.brakeDelay)/p.ground.brakeRamp, 0), 1);
reverseFraction = min(max((elapsed-p.ground.reverseDelay)/p.ground.reverseRamp, 0), 1);
f.brake = p.ground.brakeMu*brakeFraction*f.normal;
f.rolling = p.ground.rollingMu*f.normal;
f.reverse = p.ground.reverseForce*reverseFraction * ...
    min(u/p.ground.reverseFadeSpeed, 1);
f.deceleration = (f.drag+f.brake+f.rolling+f.reverse)/p.aircraft.mass;
dy = [u; -f.deceleration];
end
