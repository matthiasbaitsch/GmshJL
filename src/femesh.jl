include("femeshsimple.jl")
include("femeshgroups.jl")

GmshJL.haskey(m::FEMeshSimple, key::Symbol) = haskey(getfield(m, :fieldtable), key)
GmshJL.haskey(m::FEMeshGroups, key::Symbol) = haskey(getfield(m, :fieldtable), key)

function plotwithvalues(nodes, elements, values, colors, label)
    f, _, _ = poly(
        nodes',
        elements',
        strokewidth=1,
        color=values,
        colormap=colors,
        axis=(aspect=DataAspect(),)
    )
    Colorbar(f[1, 2], limits=(minimum(values), maximum(values)), colormap=colors, label=label)
    return f
end

function FEMesh(filename)
    m = readmesh(filename)
    if length(m.physicalNames) == 0
        return FEMeshSimple(m)
    else
        return FEMeshGroups(m)
    end
end


