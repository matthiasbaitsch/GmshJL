using Makie
using VarStructs
using ColorSchemes
using LinearAlgebra

@var struct FEMeshSimple
    Nn::Int
    nodes::Matrix{Float64}
    Ne::Int
    elements::Matrix{Int}
    edgeNodeIDs::Vector{Int}
end

function FEMeshSimple(m::GmshMesh)
    nodes = getnodes(m)
    Nn = size(nodes, 2)
    elements = nodeTags(m.elementBlocks, dimension(m))'
    Ne = size(elements, 2)
    boundaryNodeIDs = unique(reshape(nodeTags(m.elementBlocks, dimension(m) - 1), :, 1))
    return FEMeshSimple(
        Nn=Nn,
        nodes=nodes,
        Ne=Ne,
        elements=elements,
        boundaryNodeIDs=boundaryNodeIDs
    )
end

function GmshJL.plot(m::FEMeshSimple, colors=[])
    if length(colors) > 0
        cm = ColorSchemes.devon.colors
        f, a, p = poly(
            m.nodes',
            m.elements',
            strokewidth=1,
            color=colors,
            colormap=cm,
            axis=(aspect=DataAspect(),)
        )
        Colorbar(f[1, 2], colormap=cm)
        return f
    else
        return poly(m.nodes', m.elements', strokewidth=1, axis=(aspect=DataAspect(),))
    end
end