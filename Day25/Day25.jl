lines = readlines("input.txt")

mutable struct Vertex
    label::String
    edges::Dict{Vertex, Int}
end

Vertex(label) = Vertex(label, Dict{Vertex, Int}())

function Base.show(io::IO, v::Vertex)
    print(io, v.label)
    print(io, " => (")
    join(io, ["$(v.label) [$(w)]" for (v, w) in v.edges], ", ")
    print(io, ")")
end

vertices = Dict{String, Vertex}()

for line in lines
    label, edges = split(line, ": ")
    edges = split(edges)

    v1 = get!(vertices, label, Vertex(label))
    for edge in edges
        v2 = get!(vertices, edge, Vertex(edge))
        push!(v1.edges, v2 => 1)
        push!(v2.edges, v1 => 1)
    end
end

function max_adjacency_search(vertices::Dict{String, Vertex})
    @assert length(vertices) > 1
    vertices = copy(vertices)

    # Initialize found set with random seed value
    label, seed = first(vertices)
    found = Set{Vertex}([seed])
    delete!(vertices, label)

    # Initialize s and t
    s::Vertex = seed
    t::Vertex = seed

    while !isempty(vertices)
        _, label = findmax(vertices) do v
            sum(v.edges) do (edge, weight)
                edge in found ? weight : 0
            end
        end

        s, t = t, vertices[label]
        push!(found, vertices[label])
        delete!(vertices, label)
    end

    return s, t, sum(values(t.edges))
end

function merge!(s::Vertex, t::Vertex)
    for (v, weight) in t.edges
        # Ignore the t <=> s edge: this is simply contracted
        v == s && continue

        # Transfer t's edges to s, taking care to add the weight from both
        s.edges[v] = get!(s.edges, v, 0) + weight

        # Update opposite direction
        v.edges[s] = s.edges[v]
        # v.edges[s] = get!(v.edges, s, 0) + weight
    end

    # Drop return references to t
    for v in keys(t.edges)
        delete!(v.edges, t)
    end
end

# See Stoer-Wagner algorithm: https://en.wikipedia.org/wiki/Stoer–Wagner_algorithm
function mincut(vertices::Dict{String, Vertex})
    vertices = deepcopy(vertices)

    partitions = Vector{Set{String}}()

    bestcutweight = typemax(Int)
    bestpartition = String[]

    while length(vertices) > 1
        s, t, cutweight = max_adjacency_search(vertices)

        if cutweight < bestcutweight
            bestcutweight = cutweight

            # Find partition that t is a member of, and record in bestpartition
            idx = findfirst(p -> t.label in p, partitions)
            partition = isnothing(idx) ? Set{String}([t.label]) : partitions[idx]
            bestpartition = copy(partition)
        end

        merge!(s, t)
        delete!(vertices, t.label)

        # Keep track of partitions for each merge we perform
        idxt = findfirst(p -> t.label in p, partitions)
        idxs = findfirst(p -> s.label in p, partitions)

        if isnothing(idxt) && isnothing(idxs)
            # Brand new partition
            push!(partitions, Set{String}([t.label, s.label]))
        elseif isnothing(idxt)
            # Add t to s's partition
            push!(partitions[idxs], t.label)
        elseif isnothing(idxs)
            push!(partitions[idxt], s.label)
            # Add s to t's partition
        elseif idxt != idxs
            # Merge two existing partitions
            partitions[idxt] = partitions[idxt] ∪ partitions[idxs]
            deleteat!(partitions, idxs)
        end
    end

    return collect(bestpartition)
end

partition1 = mincut(vertices)
partition2 = [label for label in keys(vertices) if !(label in partition1)]
println("Part 1: ", length(partition1) * length(partition2))
