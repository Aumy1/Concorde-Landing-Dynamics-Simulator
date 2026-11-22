function result = run_demo(outputFolder, showFigures)
%RUN_DEMO Run the baseline and save performance plots, telemetry and metrics.
% From the repository root: result = run_demo;
% Batch/export use: result = run_demo('results/baseline',false);
root = fileparts(mfilename('fullpath')); addpath(root);
if nargin < 1, outputFolder = fullfile(root,'results','baseline'); end
if nargin < 2, showFigures = true; end
result = landing.simulate(landing.defaultConfig());
landing.exportResults(result,outputFolder);
if showFigures, visibility = 'on'; else, visibility = 'off'; end
figs = landing.plotResults(result,visibility);
exportgraphics(figs(1),fullfile(outputFolder,'performance.png'),'Resolution',160);
exportgraphics(figs(2),fullfile(outputFolder,'forces.png'),'Resolution',160);
if ~showFigures, close(figs); end
disp(struct2table(result.metrics));
fprintf('Saved simulation outputs to %s\n',outputFolder);
end
