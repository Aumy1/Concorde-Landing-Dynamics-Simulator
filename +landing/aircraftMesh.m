function model = aircraftMesh(ax)
%AIRCRAFTMESH Original procedural Concorde-inspired mesh. Metres, nose +x.
% Local origin is the main wheel contact datum; surfaces are illustrative.
model.root = hgtransform('Parent',ax);
n = model.root;
ivory = [.94 .94 .91]; silver = [.58 .65 .70]; dark = [.09 .13 .18];
navy = [.055 .105 .22]; red = [.78 .075 .13];
body = [-31 .04 .04 5.7; -27 .48 .55 5.1; -22 1.1 1.2 4.7; ...
    -15 1.43 1.52 4.65; 0 1.47 1.57 4.65; 16 1.40 1.46 4.65; ...
    23 1.06 1.05 4.55; 28 .45 .46 3.65; 31 .025 .035 3.12];
loft(n,body(:,1)',body(:,2)',body(:,3)',0,body(:,4)',ivory);
landing.landorMarkings(n,body,navy,red,ivory);
% Each ogival wing follows a sampled curved leading edge.
for side = [-1 1]
    x = [17 10 3 -3 -9 -15 -21 -23 -20 -14];
    y = side*[1 2.2 4.8 6.8 9.1 11 12.8 12.55 7 1];
    z = [4.4 4.25 4.05 3.95 3.85 3.75 3.65 3.63 3.75 3.94];
    plate(n,[x(:),y(:),z(:)],.22,ivory);
    for yEng = side*[3.15 5.05]
        loft(n,[-23.8 -22.8 -12 -8.3], [.60 .85 .96 .74], ...
            [.65 .74 .81 .61],yEng,[2.9 2.95 3 3.12],silver);
        cap(n,-8.27,yEng,3.12,.58,.47,dark);
        cap(n,-23.85,yEng,2.9,.54,.52,dark);
    end
    plate(n,[23 side*.63 5.40; 20.8 side*1.19 5.59; ...
        20.8 side*1.29 5.15; 23.5 side*.69 5.04],.025,dark);
    lamp(n,-21,side*12.7,3.75,side);
end
% The flag and crest are drawn on both faces by landorMarkings.
v = [-12 0 5.7; -24 0 12.6; -28.0 0 12.7; -27.2 0 5.4];
plate(n,v,.38,navy,2);
% Main legs sit at the pitch pivot. Nose gear meets the runway on derotation.
for y = [-3.5 3.5]
    line('Parent',n,'XData',[0 0],'YData',[y y],'ZData',[.75 4], ...
        'Color',silver,'LineWidth',4);
    for x = [-.75 .75]
        for dy = [-.38 .38], wheel(n,x,y+dy,.62,.62,.24); end
    end
end
line('Parent',n,'XData',[20 20],'YData',[0 0],'ZData',[.52 4.3], ...
    'Color',silver,'LineWidth',3);
for y = [-.29 .29], wheel(n,20,y,.5,.5,.21); end
end

function loft(p,x,ry,rz,y,z,c)
a = linspace(0,2*pi,33)';
surface('Parent',p,'XData',repmat(x,numel(a),1),'YData',y+cos(a)*ry, ...
    'ZData',z+sin(a)*rz,'FaceColor',c,'EdgeColor','none','FaceLighting','gouraud', ...
    'BackFaceLighting','reverselit','AmbientStrength',.62,'SpecularStrength',.18);
end

function plate(p,v,thickness,c,axisIndex)
if nargin < 5, axisIndex = 3; end
offset = zeros(1,3); offset(axisIndex) = thickness/2;
N = size(v,1); faces = nan(N+2,N);
faces(1,:) = 1:N; faces(2,:) = (2*N):-1:(N+1);
for k = 1:N
    j = mod(k,N)+1; faces(k+2,1:4) = [k k+N j+N j];
end
patch('Parent',p,'Vertices',[v+offset;v-offset],'Faces',faces, ...
    'FaceColor',c,'EdgeColor','none','FaceLighting','flat','AmbientStrength',.75);
end

function cap(p,x,y,z,ry,rz,c)
a = linspace(0,2*pi,40);
patch('Parent',p,'XData',0*a+x,'YData',y+ry*cos(a), ...
    'ZData',z+rz*sin(a),'FaceColor',c,'EdgeColor','none');
end

function wheel(p,x,y,z,r,w)
a = linspace(0,2*pi,19)';
surface('Parent',p,'XData',x+cos(a)*[r r],'YData',y+0*a+[-w/2 w/2], ...
    'ZData',z+sin(a)*[r r],'FaceColor',[.07 .08 .09],'EdgeColor','none');
for dy = [-w/2 w/2]
    patch('Parent',p,'XData',x+r*cos(a),'YData',y+dy+0*a,'ZData',z+r*sin(a), ...
        'FaceColor',[.19 .22 .25],'EdgeColor','none');
end
end

function lamp(p,x,y,z,side)
if side < 0, c = [1 .16 .17]; else, c = [.16 1 .53]; end
line('Parent',p,'XData',x,'YData',y,'ZData',z, ...
    'Marker','o','MarkerSize',4,'MarkerFaceColor',c,'MarkerEdgeColor',c);
end
