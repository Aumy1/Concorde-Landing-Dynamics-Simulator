function exportResults(r, folder)
%EXPORTRESULTS Portable CSV/JSON plus full MATLAB data for reproducibility.
if ~isfolder(folder), mkdir(folder); end
writetable(r.history,fullfile(folder,'telemetry.csv'));
writetable(struct2table(r.metrics),fullfile(folder,'metrics.csv'));
writeJson(fullfile(folder,'config.json'),r.config);
writeJson(fullfile(folder,'metrics.json'),r.metrics);
event = ["flare";"touchdown";"stop"];
time_s = [r.events.flareTime;r.events.touchdownTime;r.events.stopTime];
fi = find(r.air.time >= r.events.flareTime,1);
x_m = [r.air.state(fi,1);r.metrics.touchdownX_m;r.metrics.stopX_m];
writetable(table(event,time_s,x_m),fullfile(folder,'events.csv'));
result = r; %#ok<NASGU>
save(fullfile(folder,'result.mat'),'result');
end

function writeJson(path, value)
fid = fopen(path,'w'); assert(fid >= 0,'landing:FileWrite','Cannot write %s.',path);
cleanup = onCleanup(@() fclose(fid));
fprintf(fid,'%s\n',jsonencode(value,'PrettyPrint',true));
end
