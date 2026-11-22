function styleFigure(fig)
%STYLEFIGURE Keep exported charts readable regardless of desktop theme.
if isprop(fig,'Theme'), fig.Theme = 'light'; end
fig.Color = 'w'; ink = [.12 .18 .25];
axesHandles = findall(fig,'Type','axes');
set(axesHandles,'Color','w','XColor',ink,'YColor',ink, ...
    'GridColor',[.65 .7 .75],'GridAlpha',.35,'FontSize',11);
set(findall(fig,'Type','text'),'Color',ink);
legends = findall(fig,'Type','legend');
set(legends,'Color','w','TextColor',ink,'EdgeColor',[.75 .8 .85]);
end
