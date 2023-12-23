using StaticArrays

const XYZ = SVector{3, Int}

bricks = map(enumerate(readlines("input.txt"))) do (i, line)
    end1, end2 = split(line, "~")
    end1 = XYZ(parse.(Int, split(end1, ","))...)
    end2 = XYZ(parse.(Int, split(end2, ","))...)
    return i, end1, end2
end

sort!(bricks, by=b -> min(b[2][3], b[3][3]))

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

function settle(bricks)
    moved::Bool = false

    for (i, (id, end1, end2)) in enumerate(bricks)
        z =  min(end1[3], end2[3])
        z <= 1 && continue

        # Test for empty space below
        end1 = end1 - SVector(0, 0, 1)
        end2 = end2 - SVector(0, 0, 1)
        z -= 1

        for (j, (_, other1, other2)) in enumerate(bricks)
            if i == j
                continue
            end

            if max(other1[3], other2[3]) != z
                continue
            end

            if isoverlapping((end1, end2), (other1, other2))
                @goto nogo
            end
        end

        # If we're here: we can shift down
        bricks[i] = (id, end1, end2)
        moved = true

        @label nogo
    end

    return moved
end

# Do the settling, until there is no more settling to do
@time while(settle(bricks)) end

@time part1 = count(eachindex(bricks)) do i
    brick = bricks[i]
    futurebricks = copy(bricks)
    deleteat!(futurebricks, i)

    return !settle(futurebricks)
end
println("Part 1: ", part1)

@time part2 = sum(eachindex(bricks)) do i
    brick = bricks[i]
    futurebricks = copy(bricks)
    deleteat!(futurebricks, i)

    while settle(futurebricks) end

    unmoved = length(intersect(bricks, futurebricks))
    return length(bricks) - unmoved - 1
end
println("Part 2: ", part2)