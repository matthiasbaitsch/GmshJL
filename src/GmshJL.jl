module GmshJL

include("arrayscanner.jl")
include("mesh.jl")
include("readmesh.jl")
include("femesh.jl")

export FEMesh
export hasprop
export plotmesh
export readmesh

end
