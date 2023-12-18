const puzzle = stack(map(collect, readlines("input.txt")), dims=1)

const up = CartesianIndex(-1, 0)
const down = CartesianIndex(1, 0)
const right = CartesianIndex(0, 1)
const left = CartesianIndex(0, -1)

const directions = Dict(
    up => Dict(
        '.' => [up],
        '\\' => [left],
        '/' => [right],
        '-' => [left, right],
        '|' => [up],
    ),
    down => Dict(
        '.' => [down],
        '\\' => [right],
        '/' => [left],
        '-' => [left, right],
        '|' => [down],
    ),
    right => Dict(
        '.' => [right],
        '\\' => [down],
        '/' => [up],
        '-' => [right],
        '|' => [up, down],
    ),
    left => Dict(
        '.' => [left],
        '\\' => [up],
        '/' => [down],
        '-' => [left],
        '|' => [up, down],
    ),
)

const code = Dict(up => 2^1, down => 2^2, left => 2^3, right => 2^4)

function pathfind(pos, direction, activated)
    if (activated[pos] & code[direction] > 0)
        return
    end
    activated[pos] = activated[pos] | code[direction]

    char = puzzle[pos]
    for newdirection in directions[direction][char]
        nextpos = pos + newdirection
        if nextpos in CartesianIndices(puzzle)
            pathfind(nextpos, newdirection, activated)
        end
    end
end

function countactivated(pos, direction)
    activated = zeros(Int, size(puzzle)...)
    pathfind(pos, direction, activated)
    return count(!=(0), activated)
end

# Part 1
part1 = countactivated(CartesianIndex(1, 1), right)
println("Part 1: ", part1)

# Part 2
idxs = CartesianIndices(puzzle)
inits = vcat(
    [(idx, down) for idx in eachrow(idxs)[begin]],
    [(idx, up) for idx in eachrow(idxs)[end]],
    [(idx, right) for idx in eachcol(idxs)[begin]],
    [(idx, left) for idx in eachcol(idxs)[end]],
)

part2 = maximum(inits) do (pos, direction)
    countactivated(pos, direction)
end
println("Part 2: ", part2)
