function landorMarkings(parent,body,navy,red,pearl,drawWindows)
%LANDORMARKINGS Original model geometry for the BA Concorde's Landor scheme.
% The tail crest is stylized. No photograph or third-party texture is used.
if nargin<6, drawWindows=true; end
for side = [-1 1]
    % Low belt line and tapered red Speedwing on the mostly pearl fuselage.
    shell(parent,body,side,[-24 4.17; -20 4.10; 17 4.10; ...
        25.8 4.13; 25.2 4.02; 17 3.97; -21 3.97],navy);
    shell(parent,body,side,[-23 4.28; -18 4.23; 17 4.23; ...
        23.8 4.33; 26.25 4.52; 24.7 4.27; 20.8 4.13; -20 4.13],red);
    % Windows and letters are world-space decals attached to the mesh.
    windows = -20:.88:8;
    if ~drawWindows, windows=[]; end
    for x = windows
        shell(parent,body,side,[x 4.73; x+.27 4.73; ...
            x+.27 5.00; x 5.00],navy);
    end
    wordmark(parent,body,side,navy);
    fin = @(xz,c) patch('Parent',parent,'Vertices', ...
        [xz(:,1),repmat(side*(.205+.006*isequal(c,red)),size(xz,1),1),xz(:,2)], ...
        'Faces',1:size(xz,1),'FaceColor',c,'EdgeColor','none');
    % Cropped Union Flag: white diagonals and red inset plus cross.
    fin([-26.98 5.72; -17.2 5.90; -19.2 8.05; -27.34 9.20; ...
        -27.44 10.03; -20.0 8.86; -22.15 10.75; -21.18 10.18; ...
        -17.35 7.12; -14.25 6.00; -15.8 5.92; -20.35 7.25],pearl);
    fin([-26.98 5.78; -22.55 5.88; -22.88 10.0; -24.10 10.16; ...
        -23.80 7.7; -27.19 7.52; -27.13 6.74; -23.68 6.93; -23.62 5.91],pearl);
    fin([-27.25 8.71; -27.28 9.06; -20.03 7.84; -18.15 6.31; ...
        -17.18 5.95; -18.63 6.13; -20.36 7.50],red);
    fin([-23.26 5.96; -23.58 9.96; -23.12 9.91; -22.79 7.49; ...
        -17.91 7.56; -17.15 7.04; -22.74 6.98; -22.66 5.96],red);
    fin([-27.15 6.91; -27.18 7.36; -23.63 7.56; -23.59 7.08],red);
    crest(parent,side,pearl,navy,red);
end
end

function shell(p,body,s,xz,c)
% Densify long edges so the decals follow the tapered hull.
v = zeros(0,2);
for k = 1:size(xz,1)
    a = xz(k,:); b = xz(mod(k,size(xz,1))+1,:);
    count = max(1,ceil(abs(b(1)-a(1))/.5));
    v = [v; a+((0:count-1)'/count).*(b-a)]; %#ok<AGROW>
end
xyz = onHull(body,s,v);
patch('Parent',p,'Vertices',xyz,'Faces',1:size(xyz,1), ...
    'FaceColor',c,'EdgeColor','none');
end

function xyz = onHull(body,s,xz)
shape = interp1(body(:,1),body(:,2:4),xz(:,1),'linear');
frac = (xz(:,2)-shape(:,3))./shape(:,2);
y = s*(shape(:,1).*sqrt(max(0,1-frac.^2))+.026);
xyz = [xz(:,1),y,xz(:,2)];
end

function wordmark(p,body,s,c)
letters = 'BRITISH AIRWAYS';
alphabet = 'BRITSH AWY';
rows = {'11110 10001 10001 11110 10001 10001 11110', ...
    '11110 10001 10001 11110 10100 10010 10001', ...
    '11111 00100 00100 00100 00100 00100 11111', ...
    '11111 00100 00100 00100 00100 00100 00100', ...
    '01111 10000 10000 01110 00001 00001 11110', ...
    '10001 10001 10001 11111 10001 10001 10001', ...
    '00000 00000 00000 00000 00000 00000 00000', ...
    '01110 10001 10001 11111 10001 10001 10001', ...
    '10001 10001 10001 10101 10101 11011 10001', ...
    '10001 10001 01010 00100 00100 00100 00100'};
v = zeros(0,2);
for i = 1:numel(letters)
    index = find(alphabet==letters(i),1);
    bitmap = reshape(rows{index}(rows{index}~=' '),5,7)';
    [rr,cc] = find(bitmap=='1');
    for j = 1:numel(rr)
        x = 14.8-s*.106*((i-1)*6+cc(j)-1-(numel(letters)*6-2)/2);
        z = 5.57-.102*(rr(j)-1);
        v = [v; x z; x-s*.106 z; x-s*.106 z-.102; x z-.102]; %#ok<AGROW>
    end
end
patch('Parent',p,'Vertices',onHull(body,s,v),'Faces',reshape(1:size(v,1),4,[])', ...
    'FaceColor',c,'EdgeColor','none');
end

function crest(p,s,pearl,navy,red)
% Original miniature approximation: crowned shield and winged supporters.
z0 = 11.43; x0 = -25.63;
decal = @(xz,c,depth) patch('Parent',p,'Vertices', ...
    [x0+xz(:,1),repmat(s*(.218+depth),size(xz,1),1),z0+xz(:,2)], ...
    'Faces',1:size(xz,1),'FaceColor',c,'EdgeColor','none');
gold = [.93 .73 .37];
decal([-.43 .26; .43 .26; .38 -.30; 0 -.62; -.38 -.30],gold,0);
decal([-.32 .15; .32 .15; .28 -.22; 0 -.47; -.28 -.22],red,.004);
decal([-.27 .12; .27 .12; .25 -.01; -.25 -.01],navy,.008);
decal([-.38 .37; -.49 .72; -.24 .55; 0 .79; .24 .55; .49 .72; .38 .37],gold,0);
for q = [-1 1]
    b = [ .40 .19; .75 .53; 1.14 .34; 1.04 .12; .83 .22; ...
        .67 -.10; .98 -.20; .87 -.40; .52 -.34; .42 -.45];
    b(:,1) = q*b(:,1); decal(b,pearl,0);
end
decal([-.78 -.51; 0 -.72; .78 -.51; .66 -.71; 0 -.82; -.66 -.71],gold,0);
end
