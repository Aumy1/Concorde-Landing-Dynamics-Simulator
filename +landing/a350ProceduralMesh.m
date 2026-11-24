function model = a350ProceduralMesh(ax)
%A350PROCEDURALMESH Original illustrative twin-engine airliner fallback.
model.root = hgtransform('Parent',ax); model.isCAD = false;
model.cockpit = [28 0 7]; n = model.root;
white=[.92 .94 .96]; black=[.07 .08 .10]; silver=[.6 .63 .66]; red=[.8 .08 .12];
x=[-34 -31 -25 -20 0 18 26 31 32]; rad=[.05 .7 2.3 3 3 3 2.7 1 .05];
loft(x,rad,0,6.1,white);
for side=[-1 1]
    wing=[9 side*2.8 5.4; -15 side*22 5.3; -22 side*31 6.8; -26 side*30 6.5; -15 side*11 5.1; -10 side*2.8 5.1];
    poly(wing,white);
    poly([-22 side*30 6.8;-22 side*31 9;-26 side*31 8.7;-26 side*30 6.5],black);
    poly([-24 side*2 7.3;-30 side*11 8.2;-33 side*10 8.2;-31 side*2 7.3],white);
    loft([-7 -6 1 3],[1.2 2.1 2.1 1.5],side*8,3.1,silver);
    loft([3 3.03],[1.5 1.5],side*8,3.1,black);
    for xx=[-1.4 0 1.4]
        wheel(xx,side*5,.6,.6);
    end
    line('Parent',n,'XData',[0 0],'YData',[side*5 side*5],'ZData',[.65 5.3],'Color',silver,'LineWidth',3);
    for xx=-18:1.45:24
        line('Parent',n,'XData',xx,'YData',side*2.94,'ZData',6.6,'Marker','o','MarkerSize',2,'MarkerFaceColor',black,'MarkerEdgeColor',black);
    end
    poly([27 side*2.08 7.7;30 side*1.3 7.0;29 side*1.7 6.7;26 side*2.55 7.15],black);
end
poly([-20 0 8;-28 0 17;-32 0 17.2;-32 0 7],black);
for side=[-1 1]
    t=linspace(0,2*pi,36); poly([-27+1.7*cos(t(:)),side*.045+0*t(:),12+1.7*sin(t(:))],red);
end
line('Parent',n,'XData',[24 24],'YData',[0 0],'ZData',[.55 3.3],'Color',silver,'LineWidth',3);
wheel(24,0,.48,.48);
    function loft(xx,rr,yy,zz,c)
        t=linspace(0,2*pi,40)'; surface('Parent',n,'XData',repmat(xx,numel(t),1),'YData',yy+cos(t)*rr,'ZData',zz+sin(t)*rr,'FaceColor',c,'EdgeColor','none','FaceLighting','gouraud');
    end
    function poly(v,c)
        patch('Parent',n,'Vertices',v,'Faces',1:size(v,1),'FaceColor',c,'EdgeColor','none','FaceLighting','flat','BackFaceLighting','reverselit');
    end
    function wheel(xx,yy,zz,r)
        t=linspace(0,2*pi,24)'; surface('Parent',n,'XData',xx+cos(t)*[r r],'YData',yy+zeros(size(t))*[-.25 .25]+ones(size(t))*[-.25 .25],'ZData',zz+sin(t)*[r r],'FaceColor',black,'EdgeColor','none');
    end
end
