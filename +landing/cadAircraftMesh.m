function model = cadAircraftMesh(ax,path)
%CADAIRCRAFTMESH Attach the supplied Concorde's tessellated STEP surfaces.
% Format: two uint32 counts, float32 xyz vertices, then 3 uint32 indices
% and 3 uint8 colors per triangle; little endian, 1-based indices.
fid = fopen(path,'r','ieee-le');
assert(fid>=0,'landing:CadMesh','Cannot open CAD mesh.');
cleanup = onCleanup(@() fclose(fid));
counts = fread(fid,2,'uint32=>double');
assert(numel(counts)==2 && all(counts>0) && all(counts<2e6), ...
    'landing:CadMesh','Invalid CAD mesh header.');
v0 = fread(fid,[3 counts(1)],'single=>double')';
f0 = fread(fid,[15 counts(2)],'uint8=>uint8');
assert(size(v0,1)==counts(1) && size(f0,2)==counts(2) && all(isfinite(v0(:))), ...
    'landing:CadMesh','Incomplete CAD mesh.');
f = double(reshape(typecast(reshape(f0(1:12,:),1,[]),'uint32'),3,[])');
assert(all(f(:)>=1 & f(:)<=size(v0,1)), 'landing:CadMesh','Invalid triangle indices.');
c = double(f0(13:15,:)')/255;
% STEP nose is -Y, wings span X, Z is up. Fit published bounding dimensions.
% This student CAD is not a dimensional survey; each axis is scaled separately.
zMain = min(v0(abs(v0(:,1))>25,3));
gearX = 129.4; % STEP longitudinal centre between the two main bogie axles
v = [-v0(:,2)+gearX,v0(:,1),v0(:,3)-zMain];
scale = [62.1 25.5 11.3]./(max(v)-min(v));
v = v.*scale;
model.root = hgtransform('Parent',ax);
model.isCAD = true;
model.contact = v(v(:,3)<.28 & abs(v(:,2))>1.2 & abs(v(:,1))<3.2,[1 3]);
assert(size(model.contact,1)>10,'landing:CadMesh','Could not locate the main wheel tread.');
model.cockpit = [max(v(:,1))-6.4,0,6.15];
pearl = [.95 .95 .92];
% Neutralize the STEP's red wing trim; preserve dark glazing, tires and metals.
redTrim = c(:,1)>.7 & c(:,2)<.50 & c(:,3)<.50;
blueTrim = c(:,3)>.75 & c(:,1)<.15;
lightPaint = min(c,[],2)>.88;
c(redTrim|blueTrim|lightPaint,:) = repmat(pearl,nnz(redTrim|blueTrim|lightPaint),1);
patch('Parent',model.root,'Vertices',v,'Faces',f,'FaceVertexCData',c, ...
    'FaceColor','flat','EdgeColor','none','FaceLighting','gouraud', ...
    'AmbientStrength',.70,'DiffuseStrength',.62,'SpecularStrength',.16, ...
    'BackFaceLighting','reverselit','Tag','StepAircraftSurface');
landing.paintCadLandor(model.root,v,f);
end
