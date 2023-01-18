include("femeshsimple.jl")
include("femeshgroups.jl")

GmshJL.haskey(m::FEMeshSimple, key::Symbol) = haskey(getfield(m, :fieldtable), key)
GmshJL.haskey(m::FEMeshGroups, key::Symbol) = haskey(getfield(m, :fieldtable), key)
GmshJL.haskey(g::Group, key::Symbol) = haskey(getfield(g, :fieldtable), key)

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

function findNodeAt(m, x)
    for i ∈ 1:m.Nn
        if norm(m.nodes[:, i] - x) < 1e-10
            return i
        end
    end
    return -1
end

function findNodesAt(m, x)
    ids = zeros(Int, length(x))
    for i ∈ 1:length(x)
        ids[i] = findNodeAt(m, x[i])
    end
    return ids
end





