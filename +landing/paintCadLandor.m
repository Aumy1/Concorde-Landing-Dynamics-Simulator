function paintCadLandor(root,v,f)
%PAINTCADLANDOR Apply original vector markings from a Landor side reference.
% Paint is clipped against individual STEP triangles in side elevation.
% Interpolating back onto each triangle keeps long stripes against the skin.
red=[.82 .065 .095]; blue=[.047 .070 .23]; white=[.97 .965 .94];
dark=[.10 .13 .18];
a=v(f(:,1),:); b=v(f(:,2),:); c=v(f(:,3),:);
ctr=(a+b+c)/3; e=b-a; g=c-a;
d=e(:,1).*g(:,3)-e(:,3).*g(:,1);
lo=min(cat(3,a,b,c),[],3); hi=max(cat(3,a,b,c),[],3);
within=abs(d)>1e-8;
body=within & lo(:,3)<6.2 & hi(:,3)>4.2 & ...
    max(abs([lo(:,2),hi(:,2)]),[],2)<1.95;
fin=within & lo(:,1)<-8 & hi(:,3)>6.38 & ...
    max(abs([lo(:,2),hi(:,2)]),[],2)<.65 & abs(ctr(:,2))>.022;
layer=hgtransform('Parent',root,'Tag','LandorPaint');
for side=[-1 1]
    skin=body & side*ctr(:,2)>.22;
    stab=fin & side*ctr(:,2)>.015;
    % Pearl body, long narrow red line, and the swept red Speedwing at the nose.
    bands={[-15.4 5.035; 28.0 5.035; 28.0 5.16; -15.4 5.16], ...
        [24.6 4.36; 25.75 4.36; 28.0 5.16; 27.35 5.16; 25.05 4.52]};
    apply(bands,skin,red,.025,'LandorSpeedwing');
    apply(titlePolys(side),skin,blue,.031,'LandorTitle');
    windows=cell(1,55);
    for k=1:numel(windows)
        x=-14.65+(k-1)*.64;
        % These are painted cabin windows; the cockpit glazing is the STEP detail.
        windows{k}=[x 5.30;x+.145 5.30;x+.145 5.48;x 5.48];
    end
    apply(windows,skin,dark,.022,'LandorCabinWindows');
    % Upper navy field with pearl leading edge; the flag is confined below it.
    apply({[-21 8.56;-13.18 8.56;-15.33 11.60;-21 11.60]},stab,blue,.023,'LandorFinNavy');
    apply({[-20.4 6.45;-18.75 6.45;-13.67 8.33;-20.4 8.33]}, ...
        stab,blue,.027,'LandorFlagField');
    apply({[-20.6 6.42;-18.31 6.42;-13.55 8.27;-14.86 8.45], ...
        [-20.3 7.82;-15.24 7.82;-14.46 8.24;-20.3 8.24]}, ...
        stab,white,.034,'LandorFlagWhite');
    apply({[-20.4 6.49;-19.21 6.49;-14.70 8.30;-15.53 8.31], ...
        [-20.3 7.92;-15.24 7.92;-14.90 8.09;-20.3 8.09]}, ...
        stab,red,.045,'LandorFlagRed');
    [du,cut]=crest();
    apply(du,stab,white,.042,'LandorCrest');
    apply(cut,stab,blue,.053,'LandorCrestDetail');
end

    function apply(polys,mask,rgb,lift,tag)
        vertices=zeros(0,3); faces=zeros(0,3);
        for k=1:numel(polys)
            points=polys{k};
            % Triangulate concave design shapes before clipping to CAD faces.
            region=polyshape(points(:,1),points(:,2),'Simplify',true);
            if isempty(region.Vertices), continue; end
            T=triangulation(region); P=T.Points; C=T.ConnectivityList;
            hits=find(mask & lo(:,1)<=max(P(:,1)) & hi(:,1)>=min(P(:,1)) & ...
                lo(:,3)<=max(P(:,2)) & hi(:,3)>=min(P(:,2)));
            for i=reshape(hits,1,[])
                clipper=[a(i,[1 3]);b(i,[1 3]);c(i,[1 3])];
                if d(i)<0, clipper=flipud(clipper); end
                for t=1:size(C,1)
                    q=intersection(P(C(t,:),:),clipper);
                    n=size(q,1);
                    if n<3 || polyarea(q(:,1),q(:,2))<1e-9, continue; end
                    dx=q(:,1)-a(i,1); dz=q(:,2)-a(i,3);
                    r=(dx*g(i,3)-dz*g(i,1))/d(i);
                    s=(e(i,1)*dz-e(i,3)*dx)/d(i);
                    y=a(i,2)+r*e(i,2)+s*g(i,2)+side*lift;
                    offset=size(vertices,1);
                    vertices=[vertices; q(:,1),y,q(:,2)]; %#ok<AGROW>
                    faces=[faces; offset+[ones(n-2,1),(2:n-1)',(3:n)']]; %#ok<AGROW>
                end
            end
        end
        if ~isempty(faces)
            patch('Parent',layer,'Vertices',vertices,'Faces',faces, ...
                'FaceColor',rgb,'FaceLighting','none','EdgeColor','none','Tag',tag);
        end
    end
