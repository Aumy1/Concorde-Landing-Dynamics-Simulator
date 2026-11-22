function fig = landing_app()
%LANDING_APP Optional parameter panel using base MATLAB UI components.
% The same tested model powers both this UI and the command-line functions.
root = fileparts(mfilename('fullpath')); addpath(root);
p = landing.defaultConfig();
fig = uifigure('Name','Concorde | Landing Dynamics','Position',[80 80 1120 740]);
if isprop(fig,'Theme'), fig.Theme = 'light'; end
g = uigridlayout(fig,[7 4]);
g.RowHeight = {36,28,28,28,40,'1x',80};
g.ColumnWidth = {170,120,'1x','1x'};
label = uilabel(g,'Text','CONCORDE / LANDING DYNAMICS','FontSize',21,'FontWeight','bold');
label.Layout.Row = 1; label.Layout.Column = [1 4];
uilabel(g,'Text','Landing mass (kg)'); mass = uieditfield(g,'numeric','Value',p.aircraft.mass,'Limits',[80000 120000]);
uilabel(g,'Text','Tailwind + / headwind - (m/s)'); wind = uieditfield(g,'numeric','Value',0,'Limits',[-15 15]);
uilabel(g,'Text','Wheel brake coefficient'); mu = uieditfield(g,'numeric','Value',.30,'Limits',[0 .6]);
uilabel(g,'Text','Flare height (m)'); flare = uieditfield(g,'numeric','Value',12,'Limits',[1 14.9]);
uilabel(g,'Text','Reverse force (kN)'); reverse = uieditfield(g,'numeric','Value',85,'Limits',[0 200]);
uilabel(g,'Text','Runway length (m)'); runway = uieditfield(g,'numeric','Value',3000,'Limits',[500 6000]);
button = uibutton(g,'Text','Run landing','ButtonPushedFcn',@runLanding);
button.Layout.Row = 5; button.Layout.Column = [1 2];
exportButton = uibutton(g,'Text','Export current run','Enable','off','ButtonPushedFcn',@exportRun);
exportButton.Layout.Row = 5; exportButton.Layout.Column = [3 4];
ax1 = uiaxes(g); ax1.Layout.Row = 6; ax1.Layout.Column = [1 2];
ax2 = uiaxes(g); ax2.Layout.Row = 6; ax2.Layout.Column = [3 4];
status = uitextarea(g,'Editable','off','Value', ...
    {'Simplified civilian landing model. Adjust parameters, then run.'; ...
    'Estimated force coefficients; see docs/MODEL.md and docs/PARAMETERS.md.'});
status.Layout.Row = 7; status.Layout.Column = [1 4];
current = [];

    function runLanding(~,~)
        button.Enable = 'off'; exportButton.Enable = 'off'; drawnow;
        cleanup = onCleanup(@() set(button,'Enable','on'));
        try
            cfg = p; cfg.aircraft.mass = mass.Value; cfg.environment.wind = wind.Value;
            cfg.ground.brakeMu = mu.Value; cfg.flare.height = flare.Value;
            cfg.ground.reverseForce = reverse.Value*1000; cfg.runway.length = runway.Value;
            current = landing.simulate(cfg);
            plot(ax1,current.history.x_m,current.history.height_m,'LineWidth',2);
            xlabel(ax1,'Runway coordinate (m)'); ylabel(ax1,'Height (m)'); grid(ax1,'on'); title(ax1,'Approach and flare');
            plot(ax2,current.ground.state(:,1)-current.metrics.touchdownX_m, ...
                current.ground.state(:,2),'LineWidth',2);
            xlabel(ax2,'Distance after touchdown (m)'); ylabel(ax2,'Ground speed (m/s)'); grid(ax2,'on'); title(ax2,'Ground roll');
            m = current.metrics;
            status.Value = {sprintf('Touchdown %.1f kt | sink %.2f m/s | ground roll %.0f m', ...
                m.touchdownAirspeed_kt,m.touchdownSinkRate_mps,m.groundRoll_m); ...
                sprintf('Stop x %.0f m | runway remaining %.0f m | within runway: %s', ...
                m.stopX_m,m.runwayRemaining_m,mat2str(m.stoppedWithinRunway)); ...
                sprintf('Control saturation: %s',mat2str(m.anyControlSaturation))};
            exportButton.Enable = 'on';
        catch err
            current = []; status.Value = {err.identifier;err.message};
        end
    end

    function exportRun(~,~)
        folder = fullfile(root,'results','interactive');
        landing.exportResults(current,folder);
        status.Value = [status.Value;{['Saved CSV, JSON and MAT files: ' folder]}];
    end
end
