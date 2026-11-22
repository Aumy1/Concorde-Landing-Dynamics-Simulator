function fig = landing_replay(result)
%LANDING_REPLAY Interactive 3D replay of the MATLAB civilian landing model.
% landing_replay() uses the baseline; landing_replay(result) replays a run.
% Space = pause/play; arrows = seek; 1–9 select cameras; C cycles them.
if nargin < 1 || isempty(result), result = landing.simulate(); end
r = result; finish = r.events.stopTime;
ink = [.065 .095 .13]; pale = [.87 .93 .96]; gold = [.99 .77 .38];
fig = figure('Name','Concorde | 3D Landing Replay','NumberTitle','off', ...
    'MenuBar','none','ToolBar','none','Color',ink,'Position',[70 70 1240 760], ...
    'Resize','on','Tag','ConcordeReplay');
scene = uipanel('Parent',fig,'Units','normalized','Position',[0 .18 1 .74], ...
    'BorderType','none','BackgroundColor',[.58 .72 .81]);
ax = axes('Parent',scene,'Position',[0 0 1 1],'Color','none', ...
    'XColor','none','YColor','none','ZColor','none','Box','off', ...
    'DataAspectRatio',[1 1 1],'Projection','perspective');
hold(ax,'on'); view(ax,3); disableDefaultInteractivity(ax);
ax.Toolbar.Visible = 'off';
L = r.config.runway.length;
shadow = landing.airfieldScene(ax,L,r.air.state(1,1),r.metrics.stopX_m);
asset = fullfile(fileparts(mfilename('fullpath')),'local-assets','concorde-cad.bin');
if isfile(asset)
    model = landing.cadAircraftMesh(ax,asset);
else
    model = landing.aircraftMesh(ax);
    model.isCAD = false;
    model.cockpit = [21 0 5.8];
end
setappdata(fig,'ReplayUsesCAD',model.isCAD);
xlim(ax,[r.air.state(1,1)-4000 max(L,r.metrics.stopX_m)+4300]);
ylim(ax,[-3500 3500]); zlim(ax,[-1 max(320,r.config.approach.initialHeight+40)]);
light(ax,'Style','infinite','Position',[-.7 -.9 1],'Color',[1 .96 .88]);
light(ax,'Style','infinite','Position',[.1 1 .4],'Color',[.44 .50 .60]);
uicontrol(fig,'Style','text','Units','normalized', ...
    'Position',[.024 .93 .65 .049],'String','CONCORDE  /  LANDING REPLAY', ...
    'ForegroundColor',pale,'BackgroundColor',ink,'HorizontalAlignment','left', ...
    'FontWeight','bold','FontSize',18);
uicontrol(fig,'Style','text','Units','normalized','Position',[.68 .938 .29 .033], ...
    'String','BRITISH AIRWAYS  /  LANDOR LIVERY','ForegroundColor',gold, ...
    'BackgroundColor',ink,'HorizontalAlignment','right','FontSize',10);
hud = uicontrol(fig,'Style','text','Units','normalized','Position',[.024 .118 .95 .047], ...
    'ForegroundColor',pale,'BackgroundColor',ink,'FontName','Menlo', ...
    'HorizontalAlignment','left','FontSize',12,'Tag','FlightReadout');
btn = control('pushbutton',[.024 .061 .092 .045],'Play',@toggle);
reset = control('pushbutton',[.121 .061 .072 .045],'Restart',@restart); %#ok<NASGU>
timeline = control('slider',[.207 .067 .489 .033],'',@seek);
set(timeline,'Min',0,'Max',finish,'Value',0,'SliderStep',[min(1,1/finish) min(1,5/finish)]);
names = {'Chase','Cockpit','Tower','Side profile','Nose view','Overhead', ...
    'Runway edge','Director','Low approach'};
cam = control('popupmenu',[.710 .061 .172 .045],names,@refresh);
cam.Tag = 'ReplayCamera';
rate = control('popupmenu',[.892 .061 .083 .045],{'0.5x','1x','2x','4x'},@speedChanged);
rate.Value = 2; rates = [.5 1 2 4];
uicontrol(fig,'Style','text','Units','normalized','Position',[.024 .012 .95 .032], ...
    'String','SPACE  play / pause     LEFT / RIGHT  seek     1–9  camera     C  next view     |     Fictional airfield', ...
    'ForegroundColor',[.62 .71 .78],'BackgroundColor',ink, ...
    'HorizontalAlignment','left','FontSize',10);
clockRef = tic; lastT = 0;
player = timer('ExecutionMode','fixedRate','BusyMode','drop','Period',.05, ...
    'TimerFcn',@tick);
set(fig,'CloseRequestFcn',@closeReplay,'WindowKeyPressFcn',@onKey, ...
    'DeleteFcn',@disposeTimer);
