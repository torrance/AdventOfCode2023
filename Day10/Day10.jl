lines = readlines("input.txt")

# Column major: (row=y, col=x)
up = CartesianIndex(-1, 0)
down = CartesianIndex(1, 0)
left = CartesianIndex(0, -1)
right = CartesianIndex(0, 1)

const directions = Dict{Char, Vector{CartesianIndex{2}}}(
    '.' => CartesianIndex{2}[],
    'S' => [up, down, left, right],
    'F' => [down, right],
    'J' => [up, left],
    '-' => [left, right],
    '|' => [up, down],
    '7' => [down, left],
    'L' => [up, right]
)

const diagram = stack(map(collect, lines), dims=1)
const steps = Matrix{Union{Int, Missing}}(missing, size(diagram))
const Sidx = findfirst(==('S'), diagram)
const idxs = CartesianIndices(diagram)

function setsteps(idx, stepcount=0)
    # Update count if we are the first to visit it
    # otherwise return (there's a faster way to get here)
    if ismissing(steps[idx]) || stepcount <= steps[idx]
        steps[idx] = stepcount
    else
        return
    end

    # Search for neighbours that include us as _their_ neighbour
    for myneighbour in filter(in(idxs), (idx,) .+ directions[diagram[idx]])
        if idx in (myneighbour,) .+ directions[diagram[myneighbour]]
            setsteps(myneighbour, stepcount + 1)
        end
    end

    return
end
setsteps(Sidx)

println("Part 1: ", maximum(skipmissing(steps)))

# What is S acting as? Get the list of directions it connects to
# and invert the directions map
Sdirections = filter([up, down, left, right]) do direction
    return steps[Sidx + direction] == 1
end

Ssymbol = Dict([v => k for (k, v) in directions])[Sdirections]
diagram[Sidx] = Ssymbol  # Set S to it's behaved symbol

# To determine the inside/outside-ness of a tile,
# count the parity along the row of 'up' tiles
for (steps, symbols) in zip(eachrow(steps), eachrow(diagram))
    parity = 0
    for (idx, (step, symbol)) in enumerate(zip(steps, symbols))
        if up in directions[symbol] && !ismissing(step)
            parity += 1
        end

        # If it's even, it's an outside tile
        if ismissing(step) && iseven(parity)
            steps[idx] = 0
        end
    end
end

println("Part 2: ", count(ismissing, steps))
