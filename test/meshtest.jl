using Test
using Revise

include("../src/mesh.jl")
include("../src/readmesh.jl")

m = readmesh("data/rectangle-ng.msh")
@test dimension(m) == 2

@test nodeTags(m.elementBlocks, 2) == [1 8 4; 5 8 1; 3 7 2; 2 7 5; 6 7 3; 4 8 6; 5 7 6; 6 8 5]


nodeTags(m.elementBlocks, 1)
