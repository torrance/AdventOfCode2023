const puzzle = map(stack(map(collect, readlines("input.txt")), dims=1)) do char
    parse(Int, char)
end

const idxs = CartesianIndices(puzzle)

const directions = [
    CartesianIndex(0, 1),
    CartesianIndex(1, 0),
    CartesianIndex(0, -1),
    CartesianIndex(-1, 0),
]

struct Edge
    pos::CartesianIndex{2}
    cost::Int
    direction::CartesianIndex{2}
end

function search(init, costmap, bounds::UnitRange{Int})
    edges::Vector{Edge} = Edge[init]
    nextedges::Vector{Edge} = Edge[]

    while !isempty(edges)
        for edge in edges
            # Terminating condtion
            if edge.pos == idxs[end, end]
                continue
            end

            for (i, direction) in enumerate(directions)
                # We can't go reverse
                if direction == edge.direction || direction == -edge.direction
                    continue
                end

                for n in bounds
                    nextpos = edge.pos + n * direction

                    # Don't enter a square that is out of bounds
                    if nextpos ∉ idxs
                        continue
                    end

                    # Avoid entering a tile if it has been entered horizontally/vertically
                    # for a cheaper cost
                    nextcost = sum(1:n; init=edge.cost) do i
                        puzzle[edge.pos + i * direction]
                    end

                    y, x = Tuple(nextpos)
                    if nextcost >= costmap[y, x, mod1(i, 2)]
                        continue
                    end

                    # We can step forward!
                    costmap[y, x, mod1(i, 2)] = nextcost
                    push!(nextedges, Edge(nextpos, nextcost, direction))
                end
            end
        end

        empty!(edges)
        edges, nextedges = nextedges, edges
    end
end

init = Edge(CartesianIndex(1, 1), 0, CartesianIndex(0, 0))

# Part 1
costmap = zeros(Int, size(puzzle)..., 2)
fill!(costmap, typemax(Int))
search(init, costmap, 1:3)
println("Part 1: ", minimum(costmap[end, end, :]))

# Part 2
costmap = zeros(Int, size(puzzle)..., 2)
fill!(costmap, typemax(Int))
search(init, costmap, 4:10)
println("Part 2: ", minimum(costmap[end, end, :]))