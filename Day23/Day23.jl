const puzzle = stack(map(collect, readlines("input.txt")), dims=1)

const directions = Dict(
    "down" => CartesianIndex(1, 0),
    "up" => CartesianIndex(-1, 0),
    "right" => CartesianIndex(0, 1),
    "left" => CartesianIndex(0, -1)
)

mutable struct Node
    # Dictionary of Node => Distance pairs
    edges::IdDict{Node, Int}
end

function dfs(node::Node, finish, steps=0, seen::Vector{Node}=Node[])
    seen = copy(seen)
    push!(seen, node)

    if node == finish
        return steps
    end

    return maximum(node.edges; init=0) do (edge, distance)
        if edge in seen
            return 0
        end
        return dfs(edge, finish, steps + distance, seen)
    end
end

# Part 1

function mkgraph1(puzzle)
    nodes = similar(puzzle, Node)
    for i in eachindex(nodes)
        nodes[i] = Node(IdDict{Node, Int}())
    end

    # Link the nodes
    for idx in eachindex(IndexCartesian(), puzzle)
        char, node = puzzle[idx], nodes[idx]

        if char == '#'
            continue
        end

        for (label, direction) in directions
            nextidx = idx + direction
            if nextidx ∉ CartesianIndices(puzzle)
                continue
            end

            otherchar = puzzle[nextidx]
            if otherchar == '.'
                node.edges[nodes[nextidx]] = 1
            elseif otherchar == '>' && label == "right"
                node.edges[nodes[idx + 2 * direction]] = 2
            elseif otherchar == 'v' && label == "down"
                node.edges[nodes[idx + 2 * direction]] = 2
            end
        end
    end

    # Return start and end nodes
    return nodes[1, 2], nodes[end, end - 1]
end

start, finish = mkgraph1(puzzle)
part1 = dfs(start, finish)
println("Part 1: ", part1)

# Part 2

function mkgraph2(puzzle)
    nodes = similar(puzzle, Node)
    for i in eachindex(nodes)
        nodes[i] = Node(IdDict{Node, Int}())
    end

    # Link the nodes
    for idx in eachindex(IndexCartesian(), puzzle)
        char, node = puzzle[idx], nodes[idx]

        if char == '#'
            continue
        end

        for direction in values(directions)
            nextidx = idx + direction
            if nextidx ∉ CartesianIndices(puzzle)
                continue
            end

            if puzzle[nextidx] == '#'
                continue
            end

            node.edges[nodes[nextidx]] = 1
        end
    end

    # Return start and end nodes
    return nodes[1, 2], nodes[end, end - 1]
end

function collapsegraph!(start::Node, finish::Node)
    # Collect all nodes into a vector
    function collectnodes(n::Node, nodes = Node[])
        for edge in keys(n.edges)
            edge in nodes && continue
            push!(nodes, edge)
            collectnodes(edge, nodes)
        end
        return nodes
    end
    nodes = collectnodes(start)

    # Iteratively prune the graph, looking for dead ends and 2-edge connectors
    # Stop when the graph is idempotent to this operation.
    N1, N2 = 0, length(nodes)

    while N1 != N2
        for node in nodes
            if node == start || node == finish
                continue
            end

            # Prune dead ends
            if length(node.edges) == 1
                other = only(keys(node.edges))
                delete!(other.edges, node)
                empty!(node.edges)
            end

            # Contract direct links
            if length(node.edges) == 2
                left, right = keys(node.edges)
                distance = sum(values(node.edges))

                delete!(left.edges, node)
                left.edges[right] = distance

                delete!(right.edges, node)
                right.edges[left] = distance

                empty!(node.edges)
            end
        end

        filter!(nodes) do n
            length(n.edges) > 0
        end

        N1, N2 = N2, length(nodes)
    end
end

start, finish = mkgraph2(puzzle)
collapsegraph!(start, finish)
part2 = dfs(start, finish)
println("Part 2: ", part2)