using Test
using GmshJL

m = FEMesh("data/heat_plate.msh");

m.x = 99

@test hasprop(m, :x)
@test !hasprop(m, :y)




