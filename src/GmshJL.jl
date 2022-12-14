module GmshJL

include("arrayscanner.jl")
include("mesh.jl")
include("femesh.jl")
include("readmesh.jl")

export FEMesh
export FEMeshSimple
export FEMeshGroups
export plot
export haskey
export getindex
export readmesh

end
