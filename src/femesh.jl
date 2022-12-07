include("femeshsimple.jl")
include("femeshgroups.jl")

GmshJL.haskey(m::FEMeshSimple, key::Symbol) = haskey(getfield(m, :fieldtable), key)
GmshJL.haskey(m::FEMeshGroups, key::Symbol) = haskey(getfield(m, :fieldtable), key)

function FEMesh(filename) 
    m = readmesh(filename)
    if length(m.physicalNames) == 0
        return FEMeshSimple(m)
    else 
        return FEMeshGroups(m)
    end
end


