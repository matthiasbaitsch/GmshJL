using Makie
using VarStructs
using LinearAlgebra

@var struct FEMeshSimple
    Nn::Int
    nodes::Matrix{Float64}
    Ne::Int
    elements::Matrix{Int}
    edgeNodeIDs::Vector{Int}
end

hasprop(m::FEMeshSimple, key::Symbol) = haskey(getfield(m, :fieldtable), key)

function plotmesh(m::FEMeshSimple, colors = [])
    if length(colors) > 0
        return poly(m.nodes', m.elements', strokewidth=1, color=colors, axis=(aspect=DataAspect(),))
    else
        return poly(m.nodes', m.elements', strokewidth=1, axis=(aspect=DataAspect(),))
    end
end

function FEMeshSimple(m::GmshMesh) 
    
    # Nodes
    Nn = m.nodeBlocks.nNodes
    nodes = zeros(Nn, 3)
    for nb ∈ m.nodeBlocks.blocks
        nodes[nb.nodeTags, :] = nb.coordinates
    end
    if norm(nodes[:, 3]) == 0
        nodes = nodes[:, 1:2]
    end
    nodes = nodes'

    # Elements    
    dim = dimension(m)
    elements = nodeTags(m.elementBlocks, dim)
    elements = elements'
    Ne = size(elements, 2)

    # Boundary nodes
    boundaryNodeIDs = unique(reshape(nodeTags(m.elementBlocks, dim - 1), :, 1))

    # FE Mesh
    return FEMeshSimple(Nn = Nn, nodes = nodes, Ne = Ne, elements = elements, boundaryNodeIDs = boundaryNodeIDs)
end

function FEMesh(filename) 
    m = readmesh(filename)
    if length(m.physicalNames) == 0
        return FEMeshSimple(m)
    end
end
