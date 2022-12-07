"""
 More or less verbatim translation of msh file format into structs.
"""

struct MeshFormat
    version::Float64
    fileType::Int
    dataSize::Int
end

struct PhysicalName
    dimension::Int
    tag::Int
    name::String
end

struct PhysicalNameCollection
    nNames::Int
    names::Vector{PhysicalName}
end

Base.length(ebc::PhysicalNameCollection) = ebc.nNames
Base.getindex(ebc::PhysicalNameCollection, idx) = ebc.names[idx]

struct BoundingBox
    bounds::Vector{Float64}
end

struct Point
    tag::Int
    position::Vector{Float64}
    physicalTags::Vector{Int}
end

struct Entity
    tag::Int
    boundingBox::BoundingBox
    physicalTags::Vector{Int}
    boundingEntities::Vector{Int}
end

struct EntityCollection
    points::Vector{Point}
    curves::Vector{Entity}
    surfaces::Vector{Entity}
    volumes::Vector{Entity}
    allEntities::Dict{Int, Vector{Any}}
    EntityCollection(points, curves, surfaces, volumes) = 
        new(
            points, curves, surfaces, volumes, 
            Dict([0 => points, 1 => curves, 2 => surfaces, 3 => volumes])
        )
end
Base.getindex(ec::EntityCollection, dim::Int) = ec.allEntities[dim]

abstract type Block end

struct NodeBlock <: Block
    entityDim::Int
    entityTag::Int
    parametric::Bool
    nodeTags::Vector{Int}
    coordinates::Matrix{Float64}
end

struct NodeBlockCollection
    nBlocks::Int
    nNodes::Int
    minNodeTag::Int
    maxNodeTag::Int
    blocks::Vector{NodeBlock}
end

Base.length(ebc::NodeBlockCollection) = ebc.nBlocks
Base.getindex(ebc::NodeBlockCollection, i) = ebc.blocks[i]

struct ElementBlock <: Block
    entityDim::Int
    entityTag::Int
    elementType::Int
    elementTags::Vector{Int}
    nodeTags::Matrix{Int}
end

struct ElementBlockCollection
    nBlocks::Int
    nElements::Int
    minElementTag::Int
    maxElementTag::Int
    blocks::Vector{ElementBlock}
end

Base.length(ebc::ElementBlockCollection) = ebc.nBlocks
Base.getindex(ebc::ElementBlockCollection, i) = ebc.blocks[i]

function nodeTags(ebc::ElementBlockCollection, dim::Int)
    nts = []
    for eb ∈ ebc.blocks
        if eb.entityDim == dim
            if length(nts) == 0
                nts = eb.nodeTags
            else
                nts = vcat(nts, eb.nodeTags)
            end
        end
    end
    return nts
end

struct GmshMesh
    meshFormat::MeshFormat
    physicalNames::PhysicalNameCollection
    entities::EntityCollection
    nodeBlocks::NodeBlockCollection
    elementBlocks::ElementBlockCollection
end

dimension(m::GmshMesh) = maximum(n -> n.entityDim, m.elementBlocks.blocks)

function blockName(m::GmshMesh, b::Block)
    entity = m.entities[b.entityDim][b.entityTag]
    physicalTags = entity.physicalTags
    if length(physicalTags) == 0
        return "_$(b.entityDim).$(b.entityTag)"
    elseif length(physicalTags) == 1
        return m.physicalNames[physicalTags[1]].name
    else
        error("Should not happen") 
    end
end

function getnodes(m::GmshMesh)
    Nn = m.nodeBlocks.nNodes
    nodes = zeros(Nn, 3)
    for nb ∈ m.nodeBlocks.blocks
        nodes[nb.nodeTags, :] = nb.coordinates
    end
    if norm(nodes[:, 3]) == 0
        nodes = nodes[:, 1:2]
    end
    return nodes'
end

