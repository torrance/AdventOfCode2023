using StaticArrays
using ThreadsX

const XYZ = SVector{3, Int}

bricks = map(enumerate(readlines("input.txt"))) do (i, line)
    end1, end2 = split(line, "~")
    end1 = XYZ(parse.(Int, split(end1, ","))...)
    end2 = XYZ(parse.(Int, split(end2, ","))...)
    return i, end1, end2
end

# It's ugly but fast, and non-allocating
function isoverlapping(brick1::Tuple{XYZ, XYZ}, brick2::Tuple{XYZ, XYZ})
    for x1 in min(brick1[1][1], brick1[2][1]):max(brick1[1][1], brick1[2][1])
        for y1 in min(brick1[1][2], brick1[2][2]):max(brick1[1][2], brick1[2][2])
            for z1 in min(brick1[1][3], brick1[2][3]):max(brick1[1][3], brick1[2][3])
                for x2 in min(brick2[1][1], brick2[2][1]):max(brick2[1][1], brick2[2][1])
                    x1 == x2 || continue
                    for y2 in min(brick2[1][2], brick2[2][2]):max(brick2[1][2], brick2[2][2])
                        y1 == y2 || continue
                        for z2 in min(brick2[1][3], brick2[2][3]):max(brick2[1][3], brick2[2][3])
                            z1 == z2 && return true
                        end
                    end
                end
            end
        end
    end

    return false
end

function settle(bricks::Vector{Tuple{Int, XYZ, XYZ}})
    settled = Vector{Tuple{Int, XYZ, XYZ}}()

    bricks = sort(bricks, by=b -> min(b[2][3], b[3][3]))
    for (id, end1, end2) in bricks
        while true
            z =  min(end1[3], end2[3])
            if z == 1
                @goto settled
            end

            # Test for empty space below
            z -= 1

            for (_, other1, other2) in settled
                if max(other1[3], other2[3]) != z
                    continue
                end

                if isoverlapping(
                    (end1 - SVector(0, 0, 1), end2 - SVector(0, 0, 1)), (other1, other2)
                )
                    @goto settled
                end
            end

            # If we're here: we can shift down
            end1 = end1 - SVector(0, 0, 1)
            end2 = end2 - SVector(0, 0, 1)
        end

        @label settled
        push!(settled, (id, end1, end2))
    end

    return settled
end

# Do the initial settling
bricks = settle(bricks)

part1, part2 = ThreadsX.sum(eachindex(bricks)) do i
    brickscopy = copy(bricks)
    deleteat!(brickscopy, i)

    unmoved = length(intersect(brickscopy, settle(brickscopy)))
    return [unmoved == length(brickscopy), length(brickscopy) - unmoved]
end

println("Part 1: ", part1)
println("Part 2: ", part2)