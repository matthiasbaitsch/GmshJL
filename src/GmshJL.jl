module GmshJL

include("arrayscanner.jl")
include("mesh.jl")
include("femesh.jl")
include("readmesh.jl")

export FEMesh
export getindex
export haskey
export plot
export readmesh

end
