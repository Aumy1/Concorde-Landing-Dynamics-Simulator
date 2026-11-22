function s = replaySample(r,t)
%REPLAYSAMPLE Interpolate physical states; pitch is visual-only.
s.time = max(0,min(t,r.events.stopTime));
td = r.events.touchdownTime;
if s.time < td
    a = interp1(r.air.time,r.air.state,s.time,'pchip');
    s.x = a(1); s.height = max(0,a(2)); s.airSpeed = a(3);
    s.groundSpeed = a(3)*cos(a(4))+r.config.environment.wind;
    s.verticalSpeed = a(3)*sin(a(4));
    % Add a nominal display angle of attack to simulated flight-path angle.
    s.pitch = deg2rad(10)+a(4);
    s.phase = 'APPROACH';
    if s.time >= r.events.flareTime, s.phase = 'FLARE'; end
else
    g = interp1(r.ground.time,r.ground.state,s.time,'pchip');
    s.x = g(1); s.height = 0; s.groundSpeed = max(0,g(2));
    s.airSpeed = max(0,s.groundSpeed-r.config.environment.wind);
    s.verticalSpeed = 0;
    tau = s.time-td;
    s.pitch = (deg2rad(10)+r.events.touchdownState(4))*max(0,1-tau/4)^2;
    if tau < .45, s.phase = 'TOUCHDOWN'; else, s.phase = 'GROUND ROLL'; end
    if s.time >= r.events.stopTime, s.phase = 'STOPPED'; end
end
end
