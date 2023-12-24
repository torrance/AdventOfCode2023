using Combinatorics
using LinearAlgebra: LinearAlgebra
using StaticArrays
using Symbolics

lines = readlines("input.txt")

hails = map(lines) do line
    position, velocity = split(line, "@ ")
    position = SVector{3, Int}(parse.(Int, split(position, ", "))...)
    velocity = SVector{3, Int}(parse.(Int, split(velocity, ", "))...)
    return position, velocity
end

function xyintercept(hail1, hail2)
    @variables t1 t2
    pos1, vel1 = hail1
    pos2, vel2 = hail2

    try
        t1, t2 = Symbolics.solve_for([
            pos1[1] + t1 * vel1[1] ~ pos2[1] + t2 * vel2[1],
            pos1[2] + t1 * vel1[2] ~ pos2[2] + t2 * vel2[2]
        ], [t1, t2])

        if t1 < 0 || t2 < 0
            return nothing
        end

        return pos1 + t1 * vel1
    catch e
        if isa(e, LinearAlgebra.SingularException)
            return
        else
            rethrow(e)
        end
    end
end

part1 = count(combinations(hails, 2)) do (hail1, hail2)
    pos = xyintercept(hail1, hail2)
    if (
        !isnothing(pos) &&
        200000000000000 <= pos[1] <= 400000000000000 &&
        200000000000000 <= pos[2] <= 400000000000000
    )
        return true
    else
        return false
    end
end

println("Part 1: ", part1)

# Part 2 solved in Mathematica