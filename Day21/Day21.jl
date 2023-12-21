using Polynomials: fit

tiles = stack(map(collect, readlines("input.txt")), dims=1)
initidx = findfirst(==('S'), tiles)
tiles[initidx] = '.'

const directions = (
    CartesianIndex(0, 1),
    CartesianIndex(0, -1),
    CartesianIndex(1, 0),
    CartesianIndex(-1, 0)
)

function search(init, limit)
    edges = [init]
    nextedges = CartesianIndex{2}[]

    for _ in 1:limit
        for edge in edges
            for direction in directions
                nextidx = edge + direction

                y, x = Tuple(nextidx)
                wrapped = CartesianIndex(
                    mod1(y, size(tiles, 1)),
                    mod1(x, size(tiles, 2))
                )

                if tiles[wrapped] == '#'
                    continue
                end

                push!(nextedges, nextidx)
            end
        end

        # Deduplicate
        unique!(nextedges)

        edges, nextedges = nextedges, edges
        empty!(nextedges)
    end

    return length(edges)
end

# Part 1: A simple BFS
part1 = search(initidx, 64)
println("Part 1: ", part1)

# Part 2: fit a quadratic
xs = range(65, step=131, length=3)
ys = map(xs) do x
    search(initidx, x)
end

p = fit(xs, ys, 2)
println("Part 2: ", Int(p(26501365)))