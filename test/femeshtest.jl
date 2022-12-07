using Test
using GmshJL

m = FEMesh("data/advanced.msh");

# Test haskey
m.x = 99
@test haskey(m, :x)
@test !haskey(m, :y)

for (n, g) ∈ m.groups
    println(n, "-->", g)
end

