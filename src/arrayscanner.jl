mutable struct ArrayScanner    
    const array::Vector{Any}
    p::Int
    ArrayScanner(array) = new(array, 1)
end

function next!(s::ArrayScanner)
    s.p += 1
    return s.array[s.p - 1]
end

function next!(s::ArrayScanner, n::Int)
    a = s.array[s.p:s.p + n - 1]
    s.p += n
    return a
end

function nextarray!(s::ArrayScanner)
    n = next!(s)
    a = s.array[s.p:s.p + n - 1]
    s.p += n
    return a
end

Base.show(io::IO, as::ArrayScanner) = Base.show(as.array[as.p:end])
