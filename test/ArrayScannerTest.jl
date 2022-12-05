using Test

include("../src/arrayscanner.jl")

as = ArrayScanner([1, 3, 2, 9, 11, 2, 1])
@test 1 == next!(as)
@test [3] == next!(as, 1)
@test [2, 9] == next!(as, 2)
@test [11, 2, 1] == next!(as, 3)

as = ArrayScanner([2, 3, 4, 1, 5, 0, 2, 2, 1])
@test [3, 4] == nextarray!(as)
@test [5] == nextarray!(as)
@test [] == nextarray!(as)
@test [2, 1] == nextarray!(as)




