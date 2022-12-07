using Test
using GmshJL

# Without groups
m = FEMesh("data/simple.msh");
m.x = 99
@test haskey(m, :x)
@test !haskey(m, :y)

# With groups
m = FEMesh("data/advanced.msh");
m.x = 99
@test haskey(m, :x)
@test !haskey(m, :y)

# Check edges
m4 = FEMesh("data/complex-g1.msh")
@test m4.groups["c1"].Ne == 40