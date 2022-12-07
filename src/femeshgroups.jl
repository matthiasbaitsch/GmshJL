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
    @pipe m.elementBlocks.blocks .|>
          blockName(m, _) .|>
          (nodeTagsDict[_] = [])
    @pipe m.elementBlocks.blocks .|>
          (push!(nodeTagsDict[blockName(m, _)], _.nodeTags))

    # Create groups
    groups = Dict{String,Group}()
    for eb ∈ m.elementBlocks.blocks
        name = blockName(m, eb)
        dimension = eb.entityDim
        elements = Matrix(reduce(vcat, nodeTagsDict[name])')
        nodeIDs = unique(reshape(elements, :, 1))
        groups[name] = Group(
            name=name,
            dimension=dimension,
            nodeIDs=nodeIDs,
            Ne=size(elements, 2),
            elements=elements
        )
    end

    # Mesh
    return FEMeshGroups(
        Nn=size(nodes, 2),
        nodes=nodes,
        groups=groups
    )
end

groupsByDimension(m::FEMeshGroups, dim::Int) = filter(g -> g.dimension == dim, collect(values(m.groups)))

function GmshJL.plot(m::FEMeshGroups)
    cnt = 1
    f = 1
    a = 1
    p = 1
    colors = ColorSchemes.Dark2_8

    for g ∈ groupsByDimension(m, 2)
        if cnt == 1
            f, a, p = poly(
                m.nodes',
                g.elements',
                strokewidth=1,
                axis=(aspect=DataAspect(),)
            )
        else
            poly!(
                a,
                m.nodes',
                g.elements',
                strokewidth=1
            )
        end
        cnt += 1
    end
    
    cnt = 1;
    for g ∈ groupsByDimension(m, 1)
        x = m.nodes[1, g.elements]
        y = m.nodes[2, g.elements]
        x = reshape(vcat(x, fill(NaN, 1, size(x, 2))), :)
        y = reshape(vcat(y, fill(NaN, 1, size(y, 2))), :)
        lines!(a, x, y, linewidth = 5, color = colors[cnt], overdraw = true)
        cnt += 1
    end

    return f
end