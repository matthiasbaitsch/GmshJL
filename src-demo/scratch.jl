using GmshJL
using Pipe: @pipe
using ColorSchemes

using GmshJL: readmesh, blocksByDimension, blockName

# m = FEMesh("data/advanced.msh")
# m = FEMesh("data/simple.msh")
# plot(m, rand(m.Nn))
# poly(m.nodes', m.elements', colors=rand(m.Nn))


m4 = readmesh("data/complex-g1.msh")

bs = blocksByDimension(m4.elementBlocks, 1)

blockName(m4, bs[1])
blockName(m4, bs[2])
blockName(m4, bs[3])

bs[1].entityTag
bs[2].entityTag
bs[3].entityTag

m4.entities[1][9].physicalTags
m4.entities[1][12].physicalTags
m4.entities[1][13].physicalTags

m4.entities[1]

cs = m4.entities.curves

reverse(ColorSchemes.Pastel1_9.colors)