function summary = run_scenarios(outputFolder, showFigures)
%RUN_SCENARIOS Controlled one-at-a-time sensitivity study, no random inputs.
root = fileparts(mfilename('fullpath')); addpath(root);
if nargin < 1, outputFolder = fullfile(root,'results','scenarios'); end
if nargin < 2, showFigures = true; end
if ~isfolder(outputFolder), mkdir(outputFolder); end
names = ["Baseline";"Lower friction";"Headwind 8 m/s";"Tailwind 8 m/s";"Mass 110 t";"No reverse"];
base = landing.defaultConfig(); configs = repmat({base},numel(names),1);
configs{2}.ground.brakeMu = 0.15;
configs{3}.environment.wind = -8; configs{4}.environment.wind = 8;
configs{5}.aircraft.mass = 110000; configs{6}.ground.reverseForce = 0;
runs = cell(numel(names),1); rows = cell(numel(names),1);
for i = 1:numel(names)
    runs{i} = landing.simulate(configs{i});
    rows{i} = struct2table(runs{i}.metrics);
end
summary = [table(names,'VariableNames',{'Scenario'}),vertcat(rows{:})];
writetable(summary,fullfile(outputFolder,'comparison.csv'));
if showFigures, visibility = 'on'; else, visibility = 'off'; end
f = figure('Name','Concorde | Sensitivity study','Color','w', ...
    'Position',[100 100 1300 600],'Visible',visibility);
layout = tiledlayout(f,1,2,'Padding','compact','TileSpacing','compact');
title(layout,'SCENARIO STUDY / ONE PARAMETER CHANGED AT A TIME','FontSize',17);
ax = nexttile(layout); barh(ax,categorical(names,flipud(names)),summary.groundRoll_m, ...
    'FaceColor',[.05 .48 .48]); xlabel(ax,'Ground roll after touchdown (m)');
title(ax,'Friction, wind, mass and reverse'); grid(ax,'on');
ax = nexttile(layout); hold(ax,'on');
for i = 1:numel(names)
    plot(ax,runs{i}.ground.state(:,1)-runs{i}.metrics.touchdownX_m, ...
        runs{i}.ground.state(:,2),'LineWidth',1.7,'DisplayName',names(i));
end
xlabel(ax,'Distance after touchdown (m)'); ylabel(ax,'Ground speed (m/s)');
title(ax,'Stopping trajectories'); legend(ax,'Location','northeast'); grid(ax,'on');
landing.styleFigure(f);
exportgraphics(f,fullfile(outputFolder,'comparison.png'),'Resolution',160);
if ~showFigures, close(f); end
save(fullfile(outputFolder,'scenarios.mat'),'runs','summary');
disp(summary(:,{'Scenario','touchdownSinkRate_mps','groundRoll_m','stopX_m'}));
end
