include("../src/readmesh.jl")

m = readmesh("data/rectangle-ng.msh")
dump(m)
println()
println("nnb = ", length(m.nodeBlocks))
dump(m.nodeBlocks)
println()
#println("neb = ", length(m.elementBlocks))
#dump(m.elementBlocks)

