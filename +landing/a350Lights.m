function a350Lights(parent)
%A350LIGHTS Stylized steady navigation and landing lights on CAD mesh.
% Positions near wing tips and forward gear; display only.
lamp([-14 -31.2 5.0],[1 .08 .06]);
lamp([-14 31.2 5.0],[.04 1 .36]);
lamp([-34 0 5.5],[1 1 .94]);
lamp([3 0 7.2],[1 .12 .08]);
for side=[-1 1]
    lamp([4 side*5 3.4],[1 .94 .72]);
    % Soft warm light cone aimed toward the runway, intentionally illustrative.
    patch('Parent',parent,'Vertices',[4 side*5 3.4; 58 side*5-8 -1; 58 side*5+8 -1], ...
        'Faces',[1 2 3],'FaceColor',[1 .9 .65],'FaceAlpha',.07,'EdgeColor','none','FaceLighting','none');
end
    function lamp(pos,c)
        line('Parent',parent,'XData',pos(1),'YData',pos(2),'ZData',pos(3), ...
            'Marker','o','MarkerSize',10,'MarkerFaceColor','none','MarkerEdgeColor',c*.65,'LineStyle','none');
        line('Parent',parent,'XData',pos(1),'YData',pos(2),'ZData',pos(3), ...
            'Marker','o','MarkerSize',4,'MarkerFaceColor',c,'MarkerEdgeColor',c,'LineStyle','none');
    end
end
