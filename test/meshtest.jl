using Test
using GmshJL

m = readmesh("data/rectangle-ng.msh")

@test GmshJL.dimension(m) == 2
@test GmshJL.nodeTags(m.elementBlocks, 1) == [1 5; 5 2; 2 3; 3 6; 6 4; 4 1]
@test GmshJL.nodeTags(m.elementBlocks, 2) == [1 8 4; 5 8 1; 3 7 2; 2 7 5; 6 7 3; 4 8 6; 5 7 6; 6 8 5]
