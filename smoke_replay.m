function smoke_replay(previewFile)
%SMOKE_REPLAY Desktop graphics check for camera selection and playback.
r = landing.simulate();
f = landing_replay(r);
player = getappdata(f,'ReplayTimer');
cleanup = onCleanup(@() close(f));
frame = getappdata(f,'ReplayRender');
ax = getappdata(f,'ReplayAxes');
hud = findobj(f,'Tag','FlightReadout');
td = r.events.touchdownTime;
assert(strcmp(landing.replaySample(r,0).phase,'APPROACH'));
assert(strcmp(landing.replaySample(r,td-0.01).phase,'FLARE'));
assert(strcmp(landing.replaySample(r,td).phase,'TOUCHDOWN'));
assert(strcmp(landing.replaySample(r,td+2).phase,'GROUND ROLL'));
assert(strcmp(landing.replaySample(r,r.events.stopTime).phase,'STOPPED'));
assert(landing.replaySample(r,td-0.01).verticalSpeed < 0);
assert(landing.replaySample(r,td).verticalSpeed == 0);
positions = zeros(9,3);
for c = 1:9
    frame(td,c); drawnow;
    assert(all(isfinite(ax.CameraPosition)) && contains(hud.String,'TOUCHDOWN'));
    positions(c,:) = ax.CameraPosition;
end
assert(size(unique(positions([1:7 9],:),'rows'),1)==8,'Manual cameras must be distinct.');
assert(isequal(positions(8,:),positions(7,:)),'Director should show runway edge at contact.');
frame(r.events.flareTime,9); drawnow;
assert(ax.CameraPosition(3)>0 && ax.CameraPosition(3)<ax.CameraTarget(3), ...
    'Low approach must look up toward the aircraft without dipping below the runway.');
frame(r.events.stopTime,1);
play = findobj(f,'Style','pushbutton','String','Play');
feval(play.Callback,play,[]); pause(.35);
assert(strcmp(player.Running,'on') && ~contains(hud.String,'STOPPED'));
feval(play.Callback,play,[]);
assert(strcmp(player.Running,'off'));
frame(td-.45,4); drawnow;
if nargin == 1
    capture = getframe(f);
    imwrite(capture.cdata,previewFile);
end
clear cleanup
assert(~isvalid(player),'Closing the viewer must release its playback timer.');
disp('Replay smoke check passed: phase transitions, nine modes, play/pause, timer cleanup.');
end