setappdata(fig,'ReplayAxes',ax);
setappdata(fig,'ReplayRender',@render);
setappdata(fig,'ReplayTimer',player);
render(max(0,r.events.flareTime-1),1);

    function h = control(style,pos,str,callback)
        h = uicontrol(fig,'Style',style,'Units','normalized','Position',pos, ...
            'String',str,'Callback',callback,'FontSize',11);
    end

    function render(t,viewIndex)
        if nargin < 2, viewIndex = cam.Value; else, cam.Value = viewIndex; end
        s = landing.replaySample(r,t);
        timeline.Value = s.time;
        % RotY(-pitch) lifts the nose (+x) about the main wheel pivot.
        visualHeight = s.height;
        if model.isCAD
            treadZ = model.contact(:,1)*sin(s.pitch)+model.contact(:,2)*cos(s.pitch);
            visualHeight = visualHeight-min(treadZ);
        end
        model.root.Matrix = makehgtform('translate',[s.x 0 visualHeight], ...
            'yrotate',-s.pitch);
        aa = linspace(0,2*pi,40);
        shadow.XData = s.x+21*cos(aa); shadow.YData = 10*sin(aa);
        shadow.FaceAlpha = .28*exp(-s.height/90);
        activeView = viewIndex;
        if viewIndex == 8
            td = r.events.touchdownTime;
            if s.time < r.events.flareTime-3, activeView = 1;
            elseif s.time < td-1.7, activeView = 5;
            elseif s.time < td+2.0, activeView = 7;
            elseif s.time < td+11, activeView = 4;
            else, activeView = 6;
            end
        end
        up = [0 0 1];
        model.root.Visible = 'on';
        switch activeView
            case 1
                eyePos = [s.x-86 -49 s.height+32];
                target = [s.x+33 0 s.height-6]; fov = 47;
            case 2
                model.root.Visible = 'off';
                eyePos = [s.x+model.cockpit(1) 0 ...
                    visualHeight+model.cockpit(3)+model.cockpit(1)*sin(s.pitch)];
                target = eyePos+[230 0 -22]; fov = 52;
            case 3
                eyePos = [min(max(r.metrics.touchdownX_m+180,200),L) -185 30];
                target = [s.x 0 s.height+4];
                fov = max(5,min(42,rad2deg(2*atan(70/norm(target-eyePos)))));
            case 4
                eyePos = [s.x+9 -91 s.height+17];
                target = [s.x+1 0 s.height+1]; fov = 33;
            case 5
                eyePos = [s.x+92 -30 s.height+16];
                target = [s.x+1 0 s.height+3]; fov = 34;
            case 6
                eyePos = [s.x 0 s.height+132];
                target = [s.x 0 0]; up = [1 0 0]; fov = 37;
            case 7
                eyePos = [r.metrics.touchdownX_m+55 -39 3.0];
                target = [s.x 0 s.height+3];
                fov = max(10,min(62,rad2deg(2*atan(44/norm(target-eyePos)))));
            case 9
                % Low front-quarter view: the belly and deployed gear face
                % the camera on approach; the camera stays above the runway.
                eyePos = [s.x+58 34 max(1.8,s.height-13)];
                target = [s.x+4 0 s.height+4.2]; fov = 39;
        end
        set(ax,'CameraPosition',eyePos,'CameraTarget',target, ...
            'CameraUpVector',up,'CameraViewAngle',fov, ...
            'Projection','perspective');
        hud.String = sprintf('%-12s    TAS %5.0f kt    GS %5.0f kt    HGT %5.0f ft    V/S %+5.0f ft/min    %05.1f / %.1f s', ...
            s.phase,s.airSpeed/0.51444444444,s.groundSpeed/0.51444444444, ...
            s.height/0.3048,s.verticalSpeed*60/0.3048,s.time,finish);
    end

    function tick(~,~)
        t = lastT+toc(clockRef)*rates(rate.Value);
        render(t);
        if t >= finish, pausePlayer(); end
    end
    function pausePlayer()
        if strcmp(player.Running,'on'), stop(player); end
        btn.String = 'Play';
    end
    function toggle(~,~)
        if strcmp(player.Running,'on'), pausePlayer(); return; end
        if timeline.Value >= finish, render(0); end
        lastT = timeline.Value; clockRef = tic;
        btn.String = 'Pause'; start(player);
    end
    function restart(~,~)
        pausePlayer(); render(0);
    end
    function seek(~,~)
        render(timeline.Value); lastT = timeline.Value; clockRef = tic;
    end
    function refresh(~,~)
        render(timeline.Value);
    end
    function speedChanged(~,~)
        lastT = timeline.Value; clockRef = tic;
    end
    function onKey(~,evt)
        switch evt.Key
            case 'space', toggle([],[]);
            case 'leftarrow', render(timeline.Value-2); seek([],[]);
            case 'rightarrow', render(timeline.Value+2); seek([],[]);
            case {'1','2','3','4','5','6','7','8','9'}, render(timeline.Value,str2double(evt.Key));
            case 'c', render(timeline.Value,mod(cam.Value,numel(names))+1);
        end
    end
    function closeReplay(~,~)
        delete(fig);
    end
    function disposeTimer(~,~)
        if isvalid(player), stop(player); delete(player); end
    end
end
