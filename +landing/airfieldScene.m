function shadow = airfieldScene(ax,L,xStart,xEnd)
%AIRFIELDSCENE Fictional airport built entirely from MATLAB graphics.
landEnd = max(L,xEnd)+1800;
rect(ax,xStart-2200,landEnd,-3400,3400,-.10,[.37 .48 .34]);
for k = 0:17
    a = xStart-800+k*(landEnd-xStart+800)/18;
    tint = [.40 .48 .33]+.035*cos(k*2.2);
    rect(ax,a,a+280,150+35*mod(k,3),500+50*mod(k,4),-.06,tint);
    rect(ax,a+110,a+340,-660,-180,-.055,tint-.035);
end
% Distant stylized hills; units remain metres throughout the scene.
for side = [-1 1]
    [X,Y] = meshgrid(linspace(xStart-4000,landEnd+2500,90), ...
        sort(side*linspace(750,3400,30)));
    ramp = min(1,max(0,(abs(Y)-750)/950));
    Z = 1+ramp.*(35+150*(.5+.5*sin(X/510+Y/460)).^2+ ...
        64*(.5+.5*cos(X/360-Y/610)));
    surf(ax,X,Y,Z,'EdgeColor','none','FaceColor',[.27 .39 .34], ...
        'FaceLighting','gouraud','AmbientStrength',.75);
end
rect(ax,0,L,-30,30,0,[.19 .22 .25]);
rect(ax,0,L,-28.5,-27.7,.02,[.91 .92 .86]);
rect(ax,0,L,27.7,28.5,.02,[.91 .92 .86]);
for x = 46:60:L-47, rect(ax,x,x+29,-.55,.55,.03,[.94 .94 .87]); end
for y = [-23:-4:-3 3:4:23], rect(ax,6,min(33,L),y-.65,y+.65,.035,[.96 .96 .9]); end
if L > 420
    for y = [-12 12], rect(ax,290,333,y-2.0,y+2.0,.04,[.96 .96 .9]); end
end
for side = [-1 1]
    x = 3:54:L; y = side*30.5+0*x;
    plot3(ax,x,y,.23+0*x,'.','Color',[1 .91 .62],'MarkerSize',7);
end
lineDots(ax,0,-26:4:26,[.30 1 .68]); lineDots(ax,L,-26:4:26,[1 .31 .23]);
for x = -360:33:-22, lineDots(ax,x,-4:4:4,[1 .80 .36]); end
% Parallel taxiway, exits and a geometric terminal apron.
rect(ax,18,L,-146,-125,-.01,[.29 .32 .34]);
rect(ax,18,L,-136.3,-135.8,.01,[.94 .72 .27]);
for f = [.12 .39 .72 .91]
    x = f*L;
    patch(ax,x+[-12 10 76 54],[-29 -29 -126 -126],.01*ones(1,4), ...
        [.29 .32 .34],'EdgeColor','none');
end
rect(ax,.22*L,.63*L,-335,-146,-.02,[.37 .39 .40]);
for k = 0:4
    building(ax,.25*L+95*k,-298,64,30,8+mod(k,3)*4,[.57 .60 .61]);
end
building(ax,.45*L,-225,11,11,25,[.63 .65 .62]);
building(ax,.45*L-2,-227,15,15,32,[.38 .50 .53]);
t = linspace(0,2*pi,40);
shadow = patch(ax,18*cos(t),9*sin(t),.08+0*t,[.045 .07 .075], ...
    'FaceAlpha',.28,'EdgeColor','none');
end

function rect(ax,x1,x2,y1,y2,z,c)
patch(ax,[x1 x2 x2 x1],[y1 y1 y2 y2],z*ones(1,4),c,'EdgeColor','none');
end

function lineDots(ax,x,y,c)
plot3(ax,x+0*y,y,.27+0*y,'.','Color',c,'MarkerSize',8);
end

function building(ax,x,y,l,w,h,c)
v = [x y 0; x+l y 0; x+l y+w 0; x y+w 0];
patch(ax,'Vertices',[v;v+[0 0 h]],'Faces',[1 2 6 5; 2 3 7 6; 3 4 8 7; ...
    4 1 5 8; 5 6 7 8],'FaceColor',c,'FaceLighting','flat','EdgeColor','none');
end