end

function q=intersection(q,triangle)
% Convex polygon clipping in projected (x,z).
for k=1:3
    if isempty(q), return; end
    a=triangle(k,:); b=triangle(mod(k,3)+1,:); e=b-a;
    p=q([end 1:end-1],:);
    fp=e(1)*(p(:,2)-a(2))-e(2)*(p(:,1)-a(1));
    fq=e(1)*(q(:,2)-a(2))-e(2)*(q(:,1)-a(1));
    next=zeros(0,2);
    for j=1:size(q,1)
        ip=fp(j)>=0; iq=fq(j)>=0;
        if ip~=iq, next(end+1,:)=p(j,:)+(q(j,:)-p(j,:))*(fp(j)/(fp(j)-fq(j))); end %#ok<AGROW>
        if iq, next(end+1,:)=q(j,:); end %#ok<AGROW>
    end
    q=next;
end
end

function polys=titlePolys(side)
label='BRITISH AIRWAYS'; alphabet='BRITSH AWY';
glyph={['11110';'10001';'10001';'11110';'10001';'10001';'11110'], ...
    ['11110';'10001';'10001';'11110';'10100';'10010';'10001'], ...
    ['11111';'00100';'00100';'00100';'00100';'00100';'11111'], ...
    ['11111';'00100';'00100';'00100';'00100';'00100';'00100'], ...
    ['01111';'10000';'10000';'01110';'00001';'00001';'11110'], ...
    ['10001';'10001';'10001';'11111';'10001';'10001';'10001'], ...
    repmat('0',7,5), ...
    ['01110';'10001';'10001';'11111';'10001';'10001';'10001'], ...
    ['10001';'10001';'10001';'10101';'10101';'11011';'10001'], ...
    ['10001';'10001';'01010';'00100';'00100';'00100';'00100']};
polys={};
for k=1:numel(label)
    [r,c]=find(glyph{alphabet==label(k)}=='1');
    for j=1:numel(r)
        x=21.4-side*.079*((k-1)*6+c(j)-1-44);
        nx=x-side*.079; z=4.90-.068*(r(j)-1);
        polys{end+1}=[x z;nx z;nx z-.068;x z-.068]; %#ok<AGROW>
    end
end
end

function [shapes,details]=crest()
% Miniature white crowned shield, supporters and ribbon, drawn as geometry.
shapes={[-.30 .36;-.40 .63;-.19 .48;0 .70;.19 .48;.40 .63;.30 .36], ...
    [-.32 .26;.32 .26;.30 -.20;0 -.43;-.30 -.20], ...
    [-.83 -.38;0 -.61;.83 -.38;.68 -.56;0 -.71;-.68 -.56]};
for side=[-1 1]
    q=[.33 .21;.59 .54;.92 .40;.86 .24;.67 .31;.51 -.07; ...
        .83 -.14;.77 -.31;.43 -.25;.35 -.36;.43 -.05];
    q(:,1)=side*q(:,1); shapes{end+1}=q; %#ok<AGROW>
end
details={[-.22 .13;.22 .13;.19 .04;-.19 .04], ...
    [-.08 .14;.08 .14;.08 -.23;0 -.29;-.08 -.23]};
shapes=cellfun(@(p) p.*[.84 1]+[-17.28 9.83],shapes,'UniformOutput',false);
details=cellfun(@(p) p.*[.84 1]+[-17.28 9.83],details,'UniformOutput',false);
end
