"""Convert the colored Fusion OBJ to the simulator's little-endian mesh format."""
import array
import pathlib
import struct
import sys

source = pathlib.Path(sys.argv[1])
output = pathlib.Path(sys.argv[2])
colors = {}
for line in source.with_suffix('.mtl').read_text().splitlines():
    fields = line.split()
    if not fields:
        continue
    if fields[0] == 'newmtl':
        material = fields[1]
    elif fields[0] == 'Kd':
        colors[material] = tuple(round(float(x) * 255) for x in fields[1:4])
vertices = array.array('f')
faces = bytearray()
color = (244, 245, 246)
with source.open() as handle:
    for line in handle:
        fields = line.split()
        if not fields:
            continue
        if fields[0] == 'v':
            vertices.extend(map(float, fields[1:4]))
        elif fields[0] == 'usemtl':
            color = colors[fields[1]]
        elif fields[0] == 'f':
            indices = [int(x.split('/')[0]) for x in fields[1:]]
            for j in range(1, len(indices)-1):
                faces.extend(struct.pack('<III3B', indices[0], indices[j], indices[j+1], *color))
if sys.byteorder != 'little':
    vertices.byteswap()
with output.open('wb') as handle:
    handle.write(struct.pack('<II',len(vertices)//3, len(faces)//15))
    vertices.tofile(handle)
    handle.write(faces)
print(f'{len(vertices)//3:,} vertices / {len(faces)//15:,} triangles')
