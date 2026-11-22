function tests = testLanding
%TESTLANDING Analytical checks, hybrid transitions and behavioral regressions.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testCase.TestData.p = landing.defaultConfig();
testCase.TestData.r = landing.simulate(testCase.TestData.p);
end

function testLiftDragAgainstHandCalculation(tc)
p = tc.TestData.p; f = landing.aero(80,0.8,p);
qS = 0.5*1.225*80^2*358.25;
verifyEqual(tc,f.lift,qS*0.8,'RelTol',1e-13);
verifyEqual(tc,f.drag,qS*(0.045+0.18*0.8^2),'RelTol',1e-13);
verifyEqual(tc,landing.aero(0,1,p).lift,0);
end

function testSteadyApproachForceBalance(tc)
p = tc.TestData.p;
y = [0;100;p.approach.speed;-p.approach.glideAngle];
[dy,f] = landing.airborneRhs(0,y,p,'approach');
verifyEqual(tc,dy(3:4),[0;0],'AbsTol',1e-12);
verifyEqual(tc,f.lift,p.aircraft.mass*p.environment.g*cos(y(4)),'RelTol',1e-12);
verifyFalse(tc,f.saturated);
end

function testWindOnlyChangesHorizontalKinematics(tc)
p = tc.TestData.p; y = [0;100;86;-deg2rad(3)];
dy0 = landing.airborneRhs(0,y,p,'approach'); p.environment.wind = 8;
dy1 = landing.airborneRhs(0,y,p,'approach');
verifyEqual(tc,dy1-dy0,[8;0;0;0],'AbsTol',1e-12);
end

function testAnalyticalConstantDecelerationStop(tc)
% Isolated limiting case: aero/reverse disabled, brakes fully deployed.
% Deliberately bypass scenario validation to test a physics building block.
p = tc.TestData.p; p.environment.rho = 0; p.ground.reverseForce = 0;
p.ground.residualCL = 0; p.ground.brakeDelay = 0;
u0 = 80; a = (p.ground.brakeMu+p.ground.rollingMu)*p.environment.g;
opts = odeset('RelTol',1e-10,'AbsTol',1e-11,'MaxStep',.1,'Events',@stopEvent);
[~,~,t,y] = ode45(@(t,y) landing.groundRhs(t+100,y,p,0),[0 100],[0;u0],opts);
verifyEqual(tc,t,u0/a,'AbsTol',1e-7);
verifyEqual(tc,y(1),u0^2/(2*a),'AbsTol',1e-5);
end

function testOrderedExactEvents(tc)
r = tc.TestData.r;
verifyGreaterThan(tc,r.events.flareTime,0);
verifyGreaterThan(tc,r.events.touchdownTime,r.events.flareTime);
verifyGreaterThan(tc,r.events.stopTime,r.events.touchdownTime);
i = find(r.air.time >= r.events.flareTime,1);
verifyEqual(tc,r.air.state(i,2),r.config.flare.height,'AbsTol',1e-7);
verifyEqual(tc,r.air.state(end,2),0,'AbsTol',1e-9);
verifyEqual(tc,r.ground.state(end,2),0,'AbsTol',1e-9);
verifyGreaterThan(tc,min(diff(r.history.time_s)),0);
end

function testTouchdownResetPreservesHorizontalVelocity(tc)
r = tc.TestData.r; y = r.events.touchdownState;
verifyEqual(tc,r.ground.state(1,1),y(1),'AbsTol',1e-12);
verifyEqual(tc,r.ground.state(1,2),y(3)*cos(y(4))+r.config.environment.wind,'AbsTol',1e-12);
verifyEqual(tc,r.metrics.verticalContactEnergy_J, ...
    0.5*r.config.aircraft.mass*(y(3)*sin(y(4)))^2,'RelTol',1e-12);
end

