using VarStructs
using ColorSchemes
using Pipe: @pipe

@var struct Group
    name::String
    dimension::Int
    nodeIDs::Vector{Int}
    Ne::Int
    elements::Matrix{Int}
end

function Group(name::String, dimension::Int, nodeTagsDict::Dict)
    elements = Matrix(reduce(vcat, nodeTagsDict[name])')
    nodeIDs = unique(reshape(elements, :, 1))
    return Group(
        name=name,
        dimension=dimension,
        nodeIDs=nodeIDs,
        Ne=size(elements, 2),
        elements=elements
    )
end

@var struct FEMeshGroups
    Nn::Int
    nodes::Matrix{Float64}
    groups::Dict{String,Group}
end

function FEMeshGroups(m::GmshMesh)

    # Nodes
    nodes = getnodes(m)

    # Collect node tags
    nodeTagsDict = Dict()
    nodeTagsDict["_faces"] = []
    nodeTagsDict["_edges"] = []
    @pipe m.elementBlocks.blocks .|>
          blockName(m, _) .|>
          (nodeTagsDict[_] = [])
    @pipe m.elementBlocks.blocks .|>
          (push!(nodeTagsDict[blockName(m, _)], _.nodeTags))
    @pipe blocksByDimension(m.elementBlocks, 1) .|>
          (push!(nodeTagsDict["_edges"], _.nodeTags))
    @pipe blocksByDimension(m.elementBlocks, 2) .|>
          (push!(nodeTagsDict["_faces"], _.nodeTags))

    # Create groups
    groups = Dict{String,Group}()
    for eb ∈ m.elementBlocks.blocks
        name = blockName(m, eb)
        groups[name] = Group(name, eb.entityDim, nodeTagsDict)
    end
    groups["_edges"] = Group("_edges", 1, nodeTagsDict)
    groups["_faces"] = Group("_faces", 2, nodeTagsDict)

    # Mesh
    return FEMeshGroups(
        Nn=size(nodes, 2),
        nodes=nodes,
        groups=groups
    )
end

groupsByDimension(m::FEMeshGroups, dim::Int) =
    filter(g -> g.dimension == dim && !startswith(g.name, "_"), collect(values(m.groups)))


function plotMesh(m::FEMeshGroups)
    f = 1
    a = 1
    p = 1

    # Faces
    cnt = 1
    colors = reverse(ColorSchemes.Pastel1_9.colors)
    for g ∈ groupsByDimension(m, 2)
        if cnt == 1
            f, a, p = poly(
                m.nodes',
                g.elements',
                strokewidth=1,
                color=colors[cnt],
                axis=(aspect=DataAspect(),)
            )
        else
            poly!(
                a,
                m.nodes',
                g.elements',
                strokewidth=1,
                color=colors[cnt]
            )
        end
        cnt += 1
    end

    # Edges
    cnt = 1
    colors = ColorSchemes.Set1_9.colors
    for g ∈ groupsByDimension(m, 1)
        x = m.nodes[1, g.elements]
        y = m.nodes[2, g.elements]
        x = reshape(vcat(x, fill(NaN, 1, size(x, 2))), :)
        y = reshape(vcat(y, fill(NaN, 1, size(y, 2))), :)
        lines!(a, x, y, linewidth=5, color=colors[cnt], overdraw=true)
        cnt += 1
    end

    # Return
    return f
end

function GmshJL.plot(m::FEMeshGroups, values=[]; colors=ColorSchemes.devon, label="")
    if length(values) == 0
        return plotMesh(m)
    else
        return plotwithvalues(m.nodes, m.groups["_faces"].elements, values, colors, label)
    end
end