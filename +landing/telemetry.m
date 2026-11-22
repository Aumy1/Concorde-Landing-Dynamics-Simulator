function h = telemetry(r)
%TELEMETRY Derived SI signals; the touchdown row retains pre-impact values.
% Ground history starts AFTER that row; exact post-reset state is in r.ground.
p = r.config; na = numel(r.air.time); ng = numel(r.ground.time)-1;
n = na+ng; time_s = [r.air.time; r.ground.time(2:end)];
x_m = [r.air.state(:,1); r.ground.state(2:end,1)];
height_m = [r.air.state(:,2); zeros(ng,1)];
airspeed_mps = zeros(n,1); groundspeed_mps = zeros(n,1);
verticalSpeed_mps = zeros(n,1); gamma_rad = zeros(n,1);
lift_N = zeros(n,1); drag_N = zeros(n,1); thrust_N = zeros(n,1);
brake_N = zeros(n,1); reverse_N = zeros(n,1); rolling_N = zeros(n,1);
normal_N = zeros(n,1); cl = zeros(n,1); acceleration_mps2 = zeros(n,1);
saturated = false(n,1); phase = strings(n,1);
for i = 1:n
    if i <= na
        y = r.air.state(i,:)';
        if time_s(i) < r.events.flareTime
            label = 'approach';
        else
            label = 'flare';
        end
        [dy,f] = landing.airborneRhs(time_s(i),y,p,label);
        phase(i) = label; airspeed_mps(i) = y(3);
        groundspeed_mps(i) = y(3)*cos(y(4))+p.environment.wind;
        verticalSpeed_mps(i) = dy(2); gamma_rad(i) = y(4);
        thrust_N(i) = f.thrust; saturated(i) = f.saturated;
        % In steady horizontal wind d(V cos gamma)/dt = ...
        acceleration_mps2(i) = dy(3)*cos(y(4))-y(3)*sin(y(4))*dy(4);
    else
        j = i-na+1; y = r.ground.state(j,:)';
        [dy,f] = landing.groundRhs(r.ground.elapsed(j),y,p,r.events.touchdownCL);
        phase(i) = "ground roll";
        groundspeed_mps(i) = y(2);
        airspeed_mps(i) = max(y(2)-p.environment.wind,0);
        brake_N(i) = f.brake; reverse_N(i) = f.reverse;
        rolling_N(i) = f.rolling; normal_N(i) = f.normal;
        acceleration_mps2(i) = dy(2);
    end
    lift_N(i) = f.lift; drag_N(i) = f.drag; cl(i) = f.cl;
end
phase(na) = "touchdown"; phase(end) = "stopped";
h = table(time_s,x_m,height_m,airspeed_mps,groundspeed_mps, ...
    verticalSpeed_mps,gamma_rad,lift_N,drag_N,thrust_N,brake_N,reverse_N, ...
    rolling_N,normal_N,cl,acceleration_mps2,saturated,phase);
end
