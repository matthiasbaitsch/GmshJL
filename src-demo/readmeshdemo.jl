using GmshJL

m = readmesh("data/simple.msh")
dump(m)

@pipe m.elementBlocks.blocks .|> GmshJL.blockName(m, _)
@pipe m.nodeBlocks.blocks .|> GmshJL.blockName(m, _)
