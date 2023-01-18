using Test
using GmshJL
using Revise

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

m.groups["s1"].x = 99
@test haskey(m.groups["s1"], :x)
@test !haskey(m.groups["s1"], :y)

# Check edges
m4 = FEMesh("data/complex-g1.msh")
@test m4.groups["c1"].Ne == 40

# Find one node
for n ∈ 1:m4.Nn
    @test findNodeAt(m4, m4.nodes[:, n]) == n
end
@test findNodeAt(m4, [-99; -99]) == -1

# Find many nodes
nodes = [m4.nodes[:, 5], m4.nodes[:, 2], [99; 99]]
@test findNodesAt(m4, nodes) == [5, 2, -1];
