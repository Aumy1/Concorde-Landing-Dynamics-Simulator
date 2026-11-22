function figs = plotResults(r, visibility)
%PLOTRESULTS Performance and force plots with SI axes and phase annotations.
if nargin < 2, visibility = 'on'; end
h = r.history; td = r.events.touchdownTime; fl = r.events.flareTime;
blue = [0.10 0.33 0.58]; teal = [0.00 0.50 0.48]; orange = [0.85 0.37 0.12];
figs(1) = figure('Name','Concorde | Landing performance','Color','w', ...
    'Position',[80 80 1300 840],'Visible',visibility);
layout = tiledlayout(figs(1),2,3,'Padding','compact','TileSpacing','compact');
title(layout,'CONCORDE / LANDING DYNAMICS', 'FontSize',20,'FontWeight','bold');
subtitle(layout,sprintf('Educational point-mass model | %.0f kg | wind %+.1f m/s | brake coefficient %.2f', ...
    r.config.aircraft.mass,r.config.environment.wind,r.config.ground.brakeMu));
ax = nexttile(layout); plot(ax,h.x_m,h.height_m,'Color',blue,'LineWidth',2);
hold(ax,'on'); plot(ax,r.metrics.touchdownX_m,0,'o','Color',orange,'MarkerFaceColor',orange);
xline(ax,0,':','Threshold'); xlabel(ax,'Runway coordinate x (m)'); ylabel(ax,'Height (m)');
title(ax,'Approach and flare'); grid(ax,'on');
ax = nexttile(layout); plot(ax,h.time_s,h.airspeed_mps,'Color',blue,'LineWidth',2);
hold(ax,'on'); plot(ax,h.time_s,h.groundspeed_mps,'--','Color',teal,'LineWidth',1.5);
xlabel(ax,'Time (s)'); ylabel(ax,'Speed (m/s)'); title(ax,'Air and ground speed');
legend(ax,{'True airspeed','Ground speed'},'Location','southwest'); markPhases(ax,fl,td);
ax = nexttile(layout); plot(ax,h.time_s,h.verticalSpeed_mps,'Color',blue,'LineWidth',2);
xlabel(ax,'Time (s)'); ylabel(ax,'Vertical speed (m/s, up +)'); title(ax,'Flare sink-rate reduction'); markPhases(ax,fl,td);
ax = nexttile(layout); plot(ax,r.ground.state(:,1)-r.metrics.touchdownX_m, ...
    r.ground.state(:,2),'Color',teal,'LineWidth',2);
xlabel(ax,'Distance after touchdown (m)'); ylabel(ax,'Ground speed (m/s)');
title(ax,sprintf('Ground roll / %.0f m',r.metrics.groundRoll_m)); grid(ax,'on');
ax = nexttile(layout); idx = h.time_s > td;
plot(ax,h.time_s(idx)-td,-h.acceleration_mps2(idx),'Color',orange,'LineWidth',2);
xlabel(ax,'Time after touchdown (s)'); ylabel(ax,'Deceleration (m/s^2)');
title(ax,'Braking and reverse deployment'); grid(ax,'on');
ax = nexttile(layout); hold(ax,'on');
plot(ax,[0 r.config.runway.length],[0 0],'Color',[.25 .3 .35],'LineWidth',12);
plot(ax,[0 r.metrics.touchdownX_m],[0 0],'Color',blue,'LineWidth',7);
plot(ax,[r.metrics.touchdownX_m r.metrics.stopX_m],[0 0],'Color',teal,'LineWidth',7);
plot(ax,r.metrics.stopX_m,0,'o','MarkerFaceColor',orange,'MarkerEdgeColor',orange);
xlim(ax,[min(-100,r.metrics.touchdownX_m-50) max(r.config.runway.length,r.metrics.stopX_m)+100]);
ylim(ax,[-1 1]); yticks(ax,[]); xlabel(ax,'Distance from runway threshold (m)');
title(ax,sprintf('Stop x = %.0f m / remaining %.0f m',r.metrics.stopX_m,r.metrics.runwayRemaining_m));
grid(ax,'on');
figs(2) = figure('Name','Concorde | Forces and control','Color','w', ...
    'Position',[100 100 1200 680],'Visible',visibility);
layout = tiledlayout(figs(2),2,2,'Padding','compact','TileSpacing','compact');
title(layout,'FORCE BALANCE / CONTROL AUTHORITY','FontSize',18);
ax = nexttile(layout); plot(ax,h.time_s,[h.lift_N h.normal_N]/1000,'LineWidth',1.7);
hold(ax,'on'); yline(ax,r.config.aircraft.mass*r.config.environment.g/1000,':','Weight');
xlabel(ax,'Time (s)'); ylabel(ax,'Force (kN)'); title(ax,'Lift unloading and runway reaction');
legend(ax,{'Lift','Normal reaction'},'Location','best'); markPhases(ax,fl,td);
ax = nexttile(layout); plot(ax,h.time_s,[h.thrust_N h.drag_N]/1000,'LineWidth',1.7);
xlabel(ax,'Time (s)'); ylabel(ax,'Force (kN)'); title(ax,'Flight-path thrust and drag');
legend(ax,{'Forward thrust','Drag'},'Location','best'); markPhases(ax,fl,td);
ax = nexttile(layout); plot(ax,h.time_s(idx)-td, ...
    [h.brake_N(idx) h.reverse_N(idx) h.drag_N(idx) h.rolling_N(idx)]/1000,'LineWidth',1.7);
xlabel(ax,'Time after touchdown (s)'); ylabel(ax,'Retarding force (kN)'); title(ax,'Ground force components');
legend(ax,{'Wheel brake','Reverse','Drag','Rolling'},'Location','best'); grid(ax,'on');
ax = nexttile(layout); plot(ax,h.time_s,h.cl,'Color',blue,'LineWidth',1.7);
hold(ax,'on'); yline(ax,r.config.aircraft.clMax,':','CL limit');
xlabel(ax,'Time (s)'); ylabel(ax,'Lift coefficient'); title(ax,'Ideal control output'); markPhases(ax,fl,td);
for i = 1:numel(figs), landing.styleFigure(figs(i)); end
end

function markPhases(ax, flareTime, touchdownTime)
xline(ax,flareTime,':','Flare','HandleVisibility','off');
xline(ax,touchdownTime,'--','Touchdown','HandleVisibility','off'); grid(ax,'on');
end