function testNoWindAirborneEnergyBalance(tc)
r = tc.TestData.r; p = r.config; t = r.air.time; y = r.air.state;
power = zeros(size(t));
for i = 1:numel(t)
    if t(i) < r.events.flareTime, phase = 'approach'; else, phase = 'flare'; end
    [~,f] = landing.airborneRhs(t(i),y(i,:)',p,phase);
    power(i) = (f.thrust-f.drag)*y(i,3);
end
energy = .5*p.aircraft.mass*y(:,3).^2+p.aircraft.mass*p.environment.g*y(:,2);
verifyLessThan(tc,abs((energy(end)-energy(1))-trapz(t,power))/abs(energy(1)),2e-4);
end

function testGroundWorkEnergyBalance(tc)
r = tc.TestData.r; t = r.ground.elapsed; y = r.ground.state;
power = zeros(size(t));
for i = 1:numel(t)
    [~,f] = landing.groundRhs(t(i),y(i,:)',r.config,r.events.touchdownCL);
    power(i) = (f.drag+f.brake+f.reverse+f.rolling)*y(i,2);
end
initialKE = .5*r.config.aircraft.mass*y(1,2)^2;
verifyLessThan(tc,abs(trapz(t,power)-initialKE)/initialKE,2e-4);
end

function testBaselinePhysicalInvariants(tc)
r = tc.TestData.r; h = r.history;
verifyTrue(tc,all(isfinite(h{:,1:16}),'all'));
verifyGreaterThanOrEqual(tc,min(h.height_m),-1e-8);
verifyGreaterThanOrEqual(tc,min(h.groundspeed_mps),-1e-8);
verifyGreaterThan(tc,min(diff(h.x_m)),0);
verifyLessThanOrEqual(tc,max(diff(r.ground.state(:,2))),1e-8);
verifyGreaterThanOrEqual(tc,min(h.normal_N),0);
verifyGreaterThanOrEqual(tc,min(h.cl),0);
verifyLessThanOrEqual(tc,max(h.cl),r.config.aircraft.clMax);
verifyFalse(tc,r.metrics.anyControlSaturation);
verifyTrue(tc,r.metrics.stoppedWithinRunway);
% Broad plausibility checks are not a flight-data validation.
verifyGreaterThan(tc,r.metrics.touchdownSinkRate_mps,0.2);
verifyLessThan(tc,r.metrics.touchdownSinkRate_mps,2);
verifyGreaterThan(tc,r.metrics.groundRoll_m,500);
verifyLessThan(tc,r.metrics.groundRoll_m,2500);
end

function testReducedFrictionIncreasesGroundRoll(tc)
p = tc.TestData.p; p.ground.brakeMu = .15; r = landing.simulate(p);
verifyGreaterThan(tc,r.metrics.groundRoll_m,tc.TestData.r.metrics.groundRoll_m*1.2);
end

function testTailwindAndHeadwindTrend(tc)
p = tc.TestData.p; p.environment.wind = 8; tail = landing.simulate(p);
p.environment.wind = -8; head = landing.simulate(p);
verifyGreaterThan(tc,tail.metrics.groundRoll_m,tc.TestData.r.metrics.groundRoll_m);
verifyLessThan(tc,head.metrics.groundRoll_m,tc.TestData.r.metrics.groundRoll_m);
verifyEqual(tc,tail.metrics.touchdownAirspeed_mps,head.metrics.touchdownAirspeed_mps,'AbsTol',1e-7);
end

function testRemovingReverseIncreasesGroundRoll(tc)
p = tc.TestData.p; p.ground.reverseForce = 0; r = landing.simulate(p);
verifyGreaterThan(tc,r.metrics.groundRoll_m,tc.TestData.r.metrics.groundRoll_m);
end

function testShortRunwayIsReported(tc)
p = tc.TestData.p; p.runway.length = 500; r = landing.simulate(p);
verifyFalse(tc,r.metrics.stoppedWithinRunway);
verifyLessThan(tc,r.metrics.runwayRemaining_m,0);
end

function testSolverConvergence(tc)
p = tc.TestData.p; p.solver.maxStep = .05;
p.solver.relativeTolerance = 1e-10; p.solver.absoluteTolerance = 1e-11;
r = landing.simulate(p); b = tc.TestData.r;
verifyEqual(tc,r.metrics.touchdownTime_s,b.metrics.touchdownTime_s,'AbsTol',.002);
verifyEqual(tc,r.metrics.touchdownSinkRate_mps,b.metrics.touchdownSinkRate_mps,'AbsTol',.002);
verifyEqual(tc,r.metrics.groundRoll_m,b.metrics.groundRoll_m,'AbsTol',.1);
end

function testDeterministicRepeat(tc)
r = landing.simulate(tc.TestData.p);
verifyEqual(tc,r.metrics,tc.TestData.r.metrics);
verifyEqual(tc,r.air.state,tc.TestData.r.air.state);
end

function testInvalidInputs(tc)
p = tc.TestData.p; p.aircraft.mass = -1;
verifyError(tc,@() landing.simulate(p),'landing:InvalidConfig');
p = tc.TestData.p; p.environment.wind = NaN;
verifyError(tc,@() landing.simulate(p),'landing:InvalidConfig');
p = tc.TestData.p; p.ground.brakeRamp = 0;
verifyError(tc,@() landing.simulate(p),'landing:InvalidConfig');
p = tc.TestData.p; p.flare.height = 20;
verifyError(tc,@() landing.simulate(p),'landing:InvalidConfig');
p = tc.TestData.p; p.aircraft.mass = [105000 110000];
verifyError(tc,@() landing.simulate(p),'landing:InvalidConfig');
p = tc.TestData.p; p.ground.brakeMU = .2;
verifyError(tc,@() landing.simulate(p),'landing:InvalidConfig');
p = rmfield(tc.TestData.p,'flare');
verifyError(tc,@() landing.simulate(p),'landing:InvalidConfig');
end

function testAirTimeoutCannotReportSuccess(tc)
p = tc.TestData.p; p.solver.maxAirTime = 1;
verifyError(tc,@() landing.simulate(p),'landing:NoTouchdown');
end

function testGroundTimeoutCannotReportSuccess(tc)
p = tc.TestData.p; p.solver.maxGroundTime = 1;
verifyError(tc,@() landing.simulate(p),'landing:NoStop');
end

function testControlAuthorityIsLimited(tc)
p = tc.TestData.p; p.aircraft.clMax = .2;
[~,f] = landing.airborneRhs(0,[0;100;86;-deg2rad(3)],p,'approach');
verifyEqual(tc,f.cl,.2); verifyTrue(tc,f.saturated);
p = tc.TestData.p; p.aircraft.maxThrust = 10;
[~,f] = landing.airborneRhs(0,[0;100;86;-deg2rad(3)],p,'approach');
verifyEqual(tc,f.thrust,10); verifyTrue(tc,f.saturated);
end

function testReverseAndBrakesCannotActBeforeDelay(tc)
p = tc.TestData.p;
[~,f] = landing.groundRhs(0,[0;80],p,.8);
verifyEqual(tc,f.brake,0); verifyEqual(tc,f.reverse,0);
[~,f] = landing.groundRhs(10,[0;0],p,.8);
verifyEqual(tc,f.reverse,0);
end

function testExportRoundTrip(tc)
folder = tempname; mkdir(folder); cleanup = onCleanup(@() rmdir(folder,'s'));
r = tc.TestData.r; landing.exportResults(r,folder);
h = readtable(fullfile(folder,'telemetry.csv'));
verifyEqual(tc,height(h),height(r.history));
m = jsondecode(fileread(fullfile(folder,'metrics.json')));
verifyEqual(tc,m.groundRoll_m,r.metrics.groundRoll_m,'RelTol',1e-12);
s = load(fullfile(folder,'result.mat'));
verifyEqual(tc,s.result.metrics,r.metrics);
events = readtable(fullfile(folder,'events.csv'));
verifyEqual(tc,height(events),3);
end

function [value,terminal,direction] = stopEvent(~,y)
value = y(2); terminal = 1; direction = -1;
end
