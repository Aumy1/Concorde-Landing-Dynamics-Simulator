function model = a350AircraftMesh(ax,path)
%A350AIRCRAFTMESH Render the user's colored Fusion-derived A350 mesh.
fid = fopen(path,'r','ieee-le');
assert(fid>=0,'landing:A350Mesh','Cannot open A350 asset.');
cleanup = onCleanup(@() fclose(fid));
n = fread(fid,2,'uint32=>double');
assert(numel(n)==2 && all(n>0) && all(n<2e6),'Invalid A350 asset.');
v = fread(fid,[3 n(1)],'single=>double')';
raw = fread(fid,[15 n(2)],'uint8=>uint8');
assert(size(raw,2)==n(2) && size(v,1)==n(1),'Incomplete A350 asset.');
f = double(reshape(typecast(reshape(raw(1:12,:),1,[]),'uint32'),3,[])');
c = double(raw(13:15,:)')/255;
% Source has nose at x=0; main gear at x=145 mm. Uniform visual scaling.
v = [(145-v(:,1)),-v(:,2),v(:,3)]*(66.8/300);
model.root = hgtransform('Parent',ax);
model.isCAD = true;
model.contact = v(v(:,3)<.24 & abs(v(:,2))>3 & abs(v(:,1))<3,[1 3]);
model.cockpit = [28 0 6];
assert(size(model.contact,1)>10,'A350 main wheel datum not found.');
patch('Parent',model.root,'Vertices',v,'Faces',f,'FaceVertexCData',c, ...
    'FaceColor','flat','EdgeColor','none','FaceLighting','gouraud', ...
    'AmbientStrength',.75,'DiffuseStrength',.55,'BackFaceLighting','reverselit');
end
