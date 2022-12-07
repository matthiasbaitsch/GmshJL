using GmshJL

using GmshJL: blocksByDimension

m = readmesh("data/simple.msh")
dump(m)

@pipe m.elementBlocks.blocks .|> GmshJL.blockName(m, _)
@pipe m.nodeBlocks.blocks .|> GmshJL.blockName(m, _)

blocksByDimension(m.elementBlocks, 2)