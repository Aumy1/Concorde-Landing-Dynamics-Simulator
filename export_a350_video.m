function export_a350_video()
%EXPORT_A350_VIDEO Record a cinematic replay of the simulated landing.
r = landing.simulate(landing.a350Config());
f = landing_replay(r,'sunset');
render = getappdata(f,'ReplayRender');
set(f,'Position',[80 80 960 600]);
out = fullfile(fileparts(mfilename('fullpath')),'A350-Landing.mp4');
w = VideoWriter(out,'MPEG-4');
w.FrameRate = 24;
w.Quality = 90;
open(w);
cleanup = onCleanup(@() close(w));
times = linspace(max(0,r.events.flareTime-8),r.events.stopTime,24*24);
for t = times
    render(t,8);
    drawnow;
    writeVideo(w,getframe(f));
end
clear cleanup;
disp(['Video saved: ' out]);
end
