function f = aero(speed, cl, p)
%AERO Lumped lift/drag in N using true airspeed and a parabolic drag polar.
q = 0.5 * p.environment.rho * speed.^2;
f.lift = q .* p.aircraft.wingArea .* cl;
f.cd = p.aircraft.cd0 + p.aircraft.inducedDrag .* cl.^2;
f.drag = q .* p.aircraft.wingArea .* f.cd;
end
