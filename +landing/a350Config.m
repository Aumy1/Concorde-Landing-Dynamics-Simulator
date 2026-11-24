function p = a350Config()
%A350CONFIG Illustrative civilian A350 approach, not certified performance.
p = landing.defaultConfig();
p.aircraft.mass = 190000;
p.aircraft.wingArea = 443;
p.aircraft.cd0 = .055;
p.aircraft.inducedDrag = .075;
p.aircraft.clMax = 2.5;
p.aircraft.maxThrust = 420000;
p.approach.speed = 75;
p.flare.speed = 72;
p.ground.reverseForce = 110000;
p.visual.aircraft = 'A350';
p.visual.alpha = 6;
end
