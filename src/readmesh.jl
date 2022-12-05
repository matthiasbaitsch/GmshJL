using Lerche
using Revise
using LinearAlgebra

include("mesh.jl")
include("arrayscanner.jl")

msh_grammar = """
    start: block+

    // Block types
    block: mesh_format
         | physical_names
         | entities
         | nodes
         | elements

    // Blocks
    mesh_format: "MeshFormat" float int int "EndMeshFormat"
    physical_names: "PhysicalNames" int physical_name* "EndPhysicalNames"
    physical_name: int int escaped_string
    entities: "Entities" (int|float)+ "EndEntities"
    nodes: "Nodes" (int|float)+ "EndNodes"
    elements: "Elements" int+ "EndElements"

    // Words
    int: INT
    float: FLOAT
    escaped_string: ESCAPED_STRING
    
    // Numbers in common does not work for me
    DIGIT: "0".."9"
    INT: ["+"|"-"]? DIGIT+
    DECIMAL: ["+"|"-"]? INT "." INT? | "." INT
    _EXP: ("e"|"E") INT
    FLOAT: ["+"|"-"]? INT _EXP | DECIMAL _EXP?

    // Some things from common
    %import common.WS
    %import common.ESCAPED_STRING

    // Ignore
    %ignore WS
    %ignore "\$"
"""

struct TTM <: Transformer end

@rule mesh_format(t::TTM, a) = MeshFormat(a...)
@inline_rule int(t::TTM, n) = Base.parse(Int, n)
@inline_rule float(t::TTM, n) = Base.parse(Float64, n)
@rule physical_name(t::TTM, a) = PhysicalName(a...)
@rule physical_names(t::TTM, a) = PhysicalNameCollection(a[1], a[2:end])
@inline_rule escaped_string(t::TTM, s) = replace(s[2:end-1], "\\\"" => "\"")

@rule entities(t::TTM, a) = begin    
    as = ArrayScanner(a)
    np, nc, ns, nv = next!(as, 4)
    rp!(n, as) = [Point(next!(as), next!(as, 3), nextarray!(as)) for _ = 1:n]
    re!(n, as) = [Entity(next!(as), BoundingBox(next!(as, 6)), nextarray!(as), nextarray!(as)) for _ = 1:n]
    return EntityCollection(rp!(np, as), re!(nc, as), re!(ns, as), re!(nv, as))
end

@rule nodes(t::TTM, a) = begin
    as = ArrayScanner(a)
    nBlocks, nNodes, minNodeTag, maxNodeTag = next!(as, 4)
    nodeBlocks = [
        begin
            eDim, eTag, para, nn = next!(as, 4)
            NodeBlock(eDim, eTag, para == 1, next!(as, nn), reshape(next!(as, 3 * nn), 3, :)')
        end
        for _ = 1:nBlocks
    ]
    return NodeBlockCollection(nBlocks, nNodes, minNodeTag, maxNodeTag, nodeBlocks)
end

@rule elements(t::TTM, a) = begin        
    as = ArrayScanner(a)
    nBlocks, nElements, minElementTag, maxElementTag = next!(as, 4)
    elementTypesNn = [2, 3, 4, 4, 8, 6, 5, 3, 6, 9, 10, 27, 18, 14, 1, 8, 20, 15, 13, 9, 10, 12, 15, 15, 21]
    elementBlocks = [
        begin
            entityDim, entityTag, elementType, numElementsInBlock = next!(as, 4)
            nn = elementTypesNn[elementType]
            data = reshape(next!(as, numElementsInBlock * (1 + nn)), 1 + nn, :)'
            elementTags = (data[:, 1])
            nodeTags = data[:, 2:end]
            ElementBlock(entityDim, entityTag, elementType, elementTags, nodeTags)
        end
        for _ = 1:nBlocks
    ]
    return ElementBlockCollection(nBlocks, nElements, minElementTag, maxElementTag, elementBlocks)
end

@rule start(t::TTM, s) = begin
    mf = MeshFormat(0, 0, 0)
    pnc = PhysicalNameCollection(0, [])
    ec = EntityCollection([], [], [], [])
    nbc = NodeBlockCollection(0, 0, 0, 0, [])
    ebc = ElementBlockCollection(0, 0, 0, 0, [])

    # Process all entries
    for e ∈ s
        o = e.children[1]
        t = typeof(o)
        if t == MeshFormat
            mf = o
        elseif t == PhysicalNameCollection
            pnc = o
        elseif t == EntityCollection
            ec = o
        elseif t == NodeBlockCollection
            nbc = o
        elseif t == ElementBlockCollection
            ebc = o
        else
            error("Unhandled type " + t)
        end
    end

    # Return
    return GmshMesh(mf, pnc, ec, nbc, ebc)
end

# Parser and read function
parser = Lark(msh_grammar, parser="lalr", transformer=TTM())
readmesh(filename) = Lerche.parse(parser, read(filename, String))

