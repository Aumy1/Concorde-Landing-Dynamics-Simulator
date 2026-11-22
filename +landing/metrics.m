function m = metrics(r)
%METRICS Distinguish threshold distance, ground roll, and total trajectory.
p = r.config; td = r.events.touchdownState;
m.touchdownTime_s = r.events.touchdownTime;
m.touchdownAirspeed_mps = td(3);
m.touchdownAirspeed_kt = td(3)/0.514444444444444;
m.touchdownGroundspeed_mps = r.ground.state(1,2);
m.touchdownSinkRate_mps = -td(3)*sin(td(4));
m.touchdownX_m = td(1);
m.groundRoll_m = r.ground.state(end,1)-td(1);
m.stopX_m = r.ground.state(end,1);
m.runwayRemaining_m = p.runway.length-m.stopX_m;
m.stoppedWithinRunway = td(1) >= 0 && m.stopX_m <= p.runway.length;
m.groundRollTime_s = r.events.stopTime-r.events.touchdownTime;
m.peakGroundDeceleration_mps2 = max(-r.history.acceleration_mps2( ...
    r.history.time_s > r.events.touchdownTime));
% Vertical contact energy removed by the inelastic reset, not a gear load.
m.verticalContactEnergy_J = 0.5*p.aircraft.mass*m.touchdownSinkRate_mps^2;
m.anyControlSaturation = any(r.history.saturated);
end
