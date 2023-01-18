using GmshJL
using GLMakie

m = FEMesh("data/heat_plate.msh")

m.x = 999

c = rand(m.Nn)

println("Nn = ", m.Nn)
println("x = ", m.x)

plot(m, c)

